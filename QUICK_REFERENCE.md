# Architecture Quick Reference

## Layer Responsibilities

| Layer | Purpose | Location | Dependencies |
|-------|---------|----------|--------------|
| **Presentation** | UI & State Management | `presentation/screens/`, `presentation/providers/` | Domain only |
| **Domain** | Business Logic & Contracts | `domain/entities/`, `domain/repositories/` | None (pure Dart) |
| **Data** | Persistence & Retrieval | `data/datasources/`, `data/models/`, `data/repositories/` | Domain only |

## File Templates Quick Links

- **Entity**: Copy from `domain/entities/journal_entry.dart`
- **Domain Repo**: Copy from `domain/repositories/journal_repository.dart`
- **Model**: Copy from `data/models/journal_entry_model.dart`
- **DataSource**: Copy from `data/datasources/local_journal_datasource.dart`
- **Repo Impl**: Copy from `data/repositories/journal_repository_impl.dart`
- **Provider**: Copy from `presentation/providers/journaling_provider.dart`
- **Screen**: Copy from `presentation/screens/journaling_screen.dart`
- **Export**: Copy from `journaling_feature.dart`

## Import Rules

```
✅ DO:
- Presentation → imports Domain
- Data → imports Domain
- Domain → imports nothing
- Features → independent

❌ DON'T:
- Domain → imports Presentation
- Domain → imports Data
- Cross-feature direct imports
- Circular dependencies
```

## Folder Structure Visualization

```
feature/
├── 📂 presentation/
│   ├── 📂 screens/              ← User sees this
│   │   └── my_feature_screen.dart
│   ├── 📂 widgets/              ← Reusable components
│   │   └── my_widget.dart
│   └── 📂 providers/            ← State management
│       └── my_provider.dart
│
├── 📂 domain/                   ← Business rules (pure Dart)
│   ├── 📂 entities/
│   │   └── my_entity.dart       ← Just data, no logic
│   └── 📂 repositories/
│       └── my_repository.dart   ← Abstract interface
│
└── 📂 data/                     ← How data moves
    ├── 📂 datasources/
    │   └── local_my_datasource.dart  ← Access logic
    ├── 📂 models/
    │   └── my_entity_model.dart      ← Serialization
    └── 📂 repositories/
        └── my_repository_impl.dart   ← Implementation
```

## Common Patterns

### Add an Entry
```dart
ref.read(myStateProvider.notifier).addEntry(entity);
```

### Watch Entries
```dart
final state = ref.watch(myStateProvider);
state.when(
  data: (entries) => ...,
  loading: () => ...,
  error: (error, stack) => ...,
);
```

### Update an Entry
```dart
ref.read(myStateProvider.notifier).updateEntry(updatedEntity);
```

### Delete an Entry
```dart
ref.read(myStateProvider.notifier).deleteEntry(entityId);
```

## File Naming Conventions

| Item | Pattern | Example |
|------|---------|---------|
| Entity | `{entity_name}.dart` | `journal_entry.dart` |
| Model | `{entity_name}_model.dart` | `journal_entry_model.dart` |
| Repository (abstract) | `{entity_name}_repository.dart` | `journal_repository.dart` |
| Repository (impl) | `{entity_name}_repository_impl.dart` | `journal_repository_impl.dart` |
| DataSource (abstract) | `local_{entity_name}_datasource.dart` | `local_journal_datasource.dart` |
| Provider | `{feature}_provider.dart` | `journaling_provider.dart` |
| Screen | `{feature}_screen.dart` | `journaling_screen.dart` |
| Widget | `{widget_name}.dart` | `journal_entry_card.dart` |
| Export | `{feature_name}_feature.dart` | `journaling_feature.dart` |

## Completed Reference Implementations

### Full Feature: Journaling
- ✅ All 8 layer files
- ✅ AI summary integration
- ✅ Share with therapist logic
- **Location**: `lib/features/journaling/`
- **Entry point**: `journaling_feature.dart`

### Full Feature: Mood Log
- ✅ All 8 layer files
- ✅ Streak calculation
- ✅ Mood selector widget
- **Location**: `lib/features/mood_log/`
- **Entry point**: `mood_log_feature.dart`

## Debug Checklist

If something isn't working:

- [ ] Did screen import from `presentation/providers/`? (not directly from data)
- [ ] Do repositories implement abstract interface?
- [ ] Does model have `fromEntity()`, `toEntity()`, `toJson()`, `fromJson()`?
- [ ] Do entities have `copyWith()`, `==`, `hashCode`?
- [ ] Did you call `loadEntries()` in state notifier constructor?
- [ ] Are Riverpod providers exported in `_feature.dart`?
- [ ] Did you check journaling/mood_log for similar patterns?

## Next Features to Complete

**High Value (do first)**:
1. chat - Simple message entity
2. appointments - Form entity with validation
3. settings - Mix of entities, large UI refactor

**Medium Value**:
4. psychologists - Role-based filtering
5. dashboard - Aggregation from other features

**Lower Value**:
6-12. Others (onboarding, app_lock, breathing_exercise, calmora, notifications)
