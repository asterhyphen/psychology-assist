part of '../screens/psychologists_screen.dart';

class _PsychologistDashboard extends ConsumerWidget {
  const _PsychologistDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final email = session.profile?.email ?? demoPsychologistEmail;
    final pendingAppointments = session.appointments
        .where((appointment) =>
            appointment.psychologistEmail == email && !appointment.confirmed)
        .toList();
    final confirmedAppointments = session.appointments
        .where((appointment) =>
            appointment.psychologistEmail == email && appointment.confirmed)
        .toList();
    final prescriptions = session.prescriptions
        .where((prescription) => prescription.prescribedByEmail == email)
        .toList();
    final sharedJournals = session.journalEntries
        .where((entry) => entry.sharedWithPsychologist)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dr. Panipuri Dashboard'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(appSessionProvider.notifier).updateProfile(
                    AppProfile(
                      role: UserRole.patient,
                      name: 'Patient',
                      email: 'patient@example.com',
                      psychologistEmail: demoPsychologistEmail,
                    ),
                  );
              AppSnackBar.showInfo(
                context,
                title: 'Switched to Patient',
                message: 'You are now viewing as a patient.',
              );
            },
            icon: const Icon(Icons.switch_account),
            tooltip: 'Switch to Patient View',
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Pending Requests',
                        value: pendingAppointments.length.toString(),
                        icon: Icons.pending_actions,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Confirmed Sessions',
                        value: confirmedAppointments.length.toString(),
                        icon: Icons.check_circle,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Active Patients',
                        value: _getUniquePatients(confirmedAppointments)
                            .length
                            .toString(),
                        icon: Icons.groups,
                        color: AppColors.neonViolet,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Prescriptions',
                        value: prescriptions.length.toString(),
                        icon: Icons.assignment,
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Active Patients (Local Device User)
                Text(
                  'Active Patients',
                  style: AppTypography.headingMedium,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SmoothCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(16),
                    backgroundColor:
                        AppColors.neonViolet.withValues(alpha: 0.1),
                    borderColor: AppColors.neonViolet.withValues(alpha: 0.3),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.neonViolet,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Demo Patient',
                                style: AppTypography.labelLarge,
                              ),
                              Text(
                                'demo@patient.com',
                                style: AppTypography.bodySmall,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      // Mock an appointment to pass to the prescription dialog
                                      final mockAppt = Appointment(
                                        psychologistEmail: email,
                                        psychologistName: 'Psychologist',
                                        patientName: 'Demo Patient',
                                        patientEmail: 'demo@patient.com',
                                        startsAt: DateTime.now(),
                                        type: 'Therapy',
                                        note: '',
                                      );
                                      _showPrescriptionDialog(
                                          context, ref, mockAppt);
                                    },
                                    icon:
                                        const Icon(Icons.assignment, size: 16),
                                    label: const Text('Prescribe'),
                                    style: OutlinedButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                  FilledButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => ChatScreen(
                                            otherUserId: 'patient',
                                            otherUserName: 'Demo Patient',
                                            currentUserId: email,
                                          ),
                                        ),
                                      );
                                    },
                                    icon:
                                        const Icon(Icons.chat_bubble, size: 16),
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
                  ),
                ),
                const SizedBox(height: 24),

                // Pending Appointments
                if (pendingAppointments.isNotEmpty) ...[
                  Text(
                    'Pending Appointment Requests',
                    style: AppTypography.headingMedium,
                  ),
                  const SizedBox(height: 12),
                  ...pendingAppointments.map(
                    (appointment) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AppointmentRequestCard(
                        appointment: appointment,
                        onApprove: () {
                          ref
                              .read(appSessionProvider.notifier)
                              .approveAppointment(appointment);
                          AppSnackBar.showSuccess(
                            context,
                            title: 'Approved',
                            message: 'Appointment confirmed.',
                          );
                        },
                        onPrescribe: () =>
                            _showPrescriptionDialog(context, ref, appointment),
                      ),
                    ),
                  ),
                ],

                // Confirmed Appointments
                if (confirmedAppointments.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Upcoming Confirmed Sessions',
                    style: AppTypography.headingMedium,
                  ),
                  const SizedBox(height: 12),
                  ...confirmedAppointments.map(
                    (appointment) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ConfirmedAppointmentCard(
                        appointment: appointment,
                        onPrescribe: () =>
                            _showPrescriptionDialog(context, ref, appointment),
                        onMessage: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ChatScreen(
                                otherUserId: 'patient', // Demo patient ID
                                otherUserName: appointment.displayPatientName,
                                currentUserId: appointment
                                    .psychologistEmail, // Current psychologist ID
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Patient Insights (Shared Journals)
                if (sharedJournals.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Patient Insights',
                    style: AppTypography.headingMedium,
                  ),
                  const SizedBox(height: 12),
                  ...sharedJournals.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SmoothCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(16),
                        backgroundColor:
                            AppColors.neonViolet.withValues(alpha: 0.05),
                        borderColor:
                            AppColors.neonViolet.withValues(alpha: 0.20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Shared Entry',
                                  style: AppTypography.labelLarge,
                                ),
                                Text(
                                  _formatDate(entry.createdAt),
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry.content,
                              style: AppTypography.bodySmall,
                            ),
                            if (entry.summary != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.neonViolet.withValues(
                                    alpha: 0.10,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.auto_awesome,
                                            size: 14,
                                            color: AppColors.neonViolet),
                                        const SizedBox(width: 6),
                                        Text(
                                          'AI Summary',
                                          style: AppTypography.labelSmall
                                              .copyWith(
                                                  color: AppColors.neonViolet),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      entry.summary!,
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // Recent Prescriptions
                if (prescriptions.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Recent Prescriptions',
                    style: AppTypography.headingMedium,
                  ),
                  const SizedBox(height: 12),
                  ...prescriptions.take(3).map(
                        (prescription) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SmoothCard(
                            borderRadius: 12,
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prescription.patientName,
                                  style: AppTypography.labelLarge,
                                ),
                                Text(
                                  prescription.medicines.join(', '),
                                  style: AppTypography.bodySmall,
                                ),
                                Text(
                                  'Created: ${_formatDate(prescription.createdAt)}',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _getUniquePatients(List<Appointment> appointments) {
    return appointments.map((a) => a.patientName).toSet().toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showPrescriptionDialog(
    BuildContext context,
    WidgetRef ref,
    Appointment appointment,
  ) async {
    final session = ref.read(appSessionProvider);
    final selectedMedicines = <String>[];
    final selectedTimes = <MedicationTime>[];
    final noteController = TextEditingController();
    final patientName = appointment.displayPatientName;
    final patientEmail = appointment.patientEmail;
    final doctorName = session.profile?.name ?? 'Dr. Panipuri';
    final doctorEmail = session.profile?.email ?? demoPsychologistEmail;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prescribe medication'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Patient: $patientName', style: AppTypography.bodySmall),
              const SizedBox(height: 12),
              Autocomplete<String>(
                optionsBuilder: (textEditingValue) {
                  final query = textEditingValue.text.toLowerCase();
                  if (query.isEmpty) {
                    return demoMedicines;
                  }
                  return demoMedicines.where(
                    (medicine) => medicine.toLowerCase().contains(query),
                  );
                },
                displayStringForOption: (option) => option,
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Medicine',
                      hintText: 'Search or type a medicine',
                    ),
                    onSubmitted: (value) {
                      final trimmed = value.trim();
                      if (trimmed.isNotEmpty &&
                          !selectedMedicines.contains(trimmed)) {
                        setDialogState(() => selectedMedicines.add(trimmed));
                      }
                      controller.clear();
                      onFieldSubmitted();
                    },
                  );
                },
                onSelected: (selection) {
                  if (!selectedMedicines.contains(selection)) {
                    setDialogState(() => selectedMedicines.add(selection));
                  }
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedMedicines
                    .map(
                      (medicine) => InputChip(
                        label: Text(medicine),
                        onDeleted: () {
                          setDialogState(
                              () => selectedMedicines.remove(medicine));
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reminder Times', style: AppTypography.labelLarge),
                  TextButton.icon(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        final newTime = MedicationTime(
                            hour: time.hour, minute: time.minute);
                        if (!selectedTimes.contains(newTime)) {
                          setDialogState(() => selectedTimes.add(newTime));
                        }
                      }
                    },
                    icon: const Icon(Icons.add_alarm, size: 16),
                    label: const Text('Add Time'),
                  ),
                ],
              ),
              if (selectedTimes.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedTimes
                      .map(
                        (time) => InputChip(
                          label: Text(time.toDisplayString()),
                          onDeleted: () {
                            setDialogState(() => selectedTimes.remove(time));
                          },
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Dosage instructions, etc.',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (selectedMedicines.isNotEmpty) {
                ref.read(appSessionProvider.notifier).addPrescription(
                      Prescription(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        patientName: patientName,
                        patientEmail: patientEmail,
                        prescribedByName: doctorName,
                        prescribedByEmail: doctorEmail,
                        medicines: selectedMedicines,
                        reminderTimes: selectedTimes,
                        note: noteController.text.trim(),
                        createdAt: DateTime.now(),
                      ),
                    );
                Navigator.of(context).pop();
                AppSnackBar.showSuccess(
                  context,
                  title: 'Prescription added',
                  message: 'Medication prescribed successfully.',
                );
              }
            },
            child: const Text('Prescribe'),
          ),
        ],
      ),
    );
  }
}
