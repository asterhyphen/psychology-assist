import '../models/journal_entry_model.dart';

/// Local data source for journal entries
/// Handles all local storage operations
abstract class LocalJournalDataSource {
  /// Get all journal entries from local storage
  Future<List<JournalEntryModel>> getAllEntries();

  /// Add a journal entry to local storage
  Future<void> addEntry(JournalEntryModel entry);

  /// Update a journal entry in local storage
  Future<void> updateEntry(JournalEntryModel entry);

  /// Delete a journal entry from local storage
  Future<void> deleteEntry(DateTime createdAt);

  /// Get entries created on a specific date
  Future<List<JournalEntryModel>> getEntriesByDate(DateTime date);
}

/// Implementation of LocalJournalDataSource using AppSessionStore
/// This maintains compatibility with the existing storage layer
class LocalJournalDataSourceImpl implements LocalJournalDataSource {
  final dynamic appSessionStore; // AppSessionStore instance

  LocalJournalDataSourceImpl({required this.appSessionStore});

  @override
  Future<List<JournalEntryModel>> getAllEntries() async {
    // Implementation delegated to appSessionStore
    // This will be filled in when we refactor AppSessionStore
    try {
      // Load from session store
      final entries = await appSessionStore.loadSession();
      // Extract journal entries and convert to models
      return (entries.journalEntries as List)
          .map((e) => JournalEntryModel.fromEntity(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addEntry(JournalEntryModel entry) async {
    // Implementation delegated to appSessionStore
    // Will update session and persist
    final session = await appSessionStore.loadSession();
    final updatedJournals = [...session.journalEntries, entry.toEntity()];
    await appSessionStore.saveSession(
      session.copyWith(journalEntries: updatedJournals),
    );
  }

  @override
  Future<void> updateEntry(JournalEntryModel entry) async {
    final session = await appSessionStore.loadSession();
    final index = session.journalEntries
        .indexWhere((e) => e.createdAt == entry.createdAt);
    if (index != -1) {
      final updatedJournals = [...session.journalEntries];
      updatedJournals[index] = entry.toEntity();
      await appSessionStore.saveSession(
        session.copyWith(journalEntries: updatedJournals),
      );
    }
  }

  @override
  Future<void> deleteEntry(DateTime createdAt) async {
    final session = await appSessionStore.loadSession();
    final updatedJournals =
        session.journalEntries.where((e) => e.createdAt != createdAt).toList();
    await appSessionStore.saveSession(
      session.copyWith(journalEntries: updatedJournals),
    );
  }

  @override
  Future<List<JournalEntryModel>> getEntriesByDate(DateTime date) async {
    final allEntries = await getAllEntries();
    final targetDate = DateTime(date.year, date.month, date.day);
    return allEntries.where((entry) {
      final entryDate = DateTime(
          entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      return entryDate == targetDate;
    }).toList();
  }
}
