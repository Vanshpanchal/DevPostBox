/// Riverpod providers for search functionality
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../inbox/domain/test_mail.dart';
import '../../inbox/providers/inbox_provider.dart';

/// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered emails based on search query
final filteredEmailsProvider = Provider<List<TestMail>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final inboxState = ref.watch(inboxNotifierProvider);

  if (inboxState is! InboxLoaded) {
    return [];
  }

  final emails = inboxState.emails;

  if (query.isEmpty) {
    return emails;
  }

  return emails.where((email) {
    // Search in subject
    if (email.subject.toLowerCase().contains(query)) {
      return true;
    }
    // Search in sender name
    if (email.fromName.toLowerCase().contains(query)) {
      return true;
    }
    // Search in sender address
    if (email.fromAddress.toLowerCase().contains(query)) {
      return true;
    }
    // Search in email body (plain text)
    if (email.text.toLowerCase().contains(query)) {
      return true;
    }
    // Search in tag
    if (email.tag.toLowerCase().contains(query)) {
      return true;
    }
    return false;
  }).toList();
});

/// Provider for search result count
final searchResultCountProvider = Provider<int>((ref) {
  return ref.watch(filteredEmailsProvider).length;
});

/// Provider to check if search is active
final isSearchActiveProvider = Provider<bool>((ref) {
  return ref.watch(searchQueryProvider).isNotEmpty;
});

/// Extension for text highlighting
extension StringHighlight on String {
  /// Get text with highlight positions for a query
  List<HighlightSpan> getHighlightSpans(String query) {
    if (query.isEmpty) {
      return [HighlightSpan(text: this, isHighlight: false)];
    }

    final lowerThis = toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <HighlightSpan>[];
    int lastEnd = 0;

    int index = lowerThis.indexOf(lowerQuery);
    while (index != -1) {
      // Add non-highlighted part before match
      if (index > lastEnd) {
        spans.add(HighlightSpan(
          text: substring(lastEnd, index),
          isHighlight: false,
        ));
      }

      // Add highlighted match
      spans.add(HighlightSpan(
        text: substring(index, index + query.length),
        isHighlight: true,
      ));

      lastEnd = index + query.length;
      index = lowerThis.indexOf(lowerQuery, lastEnd);
    }

    // Add remaining text
    if (lastEnd < length) {
      spans.add(HighlightSpan(
        text: substring(lastEnd),
        isHighlight: false,
      ));
    }

    return spans.isEmpty
        ? [HighlightSpan(text: this, isHighlight: false)]
        : spans;
  }
}

/// Represents a span of text with highlight status
class HighlightSpan {
  final String text;
  final bool isHighlight;

  const HighlightSpan({
    required this.text,
    required this.isHighlight,
  });
}
