import 'package:hive_flutter/hive_flutter.dart';
import '../../features/inbox/domain/test_mail.dart';

class HiveService {
  static const String _emailsBoxName = 'emails_box';
  static const String _settingsBoxName = 'settings_box';

  static const String _lastFetchKey = 'last_fetch_time';
  static const String _readEmailsKey = 'read_email_ids';

  /// Initialize Hive
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TestMailAdapter());
    Hive.registerAdapter(EmailAttachmentAdapter());
    await Hive.openBox<TestMail>(_emailsBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  /// Get emails box
  Box<TestMail> get _emailsBox => Hive.box<TestMail>(_emailsBoxName);
  
  /// Get settings box
  Box get _settingsBox => Hive.box(_settingsBoxName);

  /// Save emails to Hive
  Future<void> cacheEmails(List<TestMail> emails) async {
    // Clear existing emails to ensure fresh cache match or use putAll for update
    // Using putAll with ID as key to allow updates
    final Map<String, TestMail> emailMap = {
      for (var email in emails) email.id: email
    };
    await _emailsBox.putAll(emailMap);
    await _settingsBox.put(_lastFetchKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get cached emails
  List<TestMail> getCachedEmails() {
    return _emailsBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Clear all emails
  Future<void> clearEmails() async {
    await _emailsBox.clear();
    await _settingsBox.delete(_lastFetchKey);
  }

  /// Get last fetch time
  DateTime? getLastFetchTime() {
    final int? timestamp = _settingsBox.get(_lastFetchKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Save read email IDs
  Future<void> saveReadEmailIds(Set<String> readIds) async {
    await _settingsBox.put(_readEmailsKey, readIds.toList());
  }

  /// Get read email IDs
  Set<String> getReadEmailIds() {
    final List<dynamic>? ids = _settingsBox.get(_readEmailsKey);
    return ids?.cast<String>().toSet() ?? {};
  }
  
  /// Mark email as read
  Future<void> markAsRead(String emailId) async {
    final readIds = getReadEmailIds();
    if (readIds.add(emailId)) {
      await saveReadEmailIds(readIds);
      
      // Also update the object in box if it exists
      final email = _emailsBox.get(emailId);
      if (email != null) {
        email.isRead = true;
        await email.save(); // HiveObject extension
      }
    }
  }
}
