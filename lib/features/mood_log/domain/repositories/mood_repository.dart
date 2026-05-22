import '../entities/mood_entry.dart';

/// Abstract repository interface for mood operations
abstract class MoodRepository {
  /// Get all mood entries
  Future<List<MoodEntry>> getAllEntries();

  /// Add a new mood entry
  Future<void> addEntry(MoodEntry entry);

  /// Delete a mood entry
  Future<void> deleteEntry(DateTime createdAt);

  /// Get entries from the last N days
  Future<List<MoodEntry>> getEntriesFromLastDays(int days);

  /// Calculate current streak (consecutive days with entries)
  Future<int> calculateCurrentStreak();

  /// Calculate longest streak
  Future<int> calculateLongestStreak();
}
