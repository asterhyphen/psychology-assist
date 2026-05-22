import '../models/mood_entry_model.dart';

abstract class LocalMoodDataSource {
  Future<List<MoodEntryModel>> getAllEntries();
  Future<void> addEntry(MoodEntryModel entry);
  Future<void> deleteEntry(DateTime createdAt);
  Future<List<MoodEntryModel>> getEntriesFromLastDays(int days);
}

class LocalMoodDataSourceImpl implements LocalMoodDataSource {
  final dynamic appSessionStore;

  LocalMoodDataSourceImpl({required this.appSessionStore});

  @override
  Future<List<MoodEntryModel>> getAllEntries() async {
    try {
      final entries = await appSessionStore.loadSession();
      return (entries.moodEntries as List)
          .map((e) => MoodEntryModel.fromEntity(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addEntry(MoodEntryModel entry) async {
    final session = await appSessionStore.loadSession();
    final updatedMoods = [...session.moodEntries, entry.toEntity()];
    await appSessionStore.saveSession(
      session.copyWith(moodEntries: updatedMoods),
    );
  }

  @override
  Future<void> deleteEntry(DateTime createdAt) async {
    final session = await appSessionStore.loadSession();
    final updatedMoods =
        session.moodEntries.where((e) => e.createdAt != createdAt).toList();
    await appSessionStore.saveSession(
      session.copyWith(moodEntries: updatedMoods),
    );
  }

  @override
  Future<List<MoodEntryModel>> getEntriesFromLastDays(int days) async {
    final allEntries = await getAllEntries();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return allEntries
        .where((entry) => entry.createdAt.isAfter(cutoff))
        .toList();
  }
}
