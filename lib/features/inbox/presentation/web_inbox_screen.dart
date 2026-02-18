/// Web-Optimized Inbox Screen with Two-Pane Layout
/// Desktop-first design with email list and detail view side-by-side
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

class WebInboxScreen extends ConsumerStatefulWidget {
  const WebInboxScreen({super.key});

  @override
  ConsumerState<WebInboxScreen> createState() => _WebInboxScreenState();
}

class _WebInboxScreenState extends ConsumerState<WebInboxScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: AppConstants.searchDebounceMs);
  TestMail? _selectedEmail;

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

  void _selectEmail(TestMail email) {
    ref.read(inboxNotifierProvider.notifier).markAsRead(email.id);
    setState(() {
      _selectedEmail = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inboxState = ref.watch(inboxNotifierProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final isSearchActive = searchQuery.isNotEmpty;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    // On mobile, use traditional navigation
    if (!isDesktop) {
      return _buildMobileLayout(
        context,
        inboxState,
        searchQuery,
        isSearchActive,
        theme,
        isDark,
      );
    }

    // Desktop layout with two panes
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Row(
        children: [
          // Left sidebar - Email list
          Container(
            width: 420,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              border: Border(
                right: BorderSide(color: AppColors.dividerLight, width: 1),
              ),
            ),
            child: Column(
              children: [
                _buildDesktopHeader(isDark),
                _buildSearchBar(isSearchActive, isDark),
                _buildFilters(isDark),
                Expanded(
                  child: _buildEmailList(
                    inboxState,
                    searchQuery,
                    isSearchActive,
                  ),
                ),
              ],
            ),
          ),

          // Right panel - Email detail
          Expanded(
            child: _selectedEmail != null
                ? _buildDetailView(_selectedEmail!)
                : _buildEmptyDetailView(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.dividerLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight,
                  AppColors.primaryLight.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.mail_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DevPostBox',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  'Test Email Reader',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.label_outline),
            onPressed: _openTagManager,
            tooltip: 'Manage Tags',
            color: AppColors.textSecondaryLight,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
            tooltip: 'Settings',
            color: AppColors.textSecondaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isSearchActive, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search emails, tags...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: isSearchActive
              ? IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: _clearSearch,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          filled: true,
          fillColor: AppColors.backgroundLight,
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(EmailFilter.all, 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip(EmailFilter.unread, 'Unread'),
                  const SizedBox(width: 8),
                  _buildFilterChip(EmailFilter.hasAttachment, 'Files'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildSortChip(),
        ],
      ),
    );
  }

  Widget _buildEmailList(
    InboxState state,
    String searchQuery,
    bool isSearchActive,
  ) {
    final filteredEmails = ref.watch(filteredInboxProvider);
    final allEmailsInState = _getEmailsFromState(state);

    if (state is InboxLoading && allEmailsInState.isEmpty) {
      return const LoadingWidget(message: 'Loading emails...');
    }

    if (state is InboxInitial) {
      return const LoadingWidget(message: 'Loading...');
    }

    if (state is InboxEmpty) {
      return const EmptyStateWidget(
        title: 'No emails yet',
        subtitle:
            'Emails sent to your testmail.app namespace will appear here.',
        icon: Icons.inbox_outlined,
      );
    }

    final searchingEmails = _filterEmails(filteredEmails, searchQuery);

    if (searchingEmails.isEmpty) {
      return const EmptyStateWidget(
        title: 'No emails found',
        subtitle: 'Try adjusting your filters or search query.',
        icon: Icons.filter_list_off,
      );
    }

    final hasError = state is InboxError;

    return Column(
      children: [
        if (hasError)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_off, size: 16, color: AppColors.error),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Network error',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(inboxNotifierProvider.notifier).refresh(),
                  child: const Text('Retry', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(inboxNotifierProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: searchingEmails.length,
              itemBuilder: (context, index) {
                final email = searchingEmails[index];
                final isSelected = _selectedEmail?.id == email.id;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLight.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.3,
                            ),
                            width: 2,
                          )
                        : null,
                  ),
                  child: EmailCard(
                    email: email,
                    searchQuery: searchQuery,
                    onTap: () => _selectEmail(email),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailView(TestMail email) {
    return Container(
      color: AppColors.backgroundLight,
      child: EmailDetailScreen(email: email, isEmbedded: true),
    );
  }

  Widget _buildEmptyDetailView() {
    return Container(
      color: AppColors.backgroundLight,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, size: 120, color: AppColors.dividerLight),
            SizedBox(height: 24),
            Text(
              'Select an email to view',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryLight,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Choose an email from the list to see its content',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    InboxState inboxState,
    String searchQuery,
    bool isSearchActive,
    ThemeData theme,
    bool isDark,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.label_outline),
            onPressed: _openTagManager,
            tooltip: 'Manage Tags',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isSearchActive, isDark),
          _buildFilters(isDark),
          Expanded(
            child: _buildMobileEmailList(
              inboxState,
              searchQuery,
              isSearchActive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileEmailList(
    InboxState state,
    String searchQuery,
    bool isSearchActive,
  ) {
    final filteredEmails = ref.watch(filteredInboxProvider);
    final allEmailsInState = _getEmailsFromState(state);

    if (state is InboxLoading && allEmailsInState.isEmpty) {
      return const LoadingWidget(message: 'Loading emails...');
    }

    if (state is InboxInitial) {
      return const LoadingWidget(message: 'Loading...');
    }

    if (state is InboxEmpty) {
      return const EmptyStateWidget(
        title: 'No emails yet',
        subtitle:
            'Emails sent to your testmail.app namespace will appear here.',
        icon: Icons.inbox_outlined,
      );
    }

    final searchingEmails = _filterEmails(filteredEmails, searchQuery);

    if (searchingEmails.isEmpty) {
      return const EmptyStateWidget(
        title: 'No emails found',
        subtitle: 'Try adjusting your filters or search query.',
        icon: Icons.filter_list_off,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(inboxNotifierProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: searchingEmails.length,
        itemBuilder: (context, index) {
          final email = searchingEmails[index];
          return EmailCard(
            email: email,
            searchQuery: searchQuery,
            onTap: () {
              ref.read(inboxNotifierProvider.notifier).markAsRead(email.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmailDetailScreen(email: email),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(EmailFilter filter, String label) {
    final currentFilter = ref.watch(emailFilterProvider);
    final isSelected = currentFilter == filter;

    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 13)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(emailFilterProvider.notifier).state = filter;
        }
      },
      selectedColor: AppColors.primaryLight.withValues(alpha: 0.15),
      checkmarkColor: AppColors.primaryLight,
      labelStyle: TextStyle(
        color: isSelected
            ? AppColors.primaryLight
            : AppColors.textSecondaryLight,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primaryLight : AppColors.dividerLight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildSortChip() {
    final currentSort = ref.watch(emailSortProvider);
    final isNewest = currentSort == EmailSort.newest;

    return InkWell(
      onTap: () {
        ref.read(emailSortProvider.notifier).state = isNewest
            ? EmailSort.oldest
            : EmailSort.newest;
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.dividerLight),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isNewest ? Icons.arrow_downward : Icons.arrow_upward,
              size: 14,
              color: AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 4),
            const Text(
              'Date',
              style: TextStyle(
                color: AppColors.textSecondaryLight,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
}
