/// Riverpod providers for configuration state
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/secure_storage_service.dart';

/// Provider for SecureStorageService
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// State class for configuration status
sealed class ConfigState {}

class ConfigInitial extends ConfigState {}

class ConfigLoading extends ConfigState {}

class ConfigLoaded extends ConfigState {
  final ApiConfig config;
  ConfigLoaded(this.config);
}

class ConfigNotConfigured extends ConfigState {}

class ConfigError extends ConfigState {
  final String message;
  ConfigError(this.message);
}

/// Notifier for configuration state
class ConfigNotifier extends StateNotifier<ConfigState> {
  final SecureStorageService _storageService;

  ConfigNotifier(this._storageService) : super(ConfigInitial());

  /// Check if configuration exists
  Future<void> checkConfiguration() async {
    state = ConfigLoading();
    try {
      final config = await _storageService.getApiConfig();
      if (config != null && config.isValid) {
        state = ConfigLoaded(config);
      } else {
        state = ConfigNotConfigured();
      }
    } catch (e) {
      state = ConfigError('Failed to load configuration');
    }
  }

  /// Save new configuration
  Future<bool> saveConfiguration({
    required String apiKey,
    required String baseUrl,
    required String namespace,
  }) async {
    state = ConfigLoading();
    try {
      final config = ApiConfig(
        apiKey: apiKey,
        baseUrl: baseUrl,
        namespace: namespace,
      );
      await _storageService.saveApiConfig(config);
      state = ConfigLoaded(config);
      return true;
    } catch (e) {
      state = ConfigError('Failed to save configuration');
      return false;
    }
  }

  /// Clear configuration (for logout/reset)
  Future<void> clearConfiguration() async {
    state = ConfigLoading();
    try {
      await _storageService.clearConfig();
      state = ConfigNotConfigured();
    } catch (e) {
      state = ConfigError('Failed to clear configuration');
    }
  }

  /// Update API key only
  Future<bool> updateApiKey(String newApiKey) async {
    try {
      await _storageService.updateApiKey(newApiKey);
      await checkConfiguration();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for ConfigNotifier
final configNotifierProvider =
    StateNotifierProvider<ConfigNotifier, ConfigState>((ref) {
  final storageService = ref.watch(secureStorageProvider);
  return ConfigNotifier(storageService);
});
