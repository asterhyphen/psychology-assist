import 'package:flutter/material.dart';
import '../../../../app/app_state.dart';
import '../../../../core/theme/app_typography.dart';
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.28),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Journal',
                  style: AppTypography.headingSmall.copyWith(
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                const Spacer(),
                Text(
                  '${entries.length}',
                  style: AppTypography.labelMedium.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SearchBar(
              controller: searchController,
              hintText: 'Search notes',
              leading: const Icon(Icons.search, size: 20),
              elevation: const WidgetStatePropertyAll(0),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12),
              ),
              constraints: const BoxConstraints(minHeight: 44),
              backgroundColor: WidgetStatePropertyAll(
                scheme.surface.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: entries.isEmpty
                  ? _EmptyNotes(compact: compact)
                  : ListView.separated(
                      itemCount: entries.length,
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

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: compact ? 34 : 46,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.36),
            ),
            const SizedBox(height: 10),
            Text(
              'No notes found',
              textAlign: TextAlign.center,
              style: AppTypography.labelMedium.copyWith(
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Create a note or adjust your search.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color:
                    theme.textTheme.bodySmall?.color?.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
