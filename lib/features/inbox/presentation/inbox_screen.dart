/// Inbox Screen
/// Displays list of emails with search below app bar
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/debouncer.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../../shared/widgets/tag_manager_dialog.dart';
import '../../config/presentation/config_screen.dart';
import '../../detail/presentation/email_detail_screen.dart';
import '../../search/providers/search_provider.dart';
import '../domain/test_mail.dart';
import '../providers/inbox_provider.dart';
import 'widgets/email_card.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: AppConstants.searchDebounceMs);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inboxNotifierProvider.notifier).fetchEmails();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  Future<void> _openTagManager() async {
    await showDialog(
      context: context,
      builder: (context) => const TagManagerDialog(),
    );
    // Refresh to show updated tags
    setState(() {});
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const ConfigScreen(isSettings: true),
      ),
    );

    if (result == true && mounted) {
      ref.read(inboxNotifierProvider.notifier).refresh();
    }
  }

  void _openEmail(String emailId) {
    ref.read(inboxNotifierProvider.notifier).markAsRead(emailId);
    try {
      final email = ref
          .read(inboxNotifierProvider.notifier)
          .allEmails
          .firstWhere((e) => e.id == emailId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailDetailScreen(email: email),
        ),
      );
    } catch (e) {
      // Email not found
    }
  }

  @override
  Widget build(BuildContext context) {
    final inboxState = ref.watch(inboxNotifierProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final isSearchActive = searchQuery.isNotEmpty;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.label_outline),
            onPressed: _openTagManager,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            tooltip: 'Manage Tags',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
        ],
      ),
      body: MaxWidthContainer(
        maxWidth: 1400,
        padding: ResponsiveLayout.isDesktop(context)
            ? const EdgeInsets.symmetric(horizontal: 24)
            : EdgeInsets.zero,
        child: SafeArea(
          child: Column(
            children: [
              // Search & Filter Section
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.surfaceLight,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search emails, tags...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: isSearchActive
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _clearSearch,
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filters & Sort
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Filter Chips
                          _buildFilterChip(EmailFilter.all, 'All'),
                          const SizedBox(width: 8),
                          _buildFilterChip(EmailFilter.unread, 'Unread'),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            EmailFilter.hasAttachment,
                            'Attachments',
                          ),

                          const SizedBox(width: 16),
                          Container(
                            height: 24,
                            width: 1,
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.dividerLight,
                          ),
                          const SizedBox(width: 16),

                          // Sort Chip
                          _buildSortChip(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Email list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(inboxNotifierProvider.notifier).refresh(),
                  child: _buildBody(inboxState, searchQuery, isSearchActive),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(EmailFilter filter, String label) {
    final currentFilter = ref.watch(emailFilterProvider);
    final isSelected = currentFilter == filter;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(emailFilterProvider.notifier).state = filter;
        }
      },
      selectedColor: isDark
          ? AppColors.primaryDark.withValues(alpha: 0.2)
          : AppColors.primaryLight.withValues(alpha: 0.2),
      checkmarkColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      labelStyle: TextStyle(
        color: isSelected
            ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
            : (isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
              : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
        ),
      ),
    );
  }

  Widget _buildSortChip() {
    final currentSort = ref.watch(emailSortProvider);
    final isNewest = currentSort == EmailSort.newest;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        ref.read(emailSortProvider.notifier).state = isNewest
            ? EmailSort.oldest
            : EmailSort.newest;
      },
      child: Row(
        children: [
          Icon(
            isNewest ? Icons.arrow_downward : Icons.arrow_upward,
            size: 16,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 4),
          Text(
            'Date',
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  List<TestMail> _getEmailsFromState(InboxState state) {
    if (state is InboxLoaded) {
      return state.emails;
    } else if (state is InboxLoading) {
      return state.cachedEmails;
    } else if (state is InboxError) {
      return state.cachedEmails;
    }
    return [];
  }

  List<TestMail> _filterEmails(List<TestMail> emails, String query) {
    if (query.isEmpty) return emails;
    final lowerQuery = query.toLowerCase();
    return emails.where((email) {
      return email.subject.toLowerCase().contains(lowerQuery) ||
          email.fromName.toLowerCase().contains(lowerQuery) ||
          email.fromAddress.toLowerCase().contains(lowerQuery) ||
          email.text.toLowerCase().contains(lowerQuery) ||
          email.tag.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Widget _buildBody(InboxState state, String searchQuery, bool isSearchActive) {
    // Get emails using the filtered provider logic
    // We need to access the provider from the build method scope generally,
    // but here we are inside _buildBody which is called from build.
    // However, ref.watch(filteredInboxProvider) should be called in build.
    // Let's refactor: pass filteredEmails to _buildBody.

    // Actually, let's just use ref.read (or ref.watch in build)
    // But since _buildBody is a helper, we should pass the data.
    // Let's modify the build method to get filtered emails.

    // WAIT: ref.watch inside a helper method is fine if the helper is valid.
    // But best practice is to pass data.

    // Let's stick to the current structure but use the new provider.
    final filteredEmails = ref.watch(filteredInboxProvider);

    // Handle loading states as before but use filteredEmails for the list

    final allEmailsInState = _getEmailsFromState(state);

    // Handle pure loading (no cached emails)
    if (state is InboxLoading && allEmailsInState.isEmpty) {
      return const LoadingWidget(message: 'Loading emails...');
    }

    // Handle initial state
    if (state is InboxInitial) {
      return const LoadingWidget(message: 'Loading...');
    }

    // Handle empty inbox
    if (state is InboxEmpty) {
      return const EmptyStateWidget(
        title: 'No emails yet',
        subtitle:
            'Emails sent to your testmail.app namespace will appear here.',
        icon: Icons.inbox_outlined,
      );
    }

    // ... rest of error handling ...

    // Apply search query on top of filters
    final searchingEmails = _filterEmails(filteredEmails, searchQuery);

    // Show empty state if filters result in no emails
    if (searchingEmails.isEmpty) {
      // ... empty state ...
      return EmptyStateWidget(
        title: 'No emails found',
        subtitle: 'Try adjusting your filters or search query.',
        icon: Icons.filter_list_off,
      );
    }

    final isLoading = state is InboxLoading;
    final hasError = state is InboxError;

    return Column(
      children: [
        // Error banner
        if (hasError) _buildErrorBanner((state as InboxError).message),

        // Email list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: searchingEmails.length,
            itemBuilder: (context, index) {
              final email = searchingEmails[index];
              return EmailCard(
                email: email,
                searchQuery: searchQuery,
                onTap: () => _openEmail(email.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.error.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 18, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(inboxNotifierProvider.notifier).refresh(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
