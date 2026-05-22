# Psychol App - Setup & Development Guide

## 📦 Quick Setup

### Prerequisites
- Flutter SDK 3.13.0 or higher
- Dart 3.1.0 or higher
- An IDE (VS Code, Android Studio, or IntelliJ)

### Installation Steps

```bash
# 1. Navigate to project directory
cd psychol

# 2. Get dependencies
flutter pub get

# 3. Run the app on an emulator/device
flutter run

# Or specify device
flutter run -d "device-name"
```

### Troubleshooting Setup

**Build issues:**
```bash
# Clean build cache
flutter clean
flutter pub get

# Run with specific target
flutter run -v  # Verbose output
```

**Analyzer warnings:**
The analyzer may show false positives for Riverpod types. These don't affect runtime. To suppress:
```bash
# Ignore specific warnings
flutter analyze --no-pub
```

## 🏗️ Project Structure

```
lib/
├── main.dart                      # App entry point with Riverpod setup
│
├── app/
│   ├── home_screen.dart          # Main navigation hub (bottom nav)
│   ├── theme_provider.dart       # Riverpod theme state management
│   ├── user_preferences_provider.dart  # Notification preferences state
│   └── navigation/
│       └── app_router.dart       # Route definitions
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart       # 3 color palettes
│   │   ├── app_typography.dart   # Text styles
│   │   └── app_theme.dart        # Material 3 theme definitions
│   ├── widgets/
│   │   ├── smooth_widgets.dart   # Reusable UI components
│   │   └── animations.dart       # Page transitions & animation utilities
│   └── services/
│       └── notification_service.dart  # Local notification handling
│
└── features/
    ├── dashboard/
    │   └── dashboard_screen.dart    # Home screen with mood trends
    ├── mood_log/
    │   └── mood_log_screen.dart     # Mood entry screen
    ├── settings/
    │   └── settings_screen.dart     # Settings & preferences
    └── notifications/
        └── notifications_screen.dart  # Notifications (future)
```

## 🎨 Customizing the App

### Changing Colors

Edit `lib/core/theme/app_colors.dart`:

```dart
// Modify any color palette
static const Color lightPrimary = Color(0xFF5B8DEE);  // Change this

// Or add new custom colors
static const Color customTeal = Color(0xFF1ABC9C);
```

Then use in theme:
```dart
// lib/core/theme/app_theme.dart
primary: AppColors.customTeal,
```

### Adding New Themes

1. Add new colors to `app_colors.dart`
2. Create a new theme in `app_theme.dart`:
```dart
static ThemeData customTheme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: AppColors.customPrimary,
    // ...
  ),
  // ... rest of theme
);
```
3. Add to `AppThemeMode` enum in `app/theme_provider.dart`
4. Update main.dart to use the new mode

### Modifying Typography

Edit `lib/core/theme/app_typography.dart`:

```dart
static const TextStyle bodyLarge = TextStyle(
  fontSize: 16,        // Adjust size
  fontWeight: FontWeight.w500,  // Adjust weight
  letterSpacing: 0.15,
  height: 1.5,
);
```

## ✨ Adding Features

### Adding a New Screen

1. **Create the screen file:**
```bash
touch lib/features/new_feature/new_feature_screen.dart
```

2. **Implement the screen:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewFeatureScreen extends ConsumerWidget {
  const NewFeatureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('New Feature')),
      body: Center(
        child: SmoothCard(
          child: Text('Feature content'),
        ),
      ),
    );
  }
}
```

3. **Add to navigation** (if using bottom nav):
```dart
// lib/app/home_screen.dart
const pages = [
  DashboardScreen(),
  MoodLogScreen(),
  SettingsScreen(),
  NewFeatureScreen(),  // Add here
];

// Update bottom nav items
BottomNavigationBarItem(
  icon: Icon(Icons.new_icon),
  label: 'New',
),
```

### Using Smooth Components

```dart
// Smooth Card
SmoothCard(
  padding: EdgeInsets.all(16),
  borderRadius: 16,
  child: Text('Content'),
  onTap: () => print('Tapped'),
)

// Smooth Button
SmoothButton(
  label: 'Action',
  onPressed: () {},
  backgroundColor: Colors.black87,
  isLoading: false,
  isOutlined: false,
)

// Smooth TextField
SmoothTextField(
  label: 'Enter text',
  hint: 'Placeholder',
  controller: controller,
  maxLines: 3,
  onChanged: (value) {},
)

// Page Transition
Navigator.push(
  context,
  SmoothPageTransition(
    page: MyNewScreen(),
    axisDirection: AxisDirection.up,
  ),
)

// Staggered Animation for Lists
StaggeredAnimationBuilder(
  children: [
    widget1,
    widget2,
    widget3,
  ],
  delay: Duration(milliseconds: 80),
)
```

## 🔌 State Management with Riverpod

### Accessing Theme

```dart
// Get current theme
final themeMode = ref.watch(themeModeProvider);

