import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class InboxHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTagManagerPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onGenerateEmailPressed;

  const InboxHeader({
    super.key,
    required this.isDark,
    required this.onTagManagerPressed,
    required this.onSettingsPressed,
    required this.onGenerateEmailPressed,
  });

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryLight,
                  AppColors.unreadDot, // Violet gradient 
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.mail_outline,
              color: Colors.white,
              size: 26,
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
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  'Modern Test Email Reader',
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
            onPressed: onTagManagerPressed,
            tooltip: 'Manage Tags',
            color: AppColors.textSecondaryLight,
          ),
          IconButton(
            icon: const Icon(Icons.generating_tokens_outlined),
            onPressed: onGenerateEmailPressed,
            tooltip: 'Generated Emails',
            color: AppColors.textSecondaryLight,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: onSettingsPressed,
            tooltip: 'Settings',
            color: AppColors.textSecondaryLight,
          ),
        ],
      ),
    );
  }
}
