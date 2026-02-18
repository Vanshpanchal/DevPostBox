/// TestMail data model
/// Represents an email from testmail.com API
library;

/// Attachment data model
import 'package:hive/hive.dart';

part 'test_mail.g.dart';

/// Attachment data model
@HiveType(typeId: 0)
class EmailAttachment {
  @HiveField(0)
  final String filename;
  @HiveField(1)
  final int size;
  @HiveField(2)
  final String contentType;
  @HiveField(3)
  final String downloadUrl;
  @HiveField(4)
  final String? contentId;

  EmailAttachment({
    required this.filename,
    required this.size,
    required this.contentType,
    required this.downloadUrl,
    this.contentId,
  });

  factory EmailAttachment.fromJson(Map<String, dynamic> json) {
    return EmailAttachment(
      filename: json['filename'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      contentType: json['contentType'] as String? ?? '',
      downloadUrl: json['downloadUrl'] as String? ?? '',
      contentId: json['contentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'size': size,
      'contentType': contentType,
      'downloadUrl': downloadUrl,
      'contentId': contentId,
    };
  }

  /// Get file size in human readable format
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get file extension
  String get extension {
    final parts = filename.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : '';
  }

  /// Check if is image
  bool get isImage => contentType.startsWith('image/');

  /// Check if is PDF
  bool get isPdf => contentType == 'application/pdf';
}

@HiveType(typeId: 1)
class TestMail extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String from;
  @HiveField(2)
  final String fromName;
  @HiveField(3)
  final String fromAddress;
  @HiveField(4)
  final String to;
  @HiveField(5)
  final String subject;
  @HiveField(6)
  final String html;
  @HiveField(7)
  final String text;
  @HiveField(8)
  final DateTime createdAt;
  @HiveField(9)
  final String tag;
  @HiveField(10)
  final String namespace;
  @HiveField(11)
  final String messageId;
  @HiveField(12)
  final String downloadUrl;
  @HiveField(13)
  final List<EmailAttachment> attachments;
  @HiveField(14)
  bool isRead;
  @HiveField(15)
  List<String> customTags; // User-defined tags (tag IDs)

  TestMail({
    required this.id,
    required this.from,
    required this.fromName,
    required this.fromAddress,
    required this.to,
    required this.subject,
    required this.html,
    required this.text,
    required this.createdAt,
    required this.tag,
    required this.namespace,
    required this.messageId,
    required this.downloadUrl,
    this.attachments = const [],
    this.isRead = false,
    this.customTags = const [],
  });

  /// Factory constructor from API JSON response
  factory TestMail.fromJson(Map<String, dynamic> json) {
    // Parse from_parsed array for name and address
    String fromName = '';
    String fromAddress = '';
    if (json['from_parsed'] is List &&
        (json['from_parsed'] as List).isNotEmpty) {
      final parsed = json['from_parsed'][0] as Map<String, dynamic>;
      fromName = parsed['name'] as String? ?? '';
      fromAddress = parsed['address'] as String? ?? '';
    }

    // Parse timestamp - API returns milliseconds
    final timestamp = json['timestamp'] as int? ?? json['date'] as int? ?? 0;
    final createdAt = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // Parse attachments
    final attachmentsList = <EmailAttachment>[];
    if (json['attachments'] is List) {
      for (final att in json['attachments'] as List) {
        if (att is Map<String, dynamic>) {
          attachmentsList.add(EmailAttachment.fromJson(att));
        }
      }
    }

    return TestMail(
      id: json['id'] as String? ?? json['oid'] as String? ?? '',
      from: json['from'] as String? ?? '',
      fromName: fromName,
      fromAddress: fromAddress,
      to: json['to'] as String? ?? '',
      subject: json['subject'] as String? ?? '(No Subject)',
      html: json['html'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt: createdAt,
      tag: json['tag'] as String? ?? '',
      namespace: json['namespace'] as String? ?? '',
      messageId: json['messageId'] as String? ?? '',
      downloadUrl: json['downloadUrl'] as String? ?? '',
      attachments: attachmentsList,
    );
  }

  /// Get display name (name if available, otherwise address)
  String get displayName {
    if (fromName.isNotEmpty) {
      return fromName;
    }
    if (fromAddress.isNotEmpty) {
      return fromAddress;
    }
    return from;
  }

  /// Get preview text (plain text truncated)
  String get previewText {
    final cleanText = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleanText.length > 100) {
      return '${cleanText.substring(0, 100)}...';
    }
    return cleanText;
  }

  /// Check if email has HTML content
  bool get hasHtml => html.isNotEmpty;

  /// Check if email has attachments
  bool get hasAttachments => attachments.isNotEmpty;

  /// Get attachment count
  int get attachmentCount => attachments.length;

  /// Get initials for avatar
  String get initials {
    if (fromName.isNotEmpty) {
      final parts = fromName.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fromName[0].toUpperCase();
    }
    if (fromAddress.isNotEmpty) {
      return fromAddress[0].toUpperCase();
    }
    return '?';
  }

  /// Copy with method for immutable updates
  TestMail copyWith({
    String? id,
    String? from,
    String? fromName,
    String? fromAddress,
    String? to,
    String? subject,
    String? html,
    String? text,
    DateTime? createdAt,
    String? tag,
    String? namespace,
    String? messageId,
    String? downloadUrl,
    List<EmailAttachment>? attachments,
    bool? isRead,
    List<String>? customTags,
  }) {
    return TestMail(
      id: id ?? this.id,
      from: from ?? this.from,
      fromName: fromName ?? this.fromName,
      fromAddress: fromAddress ?? this.fromAddress,
      to: to ?? this.to,
      subject: subject ?? this.subject,
      html: html ?? this.html,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      tag: tag ?? this.tag,
      namespace: namespace ?? this.namespace,
      messageId: messageId ?? this.messageId,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      attachments: attachments ?? this.attachments,
      isRead: isRead ?? this.isRead,
      customTags: customTags ?? this.customTags,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestMail && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