// Change theme
ref.read(themeModeProvider.notifier).setThemeMode(AppThemeMode.dark);

// Toggle theme
ref.read(themeModeProvider.notifier).toggleTheme();
```

### Accessing User Preferences

```dart
// Get preferences
final prefs = ref.watch(userPreferencesProvider);
final notificationsEnabled = prefs.notificationsEnabled;

// Update preferences
ref.read(userPreferencesProvider.notifier)
    .updateNotificationsEnabled(true);

ref.read(userPreferencesProvider.notifier)
    .updateMoodCheckInInterval(6);
```

### Creating New Providers

```dart
// Simple state provider
final myStateProvider = StateProvider<String>((ref) => 'initial');

// State notifier provider
final myComplexProvider = StateNotifierProvider<MyNotifier, MyState>(
  (ref) => MyNotifier(),
);

class MyNotifier extends StateNotifier<MyState> {
  MyNotifier() : super(MyState());
  
  void updateValue(String newValue) {
    state = state.copyWith(value: newValue);
  }
}
```

## 📝 Database Setup (SQLite)

SQLite structure is prepared. To implement:

```dart
// lib/core/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late Database _database;

  factory DatabaseService() => _instance;
  
  DatabaseService._internal();

  Future<void> initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'psychol.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        // Create tables
        db.execute('''
          CREATE TABLE moods (
            id INTEGER PRIMARY KEY,
            mood_value INTEGER,
            notes TEXT,
            created_at TEXT,
            tags TEXT
          )
        ''');
      },
    );
  }

  // Add CRUD methods
}
```

## 🔔 Notifications Setup

The notification service is ready to use. To implement full scheduling:

```dart
// Initialize in main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();
  
  // Schedule notifications
  await notificationService.scheduleMoodCheckIn(hour: 14, minute: 0);
  
  runApp(...);
}
```

## 🎨 Theme Migration

To migrate from one theme to another:

```dart
// New theme colors added to app_colors.dart
// New theme added to app_theme.dart
// New mode added to AppThemeMode enum

// Example: Adding iOS theme
enum AppThemeMode {
  light,
  dark,
  journal,
  ios,  // Add new mode
}

// In app_theme.dart
static ThemeData iosTheme = ThemeData(
  // iOS-specific theme
);

// In theme_provider.dart
ThemeData getTheme(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.ios:
      return AppThemes.iosTheme;
    // ...
  }
}
```

## 📊 Performance Tips

1. **Use ConsumerWidget instead of Consumer widget wrapper** - More efficient
2. **Cache complex data** - Use Riverpod providers with select
3. **Debounce notifications** - Don't schedule hundreds of notifications
4. **Optimize animations** - Use `AnimatedContainer` instead of `AnimationController` for simple cases
5. **Lazy load screens** - Use IndexedStack for tab-based navigation (already done)

## 🚀 Building for Release

```bash
# Build iOS
flutter build ios

# Build Android
flutter build apk   # Single APK
flutter build appbundle  # For Play Store

# Build Web
flutter build web

# Obfuscate & shrink (Android)
flutter build apk --obfuscate --split-debug-info=build/app/outputs/symbols
```

## 🐛 Debugging

```bash
# Enable debug logging
flutter run --verbose

# Profile app
flutter run --profile

# Check device status
flutter devices

# Hot reload during development
r          # Hot reload
R          # Hot restart
q          # Quit
```

## 📚 Learning Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Material Design 3](https://m3.material.io)
- [Flutter Animation Guide](https://flutter.dev/docs/development/ui/animations)

## 🤝 Contributing

1. Create feature branch: `git checkout -b feature/new-feature`
2. Make changes following project structure
3. Test thoroughly: `flutter test`
4. Ensure `flutter analyze` passes
5. Commit with clear messages
6. Push and create PR

## 📄 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Hot reload fails | Try hot restart (R) |
| Build fails | Run `flutter clean && flutter pub get` |
| Permissions denied | Run `chmod +x gradlew` for Android |
| Dependencies conflict | Run `flutter pub upgrade` |
| Analyzer false positives | These don't affect runtime, ignore them |

## 💡 Next Steps for Development

1. **Implement SQLite** for mood history
2. **Add mood analytics** - Pattern detection
3. **Create mood calendar** - Visual history
4. **Add meditation guides** - Wellness content
5. **Implement data export** - Privacy-respecting backups
6. **Add app shortcuts** - Quick mood logging
7. **Implement widgets** - Home screen widgets
8. **Add dark mode schedule** - Time-based theme switching

---

**Happy coding!** 🎉 Feel free to explore, modify, and build upon this foundation.
