import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/smooth_widgets.dart';
import '../../../psychologists/presentation/screens/psychologists_screen.dart';
import '../../../chat/presentation/screens/chat_screen.dart';



part '../widgets/appointments_hero.dart';
part '../widgets/picker_chip.dart';
part '../widgets/appointment_card.dart';
part '../widgets/prescription_card.dart';
part '../widgets/empty_appointments.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _type = 'Video session';

  @override
  void dispose() {
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = ref.read(appSessionProvider).profile;
    final linkedEmail = profile?.psychologistEmail ?? demoPsychologistEmail;
    if (_emailController.text.isEmpty) {
      _emailController.text = linkedEmail;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _bookAppointment() async {
    final profile = ref.read(appSessionProvider).profile;
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      _showMessage('Enter your psychologist email.');
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      _showMessage('Choose date and time.');
      return;
    }

    final startsAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    if (startsAt.isBefore(DateTime.now())) {
      _showMessage('Choose a future time.');
      return;
    }

    final psychologist = demoPsychologists.firstWhere(
      (item) => item.email == email,
      orElse: () => AppPsychologist(
        name: 'Linked psychologist',
        email: email,
        specialty: 'Care provider',
        availability: 'By request',
      ),
    );
    final confirmed = await _confirmAppointment(psychologist, startsAt);
    if (!confirmed) {
      return;
    }

    ref.read(appSessionProvider.notifier).addAppointment(
          Appointment(
            psychologistEmail: email,
            psychologistName: psychologist.name,
            patientName: profile?.name ?? 'Patient',
            patientEmail: profile?.email,
            startsAt: startsAt,
            type: _type,
            note: _noteController.text.trim(),
            confirmed: false,
            driftIndex: profile?.driftIndex ?? 0.0,
          ),
        );

    _noteController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
    });
    _showMessage('Appointment request sent.', success: true);
  }

  Future<bool> _confirmAppointment(
    AppPsychologist psychologist,
    DateTime startsAt,
  ) async {
    final minutes = startsAt.minute.toString().padLeft(2, '0');
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm appointment'),
            content: Text(
              '${psychologist.name}\n'
              '${startsAt.day}/${startsAt.month}/${startsAt.year} at '
              '${startsAt.hour}:$minutes\n\n'
              'Your psychologist can approve this from their patient dashboard.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.check),
                label: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showMessage(String message, {bool success = false}) {
    if (success) {
      AppSnackBar.showSuccess(context, message: message);
    } else {
      AppSnackBar.showInfo(context, message: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final profile = session.profile;
    final isPsychologist = profile?.role == UserRole.psychologist;
    final appointments = session.appointments
        .where((appointment) => appointment.startsAt.isAfter(DateTime.now()))
        .toList()
        ..sort((a, b) => b.driftIndex.compareTo(a.driftIndex));

    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                  child: _AppointmentsHero(
                    profile: profile,
                    isPsychologist: isPsychologist,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
                  child: SmoothCard(
                    borderRadius: 22,
                    elevation: 16,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.72),
                    borderColor: AppColors.neonViolet.withValues(alpha: 0.2),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Book an appointment',
                          style: AppTypography.headingSmall,
                        ),
                        const SizedBox(height: 16),
                        SmoothTextField(
                          label: 'Psychologist email',
                          hint: 'doctor@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: demoPsychologists
                              .map(
                                (psychologist) => ChoiceChip(
                                  selected: _emailController.text ==
                                      psychologist.email,
                                  avatar: const Icon(
                                    Icons.psychology_alt_outlined,
                                    size: 18,
                                  ),
                                  label: Text(psychologist.name),
                                  onSelected: (_) {
                                    setState(() {
                                      _emailController.text =
                                          psychologist.email;
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        if (appointments.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Only one appointment can be active. Booking a new one replaces the current future appointment.',
                            style: AppTypography.bodySmall.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _PickerChip(
                              icon: Icons.calendar_month,
                              label: _selectedDate == null
                                  ? 'Date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}',
                              onTap: _pickDate,
                            ),
                            _PickerChip(
                              icon: Icons.schedule,
                              label: _selectedTime == null
                                  ? 'Time'
                                  : _selectedTime!.format(context),
                              onTap: _pickTime,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: _type,
                          decoration: const InputDecoration(
                            labelText: 'Session type',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Video session',
                              child: Text('Video session'),
                            ),
                            DropdownMenuItem(
                              value: 'In-person visit',
                              child: Text('In-person visit'),
                            ),
                            DropdownMenuItem(
                              value: 'Follow-up',
                              child: Text('Follow-up'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _type = value);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        SmoothTextField(
                          label: 'Note',
                          hint: 'Anything you want to discuss?',
                          controller: _noteController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: SmoothButton(
                            label: 'Confirm Appointment',
                            icon: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                            backgroundColor: AppColors.neonViolet,
                            onPressed: _bookAppointment,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 12, 18, 8),
                  child: Text(
                    'Future appointments',
                    style: AppTypography.headingSmall,
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: appointments.isEmpty ? 1 : appointments.length,
                itemBuilder: (context, index) {
                  if (appointments.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.fromLTRB(18, 0, 18, 24),
                      child: _EmptyAppointments(),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                    child: _AppointmentCard(
                      appointment: appointments[index],
                      isPsychologist: profile?.role == UserRole.psychologist,
                    ),
                  );
                },
              ),
              if (profile?.role == UserRole.patient) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(18, 12, 18, 8),
                    child: Text(
                      'Your prescriptions',
                      style: AppTypography.headingSmall,
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: session.prescriptions
                      .where((prescription) =>
                          prescription.patientEmail == profile?.email ||
                          prescription.patientName == profile?.name)
                      .length,
                  itemBuilder: (context, index) {
                    final prescription = session.prescriptions
                        .where((prescription) =>
                            prescription.patientEmail == profile?.email ||
                            prescription.patientName == profile?.name)
                        .toList()[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                      child: _PrescriptionCard(prescription: prescription),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
