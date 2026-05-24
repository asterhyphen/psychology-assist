import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
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
      return const AppSession();
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
