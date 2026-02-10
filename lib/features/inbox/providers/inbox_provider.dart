import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../domain/test_mail.dart';

/// Provider for HiveService
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

/// Provider for ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  final storageService = SecureStorageService();
  return ApiService(storageService: storageService);
});

/// State class for inbox
sealed class InboxState {}

class InboxInitial extends InboxState {}

class InboxLoading extends InboxState {
  final List<TestMail> cachedEmails;
  InboxLoading({this.cachedEmails = const []});
}

class InboxLoaded extends InboxState {
  final List<TestMail> emails;
  final int totalCount;
  final bool hasMore;
  final bool isFromCache;

  InboxLoaded({
    required this.emails,
    required this.totalCount,
    this.hasMore = false,
    this.isFromCache = false,
  });

  InboxLoaded copyWith({
    List<TestMail>? emails,
    int? totalCount,
    bool? hasMore,
    bool? isFromCache,
  }) {
    return InboxLoaded(
      emails: emails ?? this.emails,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

class InboxEmpty extends InboxState {}

class InboxError extends InboxState {
  final String message;
  final bool isAuthError;
  final List<TestMail> cachedEmails;

  InboxError(this.message, {this.isAuthError = false, this.cachedEmails = const []});
}

/// Notifier for inbox state
class InboxNotifier extends StateNotifier<InboxState> {
  final ApiService _apiService;
  final HiveService _hiveService;
  final Set<String> _readEmailIds = {};

  InboxNotifier(this._apiService, this._hiveService) : super(InboxInitial());

  /// Load read email IDs from storage
  void _loadReadEmailIds() {
    final readIds = _hiveService.getReadEmailIds();
    _readEmailIds.addAll(readIds);
  }

  /// Fetch emails from API with local caching
  Future<void> fetchEmails({bool refresh = false}) async {
    debugPrint('🔄 fetchEmails called, refresh: $refresh, current state: ${state.runtimeType}');
    
    if (!refresh && state is InboxLoading) {
      debugPrint('⏭️ Already loading, skipping');
      return;
    }

    // Load read IDs first
    _loadReadEmailIds();
    debugPrint('📖 Loaded ${_readEmailIds.length} read email IDs');

    // Load cached emails while fetching
    final cachedEmails = _hiveService.getCachedEmails();
    debugPrint('💾 Loaded ${cachedEmails.length} cached emails');
    
    // Determine if we should update state to loading
    bool shouldShowLoading = !refresh;
    
    if (refresh) {
      if (state is InboxInitial || state is InboxEmpty) {
        shouldShowLoading = true;
      }
    }

    if (shouldShowLoading) {
      if (cachedEmails.isNotEmpty) {
        final marked = _markReadEmails(cachedEmails);
        state = InboxLoading(cachedEmails: marked);
      } else {
        state = InboxLoading();
      }
      debugPrint('📍 State set to InboxLoading');
    } else {
      debugPrint('📍 Refreshing silently (keeping current state)');
    }

    try {
      debugPrint('🌐 Fetching emails from API...');
      final response = await _apiService.fetchEmails();
      debugPrint('✅ API response: ${response.emails.length} emails');

      if (response.emails.isEmpty) {
        state = InboxEmpty();
        return;
      }

      // Mark read emails
      final emails = _markReadEmails(response.emails);
      
      // Update state first to show UI immediately
      state = InboxLoaded(
        emails: emails,
        totalCount: response.count,
        hasMore: response.offset + response.limit < response.count,
        isFromCache: false,
      );

      // Cache in background
      try {
        await _hiveService.cacheEmails(emails);
      } catch (e) {
        debugPrint('⚠️ Failed to cache emails: $e');
      }
    } on ApiException catch (e) {
      debugPrint('❌ API Error: ${e.message}');
      // On error, use cached emails if available
      if (cachedEmails.isNotEmpty) {
        state = InboxError(
          e.message,
          isAuthError: e.statusCode == 401 || e.statusCode == 403,
          cachedEmails: _markReadEmails(cachedEmails),
        );
      } else {
        state = InboxError(
          e.message,
          isAuthError: e.statusCode == 401 || e.statusCode == 403,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected Error: $e\n$stackTrace');
      if (cachedEmails.isNotEmpty) {
        state = InboxError(
          'Network error. Showing cached emails.',
          cachedEmails: _markReadEmails(cachedEmails),
        );
      } else {
        state = InboxError('An unexpected error occurred: $e');
      }
    }
  }

  List<TestMail> _markReadEmails(List<TestMail> emails) {
    return emails.map((email) {
      return email.copyWith(isRead: _readEmailIds.contains(email.id));
    }).toList();
  }

  /// Refresh emails
  Future<void> refresh() => fetchEmails(refresh: true);

  /// Mark email as read
  Future<void> markAsRead(String emailId) async {
    _readEmailIds.add(emailId);
    await _hiveService.markAsRead(emailId);

    if (state is InboxLoaded) {
      final currentState = state as InboxLoaded;
      final updatedEmails = currentState.emails.map((email) {
        if (email.id == emailId) {
          return email.copyWith(isRead: true);
        }
        return email;
      }).toList();

      state = currentState.copyWith(emails: updatedEmails);
      
      // Update cache with read status - actually markAsRead handles it in Hive, but we might want to update the full list too or relied on HiveObject.save()
      // Since we updated state, and cache is updated separately via markAsRead, we are good.
      // But fetchEmails reloads from API which overwrites cache.
      // _hiveService.markAsRead does update the object in the box.
    }
  }

  /// Get unread count
  int get unreadCount {
    if (state is InboxLoaded) {
      return (state as InboxLoaded).emails.where((e) => !e.isRead).length;
    }
    return 0;
  }

  /// Get all emails for search (including from loading/error states)
  List<TestMail> get allEmails {
    if (state is InboxLoaded) {
      return (state as InboxLoaded).emails;
    }
    if (state is InboxLoading) {
      return (state as InboxLoading).cachedEmails;
    }
    if (state is InboxError) {
      return (state as InboxError).cachedEmails;
    }
    return [];
  }
}

final inboxNotifierProvider =
    StateNotifierProvider<InboxNotifier, InboxState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  return InboxNotifier(apiService, hiveService);
});

/// Filter types
enum EmailFilter { all, unread, hasAttachment }

/// Sort types
enum EmailSort { newest, oldest }

/// Provider for current filter
final emailFilterProvider = StateProvider<EmailFilter>((ref) => EmailFilter.all);

/// Provider for current sort
final emailSortProvider = StateProvider<EmailSort>((ref) => EmailSort.newest);

/// Provider for filtered and sorted emails
final filteredInboxProvider = Provider<List<TestMail>>((ref) {
  final inboxState = ref.watch(inboxNotifierProvider);
  final filter = ref.watch(emailFilterProvider);
  final sort = ref.watch(emailSortProvider);

  List<TestMail> emails = [];

  // Get emails from state
  if (inboxState is InboxLoaded) {
    emails = inboxState.emails.toList();
  } else if (inboxState is InboxLoading) {
    emails = inboxState.cachedEmails.toList();
  } else if (inboxState is InboxError) {
    emails = inboxState.cachedEmails.toList();
  }

  // Apply Filter
  if (filter == EmailFilter.unread) {
    emails = emails.where((e) => !e.isRead).toList();
  } else if (filter == EmailFilter.hasAttachment) {
    emails = emails.where((e) => e.hasAttachments).toList();
  }

  // Apply Sort
  emails.sort((a, b) {
    final comparison = b.createdAt.compareTo(a.createdAt);
    return sort == EmailSort.newest ? comparison : -comparison;
  });

  return emails;
});
