part of '../screens/settings_screen.dart';

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: enabled
                        ? (value ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant)
                        : theme.textTheme.bodySmall?.color?.withOpacity(0.4),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.labelLarge.copyWith(
                        color: enabled
                            ? theme.textTheme.labelLarge?.color
                            : theme.textTheme.labelLarge?.color?.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: enabled
                        ? theme.textTheme.bodySmall?.color?.withOpacity(0.7)
                        : theme.textTheme.bodySmall?.color?.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: enabled ? value : false,
          onChanged: enabled ? onChanged : null,
          activeColor: theme.colorScheme.primary,
          activeTrackColor: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ],
    );
  }
}


/// Settings info row
