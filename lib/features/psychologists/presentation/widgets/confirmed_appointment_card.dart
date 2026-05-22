part of '../screens/psychologists_screen.dart';

class _ConfirmedAppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onPrescribe;
  final VoidCallback onMessage;

  const _ConfirmedAppointmentCard({
    required this.appointment,
    required this.onPrescribe,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.success.withOpacity(0.1),
      borderColor: AppColors.success.withOpacity(0.3),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.success,
            child: const Icon(Icons.check_circle, color: Colors.white),
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
                if (appointment.note.isNotEmpty)
                  Text(
                    'Note: ${appointment.note}',
                    style: AppTypography.bodySmall.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: onPrescribe,
                      icon: const Icon(Icons.assignment, size: 16),
                      label: const Text('Prescribe'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: onMessage,
                      icon: const Icon(Icons.chat_bubble, size: 16),
                      label: const Text('Message'),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
