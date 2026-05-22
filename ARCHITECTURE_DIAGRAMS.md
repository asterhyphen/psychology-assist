# Psychol Architecture - Complete Visual Guide

## System Architecture Diagram

```mermaid
graph TB
    User["👤 User<br/>Interacts with App"]
    
    User -->|Taps Button| UI["📱 Presentation Layer<br/>Screens & Widgets"]
    
    UI -->|Watches| Provider["🔄 Riverpod Providers<br/>State Management"]
    
    Provider -->|Calls| DomainRepo["📋 Domain Repository<br/>Abstract Interface"]
    
    DomainRepo -->|Implemented By| DataRepo["💾 Data Repository<br/>Concrete Implementation"]
    
    DataRepo -->|Uses| DataSource["📥 Local DataSource<br/>Access Logic"]
    
    DataSource -->|Persists To| DB["🗄️ SQLite<br/>via AppSessionStore"]
    
    DB -->|Returns Data| DataSource
    DataSource -->|Maps to Entity| DataRepo
    DataRepo -->|Returns Domain Entity| Provider
    Provider -->|Updates State| UI
    UI -->|Re-renders| User
    
    style UI fill:#E8F5E9
    style Provider fill:#E8F5E9
    style DomainRepo fill:#FFF3E0
    style DataRepo fill:#FCE4EC
    style DataSource fill:#FCE4EC
    style DB fill:#ECEFF1
```

## Feature Structure Example: Journaling

```mermaid
graph LR
    A["🎯 journaling/<br/>feature<br/>directory"]
    
    A --> B["📂 presentation/"]
    A --> C["📂 domain/"]
    A --> D["📂 data/"]
    
    B --> B1["📂 screens/"]
    B --> B2["📂 widgets/"]
    B --> B3["📂 providers/"]
    
    B1 --> B1a["journaling_screen.dart"]
    B1 --> B1b["journal_history_screen.dart"]
    
    B2 --> B2a["journal_entry_card.dart"]
    
    B3 --> B3a["journaling_provider.dart<br/>(StateNotifier)"]
    
    C --> C1["📂 entities/"]
    C --> C2["📂 repositories/"]
    
    C1 --> C1a["journal_entry.dart"]
    
    C2 --> C2a["journal_repository.dart<br/>(abstract)"]
    
    D --> D1["📂 datasources/"]
    D --> D2["📂 models/"]
    D --> D3["📂 repositories/"]
    
    D1 --> D1a["local_journal_datasource.dart"]
    
    D2 --> D2a["journal_entry_model.dart"]
    
    D3 --> D3a["journal_repository_impl.dart"]
    
    A --> Export["journaling_feature.dart<br/>(Public API)"]
    
    style B fill:#E8F5E9,color:#000
    style C fill:#FFF3E0,color:#000
    style D fill:#FCE4EC,color:#000
    style Export fill:#F3E5F5,color:#000
```

## Data Flow in Action: Adding a Journal Entry

```mermaid
sequenceDiagram
    participant Screen as JournalingScreen
    participant Provider as StateNotifier
    participant Repo as JournalRepository
    participant DataSrc as LocalDataSource
    participant Store as AppSessionStore
    participant DB as SQLite
    
    Screen->>Provider: addEntry(content)
    activate Provider
    
    Provider->>Repo: addEntry(entity)
    activate Repo
    
    Repo->>DataSrc: addEntry(model)
    activate DataSrc
    
    DataSrc->>Store: loadSession()
    Store->>DB: Read current data
    DB-->>Store: Current session
    Store-->>DataSrc: Session loaded
    
    DataSrc->>DataSrc: Update journal list
    
    DataSrc->>Store: saveSession(updated)
    Store->>DB: Write to SQLite
    DB-->>Store: ✅ Success
    Store-->>DataSrc: Saved
    
    DataSrc-->>Repo: Complete
    deactivate DataSrc
    
    Repo->>Repo: Call loadEntries()
    Repo-->>Provider: Entries refreshed
    deactivate Repo
    
    Provider->>Provider: Emit new state
    Provider-->>Screen: Notify of change
    deactivate Provider
    
    Screen->>Screen: Rebuild with new data
    Screen-->>User: Display updated list
```

## Layer Dependencies

```mermaid
graph TB
    Presentation["📱 Presentation<br/>Screens, Widgets,<br/>Riverpod Notifiers"]
    
    Domain["📋 Domain<br/>Entities,<br/>Abstract Repos<br/>Pure Dart"]
    
    Data["💾 Data<br/>DataSources,<br/>Models,<br/>Repo Implementations"]
    
    Core["🔧 Core<br/>Services, Utilities,<br/>AppSessionStore"]
    
    Presentation -->|imports| Domain
    Data -->|imports| Domain
    Presentation -->|may use| Core
    Data -->|may use| Core
    
    Domain -->|NO dependencies| Domain
    Domain -->|❌ doesn't import| Data
    Domain -->|❌ doesn't import| Presentation
    Data -->|❌ doesn't import| Presentation
    
    style Presentation fill:#E8F5E9,stroke:#4CAF50,stroke-width:3px
    style Domain fill:#FFF3E0,stroke:#FF9800,stroke-width:3px
    style Data fill:#FCE4EC,stroke:#E91E63,stroke-width:3px
    style Core fill:#ECEFF1,stroke:#607D8B,stroke-width:2px
    
    classDef blocked fill:#FFEBEE,stroke:#F44336,stroke-width:2px,stroke-dasharray: 5 5
    class Blocked blocked
```

