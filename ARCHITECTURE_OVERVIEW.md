# Psychol Project - New Architecture Overview

## 🏗️ Architecture: Feature-First Clean Architecture

Your project has been restructured from **monolithic screens** to **feature-first clean architecture** with **presentation, domain, and data layers**.

### Quick Navigation

```
lib/features/
├── journaling/              ✅ COMPLETE - Full clean architecture
│   ├── presentation/        (screens, widgets, providers)
│   ├── domain/             (entities, repositories)
│   └── data/               (datasources, models, repositories impl)
│
├── mood_log/               ✅ COMPLETE - Full clean architecture
│   ├── presentation/
│   ├── domain/
│   └── data/
│
├── chat/                   📁 Structure ready, needs implementation
├── appointments/           📁 Structure ready, needs implementation
├── settings/               📁 Structure ready, needs implementation
├── psychologists/          📁 Structure ready, needs implementation
├── dashboard/              📁 Structure ready, needs implementation
├── onboarding/             📁 Structure ready, needs implementation
├── app_lock/               📁 Structure ready, needs implementation
├── breathing_exercise/     📁 Structure ready, needs implementation
├── calmora/                📁 Structure ready, needs implementation
└── notifications/          📁 Structure ready, needs implementation
```

---

## 📚 Inside Each Feature

Every feature follows the same structure:

### Presentation Layer (`presentation/`)
**What**: User-facing code
- **screens/**: Main UI screens (JournalingScreen, etc.)
- **widgets/**: Reusable feature-specific components (JournalEntryCard, etc.)
- **providers/**: Riverpod state notifiers and providers

**Depends on**: Domain layer only

```dart
// Import domain entities and use providers
final entries = ref.watch(journalStateProvider);
```

### Domain Layer (`domain/`)
**What**: Business logic and contracts
- **entities/**: Pure, immutable business models (JournalEntry, MoodEntry, etc.)
- **repositories/**: Abstract interfaces defining what data operations are available

**Depends on**: Nothing! (Pure Dart, no Flutter dependency)

```dart
// Define the contract, no implementation
abstract class JournalRepository {
  Future<List<JournalEntry>> getAllEntries();
}
```

### Data Layer (`data/`)
**What**: How data is actually stored/retrieved
- **datasources/**: Local/remote data access (LocalJournalDataSourceImpl)
- **models/**: Serializable models (extend entities, handle JSON)
- **repositories/**: Concrete implementations of domain repositories

**Depends on**: Domain layer only

```dart
// Implement the contract with actual persistence logic
class JournalRepositoryImpl implements JournalRepository {
  // Uses AppSessionStore for SQLite persistence
}
```

---

## 🔄 Data Flow

```
UI Screen (Presentation)
       ↓ watches
Riverpod Provider (Presentation)
       ↓ calls
Repository (Domain Interface)
       ↓ implemented by
RepositoryImpl (Data)
       ↓ uses
LocalDataSource (Data)
       ↓ persists to
AppSessionStore (SQLite)
```

---

## ✅ Benefits of This Architecture

### 1. **Separation of Concerns**
   - Presentation: "How to display?"
   - Domain: "What business rules apply?"
   - Data: "How to persist?"

### 2. **Testability**
   - Mock repositories at domain level
   - Test business logic independently
   - No UI dependencies in domain

### 3. **Maintainability**
   - Change UI without touching business logic
   - Change data source without affecting screens
   - Clear dependencies

### 4. **Scalability**
   - Add new features easily using the same pattern
   - Reusable patterns reduce code duplication
   - Features are independent modules

### 5. **Code Organization**
   - Files are much smaller (was 1,175 lines settings screen → now split)
   - Clear naming conventions
   - Easy to find related code

---

## 🚀 Examples

### Example 1: Using a Feature
```dart
// In presentation/screens/journaling_screen.dart
final entries = ref.watch(journalStateProvider);
entries.when(
  data: (entries) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error: error),
);
```

### Example 2: Adding a New Entry
```dart
// Call the notifier which handles state updates
ref.read(journalStateProvider.notifier).addEntry(content);
```

### Example 3: Feature Export
```dart
// Users import from feature_name_feature.dart
import 'package:psychol/features/journaling/journaling_feature.dart';

// Access:
JournalingScreen()
JournalEntry(...)
journalStateProvider
```

---

## 📖 Documentation

- **[ARCHITECTURE_REFACTORING.md](./ARCHITECTURE_REFACTORING.md)** - Complete implementation guide with templates
- **[journaling/journaling_feature.dart](./lib/features/journaling/journaling_feature.dart)** - Example of complete feature
- **[mood_log/mood_log_feature.dart](./lib/features/mood_log/mood_log_feature.dart)** - Another complete feature

---

## 🔧 What's Next?

### For Developers
1. Use journaling/mood_log as reference implementations
2. Follow [ARCHITECTURE_REFACTORING.md](./ARCHITECTURE_REFACTORING.md) for new features
3. Use the provided templates - copy/paste, adjust for your entity

### For This Project
Complete remaining 10 features following the established pattern. Directory structures are ready - just needs core files created.

**Recommended order**:
1. Chat (simpler messaging)
2. Appointments (forms)
3. Settings (large refactor)
4. Psychologists (dual UI logic)
5. Dashboard (aggregation)
6. Others (smaller features)

---

## 💡 Key Files

- **Entity**: `domain/entities/{name}.dart` - immutable model
- **Repository Interface**: `domain/repositories/{name}_repository.dart` - abstract
- **Model**: `data/models/{name}_model.dart` - serialization
- **DataSource**: `data/datasources/local_{name}_datasource.dart` - persistence
- **Repository Impl**: `data/repositories/{name}_repository_impl.dart` - implementation
- **Providers**: `presentation/providers/{name}_provider.dart` - state management
- **Screen**: `presentation/screens/{name}_screen.dart` - UI
- **Export**: `{feature_name}_feature.dart` - public API

---

## 🎓 Learning More

This is a **Clean Architecture** pattern, also known as:
- Feature-first architecture
- Onion architecture
- Layered architecture

Benefits are especially visible as your app grows. Each feature is now a mini-application with its own layers.
