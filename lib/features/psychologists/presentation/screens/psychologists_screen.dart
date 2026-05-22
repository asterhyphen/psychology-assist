import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/smooth_widgets.dart';
import '../../../chat/presentation/screens/chat_screen.dart';

part '../widgets/psychologist_dashboard.dart';
part '../widgets/summary_card.dart';
part '../widgets/appointment_request_card.dart';
part '../widgets/confirmed_appointment_card.dart';
part '../widgets/psychologist_card.dart';

class PsychologistsScreen extends ConsumerWidget {
  const PsychologistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final profile = session.profile;
    final isPsychologist = profile?.role == UserRole.psychologist;

    if (isPsychologist) {
      return const _PsychologistDashboard();
    }

    final psychologists = _dynamicPsychologists(profile);

    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            children: [
              Text(
                'Psychologists',
                style: AppTypography.headingLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a care provider, then book from the appointments tab.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.lightSubtext,
                ),
              ),
              const SizedBox(height: 18),
              ...psychologists.map(
                (psychologist) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PsychologistCard(psychologist: psychologist),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<AppPsychologist> _dynamicPsychologists(AppProfile? profile) {
    final linkedEmail = profile?.psychologistEmail;
    if (linkedEmail == null ||
        demoPsychologists.any((item) => item.email == linkedEmail)) {
      return demoPsychologists;
    }
    return [
      AppPsychologist(
        name: 'Linked psychologist',
        email: linkedEmail,
        specialty: 'Your saved provider',
        availability: 'By appointment',
      ),
      ...demoPsychologists,
    ];
  }
}
