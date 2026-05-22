import '../entities/journal_entry.dart';

/// Abstract repository interface for journal operations
/// Implementation-agnostic - can be backed by SQLite, Firebase, or any other storage
abstract class JournalRepository {
  /// Get all journal entries
  Future<List<JournalEntry>> getAllEntries();

  /// Add a new journal entry
  Future<void> addEntry(JournalEntry entry);

  /// Update an existing journal entry
  Future<void> updateEntry(JournalEntry entry);

  /// Delete a journal entry
  Future<void> deleteEntry(DateTime createdAt);

  /// Get entries created on a specific date
  Future<List<JournalEntry>> getEntriesByDate(DateTime date);
}
