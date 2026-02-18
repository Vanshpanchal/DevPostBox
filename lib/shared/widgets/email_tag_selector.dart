/// Email Tag Selector
/// UI for adding/removing tags from an email
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/tag_service.dart';
import '../../features/inbox/domain/email_tag.dart';
import '../../features/inbox/domain/test_mail.dart';
import 'tag_manager_dialog.dart';

class EmailTagSelector extends ConsumerStatefulWidget {
  final TestMail email;
  final Function(List<String> tagIds) onTagsChanged;

  const EmailTagSelector({
    super.key,
    required this.email,
    required this.onTagsChanged,
  });

  @override
  ConsumerState<EmailTagSelector> createState() => _EmailTagSelectorState();
}

class _EmailTagSelectorState extends ConsumerState<EmailTagSelector> {
  late TagService _tagService;
  List<EmailTag> _allTags = [];
  Set<String> _selectedTagIds = {};

  @override
  void initState() {
    super.initState();
    _tagService = ref.read(tagServiceProvider);
    _loadTags();
  }

  void _loadTags() {
    setState(() {
      _allTags = _tagService.getAllTags();
      _selectedTagIds = _tagService.getEmailTagIds(widget.email.id).toSet();
    });
  }

  Future<void> _toggleTag(String tagId) async {
    if (_selectedTagIds.contains(tagId)) {
      await _tagService.removeTagFromEmail(widget.email.id, tagId);
      _selectedTagIds.remove(tagId);
    } else {
      await _tagService.addTagToEmail(widget.email.id, tagId);
      _selectedTagIds.add(tagId);
    }
    setState(() {});
    widget.onTagsChanged(_selectedTagIds.toList());
  }

  Future<void> _openTagManager() async {
    await showDialog(
      context: context,
      builder: (context) => const TagManagerDialog(),
    );
    _loadTags();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.dividerDark
                        : AppColors.dividerLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Add Tags',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Tags list
            Expanded(
              child: _allTags.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.label_off,
                            size: 64,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tags available',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _openTagManager,
                            icon: const Icon(Icons.add),
                            label: const Text('Create your first tag'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _allTags.length,
                      itemBuilder: (context, index) {
                        final tag = _allTags[index];
                        final isSelected = _selectedTagIds.contains(tag.id);
                        final tagColor = Color(
                          int.parse('0xFF${tag.color.substring(1)}'),
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) => _toggleTag(tag.id),
                            secondary: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: tagColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.label,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              tag.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            activeColor: tagColor,
                          ),
                        );
                      },
                    ),
            ),

            // Footer with manage button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.dividerDark
                        : AppColors.dividerLight,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openTagManager,
                  icon: const Icon(Icons.settings),
                  label: const Text('Manage Tags'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
