part of '../screens/dashboard_screen.dart';

class _SectionLabel extends StatelessWidget {
  final String title;
  final ColorScheme scheme;

  const _SectionLabel({required this.title, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.labelLarge.copyWith(
        color: scheme.onSurface.withValues(alpha: 0.5),
        letterSpacing: 0.8,
        fontSize: 12,
      ),
    );
  }
}

/// Individual mood bar for the chart
