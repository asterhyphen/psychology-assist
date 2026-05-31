import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'app/theme_provider.dart';
import 'app/app_state.dart';
import 'core/services/app_session_store.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_error_view.dart';
import 'app/navigation/app_router.dart';
import 'features/app_lock/presentation/screens/app_lock_gate.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'app/home_screen.dart'; // To access selectedTabProvider

Future<void> main() async {
  await runZonedGuarded<Future<void>>(_startApp, _reportUncaughtError);
}

Future<void> _startApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installErrorHandlers();
  await dotenv.load(fileName: '.env', isOptional: true);

  const store = AppSessionStore();
  final initialSession = await _loadInitialSession(store);
  final notificationService = NotificationService();
  try {
    await notificationService.initialize();
    await notificationService.requestPermissions();
  } catch (error, stackTrace) {
    _reportUncaughtError(error, stackTrace);
  }

  runApp(
    ProviderScope(
      overrides: [
        appSessionStoreProvider.overrideWithValue(store),
        initialAppSessionProvider.overrideWithValue(initialSession),
      ],
      child: const MyApp(),
    ),
  );
}

void _installErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _reportUncaughtError(details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    _reportUncaughtError(error, stackTrace);
    return true;
  };

  ErrorWidget.builder = (details) => AppErrorView(details: details);
}

Future<AppSession> _loadInitialSession(AppSessionStore store) async {
  try {
    final savedSession = await store.load();
    if (savedSession == null) {
      final now = DateTime.now();
      final seededSession = AppSession(
        appointments: [
          Appointment(
            psychologistEmail: demoPsychologistEmail,
            psychologistName: 'Dr. Aisha Mehta',
            patientName: 'Alex Morgan',
            patientEmail: 'alex.m@example.com',
            startsAt: now.subtract(const Duration(hours: 2)),
            type: 'Therapy',
            note: 'Burnout Risk, Sleep Issues, High Stress',
            status: AppointmentStatus.confirmed,
            driftIndex: 0.82,
          ),
          Appointment(
            psychologistEmail: demoPsychologistEmail,
            psychologistName: 'Dr. Aisha Mehta',
            patientName: 'Casey Kim',
            patientEmail: 'casey.k@example.com',
            startsAt: now.subtract(const Duration(hours: 5)),
            type: 'Consultation',
            note: 'Work Stress, Fatigue',
            status: AppointmentStatus.confirmed,
            driftIndex: 0.61,
          ),
          Appointment(
            psychologistEmail: demoPsychologistEmail,
            psychologistName: 'Dr. Aisha Mehta',
            patientName: 'Jordan Lee',
            patientEmail: 'jordan.l@example.com',
            startsAt: now.subtract(const Duration(days: 1)),
            type: 'CBT Session',
            note: 'Anxiety, Rumination',
            status: AppointmentStatus.confirmed,
            driftIndex: 0.54,
          ),
          Appointment(
            psychologistEmail: demoPsychologistEmail,
            psychologistName: 'Dr. Aisha Mehta',
            patientName: 'Taylor Pham',
            patientEmail: 'taylor.p@example.com',
            startsAt: now.subtract(const Duration(minutes: 30)),
            type: 'General Check-up',
            note: 'Stable, Positive',
            status: AppointmentStatus.confirmed,
            driftIndex: 0.24,
          ),
          Appointment(
            psychologistEmail: demoPsychologistEmail,
            psychologistName: 'Dr. Aisha Mehta',
            patientName: 'Sam Rivera',
            patientEmail: 'sam.r@example.com',
            startsAt: now.subtract(const Duration(hours: 3)),
            type: 'Support Group',
            note: 'Stable, Consistent',
            status: AppointmentStatus.confirmed,
            driftIndex: 0.18,
          ),
        ],
        journalEntries: [
          JournalEntry(
            createdAt: now.subtract(const Duration(hours: 2)),
            content: 'Lately I feel like I am running on empty constantly. Sleep is elusive and my brain won\'t turn off at 3 AM.',
            summary: 'Feel like running on empty constantly. Sleep is elusive and mind racing at 3 AM.',
            sharedWithPsychologist: true,
          ),
          JournalEntry(
            createdAt: now.subtract(const Duration(days: 1)),
            content: 'Overthinking everything Jordan said today. Felt my heart racing at my desk for no good reason. Tried a quick breathing exercise.',
            summary: 'Overthinking social interactions. Felt chest tightness at desk and tried breathing exercise.',
            sharedWithPsychologist: true,
          ),
        ],
      );
      await store.save(seededSession);
      return seededSession;
    }
    return AppSession.fromJson(savedSession);
  } catch (error, stackTrace) {
    _reportUncaughtError(error, stackTrace);
    await store.clear();
    return const AppSession();
  }
}

void _reportUncaughtError(Object error, StackTrace? stackTrace) {
  debugPrint('Uncaught app error: $error');
  if (stackTrace != null) {
    debugPrintStack(stackTrace: stackTrace);
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      _appLinks = AppLinks();

      // Handle initial link if app was closed
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }

      // Handle link when app is in background/foreground
      _appLinks.uriLinkStream.listen(
        _handleDeepLink,
        onError: (Object error, StackTrace stackTrace) {
          _reportUncaughtError(error, stackTrace);
        },
      );
    } catch (error, stackTrace) {
      _reportUncaughtError(error, stackTrace);
    }
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'calmora' && uri.host == 'feature') {
      final feature = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      if (feature == 'mood') {
        ref.read(selectedTabProvider.notifier).state = 1;
      } else if (feature == 'journal') {
        ref.read(selectedTabProvider.notifier).state = 2;
      } else if (feature == 'appointment') {
        ref.read(selectedTabProvider.notifier).state = 3;
      }
      // For SOS, you might want to show an alert or trigger a specific SOS provider
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final session = ref.watch(appSessionProvider);

    // Map AppThemeMode to ThemeData
    ThemeData getTheme(AppThemeMode mode) {
      switch (mode) {
        case AppThemeMode.light:
          return AppThemes.lightTheme;
        case AppThemeMode.dark:
          return AppThemes.darkTheme;
        case AppThemeMode.journal:
          return AppThemes.journalTheme;
      }
    }

    return MaterialApp(
      title: 'Calmora',
      theme: getTheme(themeMode),
      darkTheme: AppThemes.darkTheme,
      themeMode:
          themeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        child: !session.onboardingComplete
            ? const OnboardingScreen()
            : const AppLockGate(),
      ),
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
