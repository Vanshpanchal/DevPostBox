/// Secure storage service for API credentials
/// Uses AES encryption via flutter_secure_storage
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
    final results = await Future.wait([
      _storage.read(key: AppConstants.apiKeyStorageKey),
      _storage.read(key: AppConstants.apiBaseUrlStorageKey),
      _storage.read(key: AppConstants.namespaceStorageKey),
    ]);

    final apiKey = results[0];
    final baseUrl = results[1];
    final namespace = results[2];

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
    final apiKey = await _storage.read(key: AppConstants.apiKeyStorageKey);
    return apiKey != null && apiKey.isNotEmpty;
  }

  /// Clear all stored configuration
  /// Used for key rotation or logout
  Future<void> clearConfig() async {
    await Future.wait([
      _storage.delete(key: AppConstants.apiKeyStorageKey),
      _storage.delete(key: AppConstants.apiBaseUrlStorageKey),
      _storage.delete(key: AppConstants.namespaceStorageKey),
    ]);
  }

  /// Update only the API key (for key rotation)
  Future<void> updateApiKey(String newApiKey) async {
    await _storage.write(
      key: AppConstants.apiKeyStorageKey,
      value: newApiKey,
    );
  }
}
