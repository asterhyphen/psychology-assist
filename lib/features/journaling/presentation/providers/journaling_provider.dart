import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_journal_datasource.dart';
import '../../data/repositories/journal_repository_impl.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';

/// Provider for repository instance
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  // This will be injected with proper AppSessionStore dependency
  // For now, create a temporary data source
  // TODO: Inject AppSessionStore properly
  final dataSource = LocalJournalDataSourceImpl(appSessionStore: null);
  return JournalRepositoryImpl(localDataSource: dataSource);
});

/// State notifier for managing journal entries
class JournalStateNotifier
    extends StateNotifier<AsyncValue<List<JournalEntry>>> {
  final JournalRepository repository;

  JournalStateNotifier({required this.repository})
      : super(const AsyncValue.loading()) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getAllEntries());
  }

  Future<void> addEntry(String content) async {
    final entry = JournalEntry(
      createdAt: DateTime.now(),
      content: content,
    );
    await repository.addEntry(entry);
    await loadEntries();
  }

  Future<void> updateEntry(JournalEntry entry) async {
    await repository.updateEntry(entry);
    await loadEntries();
  }

  Future<void> deleteEntry(DateTime createdAt) async {
    await repository.deleteEntry(createdAt);
    await loadEntries();
  }
}

/// Provider for journal state
final journalStateProvider =
    StateNotifierProvider<JournalStateNotifier, AsyncValue<List<JournalEntry>>>(
  (ref) {
    final repository = ref.watch(journalRepositoryProvider);
    return JournalStateNotifier(repository: repository);
  },
);

/// Provider to get entries in reverse chronological order (newest first)
final journalEntriesReversedProvider =
    Provider<AsyncValue<List<JournalEntry>>>((ref) {
  final state = ref.watch(journalStateProvider);
  return state.whenData((entries) => entries.reversed.toList());
});

/// Provider for selected/editing journal entry
final selectedJournalEntryProvider =
    StateProvider<JournalEntry?>((ref) => null);

/// Provider for journal summary state
final journalSummaryLoadingProvider = StateProvider<bool>((ref) => false);
