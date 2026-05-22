import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import '../datasources/local_mood_datasource.dart';
import '../models/mood_entry_model.dart';

class MoodRepositoryImpl implements MoodRepository {
  final LocalMoodDataSource localDataSource;

  MoodRepositoryImpl({required this.localDataSource});

  @override
  Future<List<MoodEntry>> getAllEntries() async {
    final models = await localDataSource.getAllEntries();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addEntry(MoodEntry entry) async {
    final model = MoodEntryModel.fromEntity(entry);
    await localDataSource.addEntry(model);
  }

  @override
  Future<void> deleteEntry(DateTime createdAt) async {
    await localDataSource.deleteEntry(createdAt);
  }

  @override
  Future<List<MoodEntry>> getEntriesFromLastDays(int days) async {
    final models = await localDataSource.getEntriesFromLastDays(days);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> calculateCurrentStreak() async {
    final entries = await getAllEntries();
    if (entries.isEmpty) return 0;

    final sortedByDate = entries.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int streak = 0;
    DateTime? lastDate;

    for (final entry in sortedByDate) {
      final entryDate = DateTime(
          entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);

      if (lastDate == null) {
        lastDate = entryDate;
        streak = 1;
      } else {
        final daysDiff = lastDate.difference(entryDate).inDays;
        if (daysDiff == 1) {
          streak++;
          lastDate = entryDate;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  @override
  Future<int> calculateLongestStreak() async {
    final entries = await getAllEntries();
    if (entries.isEmpty) return 0;

    final sortedByDate = entries.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    int longestStreak = 1;
    int currentStreak = 1;
    DateTime? lastDate;

    for (final entry in sortedByDate) {
      final entryDate = DateTime(
          entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);

      if (lastDate == null) {
        lastDate = entryDate;
      } else {
        final daysDiff = entryDate.difference(lastDate).inDays;
        if (daysDiff == 1) {
          currentStreak++;
          longestStreak =
              longestStreak < currentStreak ? currentStreak : longestStreak;
        } else if (daysDiff > 1) {
          currentStreak = 1;
        }
        lastDate = entryDate;
      }
    }

    return longestStreak;
  }
}
