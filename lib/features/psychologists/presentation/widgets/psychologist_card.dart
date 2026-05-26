part of '../screens/psychologists_screen.dart';

class _PsychologistCard extends ConsumerWidget {
  final AppPsychologist psychologist;

  const _PsychologistCard({required this.psychologist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SmoothCard(
      borderRadius: 18,
      backgroundColor: scheme.surface.withValues(alpha: 0.72),
      borderColor: scheme.primary.withValues(alpha: 0.18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: scheme.primary,
            child: Icon(Icons.psychology_alt_outlined, color: scheme.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        psychologist.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          psychologist.rating.toStringAsFixed(1),
                          style: theme.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                if (psychologist.rating >= 4.8) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Highly recommended',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  psychologist.specialty,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.mutedText,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: scheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        psychologist.availability,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.mutedText,
                        ),
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
                      final currentProfile =
                          ref.read(appSessionProvider).profile;
                      ref.read(appSessionProvider.notifier).updateProfile(
                            AppProfile(
                              role: UserRole.patient,
                              name: currentProfile?.name ?? 'Patient',
                              email:
                                  currentProfile?.email ?? 'patient@example.com',
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
