/// Secure storage service for API credentials
/// Uses AES encryption via flutter_secure_storage
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

/// Configuration data class
class ApiConfig {
  final String apiKey;
  final String baseUrl;
  final String namespace;

  const ApiConfig({
    required this.apiKey,
    required this.baseUrl,
    required this.namespace,
  });

  bool get isValid =>
      apiKey.isNotEmpty && baseUrl.isNotEmpty && namespace.isNotEmpty;
}

/// Service for securely storing and retrieving API configuration
class SecureStorageService {
  // Use Android encrypted shared preferences for enhanced security
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Save API configuration securely
  /// Never logs sensitive data
  Future<void> saveApiConfig(ApiConfig config) async {
    if (kIsWeb) {
      final box = Hive.box('settings_box');
      await box.put(AppConstants.apiKeyStorageKey, config.apiKey);
      await box.put(AppConstants.apiBaseUrlStorageKey, config.baseUrl);
      await box.put(AppConstants.namespaceStorageKey, config.namespace);
      return;
    }

    await Future.wait([
      _storage.write(
        key: AppConstants.apiKeyStorageKey,
        value: config.apiKey,
      ),
      _storage.write(
        key: AppConstants.apiBaseUrlStorageKey,
        value: config.baseUrl,
      ),
      _storage.write(
        key: AppConstants.namespaceStorageKey,
        value: config.namespace,
      ),
    ]);
  }

  /// Retrieve API configuration from secure storage
  /// Returns null if not configured
  Future<ApiConfig?> getApiConfig() async {
    String? apiKey, baseUrl, namespace;

    if (kIsWeb) {
      final box = Hive.box('settings_box');
      apiKey = box.get(AppConstants.apiKeyStorageKey) as String?;
      baseUrl = box.get(AppConstants.apiBaseUrlStorageKey) as String?;
      namespace = box.get(AppConstants.namespaceStorageKey) as String?;
    } else {
      final results = await Future.wait([
        _storage.read(key: AppConstants.apiKeyStorageKey),
        _storage.read(key: AppConstants.apiBaseUrlStorageKey),
        _storage.read(key: AppConstants.namespaceStorageKey),
      ]);
      apiKey = results[0];
      baseUrl = results[1];
      namespace = results[2];
    }

    if (apiKey == null || baseUrl == null || namespace == null) {
      return null;
    }

    return ApiConfig(
      apiKey: apiKey,
      baseUrl: baseUrl,
      namespace: namespace,
    );
  }

  /// Check if API is configured
  Future<bool> hasConfig() async {
    if (kIsWeb) {
      final box = Hive.box('settings_box');
      final apiKey = box.get(AppConstants.apiKeyStorageKey) as String?;
      return apiKey != null && apiKey.isNotEmpty;
    }

    final apiKey = await _storage.read(key: AppConstants.apiKeyStorageKey);
    return apiKey != null && apiKey.isNotEmpty;
  }

  /// Clear all stored configuration
  /// Used for key rotation or logout
  Future<void> clearConfig() async {
    if (kIsWeb) {
      final box = Hive.box('settings_box');
      await box.delete(AppConstants.apiKeyStorageKey);
      await box.delete(AppConstants.apiBaseUrlStorageKey);
      await box.delete(AppConstants.namespaceStorageKey);
      return;
    }

    await Future.wait([
      _storage.delete(key: AppConstants.apiKeyStorageKey),
      _storage.delete(key: AppConstants.apiBaseUrlStorageKey),
      _storage.delete(key: AppConstants.namespaceStorageKey),
    ]);
  }

  /// Update only the API key (for key rotation)
  Future<void> updateApiKey(String newApiKey) async {
    if (kIsWeb) {
      final box = Hive.box('settings_box');
      await box.put(AppConstants.apiKeyStorageKey, newApiKey);
      return;
    }

    await _storage.write(
      key: AppConstants.apiKeyStorageKey,
      value: newApiKey,
    );
  }
}
