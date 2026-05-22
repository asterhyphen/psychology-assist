import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../datasources/local_journal_datasource.dart';
import '../models/journal_entry_model.dart';

/// Implementation of JournalRepository
/// Bridges between domain layer and data layer
class JournalRepositoryImpl implements JournalRepository {
  final LocalJournalDataSource localDataSource;

  JournalRepositoryImpl({required this.localDataSource});

  @override
  Future<List<JournalEntry>> getAllEntries() async {
    final models = await localDataSource.getAllEntries();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addEntry(JournalEntry entry) async {
    final model = JournalEntryModel.fromEntity(entry);
    await localDataSource.addEntry(model);
  }

  @override
  Future<void> updateEntry(JournalEntry entry) async {
    final model = JournalEntryModel.fromEntity(entry);
    await localDataSource.updateEntry(model);
  }

  @override
  Future<void> deleteEntry(DateTime createdAt) async {
    await localDataSource.deleteEntry(createdAt);
  }

  @override
  Future<List<JournalEntry>> getEntriesByDate(DateTime date) async {
    final models = await localDataSource.getEntriesByDate(date);
    return models.map((model) => model.toEntity()).toList();
  }
}
