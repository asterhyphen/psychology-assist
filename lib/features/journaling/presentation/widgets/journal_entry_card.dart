part of '../screens/journal_history_screen.dart';

class _JournalEntryCard extends ConsumerStatefulWidget {
  final JournalEntry entry;

  const _JournalEntryCard({required this.entry});

  @override
  ConsumerState<_JournalEntryCard> createState() => _JournalEntryCardState();
}
