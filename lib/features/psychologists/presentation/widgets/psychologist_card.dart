part of '../screens/psychologists_screen.dart';

class _PsychologistCard extends ConsumerWidget {
  final AppPsychologist psychologist;

  const _PsychologistCard({required this.psychologist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SmoothCard(
      borderRadius: 18,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.72),
      borderColor: AppColors.neonViolet.withOpacity(0.18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.neonViolet,
            child: Icon(Icons.psychology_alt_outlined, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(psychologist.name, style: AppTypography.labelLarge)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(psychologist.rating.toStringAsFixed(1), style: AppTypography.labelMedium),
                      ],
                    ),
                  ],
                ),
                if (psychologist.rating >= 4.8) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('🌟 Highly Recommended', style: AppTypography.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                  ),
                ],
                const SizedBox(height: 4),
                Text(psychologist.specialty, style: AppTypography.bodySmall),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: AppColors.neonViolet,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        psychologist.availability,
                        style: AppTypography.caption,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('Book appointment'),
                    onPressed: () {
                      ref.read(appSessionProvider.notifier).updateProfile(
                            AppProfile(
                              role: UserRole.patient,
                              name:
                                  ref.read(appSessionProvider).profile?.name ??
                                      'Patient',
                              email:
                                  ref.read(appSessionProvider).profile?.email ??
                                      'patient@example.com',
                              psychologistEmail: psychologist.email,
                            ),
                          );
                      AppSnackBar.showSuccess(
                        context,
                        title: 'Psychologist selected',
                        message: 'Go to Appointments to book a session.',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
