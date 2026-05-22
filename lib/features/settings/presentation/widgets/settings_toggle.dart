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
                        ? Colors.black87
                        : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.labelLarge.copyWith(
                        color: enabled
                            ? theme.textTheme.labelLarge?.color
                            : theme.textTheme.labelLarge?.color?.withValues(
                                alpha: 0.5,
                              ),
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
                        ? theme.textTheme.bodySmall?.color
                        : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: enabled ? value : false,
          onChanged: enabled ? onChanged : null,
          activeThumbColor: Colors.black87,
        ),
      ],
    );
  }
}

/// Settings info row
