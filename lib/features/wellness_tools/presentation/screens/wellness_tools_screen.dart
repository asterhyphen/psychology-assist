import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../breathing_exercise/presentation/screens/breathing_exercise_screen.dart';
import '../../../journaling/presentation/screens/typing_test_screen.dart';
import '../../../mood_log/presentation/screens/mood_log_screen.dart';

class WellnessToolsScreen extends StatelessWidget {
  const WellnessToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Tools'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            Text(
              'Tools',
              style: AppTypography.headingMedium.copyWith(
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check in, reset your breathing, or run a quick typing stress test.',
              style: AppTypography.bodySmall.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 18),
            _WellnessToolTile(
              icon: Icons.mood_outlined,
              title: 'Log mood',
              subtitle:
                  'Save a quick emotional check-in with an optional note.',
              color: scheme.primary,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MoodLogScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _WellnessToolTile(
              icon: Icons.air,
              title: 'Breathing exercise',
              subtitle: 'Use a guided breathing cycle for a calmer reset.',
              color: scheme.tertiary,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const BreathingExerciseScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _WellnessToolTile(
              icon: Icons.keyboard_outlined,
              title: 'Typing stress test',
              subtitle: 'Measure typing flow and update your drift indicator.',
              color: scheme.secondary,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const TypingTestScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WellnessToolTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _WellnessToolTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surface.withValues(alpha: 0.86),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelLarge.copyWith(
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: scheme.onSurface.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
