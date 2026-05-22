# Psychol App - Clean Architecture Refactoring Guide

## ✅ Status: Feature-First Clean Architecture Implementation

This document guides completing the refactoring from monolithic screens to feature-first clean architecture with presentation/domain/data layers.

### Completed Features (2/12)
- ✅ **journaling** - Full implementation with AI summary integration
- ✅ **mood_log** - Full implementation with streak calculation

### Partially Structured (folder structure ready - 0 files)
- chat
- appointments
- settings
- psychologists
- dashboard
- onboarding
- app_lock
- breathing_exercise
- calmora
- notifications

---

## Architecture Pattern

```
feature_name/
├── presentation/
│   ├── screens/          # UI Screens (stateless/stateful widgets)
│   ├── widgets/          # Reusable feature-specific components
│   └── providers/        # Riverpod StateNotifiers & FutureProviders
├── domain/
│   ├── entities/         # Pure business models (immutable, no dependencies)
│   └── repositories/     # Abstract repository interfaces
└── data/
    ├── datasources/      # LocalDataSourceImpl (interfaces persistence)
    ├── models/           # Serializable models extending entities
    └── repositories/     # Concrete repository implementations
    
feature_name_feature.dart  # Public API exporting key components
```

---

## Complete Implementation Checklist for Each Feature

### Step 1: Domain Entity
**File**: `domain/entities/{entity_name}.dart`

```dart
/// Immutable entity with copyWith, equality, and hashCode
class MyEntity {
  final String field1;
  final DateTime field2;

  const MyEntity({
    required this.field1,
    required this.field2,
  });

  MyEntity copyWith({
    String? field1,
    DateTime? field2,
  }) {
    return MyEntity(
      field1: field1 ?? this.field1,
      field2: field2 ?? this.field2,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyEntity &&
          runtimeType == other.runtimeType &&
          field1 == other.field1 &&
          field2 == other.field2;

  @override
  int get hashCode => field1.hashCode ^ field2.hashCode;
}
```

### Step 2: Domain Repository (Abstract Interface)
**File**: `domain/repositories/{entity_name}_repository.dart`

```dart
import '../entities/my_entity.dart';

abstract class MyRepository {
  Future<List<MyEntity>> getAll();
  Future<void> add(MyEntity entity);
  Future<void> update(MyEntity entity);
  Future<void> delete(String id);
  // Add feature-specific methods as needed
}
```

### Step 3: Data Model
**File**: `data/models/{entity_name}_model.dart`

```dart
import '../../domain/entities/my_entity.dart';

class MyEntityModel extends MyEntity {
  const MyEntityModel({
    required super.field1,
    required super.field2,
  });

  factory MyEntityModel.fromEntity(MyEntity entity) {
    return MyEntityModel(
      field1: entity.field1,
      field2: entity.field2,
    );
  }

  Map<String, dynamic> toJson() => {
    'field1': field1,
    'field2': field2.toIso8601String(),
  };

  factory MyEntityModel.fromJson(Map<String, dynamic> json) {
    return MyEntityModel(
      field1: json['field1'] as String,
      field2: DateTime.parse(json['field2'] as String),
    );
  }

  MyEntity toEntity() => MyEntity(
    field1: field1,
    field2: field2,
  );
}
```

### Step 4: Local Data Source
**File**: `data/datasources/local_{entity_name}_datasource.dart`

```dart
import '../models/my_entity_model.dart';

abstract class LocalMyDataSource {
  Future<List<MyEntityModel>> getAll();
  Future<void> add(MyEntityModel entity);
  Future<void> update(MyEntityModel entity);
  Future<void> delete(String id);
}

class LocalMyDataSourceImpl implements LocalMyDataSource {
  final dynamic appSessionStore;

  LocalMyDataSourceImpl({required this.appSessionStore});

  @override
  Future<List<MyEntityModel>> getAll() async {
    try {
      final session = await appSessionStore.loadSession();
      return (session.myEntities as List)
          .map((e) => MyEntityModel.fromEntity(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> add(MyEntityModel entity) async {
    final session = await appSessionStore.loadSession();
    final updated = [...session.myEntities, entity.toEntity()];
    await appSessionStore.saveSession(
      session.copyWith(myEntities: updated),
    );
  }

  // ... implement other methods following same pattern
}
```

### Step 5: Repository Implementation
**File**: `data/repositories/{entity_name}_repository_impl.dart`

```dart
import '../../domain/entities/my_entity.dart';
import '../../domain/repositories/my_repository.dart';
import '../datasources/local_my_datasource.dart';
import '../models/my_entity_model.dart';

class MyRepositoryImpl implements MyRepository {
  final LocalMyDataSource localDataSource;

  MyRepositoryImpl({required this.localDataSource});

  @override
  Future<List<MyEntity>> getAll() async {
    final models = await localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> add(MyEntity entity) async {
    final model = MyEntityModel.fromEntity(entity);
    await localDataSource.add(model);
  }

  // ... implement other methods
}
```

