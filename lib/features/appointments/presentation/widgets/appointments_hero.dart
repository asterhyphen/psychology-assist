part of '../screens/appointments_screen.dart';

class _AppointmentsHero extends StatelessWidget {
  final AppProfile? profile;
  final bool isPsychologist;

  const _AppointmentsHero({this.profile, this.isPsychologist = false});

  @override
  Widget build(BuildContext context) {
    final linkedEmail = profile?.psychologistEmail ?? demoPsychologistEmail;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppColors.deepViolet, AppColors.neonViolet],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonViolet.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.event_available, color: Colors.white, size: 32),
          const SizedBox(height: 18),
          Text(
            'Care, scheduled beautifully',
            style: AppTypography.headingLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            isPsychologist
                ? 'Your patient sessions'
                : 'Linked psychologist: $linkedEmail',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
          if (!isPsychologist) ...[
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PsychologistsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.search, size: 16),
                  label: const Text('Find a Psychologist'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side:
                        BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ),
                if (profile?.hasPsychologist == true)
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ChatScreen(
                            otherUserId: profile!.psychologistEmail!,
                            otherUserName: 'Your Therapist',
                            currentUserId: 'patient', // Demo current user id
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble, size: 16),
                    label: const Text('Message Therapist'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.deepViolet,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
