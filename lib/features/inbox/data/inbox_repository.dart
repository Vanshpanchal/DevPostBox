import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/hive_service.dart';
import '../domain/test_mail.dart';

final inboxRepositoryProvider = Provider<InboxRepository>((ref) {
  // We'll define these in inbox_provider.dart or move them here.
  // Actually let's just create them here so they are central, or keep them in inbox_provider.dart.
  throw UnimplementedError('Provider defined in inbox_provider.dart');
});

class InboxRepository {
  final ApiService _apiService;
  final HiveService _hiveService;

  InboxRepository(this._apiService, this._hiveService);

  List<TestMail> getCachedEmails() {
    return _hiveService.getCachedEmails();
  }

  Set<String> getReadEmailIds() {
    return _hiveService.getReadEmailIds();
  }

  Future<EmailsResponse> fetchEmails({int limit = 100, int offset = 0, String? tag}) async {
    return await _apiService.fetchEmails(limit: limit, offset: offset, tag: tag);
  }

  Future<void> cacheEmails(List<TestMail> emails) async {
    await _hiveService.cacheEmails(emails);
  }

  Future<void> markAsRead(String emailId) async {
    await _hiveService.markAsRead(emailId);
  }
}
