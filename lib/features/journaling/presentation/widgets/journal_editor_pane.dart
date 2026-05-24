import 'package:flutter/material.dart';
import '../../../../app/app_state.dart';
import '../../../../core/theme/app_typography.dart';

class JournalEditorPane extends StatelessWidget {
  final TextEditingController controller;
  final JournalEntry? editingEntry;
  final VoidCallback onNewNote;

  const JournalEditorPane({
    super.key,
    required this.controller,
    required this.editingEntry,
    required this.onNewNote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  editingEntry == null ? 'New note' : 'Editing note',
                  style: AppTypography.headingSmall.copyWith(
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
              ),
              if (editingEntry != null)
                IconButton.filledTonal(
                  tooltip: 'Start new note',
                  onPressed: onNewNote,
                  icon: const Icon(Icons.add),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            editingEntry == null
                ? 'Private journal note'
                : _formatEditorDate(editingEntry!.createdAt),
            style: AppTypography.bodySmall.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.66),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Start typing...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(18),
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.44),
                  ),
                ),
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.textTheme.bodyMedium?.color,
                  height: 1.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatEditorDate(DateTime date) {
    return 'Created ${date.day}/${date.month}/${date.year} at '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
