import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../search/providers/search_provider.dart';

class InboxSearchBar extends ConsumerStatefulWidget {
  final bool isDark;

  const InboxSearchBar({super.key, required this.isDark});

  @override
  ConsumerState<InboxSearchBar> createState() => _InboxSearchBarState();
}

class _InboxSearchBarState extends ConsumerState<InboxSearchBar> {
  late final TextEditingController _searchController;
  late final Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: ref.read(searchQueryProvider));
    _debouncer = Debouncer(milliseconds: AppConstants.searchDebounceMs);
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

  @override
  Widget build(BuildContext context) {
    final isSearchActive = ref.watch(isSearchActiveProvider);
    
    // Sync the controller if query was cleared externally
    ref.listen<String>(searchQueryProvider, (previous, next) {
      if (next.isEmpty && _searchController.text.isNotEmpty) {
        _searchController.clear();
      }
    });

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: AppColors.dividerLight.withValues(alpha: 0.6),
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search emails, tags...',
            hintStyle: const TextStyle(
              color: AppColors.textSecondaryLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Icon(
              Icons.search,
              size: 20,
              color: AppColors.textSecondaryLight,
            ),
            suffixIcon: isSearchActive
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: _clearSearch,
                    color: AppColors.textSecondaryLight,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            filled: true,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
