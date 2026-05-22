part of '../screens/appointments_screen.dart';

class _PickerChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, color: AppColors.neonViolet, size: 18),
      label: Text(label),
      backgroundColor: AppColors.neonViolet.withValues(alpha: 0.08),
      side: BorderSide(color: AppColors.neonViolet.withValues(alpha: 0.24)),
      onPressed: onTap,
    );
  }
}
