part of '../screens/appointments_screen.dart';

class _EmptyAppointments extends StatelessWidget {
  const _EmptyAppointments();

  @override
  Widget build(BuildContext context) {
    return SmoothCard(
      borderRadius: 20,
      backgroundColor:
          Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
      padding: const EdgeInsets.all(20),
      child: const Row(
        children: [
          Icon(Icons.calendar_today_outlined, color: AppColors.neonViolet),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No future appointments yet. Your next sessions will appear here.',
              style: AppTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
