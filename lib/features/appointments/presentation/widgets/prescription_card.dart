part of '../screens/appointments_screen.dart';

class _PrescriptionCard extends ConsumerWidget {
  final Prescription prescription;

  const _PrescriptionCard({required this.prescription});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showPrescriptionDetails(context, ref),
      child: SmoothCard(
        borderRadius: 20,
        backgroundColor:
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
        borderColor: AppColors.success.withValues(alpha: 0.3),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: 0.16),
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From ${prescription.prescribedByName}',
                    style: AppTypography.labelLarge,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prescription.medicines.take(2).join(', ') +
                        (prescription.medicines.length > 2 ? '...' : ''),
                    style: AppTypography.bodySmall,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Issued ${prescription.createdAt.day}/${prescription.createdAt.month}/${prescription.createdAt.year}',
                    style: AppTypography.caption,
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  void _showPrescriptionDetails(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prescription Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Prescribed by: ${prescription.prescribedByName}',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Patient: ${prescription.patientName}',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Medicines & Log Adherence:',
                style: AppTypography.labelMedium,
              ),
              const SizedBox(height: 4),
              ...prescription.medicines.map((medicine) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.medication,
                            size: 16, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(medicine, style: AppTypography.bodyMedium),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                          tooltip: 'Log taken',
                          onPressed: () {
                            ref.read(appSessionProvider.notifier).logMedicationAdherence(
                              AdherenceRecord(
                                timestamp: DateTime.now(),
                                medicineName: medicine,
                                taken: true,
                              ),
                            );
                            Navigator.of(context).pop();
                            AppSnackBar.showSuccess(context, message: 'Logged: Took $medicine');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.highlight_off, color: Colors.red, size: 20),
                          tooltip: 'Log missed',
                          onPressed: () {
                            ref.read(appSessionProvider.notifier).logMedicationAdherence(
                              AdherenceRecord(
                                timestamp: DateTime.now(),
                                medicineName: medicine,
                                taken: false,
                              ),
                            );
                            Navigator.of(context).pop();
                            AppSnackBar.showInfo(context, title: 'Missed Medication', message: 'Logged: Missed $medicine');
                          },
                        ),
                      ],
                    ),
                  )),
              if (prescription.note.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Notes:',
                  style: AppTypography.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  prescription.note,
                  style: AppTypography.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Prescribed on: ${prescription.createdAt.day}/${prescription.createdAt.month}/${prescription.createdAt.year} at ${prescription.createdAt.hour.toString().padLeft(2, '0')}:${prescription.createdAt.minute.toString().padLeft(2, '0')}',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
