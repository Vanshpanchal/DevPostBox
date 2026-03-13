/// Web-Optimized Inbox Screen with Two-Pane Layout
/// Desktop-first design with email list and detail view side-by-side
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../../shared/widgets/tag_manager_dialog.dart';
import '../../config/presentation/config_screen.dart';
import '../../detail/presentation/email_detail_screen.dart';
import '../../search/providers/search_provider.dart';
import '../domain/test_mail.dart';
import '../providers/inbox_provider.dart';

import 'widgets/inbox_header.dart';
import 'widgets/inbox_search_bar.dart';
import 'widgets/inbox_filter_bar.dart';
import 'widgets/email_list_view.dart';
import 'widgets/generated_emails_dialog.dart';

class WebInboxScreen extends ConsumerStatefulWidget {
  const WebInboxScreen({super.key});

  @override
  ConsumerState<WebInboxScreen> createState() => _WebInboxScreenState();
}

class _WebInboxScreenState extends ConsumerState<WebInboxScreen> {
  TestMail? _selectedEmail;
  final FocusNode _listFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inboxNotifierProvider.notifier).fetchEmails();
    });
  }

  @override
  void dispose() {
    _listFocusNode.dispose();
    super.dispose();
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

  Future<void> _openGeneratedEmails() async {
    await showDialog(
      context: context,
      builder: (context) => const GeneratedEmailsDialog(),
    );
  }

  void _selectEmail(TestMail email, {bool isMobile = false}) {
    ref.read(inboxNotifierProvider.notifier).markAsRead(email.id);
    if (isMobile) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailDetailScreen(email: email),
        ),
      );
    } else {
      setState(() {
        _selectedEmail = email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    if (!isDesktop) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Inbox'),
          actions: [
            IconButton(
              icon: const Icon(Icons.generating_tokens_outlined),
              onPressed: _openGeneratedEmails,
              tooltip: 'Generated Emails',
            ),
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
            InboxSearchBar(isDark: isDark),
            InboxFilterBar(isDark: isDark),
            Expanded(
              child: EmailListView(
                isMobile: true,
                onEmailTap: (email) => _selectEmail(email, isMobile: true),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Focus(
        focusNode: _listFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Row(
          children: [
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
                  InboxHeader(
                    isDark: isDark,
                    onTagManagerPressed: _openTagManager,
                    onSettingsPressed: _openSettings,
                    onGenerateEmailPressed: _openGeneratedEmails,
                  ),
                  InboxSearchBar(isDark: isDark),
                  InboxFilterBar(isDark: isDark),
                  Expanded(
                    child: EmailListView(
                      isMobile: false,
                      selectedEmail: _selectedEmail,
                      onEmailTap: (email) => _selectEmail(email, isMobile: false),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _selectedEmail != null
                  ? Container(
                      color: AppColors.backgroundLight,
                      child: EmailDetailScreen(
                        email: _selectedEmail!,
                        isEmbedded: true,
                        key: ValueKey(_selectedEmail!.id),
                      ),
                    )
                  : _buildEmptyDetailView(),
            ),
          ],
        ),
      ),
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
              'Choose an email from the list to see its content, or use Up/Down arrow keys.',
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

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    
    // We access the displayed emails list from Riverpod's container state
    // But since this is a widget method, ref.read works beautifully here
    // Wait, ref is available in ConsumerState
    final emails = ref.read(displayedEmailsProvider);
    if (emails.isEmpty) return KeyEventResult.ignored;

    final currentIndex = _selectedEmail == null 
        ? -1 
        : emails.indexWhere((e) => e.id == _selectedEmail!.id);

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (currentIndex < emails.length - 1) {
        _selectEmail(emails[currentIndex + 1], isMobile: false);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (currentIndex > 0) {
        _selectEmail(emails[currentIndex - 1], isMobile: false);
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }
}
