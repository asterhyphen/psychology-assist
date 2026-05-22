part of '../screens/settings_screen.dart';

class _SettingsInfo extends StatelessWidget {
  final String label;
  final String value;

  const _SettingsInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: theme.textTheme.labelLarge?.color,
          ),
        ),
      ],
    );
  }
}
