/// Journaling Feature - Organized with Clean Architecture
///
/// This feature is organized into three layers following feature-first architecture:
///
/// **Presentation Layer** (`presentation/`)
///   - `screens/`: User-facing screens (JournalingScreen, JournalHistoryScreen)
///   - `widgets/`: Reusable components (JournalEntryCard)
///   - `providers/`: Riverpod state management (journaling_provider.dart)
///
/// **Domain Layer** (`domain/`)
///   - `entities/`: Pure business models independent of storage (JournalEntry)
///   - `repositories/`: Abstract repository interfaces defining contracts
///
/// **Data Layer** (`data/`)
///   - `datasources/`: Local/remote data access (LocalJournalDataSourceImpl)
///   - `models/`: Serializable models for persistence (JournalEntryModel)
///   - `repositories/`: Concrete repository implementations
///
/// **Dependencies Flow:**
/// Presentation → Domain ← Data
///
/// The presentation layer depends on domain entities and repositories.
/// The data layer implements the domain repositories.
/// This creates a clean, testable, and maintainable architecture.

export 'presentation/screens/journaling_screen.dart';
export 'presentation/screens/journal_history_screen.dart';
export 'presentation/providers/journaling_provider.dart';
export 'domain/entities/journal_entry.dart';
