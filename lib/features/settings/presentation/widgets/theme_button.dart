part of '../screens/settings_screen.dart';

class _ThemeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? scheme.primary.withValues(alpha: 0.16) : Colors.transparent,
          border: Border.all(
            color: isSelected ? scheme.primary : theme.dividerColor.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.24),
                    blurRadius: 10,
                    spreadRadius: 0.2,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? scheme.primary : theme.textTheme.bodySmall?.color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? scheme.primary : theme.textTheme.bodySmall?.color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings toggle
