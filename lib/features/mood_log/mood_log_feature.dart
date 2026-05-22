/// Mood Logging Feature - Feature-First Clean Architecture
///
/// **Presentation Layer** (`presentation/`)
///   - `screens/mood_log_screen.dart`: Main mood logging UI
///   - `widgets/mood_selector.dart`: Reusable mood selection component
///   - `providers/mood_provider.dart`: Riverpod state management
///
/// **Domain Layer** (`domain/`)
///   - `entities/mood_entry.dart`: Pure business model
///   - `repositories/mood_repository.dart`: Abstract interface
///
/// **Data Layer** (`data/`)
///   - `datasources/local_mood_datasource.dart`: SQLite access
///   - `models/mood_entry_model.dart`: Serializable model
///   - `repositories/mood_repository_impl.dart`: Concrete implementation

export 'presentation/screens/mood_log_screen.dart';
export 'presentation/providers/mood_provider.dart';
export 'domain/entities/mood_entry.dart';
