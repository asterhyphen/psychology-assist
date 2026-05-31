part of '../screens/onboarding_screen.dart';

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.selected,
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      gradient: selected
          ? const LinearGradient(
              colors: [Color(0xFF0FA58A), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      backgroundColor: selected
          ? null
          : isDark
              ? scheme.surface.withValues(alpha: 0.5)
              : Colors.white,
      borderColor: selected
          ? Colors.white.withOpacity(0.4)
          : scheme.primary.withValues(alpha: 0.16),
      elevation: selected ? 14 : 0,
      child: Column(
        children: [
          Icon(
            icon,
            color: selected ? Colors.white : scheme.primary,
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              color: selected ? Colors.white : scheme.onSurface,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