## File Organization Pattern

```
lib/
├── features/                          ← All business features
│   ├── journaling/                    ✅ COMPLETE
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── journaling_screen.dart
│   │   │   │   └── journal_history_screen.dart
│   │   │   ├── widgets/
│   │   │   │   └── journal_entry_card.dart
│   │   │   └── providers/
│   │   │       └── journaling_provider.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── journal_entry.dart
│   │   │   └── repositories/
│   │   │       └── journal_repository.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── local_journal_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── journal_entry_model.dart
│   │   │   └── repositories/
│   │   │       └── journal_repository_impl.dart
│   │   └── journaling_feature.dart     ← Public API
│   │
│   ├── mood_log/                      ✅ COMPLETE
│   │   ├── presentation/
│   │   ├── domain/
│   │   ├── data/
│   │   └── mood_log_feature.dart
│   │
│   ├── chat/                          📁 Ready
│   ├── appointments/                  📁 Ready
│   ├── settings/                      📁 Ready
│   └── ...9 more features...
│
├── core/                              ← Shared services
│   ├── theme/
│   ├── widgets/
│   └── services/
│       ├── app_session_store.dart     ← SQLite persistence
│       ├── ollama_service.dart
│       ├── nfc_service.dart
│       └── notification_service.dart
│
└── app/                               ← App-level setup
    ├── app_state.dart                 ← Central state (being refactored)
    ├── home_screen.dart
    └── theme_provider.dart
```

## State Flow Diagram

```mermaid
stateDiagram-v2
    [*] --> Loading
    Loading --> NoData: Empty list
    Loading --> Data: Entries loaded
    NoData --> Adding: User adds entry
    Data --> Adding: User adds entry
    Adding --> Saving: Calling repository
    Saving --> Data: Successfully saved
    Saving --> Error: Save failed
    Error --> Data: Retry successful
    Error --> Adding: User retries
    Data --> Deleting: User deletes entry
    Deleting --> Saving
    [*] --> Done
```

## Import Example: Using a Feature

```dart
// ✅ CORRECT: Import from feature's public API
import 'package:psychol/features/journaling/journaling_feature.dart';

// Use the feature
final entries = ref.watch(journalStateProvider);
final screen = JournalingScreen();
final entry = JournalEntry(
  createdAt: DateTime.now(),
  content: 'My thoughts...',
);

// ❌ WRONG: Don't import internal structure
import 'package:psychol/features/journaling/presentation/providers/journaling_provider.dart';
import 'package:psychol/features/journaling/data/repositories/journal_repository_impl.dart';
```

## Testing Structure (Future)

```mermaid
graph LR
    A["🧪 test/"]
    
    A --> B["features/"]
    
    B --> J["journaling/"]
    J --> J1["domain/"]
    J --> J2["data/"]
    J --> J3["presentation/"]
    
    J1 --> J1a["journal_entity_test.dart"]
    J1 --> J1b["journal_repository_test.dart"]
    
    J2 --> J2a["journal_datasource_test.dart"]
    J2 --> J2b["journal_repository_impl_test.dart"]
    
    J3 --> J3a["journaling_provider_test.dart"]
    J3 --> J3b["journaling_screen_test.dart"]
    
    style J1 fill:#FFF3E0
    style J2 fill:#FCE4EC
    style J3 fill:#E8F5E9
```

## Statistics

| Metric | Before | After |
|--------|--------|-------|
| Largest file | settings_screen.dart (1,175 lines) | Refactored into multiple 200-300 line files |
| Code organization | Monolithic by screen | Organized by layer + feature |
| Dependencies clarity | All mixed together | Clear unidirectional dependencies |
| Reusability | Low | High (widgets, logic extracted) |
| Testability | Difficult | Easy (domain logic isolated) |
| Maintainability | Hard to modify | Easy to modify |
| Scalability | Degrades with size | Scales linearly with new features |

## Transition Timeline

1. **Phase 1** ✅ (COMPLETE)
   - Created clean architecture pattern
   - Implemented journaling feature
   - Implemented mood_log feature
   - Created directories for all features
   - Documented patterns and templates

2. **Phase 2** (NEXT)
   - Implement chat, appointments, settings
   - Apply pattern to psychologists, dashboard
   - Complete remaining 7 features

3. **Phase 3** (FUTURE)
   - Add comprehensive test suite
   - Optimize AppSessionStore integration
   - Consider migrating from central AppSession to fully distributed state

---

## Key Takeaways

✅ **Clean Architecture Benefits**:
- Testable business logic (no UI dependencies)
- Easy to modify features independently
- Clear dependencies between layers
- Scalable pattern as app grows
- Easier onboarding for new developers

📚 **Reference Implementations**:
- [journaling](./lib/features/journaling/) - Full feature
- [mood_log](./lib/features/mood_log/) - Full feature

📖 **Documentation**:
- [ARCHITECTURE_OVERVIEW.md](./ARCHITECTURE_OVERVIEW.md) - Architecture explanation
- [ARCHITECTURE_REFACTORING.md](./ARCHITECTURE_REFACTORING.md) - Implementation guide
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - Quick lookup

🚀 **Next Step**: Pick a feature from remaining 10 and follow the templates!
