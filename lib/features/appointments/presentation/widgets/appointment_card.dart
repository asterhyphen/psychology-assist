part of '../screens/appointments_screen.dart';

class _AppointmentCard extends ConsumerWidget {
  final Appointment appointment;
  final bool isPsychologist;

  const _AppointmentCard({
    required this.appointment,
    this.isPsychologist = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = appointment.startsAt;
    final minutes = date.minute.toString().padLeft(2, '0');
    final baseColor = Color.lerp(const Color(0xFFB7C97B), Colors.red, appointment.driftIndex) ?? const Color(0xFFB7C97B);
    return GestureDetector(
      onTap: () => _showAppointmentDetails(context, ref),
      child: SmoothCard(
        borderRadius: 20,
        backgroundColor:
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
        borderColor: baseColor.withValues(alpha: 0.5),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: baseColor.withValues(alpha: 0.16),
              ),
              child: Icon(Icons.video_call, color: baseColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${appointment.type} with ${isPsychologist ? appointment.patientName : appointment.psychologistName}',
                    style: AppTypography.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}/${date.month}/${date.year} at ${date.hour}:$minutes',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPsychologist
                        ? (appointment.patientEmail ?? 'Unknown')
                        : appointment.psychologistEmail,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.neonViolet,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        appointment.confirmed
                            ? Icons.verified_outlined
                            : Icons.pending_actions_outlined,
                        size: 14,
                        color: appointment.confirmed
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appointment.confirmed ? 'Confirmed' : 'Requested',
                        style: AppTypography.caption.copyWith(
                          color: appointment.confirmed
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.neonViolet),
          ],
        ),
      ),
    );
  }

  void _showAppointmentDetails(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${appointment.type} Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'With: ${isPsychologist ? appointment.patientName : appointment.psychologistName}',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${appointment.startsAt.day}/${appointment.startsAt.month}/${appointment.startsAt.year}',
                style: AppTypography.bodyMedium,
              ),
              Text(
                'Time: ${appointment.startsAt.hour.toString().padLeft(2, '0')}:${appointment.startsAt.minute.toString().padLeft(2, '0')}',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${appointment.status.name.toUpperCase()}',
                style: AppTypography.bodyMedium.copyWith(
                  color: appointment.status == AppointmentStatus.confirmed ||
                          appointment.status == AppointmentStatus.completed
                      ? AppColors.success
                      : appointment.status == AppointmentStatus.cancelled
                          ? Colors.red
                          : AppColors.warning,
                ),
              ),
              if (appointment.note.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Notes:',
                  style: AppTypography.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.note,
                  style: AppTypography.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (isPsychologist && appointment.status == AppointmentStatus.pending)
            TextButton(
              onPressed: () {
                ref
                    .read(appSessionProvider.notifier)
                    .approveAppointment(appointment);
                Navigator.of(context).pop();
              },
              child: const Text('Approve'),
            ),
          if (isPsychologist && appointment.status == AppointmentStatus.confirmed)
            TextButton(
              onPressed: () {
                ref
                    .read(appSessionProvider.notifier)
                    .completeAppointment(appointment);
                Navigator.of(context).pop();
                AppSnackBar.showSuccess(context, message: 'Appointment marked as completed.');
              },
              child: const Text('Complete Session'),
            ),
          if (!isPsychologist &&
              appointment.status != AppointmentStatus.cancelled &&
              appointment.status != AppointmentStatus.completed)
            TextButton(
              onPressed: () {
                final timeDiff = appointment.startsAt.difference(DateTime.now());
                final isLate = timeDiff.inHours < 24;
                ref.read(appSessionProvider.notifier).cancelAppointment(appointment);
                Navigator.of(context).pop();
                if (isLate) {
                  AppSnackBar.showInfo(context,
                      title: 'Warning',
                      message: 'Cancelled with <24h notice. Drift Index increased.');
                } else {
                  AppSnackBar.showSuccess(context,
                      message: 'Appointment cancelled successfully.');
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cancel Appointment'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
