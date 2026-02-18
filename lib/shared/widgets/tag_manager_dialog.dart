/// Tag Manager Dialog
/// UI for creating, editing, and deleting tags
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/tag_service.dart';
import '../../features/inbox/domain/email_tag.dart';

final tagServiceProvider = Provider<TagService>((ref) => TagService());

class TagManagerDialog extends ConsumerStatefulWidget {
  const TagManagerDialog({super.key});

  @override
  ConsumerState<TagManagerDialog> createState() => _TagManagerDialogState();
}

class _TagManagerDialogState extends ConsumerState<TagManagerDialog> {
  late TagService _tagService;
  List<EmailTag> _tags = [];
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tagService = ref.read(tagServiceProvider);
    _loadTags();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTags() {
    setState(() {
      _tags = _searchQuery.isEmpty
          ? _tagService.getAllTags()
          : _tagService.searchTags(_searchQuery);
    });
  }

  Future<void> _createTag() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const TagEditDialog(),
    );

    if (result != null) {
      final name = result['name']!;
      final color = result['color']!;
      await _tagService.createTag(name, color);
      _loadTags();
    }
  }

  Future<void> _editTag(EmailTag tag) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => TagEditDialog(tag: tag),
    );

    if (result != null) {
      final updatedTag = tag.copyWith(
        name: result['name'],
        color: result['color'],
      );
      await _tagService.updateTag(updatedTag);
      _loadTags();
    }
  }

  Future<void> _deleteTag(EmailTag tag) async {
    final usageCount = _tagService.getTagUsageCount(tag.id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text(
          usageCount > 0
              ? 'This tag is used in $usageCount email(s). Delete anyway?'
              : 'Are you sure you want to delete "${tag.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _tagService.deleteTag(tag.id);
      _loadTags();
    }
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
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
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
                  const Icon(Icons.label),
                  const SizedBox(width: 12),
                  const Text(
                    'Manage Tags',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tags...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _loadTags();
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _loadTags();
                },
              ),
            ),

            // Tags list
            Expanded(
              child: _tags.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isEmpty
                                ? Icons.label_off
                                : Icons.search_off,
                            size: 64,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No tags yet'
                                : 'No tags found',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _tags.length,
                      itemBuilder: (context, index) {
                        final tag = _tags[index];
                        final usageCount = _tagService.getTagUsageCount(tag.id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(
                                  int.parse('0xFF${tag.color.substring(1)}'),
                                ),
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
                            subtitle: Text('Used in $usageCount email(s)'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editTag(tag),
                                  tooltip: 'Edit tag',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () => _deleteTag(tag),
                                  tooltip: 'Delete tag',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Footer with create button
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
                child: ElevatedButton.icon(
                  onPressed: _createTag,
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Tag'),
                  style: ElevatedButton.styleFrom(
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

class TagEditDialog extends StatefulWidget {
  final EmailTag? tag;

  const TagEditDialog({super.key, this.tag});

  @override
  State<TagEditDialog> createState() => _TagEditDialogState();
}

class _TagEditDialogState extends State<TagEditDialog> {
  late TextEditingController _nameController;
  late String _selectedColor;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tag?.name ?? '');
    _selectedColor = widget.tag?.color ?? TagColors.getRandomColor();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameController.text.trim(),
        'color': _selectedColor,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      title: Text(widget.tag == null ? 'Create Tag' : 'Edit Tag'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag name input
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tag Name',
                hintText: 'Enter tag name',
                prefixIcon: Icon(Icons.label),
              ),
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a tag name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Color selection
            const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: TagColors.presets.map((color) {
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xFF${color.substring(1)}')),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: isDark ? Colors.white : Colors.black,
                              width: 3,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(
                                  int.parse('0xFF${color.substring(1)}'),
                                ).withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(widget.tag == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}
