import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_mood_datasource.dart';
import '../../data/repositories/mood_repository_impl.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  final dataSource = LocalMoodDataSourceImpl(appSessionStore: null);
  return MoodRepositoryImpl(localDataSource: dataSource);
});

class MoodStateNotifier extends StateNotifier<AsyncValue<List<MoodEntry>>> {
  final MoodRepository repository;

  MoodStateNotifier({required this.repository})
      : super(const AsyncValue.loading()) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getAllEntries());
  }

  Future<void> addEntry(MoodEntry entry) async {
    await repository.addEntry(entry);
    await loadEntries();
  }

  Future<void> deleteEntry(DateTime createdAt) async {
    await repository.deleteEntry(createdAt);
    await loadEntries();
  }
}

final moodStateProvider =
    StateNotifierProvider<MoodStateNotifier, AsyncValue<List<MoodEntry>>>(
  (ref) {
    final repository = ref.watch(moodRepositoryProvider);
    return MoodStateNotifier(repository: repository);
  },
);

final currentMoodStreakProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(moodRepositoryProvider);
  return repository.calculateCurrentStreak();
});

final longestMoodStreakProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(moodRepositoryProvider);
  return repository.calculateLongestStreak();
});

final last7DaysMoodsProvider = FutureProvider<List<MoodEntry>>((ref) async {
  final repository = ref.watch(moodRepositoryProvider);
  return repository.getEntriesFromLastDays(7);
});
