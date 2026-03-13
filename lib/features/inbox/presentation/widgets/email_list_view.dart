import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../search/providers/search_provider.dart';
import '../../domain/test_mail.dart';
import '../../providers/inbox_provider.dart';
import 'email_card.dart';

class EmailListView extends ConsumerWidget {
  final bool isMobile;
  final TestMail? selectedEmail;
  final ValueChanged<TestMail> onEmailTap;

  const EmailListView({
    super.key,
    required this.isMobile,
    required this.onEmailTap,
    this.selectedEmail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inboxNotifierProvider);
    final displayedEmails = ref.watch(displayedEmailsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    if (state is InboxLoading && displayedEmails.isEmpty) {
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

    if (displayedEmails.isEmpty) {
      return const EmptyStateWidget(
        title: 'No emails found',
        subtitle: 'Try adjusting your filters or search query.',
        icon: Icons.filter_list_off,
      );
    }

    final hasError = state is InboxError;

    return Column(
      children: [
        if (hasError && !isMobile)
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
              padding: EdgeInsets.only(
                top: isMobile ? 8 : 0, 
                bottom: 16,
              ),
              itemCount: displayedEmails.length,
              itemBuilder: (context, index) {
                final email = displayedEmails[index];
                final isSelected = !isMobile && selectedEmail?.id == email.id;

                return EmailCard(
                  email: email,
                  searchQuery: searchQuery,
                  isSelected: isSelected,
                  onTap: () => onEmailTap(email),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
