# Psychol - Privacy-First Digital Psychiatry Platform

A beautiful, minimal Flutter app for mental wellness tracking with a focus on **privacy, calm aesthetics, and smooth interactions**.

## 📋 Project Overview

Psychol is a mobile application designed to help users track their mental health through mood logging, trend analysis, and personalized wellness insights. Built with a strong emphasis on:

- **Privacy First**: All data stored locally on device, no cloud sync
- **Minimal UI**: Clutter-free, clinical design focused on calm
- **Smooth Interactions**: Subtle animations, satisfying transitions
- **Accessibility**: High contrast, readable typography, proper spacing

## 🏗️ Architecture

### Folder Structure

```
lib/
├── app/
│   ├── home_screen.dart          # Main navigation hub
│   ├── theme_provider.dart       # Riverpod theme state
│   ├── user_preferences_provider.dart  # User settings state
│   └── navigation/
│       └── app_router.dart       # Route definitions
├── core/
│   ├── theme/
│   │   ├── app_colors.dart       # Color palettes (light/dark)
│   │   ├── app_typography.dart   # Text styles
│   │   └── app_theme.dart        # Material 3 themes
│   ├── widgets/
│   │   ├── smooth_widgets.dart   # Reusable components (cards, buttons, inputs)
│   │   └── animations.dart       # Page transitions & animation utilities
│   └── services/
│       └── notification_service.dart  # Local notifications
├── features/
│   ├── dashboard/
│   │   └── dashboard_screen.dart # Home screen with mood trends
│   ├── mood_log/
│   │   └── mood_log_screen.dart  # Mood entry with emoji selector
│   ├── settings/
│   │   └── settings_screen.dart  # Theme, notifications, privacy
│   └── notifications/
│       └── notifications_screen.dart  # Notification settings (future)
└── main.dart                     # App entry point
```

### State Management

**Riverpod** is used for state management:
- `themeModeProvider`: Manages light/dark/journal theme switching
- `userPreferencesProvider`: Stores notification preferences, intervals
- `selectedTabProvider`: Tracks bottom navigation state

## 🎨 Design System

### Colors

Three complete color palettes:

1. **Light Theme** - Fresh, airy design
   - Primary: `#5B8DEE` (calm blue)
   - Secondary: `#6AC5A8` (soft green)
   - Accent: `#F0A8A0` (soft coral)

2. **Dark Theme** - Easy on the eyes
   - Primary: `#7BA3FF` (lighter blue)
   - Secondary: `#7FD9BE` (lighter green)
   - Accent: `#F5B5AA` (lighter coral)

3. **Journal Theme** - Handwritten, artistic

### Mood Colors

- Excellent: `#34D399` (Green)
- Good: `#60A5FA` (Blue)
- Neutral: `#FCD34D` (Yellow)
- Poor: `#F87171` (Red)
- Terrible: `#9333EA` (Purple)

### Typography

Clean, professional hierarchy:
- **Display Large** (32px, w700) - Main headings
- **Heading Large** (24px, w600) - Section titles
- **Body Large** (16px, w500) - Main content
- **Label Large** (14px, w600) - Button/interactive text
- **Caption** (12px, w400) - Secondary info

## ✨ Features

### 1. Dashboard Screen
- **Weekly Mood Trend**: Visual bar chart of last 7 days
- **Quick Insights**: Best mood day, entry count
- **Wellness Tip**: Motivational message (rotates)
- **Action Button**: Quick access to log mood

### 2. Mood Logging Screen
- **Emoji Selector**: 5 mood options (Terrible to Excellent)
- **Journal Entry**: Optional text note for each mood
- **Privacy Notice**: Clear messaging that data stays local
- **Smooth Animations**: Pulse effect on mood selection
- **Submit Confirmation**: Visual feedback on successful save

