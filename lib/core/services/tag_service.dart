/// Tag Service
/// Manages email tags and email-tag relationships using Hive
library;

import 'package:hive_flutter/hive_flutter.dart';
import '../../features/inbox/domain/email_tag.dart';

class TagService {
  static const String _tagsBoxName = 'tags_box';
  static const String _emailTagsBoxName =
      'email_tags_box'; // Maps email ID to tag IDs

  /// Get tags box
  Box<EmailTag> get _tagsBox => Hive.box<EmailTag>(_tagsBoxName);

  /// Get email-tags mapping box
  Box get _emailTagsBox => Hive.box(_emailTagsBoxName);

  /// Initialize tag boxes
  Future<void> init() async {
    Hive.registerAdapter(EmailTagAdapter());
    await Hive.openBox<EmailTag>(_tagsBoxName);
    await Hive.openBox(_emailTagsBoxName);
  }

  /// Create a new tag
  Future<EmailTag> createTag(String name, String color) async {
    final tag = EmailTag.create(name, color);
    await _tagsBox.put(tag.id, tag);
    return tag;
  }

  /// Get all tags
  List<EmailTag> getAllTags() {
    return _tagsBox.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  /// Get tag by ID
  EmailTag? getTag(String tagId) {
    return _tagsBox.get(tagId);
  }

  /// Update tag
  Future<void> updateTag(EmailTag tag) async {
    await _tagsBox.put(tag.id, tag);
  }

  /// Delete tag and remove from all emails
  Future<void> deleteTag(String tagId) async {
    await _tagsBox.delete(tagId);

    // Remove from all emails
    final allEmailTagMappings = _emailTagsBox.toMap();
    for (var entry in allEmailTagMappings.entries) {
      final emailId = entry.key;
      final tagIds = List<String>.from(entry.value as List);
      if (tagIds.remove(tagId)) {
        await _emailTagsBox.put(emailId, tagIds);
      }
    }
  }

  /// Add tag to email
  Future<void> addTagToEmail(String emailId, String tagId) async {
    final tagIds = getEmailTagIds(emailId);
    if (!tagIds.contains(tagId)) {
      tagIds.add(tagId);
      await _emailTagsBox.put(emailId, tagIds);
    }
  }

  /// Remove tag from email
  Future<void> removeTagFromEmail(String emailId, String tagId) async {
    final tagIds = getEmailTagIds(emailId);
    if (tagIds.remove(tagId)) {
      await _emailTagsBox.put(emailId, tagIds);
    }
  }

  /// Get tag IDs for an email
  List<String> getEmailTagIds(String emailId) {
    final dynamic tagIds = _emailTagsBox.get(emailId);
    if (tagIds == null) return [];
    return List<String>.from(tagIds as List);
  }

  /// Get tags for an email
  List<EmailTag> getEmailTags(String emailId) {
    final tagIds = getEmailTagIds(emailId);
    return tagIds.map((id) => _tagsBox.get(id)).whereType<EmailTag>().toList();
  }

  /// Set tags for an email (replaces existing tags)
  Future<void> setEmailTags(String emailId, List<String> tagIds) async {
    await _emailTagsBox.put(emailId, tagIds);
  }

  /// Get emails with specific tag
  List<String> getEmailsWithTag(String tagId) {
    final emailIds = <String>[];
    final allEmailTagMappings = _emailTagsBox.toMap();

    for (var entry in allEmailTagMappings.entries) {
      final emailId = entry.key as String;
      final tagIds = List<String>.from(entry.value as List);
      if (tagIds.contains(tagId)) {
        emailIds.add(emailId);
      }
    }

    return emailIds;
  }

  /// Search tags by name
  List<EmailTag> searchTags(String query) {
    if (query.isEmpty) return getAllTags();

    final lowerQuery = query.toLowerCase();
    return _tagsBox.values
        .where((tag) => tag.name.toLowerCase().contains(lowerQuery))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  /// Check if tag name exists (case-insensitive)
  bool tagNameExists(String name, {String? excludeTagId}) {
    final lowerName = name.toLowerCase().trim();
    return _tagsBox.values.any(
      (tag) =>
          tag.name.toLowerCase().trim() == lowerName && tag.id != excludeTagId,
    );
  }

  /// Get tag usage count
  int getTagUsageCount(String tagId) {
    return getEmailsWithTag(tagId).length;
  }

  /// Clear all tags and mappings
  Future<void> clearAll() async {
    await _tagsBox.clear();
    await _emailTagsBox.clear();
  }
}
