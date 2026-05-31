import 'package:flutter/material.dart';
import '../../../../app/app_state.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import 'note_list_tile.dart';

class NotesSidebar extends StatelessWidget {
  final List<JournalEntry> entries;
  final JournalEntry? selectedEntry;
  final TextEditingController searchController;
  final String Function(JournalEntry entry) titleFor;
  final String Function(JournalEntry entry) previewFor;
  final String Function(DateTime date) dateFor;
  final ValueChanged<JournalEntry> onSelect;
  final bool compact;

  const NotesSidebar({
    super.key,
    required this.entries,
    required this.selectedEntry,
    required this.searchController,
    required this.titleFor,
    required this.previewFor,
    required this.dateFor,
    required this.onSelect,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF11161F) 
            : scheme.surfaceContainerHighest.withValues(alpha: 0.18),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14, compact ? 6 : 12, 14, compact ? 4 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!compact) ...[
              Row(
                children: [
                  Text(
                    'Journal Reflections',
                    style: AppTypography.headingSmall.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${entries.length}',
                      style: AppTypography.labelMedium.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            
            Expanded(
              child: entries.isEmpty
                  ? _EmptyNotes(compact: compact)
                  : ListView.separated(
                      itemCount: entries.length,
                      padding: EdgeInsets.symmetric(vertical: compact ? 2 : 6),
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return NoteListTile(
                          title: titleFor(entry),
                          preview: previewFor(entry),
                          date: dateFor(entry.createdAt),
                          selected: entry.createdAt == selectedEntry?.createdAt,
                          shared: entry.sharedWithPsychologist,
                          onTap: () => onSelect(entry),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  final bool compact;

  const _EmptyNotes({required this.compact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 12, vertical: compact ? 4 : 12),
        child: Container(
          constraints: BoxConstraints(maxWidth: compact ? 260 : 320),
          padding: EdgeInsets.all(compact ? 10 : 16),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: isDark ? 0.08 : 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.primary.withValues(alpha: isDark ? 0.16 : 0.08),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.self_improvement_rounded,
                size: compact ? 22 : 32,
                color: scheme.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 6),
              Text(
                'Your Mindful Space',
                textAlign: TextAlign.center,
                style: AppTypography.labelLarge.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: compact ? 13 : 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start writing in Write Pad to record your thoughts and reflections.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: scheme.mutedText,
                  height: 1.35,
                  fontSize: compact ? 11 : 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
