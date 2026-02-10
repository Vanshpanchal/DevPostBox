/// API Service for testmail.com
/// Handles all HTTP communication with proper error handling
library;

import 'package:dio/dio.dart';
import 'secure_storage_service.dart';
import '../../features/inbox/domain/test_mail.dart';
import '../constants/app_constants.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// API response wrapper
class EmailsResponse {
  final List<TestMail> emails;
  final int count;
  final int limit;  
  final int offset;

  const EmailsResponse({
    required this.emails,
    required this.count,
    required this.limit,
    required this.offset,
  });
}

/// Service for interacting with testmail.com API
class ApiService {
  final Dio _dio;
  final SecureStorageService _storageService;

  ApiService({
    required SecureStorageService storageService,
    Dio? dio,
  })  : _storageService = storageService,
        _dio = dio ?? Dio() {
    _configureDio();
  }

  void _configureDio() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null && status < 500,
    );

    // Add logging interceptor (only logs non-sensitive data)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Never log API keys or sensitive headers
        // Only log URL path for debugging
        handler.next(options);
      },
      onError: (error, handler) {
        // Log error type without sensitive details
        handler.next(error);
      },
    ));
  }

  /// Fetch emails from testmail.com
  /// Throws [ApiException] on failure
  Future<EmailsResponse> fetchEmails({
    int limit = AppConstants.defaultEmailLimit,
    int offset = 0,
    String? tag,
  }) async {
    final config = await _storageService.getApiConfig();
    if (config == null || !config.isValid) {
      throw const ApiException('API not configured. Please add your API key.');
    }

    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        'apikey': config.apiKey,
        'namespace': config.namespace,
        'limit': limit,
        'offset': offset,
      };

      if (tag != null && tag.isNotEmpty) {
        queryParams['tag'] = tag;
      }

      final response = await _dio.get<Map<String, dynamic>>(
        config.baseUrl,
        queryParameters: queryParams,
      );

      if (response.statusCode == 401) {
        throw const ApiException(
          'Invalid API key. Please check your configuration.',
          statusCode: 401,
        );
      }

      if (response.statusCode == 403) {
        throw const ApiException(
          'Access forbidden. Check your API key permissions.',
          statusCode: 403,
        );
      }

      if (response.statusCode != 200) {
        throw ApiException(
          'Failed to fetch emails. Status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final data = response.data;
      if (data == null) {
        throw const ApiException('Empty response from server.');
      }

      // Check API result status
      if (data['result'] != 'success') {
        final message = data['message'] as String? ?? 'Unknown error';
        throw ApiException(message);
      }

      // Parse emails
      final emailsList = data['emails'] as List<dynamic>? ?? [];
      final emails = emailsList
          .map((e) => TestMail.fromJson(e as Map<String, dynamic>))
          .toList();

      return EmailsResponse(
        emails: emails,
        count: data['count'] as int? ?? emails.length,
        limit: data['limit'] as int? ?? limit,
        offset: data['offset'] as int? ?? offset,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const ApiException(
          'Connection timed out. Please check your internet connection.',
        );
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const ApiException(
          'Unable to connect. Please check your internet connection.',
        );
      }
      throw ApiException('Network error: ${e.message}');
    }
  }

  /// Test API connection with current configuration
  Future<bool> testConnection() async {
    try {
      final response = await fetchEmails(limit: 1);
      return response.emails.isNotEmpty || true; // Empty inbox is still valid
    } on ApiException {
      rethrow;
    }
  }
}
