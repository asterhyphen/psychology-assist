import 'package:flutter/material.dart';
import '../../../../core/widgets/smooth_widgets.dart';
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
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          children: [
            Text(
              'Tools',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check in, reset your breathing, or run a quick typing stress test.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.66),
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
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
    final isDark = theme.brightness == Brightness.dark;

    return SmoothCard(
      onTap: onTap,
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      backgroundColor: isDark
          ? scheme.surface.withValues(alpha: 0.68)
          : Colors.white.withOpacity(0.92),
      borderColor: color.withValues(alpha: 0.2),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.22),
                  color.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: 0.28),
                width: 1.0,
              ),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.58),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: scheme.onSurface.withValues(alpha: 0.38),
          ),
        ],
      ),
    );
  }
}
