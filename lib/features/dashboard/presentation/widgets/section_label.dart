part of '../screens/dashboard_screen.dart';

class _SectionLabel extends StatelessWidget {
  final String title;
  final ColorScheme scheme;

  const _SectionLabel({required this.title, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.56),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Individual mood bar for the chart
