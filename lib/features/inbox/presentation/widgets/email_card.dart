/// Email card widget for inbox list
/// Modern 2026 design with glassmorphism and subtle animations
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/test_mail.dart';
import '../../../search/providers/search_provider.dart';

class EmailCard extends StatelessWidget {
  final TestMail email;
  final VoidCallback onTap;
  final String searchQuery;

  const EmailCard({
    super.key,
    required this.email,
    required this.onTap,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Since we forced Light Mode, isDark will be false.
    // We can simplify logic or leave it for potential future dark mode.
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: AppColors.primaryLight.withValues(alpha: 0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.dividerLight.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with avatar, sender, time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with unread indicator
                    Stack(
                      children: [
                        _buildAvatar(context),
                        if (!email.isRead)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.unreadDot, // Orange
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.cardLight, // White border
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Sender and time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildHighlightedText(
                                  context,
                                  email.displayName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: email.isRead
                                        ? FontWeight.w500
                                        : FontWeight.w800,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatTime(email.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email.fromAddress,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Subject
                _buildHighlightedText(
                  context,
                  email.subject,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: email.isRead ? FontWeight.w500 : FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                    height: 1.3,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 6),

                // Preview text
                _buildHighlightedText(
                  context,
                  email.previewText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                  maxLines: 2,
                ),

                // Bottom row with tag and attachment indicator
                if (email.tag.isNotEmpty || email.hasAttachments) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Tag chip
                      if (email.tag.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.3), // Yellow tint
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.secondary, // Yellow border
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.label_outline,
                                size: 14,
                                color: Colors.black87, // Black/Dark Grey for contrast on yellow
                              ),
                              const SizedBox(width: 6),
                              Text(
                                email.tag,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const Spacer(),

                      // Attachment indicator
                      if (email.hasAttachments)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.dividerLight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.attach_file,
                                size: 16,
                                color: AppColors.primaryLight, // Orange icon
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${email.attachmentCount}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.textPrimaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          email.initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    BuildContext context,
    String text, {
    TextStyle? style,
    int maxLines = 1,
  }) {
    if (searchQuery.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final spans = text.getHighlightSpans(searchQuery);

    return RichText(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: spans.map((span) {
          return TextSpan(
            text: span.text,
            style: span.isHighlight
                ? style?.copyWith(
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w700,
                  )
                : style,
          );
        }).toList(),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h';
    }
    if (difference.inDays == 1) {
      return 'Yesterday';
    }
    if (difference.inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    }
    return DateFormat('MMM d').format(dateTime);
  }
}
