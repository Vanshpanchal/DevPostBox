import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/inbox_provider.dart';

class InboxFilterBar extends ConsumerWidget {
  final bool isDark;

  const InboxFilterBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(context, ref, EmailFilter.all, 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, ref, EmailFilter.unread, 'Unread'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, ref, EmailFilter.hasAttachment, 'Files'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildSortChip(context, ref),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, WidgetRef ref, EmailFilter filter, String label) {
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
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(
          color: isSelected ? AppColors.primaryLight : AppColors.dividerLight.withValues(alpha: 0.8),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }

  Widget _buildSortChip(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(emailSortProvider);
    final isNewest = currentSort == EmailSort.newest;

    return InkWell(
      onTap: () {
        ref.read(emailSortProvider.notifier).state = isNewest
            ? EmailSort.oldest
            : EmailSort.newest;
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.8)),
          borderRadius: BorderRadius.circular(30),
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
}
