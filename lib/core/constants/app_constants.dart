/// App constants for TestMail Reader
library;

class AppConstants {
  AppConstants._();

  // Storage keys
  static const String apiKeyStorageKey = 'testmail_api_key';
  static const String apiBaseUrlStorageKey = 'testmail_base_url';
  static const String namespaceStorageKey = 'testmail_namespace';

  // Default API URL
  static const String defaultBaseUrl = 'https://api.testmail.app/api/json';

  // API query params
  static const int defaultEmailLimit = 50;

  // UI constants
  static const int searchDebounceMs = 300;
  static const int maxPreviewLength = 100;

  // OTP pattern (4-8 digits)
  static const String otpPattern = r'\b\d{4,8}\b';
}
