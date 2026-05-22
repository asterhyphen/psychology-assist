import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_state.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/journaling_provider.dart';
import '../widgets/journal_entry_card.dart';

class JournalHistoryScreen extends ConsumerWidget {
  const JournalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalState = ref.watch(journalStateProvider);
    final appSession = ref.watch(appSessionProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal History'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Journal Entries',
              style: AppTypography.headingMedium.copyWith(
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View your journal entries and reflections.',
              style: AppTypography.bodySmall.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: journalState.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          children: [
                            Icon(
                              Icons.edit_note_outlined,
                              size: 64,
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No journal entries yet',
                              style: AppTypography.bodyMedium.copyWith(
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final reversedEntries = entries.reversed.toList();
                  return ListView.builder(
                    itemCount: reversedEntries.length,
                    itemBuilder: (context, index) {
                      final entry = reversedEntries[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: JournalEntryCard(
                          entry: entry,
                          psychologistEmail: appSession.profile?.psychologistEmail,
                          hasPsychologist: appSession.profile?.hasPsychologist ?? false,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text(
                    'Error loading entries: $error',
                    style: AppTypography.bodyMedium.copyWith(
                      color: scheme.error,
                    ),
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
