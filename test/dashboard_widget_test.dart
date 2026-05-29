import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psychol/app/app_state.dart';
import 'package:psychol/app/home_screen.dart';
import 'package:psychol/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:psychol/features/breathing_exercise/presentation/screens/breathing_exercise_screen.dart';

void main() {
  testWidgets('DashboardScreen renders without crashing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: DashboardScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('HomeScreen renders without crashing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('HomeScreen renders with populated Patient session without crashing', (tester) async {
    final mockSession = AppSession(
      onboardingComplete: true,
      profile: const AppProfile(
        role: UserRole.patient,
        name: 'Jane Doe',
        email: 'jane.doe@example.com',
        driftIndex: 0.42,
      ),
      moodEntries: [
        MoodEntry(
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          value: 4,
          label: 'Good',
          note: 'Feeling positive',
        ),
        MoodEntry(
          createdAt: DateTime.now(),
          value: 3,
          label: 'Neutral',
          note: 'A bit tired',
        ),
      ],
      appointments: [
        Appointment(
          psychologistEmail: 'dr.aisha@example.com',
          psychologistName: 'Dr. Aisha Mehta',
          patientName: 'Jane Doe',
          patientEmail: 'jane.doe@example.com',
          startsAt: DateTime.now().add(const Duration(days: 1)),
          type: 'Video Session',
          note: 'Weekly check-in',
        ),
      ],
      prescriptions: [
        Prescription(
          id: 'rx-1',
          patientName: 'Jane Doe',
          patientEmail: 'jane.doe@example.com',
          prescribedByName: 'Dr. Aisha Mehta',
          prescribedByEmail: 'dr.aisha@example.com',
          medicines: ['Sertraline 50mg'],
          reminderTimes: [const MedicationTime(hour: 8, minute: 30)],
          note: 'Take after breakfast',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialAppSessionProvider.overrideWithValue(mockSession),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('BreathingExerciseScreen renders without crashing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BreathingExerciseScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(BreathingExerciseScreen), findsOneWidget);
  });
}
