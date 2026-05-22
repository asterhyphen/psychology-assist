part of '../screens/onboarding_screen.dart';

class _NeonHeader extends StatelessWidget {
  final ThemeData theme;

  const _NeonHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppColors.neonViolet, AppColors.neonPink],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonViolet.withOpacity(0.35),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
          const SizedBox(height: 20),
          Text(
            'Welcome to Calmora',
            style: AppTypography.displayMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'A private mental wellness space for patients and psychologists.',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.86),
            ),
          ),
        ],
      ),
    );
  }
}