### Step 6: Riverpod Providers
**File**: `presentation/providers/{feature}_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_my_datasource.dart';
import '../../data/repositories/my_repository_impl.dart';
import '../../domain/entities/my_entity.dart';
import '../../domain/repositories/my_repository.dart';

// Repository provider
final myRepositoryProvider = Provider<MyRepository>((ref) {
  final dataSource = LocalMyDataSourceImpl(appSessionStore: null);
  return MyRepositoryImpl(localDataSource: dataSource);
});

// State Notifier
class MyStateNotifier extends StateNotifier<AsyncValue<List<MyEntity>>> {
  final MyRepository repository;

  MyStateNotifier({required this.repository})
      : super(const AsyncValue.loading()) {
    loadData();
  }

  Future<void> loadData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getAll());
  }

  Future<void> addEntity(MyEntity entity) async {
    await repository.add(entity);
    await loadData();
  }

  Future<void> updateEntity(MyEntity entity) async {
    await repository.update(entity);
    await loadData();
  }

  Future<void> deleteEntity(String id) async {
    await repository.delete(id);
    await loadData();
  }
}

// State provider
final myStateProvider =
    StateNotifierProvider<MyStateNotifier, AsyncValue<List<MyEntity>>>(
  (ref) {
    final repository = ref.watch(myRepositoryProvider);
    return MyStateNotifier(repository: repository);
  },
);

// Computed providers (examples)
final selectedEntityProvider = StateProvider<MyEntity?>((ref) => null);

final filteredEntitiesProvider = Provider<AsyncValue<List<MyEntity>>>((ref) {
  final state = ref.watch(myStateProvider);
  // Add filtering logic as needed
  return state;
});
```

### Step 7: Screens
**File**: `presentation/screens/{feature}_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/my_provider.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers from presentation layer only
    final state = ref.watch(myStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Feature')),
      body: state.when(
        data: (entities) {
          if (entities.isEmpty) {
            return const Center(child: Text('No data'));
          }
          return ListView.builder(
            itemCount: entities.length,
            itemBuilder: (context, index) {
              return MyEntityWidget(entity: entities[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

### Step 8: Feature Export File
**File**: `{feature_name}_feature.dart`

```dart
/// Feature Name Feature - Feature-First Clean Architecture
///
/// **Presentation Layer** (`presentation/`)
///   - `screens/`: User-facing screens
///   - `widgets/`: Reusable components
///   - `providers/`: State management
///
/// **Domain Layer** (`domain/`)
///   - `entities/`: Pure business models
///   - `repositories/`: Abstract interfaces
///
/// **Data Layer** (`data/`)
///   - `datasources/`: Local/remote data access
///   - `models/`: Serializable models
///   - `repositories/`: Concrete implementations

export 'presentation/screens/my_screen.dart';
export 'presentation/providers/my_provider.dart';
export 'domain/entities/my_entity.dart';
```

---

## Feature-Specific Guidance

### Chat Feature
**Entities**: ChatMessage (id, senderId, receiverId, content, timestamp, isRead)
**Key Methods**: 
- getMessages(userId)
- addMessage(message)
- markAsRead(messageId)
- getUnreadCount(userId)

### Appointments Feature
**Entities**: Appointment (psychologistEmail, patientName, startsAt, type, note, confirmed)
**Key Methods**:
- getUpcoming()
- getPast()
- add(appointment)
- approve(appointmentId)
- getByDate(date)

### Settings Feature
**Note**: Mix of feature-specific settings and global app settings
**Key Methods**:
- getTheme()
- setTheme(theme)
- getNotificationSettings()
- updateNotificationSettings()
- updateProfile()

### Psychologists Feature
**Entities**: AppPsychologist (name, email, specialty, availability, acceptingPatients)
**Key Logic**:
- Role-based filtering (patient vs psychologist view)
- Availability display
- Patient request management

### Dashboard Feature
**No entity data** - aggregates from other features
**Key Methods**:
- getTodaysMood()
- getNextAppointment()
- getMoodTrend(days)
- getStreak()

### Onboarding Feature
**Multi-step form** with role selection, profile setup, PIN
**Key Repositories**:
- Profile setup
- PIN verification

### Other Simple Features
- **app_lock**: PIN verification logic
- **breathing_exercise**: Static content, animation state
- **calmora**: AI chat integration (uses OllamaService)
- **notifications**: List display from AppSession

---

## Implementation Priority

**Tier 1 (High Value)** - Do First:
1. ✅ journaling
2. ✅ mood_log
3. chat
4. appointments

**Tier 2 (Medium Value)**:
5. settings
6. psychologists
7. dashboard

**Tier 3 (Lower Value)**:
8. onboarding
9. app_lock
10. breathing_exercise
11. calmora
12. notifications

---

## Migration Checklist

For each feature being migrated:

- [ ] Create domain entities in `domain/entities/`
- [ ] Create abstract repositories in `domain/repositories/`
- [ ] Create models in `data/models/`
- [ ] Implement datasources in `data/datasources/`
- [ ] Implement repositories in `data/repositories/`
- [ ] Create providers in `presentation/providers/`
- [ ] Refactor/move screens to `presentation/screens/`
- [ ] Extract reusable widgets to `presentation/widgets/`
- [ ] Create `{feature}_feature.dart` export file
- [ ] Update imports in main app to use new feature paths
- [ ] Delete old flat-structure screen files from `lib/features/{feature}/`
- [ ] Test in application

---

## Current Build Status

All directory structures are in place. Next step: Create core files following the templates above, starting with Tier 1 features (chat, appointments).

See journaling and mood_log features for complete reference implementations.
