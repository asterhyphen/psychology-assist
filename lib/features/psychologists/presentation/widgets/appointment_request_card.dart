part of '../screens/psychologists_screen.dart';

class _AppointmentRequestCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onApprove;
  final VoidCallback onPrescribe;

  const _AppointmentRequestCard({
    required this.appointment,
    required this.onApprove,
    required this.onPrescribe,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.warning.withValues(alpha: 0.10),
      borderColor: AppColors.warning.withValues(alpha: 0.30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.warning,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: AppTypography.labelLarge,
                    ),
                    Text(
                      '${appointment.type} - ${appointment.startsAt.day}/${appointment.startsAt.month}/${appointment.startsAt.year} at ${appointment.startsAt.hour}:${appointment.startsAt.minute.toString().padLeft(2, '0')}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (appointment.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Note: ${appointment.note}',
              style: AppTypography.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onApprove,
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Approve'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
              ),
              OutlinedButton.icon(
                onPressed: onPrescribe,
                icon: const Icon(Icons.assignment, size: 16),
                label: const Text('Prescribe'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
