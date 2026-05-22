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
    return SmoothCard(
      onTap: onTap,
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      backgroundColor: selected ? AppColors.neonViolet : Colors.white,
      borderColor: selected ? const Color(0xFFB7C97B) : AppColors.lightBorder,
      elevation: selected ? 18 : 0,
      child: Column(
        children: [
          Icon(
            icon,
            color: selected ? Colors.white : AppColors.neonViolet,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              color: selected ? Colors.white : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }
}
