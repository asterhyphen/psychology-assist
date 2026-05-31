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
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary.withValues(alpha: isDark ? 0.16 : 0.08)
              : isDark
                  ? Colors.white.withOpacity(0.02)
                  : Colors.black.withOpacity(0.02),
          border: Border.all(
            color: isSelected
                ? scheme.primary
                : theme.dividerColor.withValues(alpha: isDark ? 0.08 : 0.24),
            width: isSelected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.18),
                    blurRadius: 12,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? scheme.primary : scheme.onSurface.withValues(alpha: 0.58),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? scheme.primary : scheme.onSurface.withValues(alpha: 0.58),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