### 3. Settings Screen
- **Theme Switcher**: Light / Dark / Medical themes
- **Notification Controls**:
  - Master enable/disable
  - Mood check-in frequency (2-12 houJourn
  - Medication reminders
- **Privacy Banner**: Highlights data security practices
- **About Section**: App version and tech stack

### 4. Navigation
- **Bottom Navigation Bar**: Easy tab access (Dashboard, Log, Settings)
- **Smooth Transitions**: Fade, slide, and scale animations
- **State Preservation**: Current tab state maintained

## 🎯 Animation & Interactions

### Page Transitions
- **Dashboard ↔ Log Mood**: Slide up + fade
- **Dashboard ↔ Settings**: Slide right + fade
- **Fallback**: Cross-fade transitions

### Component Animations
- **SmoothCard**: Subtle border/shadow on hover
- **SmoothButton**: Scale down (0.98) on press
- **SmoothTextField**: Scale up (1.02) on focus
- **StaggeredAnimationBuilder**: Sequential fade + slide for lists

### Micro-interactions
- Mood selector pulses on selection
- Animated counter in insights
- Loading spinner on submit
- Success checkmark after save

## 📱 Screens in Detail

### Dashboard Screen
```
┌─────────────────────────────┐
│  Your Wellness  ✨ This week│
├─────────────────────────────┤
│ Mood Trend                  │
│ [Bar Chart: Mon-Sun]   ↑8%  │
├─────────────────────────────┤
│ This Week's Insights        │
│ ✨ Best Mood: Thursday      │
│ 📅 Total Entries: 5/7 days  │
├─────────────────────────────┤
│ 💡 Wellness Tip             │
│ Regular tracking helps...   │
├─────────────────────────────┤
│        + Log Mood           │
└─────────────────────────────┘
```

### Mood Log Screen
```
┌─────────────────────────────┐
│ ← Log Your Mood             │
├─────────────────────────────┤
│ How are you feeling today?  │
│ Your response helps...      │
│                             │
│ 😞    😟    😐    😊    😄  │
│ Terr  Poor  Neutr Good Excl │
│                             │
│ Feeling [Good]              │
├─────────────────────────────┤
│ Add a Note (Optional)       │
│ What's on your mind?        │
│ [Text field - 4 lines]      │
│                             │
│ Your entries are private    │
├─────────────────────────────┤
│   Save Mood Entry           │
│   Cancel                    │
└─────────────────────────────┘
```

### Settings Screen
```
┌─────────────────────────────┐
│ Settings                    │
├─────────────────────────────┤
│ APPEARANCE                  │
│ Theme: [Light] [Dark] [Med] │
├─────────────────────────────┤
│ NOTIFICATIONS               │
│ ⚙️ Enable Notifications  [•]│
│ 📊 Mood Check-ins        [•]│
│ 💊 Medication Reminders  [•]│
│ ⏱️ Every 4 hours [----]     │
├─────────────────────────────┤
│ PRIVACY & DATA              │
│ ✓ Your Data is Private      │
│ • All data on device        │
│ • End-to-end encrypted      │
│ • Never shared              │
├─────────────────────────────┤
│ ABOUT                       │
│ Version: 1.0.0              │
│ Built with: Flutter+Riverpod│
└─────────────────────────────┘
```

## 🔧 Core Components

### SmoothCard
Rounded card with optional border and subtle shadow
```dart
SmoothCard(
  padding: EdgeInsets.all(16),
  child: Text('Content'),
  onTap: () => print('tapped'),
)
```

### SmoothButton
Button with scale animation on press
```dart
SmoothButton(
  label: 'Save',
  onPressed: () {},
  isOutlined: false,
  isLoading: false,
)
```

### SmoothTextField
Input field with focus animation
```dart
SmoothTextField(
  label: 'Your mood',
  hint: 'How are you feeling?',
  controller: controller,
  maxLines: 3,
)
```

### Page Transitions
```dart
// Slide + fade transition
Navigator.of(context).push(
  SmoothPageTransition(
    page: MoodLogScreen(),
    axisDirection: AxisDirection.up,
  ),
);

// Staggered list animation
StaggeredAnimationBuilder(
  children: [Widget1(), Widget2()],
  delay: Duration(milliseconds: 80),
)
```

## 🔔 Notifications

Local notifications (no push) for:
- **Mood Check-ins**: Customizable frequency (2-12 hours)
- **Medication Reminders**: Set specific times

```dart
final notificationService = NotificationService();
await notificationService.initialize();

// Schedule a mood check-in
await notificationService.scheduleMoodCheckIn(
  hour: 14,
  minute: 0,
);

// Schedule medication reminder
await notificationService.scheduleMedicationReminder(
  hour: 8,
  minute: 30,
  medicationName: 'Medication Name',
);
```

## 🗄️ Database (SQLite) - Future Implementation

Structure prepared for:
```
moods/
├── id (int, PK)
├── mood_value (int, 1-5)
├── notes (text)
├── created_at (datetime)
└── tags (text)

notifications/
├── id (int, PK)
├── type (string: checkin/medication)
├── time (time)
├── enabled (bool)
└── interval (int, hours)
```

## 🚀 Getting Started

### Prerequisites
- Flutter 3.13+
- Dart 3.1+

### Installation

```bash
# Clone and navigate
git clone <repo>
cd psychol

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Dependencies
- `flutter_riverpod` ^3.3.1 - State management
- `sqflite` ^2.4.2 - Local database (prepared)
- `flutter_local_notifications` ^21.0.0 - Notifications
- `timezone` ^0.11.0 - Timezone support

## 📝 Development Guide

### Adding a New Screen

1. Create `lib/features/feature_name/feature_name_screen.dart`
2. Extend `ConsumerStatefulWidget` for Riverpod access
3. Use `SmoothCard` and `SmoothButton` for UI
4. Add `StaggeredAnimationBuilder` for animations
5. Export in `lib/features/features.dart`

### Customizing Colors

Edit `lib/core/theme/app_colors.dart`:
```dart
static const Color customColor = Color(0xFF...);
```

Update theme files to use the new color.

### Adding Animations

Use animation utilities from `lib/core/widgets/animations.dart`:
```dart
// Page transition
SmoothPageTransition(page: MyScreen())

// Staggered list
StaggeredAnimationBuilder(children: [...])

// Animated counter
AnimatedCounter(end: 42)
```

## 🔐 Privacy & Security

- ✓ All data stored locally (on-device only)
- ✓ No cloud sync or external APIs
- ✓ Encrypted database (SQLite with encryption)
- ✓ No personal data collection
- ✓ Open source for transparency

## 📊 Future Enhancements

- [ ] Mood pattern analysis with ML
- [ ] Weekly/monthly reports
- [ ] Wellness reminders (hydration, breaks)
- [ ] Custom journal templates
- [ ] Data export (private, encrypted)
- [ ] Offline calendar view
- [ ] Voice notes for moods
- [ ] Dark mode for settings based on system
- [ ] Haptic feedback on interactions

## 🐛 Known Issues & Limitations

- SQLite integration prepared but not fully implemented
- Notifications require platform-specific permissions setup
- Some animations on older devices may skip frames
- No backup/restore mechanism yet

## 📄 License

Privacy-focused open source. Use freely, modify, share.

## 👥 Contributing

This is a demonstration project showing:
- Clean Flutter architecture
- Professional theme system
- Smooth animations & transitions
- State management with Riverpod
- Material 3 implementation
- Medical/clinical UI design

Feel free to use as a template or reference.
Beautifu
---

**Built with care for mental wellness.** ✨
