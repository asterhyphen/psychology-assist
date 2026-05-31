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
    final patientProfile = session.profile;
    final isCaseCompleted = patientProfile?.status == PatientStatus.completed;

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

                if (!isCaseCompleted) ...[
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
                                  patientProfile?.name ?? 'Demo Patient',
                                  style: AppTypography.labelLarge,
                                ),
                                Text(
                                  patientProfile?.email ?? 'demo@patient.com',
                                  style: AppTypography.bodySmall,
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        final mockAppt = Appointment(
                                          psychologistEmail: email,
                                          psychologistName: 'Psychologist',
                                          patientName: patientProfile?.name ?? 'Demo Patient',
                                          patientEmail: patientProfile?.email ?? 'demo@patient.com',
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
                                              otherUserName: patientProfile?.name ?? 'Demo Patient',
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
                                    OutlinedButton.icon(
                                      onPressed: () => _showClinicalNotesDialog(context, ref),
                                      icon: const Icon(Icons.note_add_rounded, size: 16),
                                      label: const Text('Add Note'),
                                      style: OutlinedButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => _showTimelineDialog(context, ref),
                                      icon: const Icon(Icons.timeline_rounded, size: 16),
                                      label: const Text('Timeline'),
                                      style: OutlinedButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        ref.read(appSessionProvider.notifier).updatePatientStatus(PatientStatus.completed);
                                        AppSnackBar.showSuccess(
                                          context,
                                          title: 'Case Completed',
                                          message: 'Patient case marked as completed successfully.',
                                        );
                                      },
                                      icon: const Icon(Icons.check_circle_rounded, size: 16),
                                      label: const Text('Complete Case'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal.withOpacity(0.2),
                                        foregroundColor: Colors.teal,
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
                ],
                const SizedBox(height: 12),

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
                if (isCaseCompleted) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Completed Cases',
                    style: AppTypography.headingMedium,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SmoothCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(16),
                      backgroundColor:
                          Colors.grey.withOpacity(0.08),
                      borderColor: Colors.grey.withOpacity(0.3),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      patientProfile?.name ?? 'Demo Patient',
                                      style: AppTypography.labelLarge,
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'COMPLETED',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  patientProfile?.email ?? 'demo@patient.com',
                                  style: AppTypography.bodySmall,
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => _showTimelineDialog(context, ref),
                                      icon: const Icon(Icons.timeline_rounded, size: 16),
                                      label: const Text('Timeline'),
                                      style: OutlinedButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => _showClinicalNotesDialog(context, ref),
                                      icon: const Icon(Icons.note_add_rounded, size: 16),
                                      label: const Text('Add Note'),
                                      style: OutlinedButton.styleFrom(
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

  Future<void> _showClinicalNotesDialog(BuildContext context, WidgetRef ref) async {
    final noteController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Clinical Session Notes'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Enter session clinical notes here...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = noteController.text.trim();
              if (text.isNotEmpty) {
                ref.read(appSessionProvider.notifier).addClinicalNote(
                  ClinicalNote(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    timestamp: DateTime.now(),
                    note: text,
                    authorName: 'Dr. Aisha Mehta',
                  ),
                );
                Navigator.of(context).pop();
                AppSnackBar.showSuccess(context, message: 'Clinical note added successfully.');
              }
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  void _showTimelineDialog(BuildContext context, WidgetRef ref) {
    final session = ref.read(appSessionProvider);
    final List<_TimelineItem> items = [];

    for (var entry in session.moodEntries) {
      items.add(_TimelineItem(
        timestamp: entry.createdAt,
        title: 'Logged Mood',
        description: 'Rating: ${entry.value}/5 (${entry.label})\nNote: ${entry.note}',
        icon: Icons.mood_rounded,
        color: Colors.orange,
      ));
    }

    for (var entry in session.typingHistory) {
      items.add(_TimelineItem(
        timestamp: entry.timestamp,
        title: 'Typing Stress Test',
        description: '${entry.wpm} WPM | ${entry.accuracy.toStringAsFixed(1)}% Accuracy | ${entry.corrections} Corrections\nStress Score: ${entry.stressScore.toStringAsFixed(2)}',
        icon: Icons.keyboard_rounded,
        color: Colors.blue,
      ));
    }

    for (var entry in session.breathingHistory) {
      items.add(_TimelineItem(
        timestamp: entry.timestamp,
        title: 'Breathing Session',
        description: '${entry.technique} | ${entry.cyclesCompleted} cycles (${entry.durationSeconds}s duration)',
        icon: Icons.air_rounded,
        color: Colors.teal,
      ));
    }

    for (var entry in session.journalEntries) {
      items.add(_TimelineItem(
        timestamp: entry.createdAt,
        title: 'Wellness Journal',
        description: 'Content: ${entry.content}${entry.summary != null ? "\nAI Summary: ${entry.summary}" : ""}',
        icon: Icons.book_rounded,
        color: Colors.purple,
      ));
    }

    for (var entry in session.appointments) {
      items.add(_TimelineItem(
        timestamp: entry.startsAt,
        title: 'Appointment: ${entry.type}',
        description: 'With ${entry.psychologistName}\nStatus: ${entry.status.name.toUpperCase()}\nNote: ${entry.note}',
        icon: Icons.calendar_today_rounded,
        color: Colors.green,
      ));
    }

    for (var entry in session.prescriptions) {
      items.add(_TimelineItem(
        timestamp: entry.createdAt,
        title: 'Prescribed Medication',
        description: 'Medicines: ${entry.medicines.join(", ")}\nNote: ${entry.note}',
        icon: Icons.assignment_rounded,
        color: Colors.red,
      ));
    }

    for (var entry in session.adherenceHistory) {
      items.add(_TimelineItem(
        timestamp: entry.timestamp,
        title: 'Medication Adherence',
        description: 'Medicine: ${entry.medicineName}\nStatus: ${entry.taken ? "TAKEN" : "MISSED"}',
        icon: Icons.medical_services_rounded,
        color: entry.taken ? Colors.green : Colors.red,
      ));
    }

    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.teal.withOpacity(0.3)),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Patient Timeline',
                          style: AppTypography.headingSmall.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: items.isEmpty
                        ? const Center(
                            child: Text(
                              'No timeline records found.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, idx) {
                              final item = items[idx];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: item.color.withOpacity(0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(item.icon, size: 18, color: item.color),
                                        ),
                                        Container(
                                          width: 2,
                                          height: 40,
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.title,
                                                  style: AppTypography.labelMedium.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '${item.timestamp.day}/${item.timestamp.month} ${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                                                style: AppTypography.caption,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.description,
                                            style: AppTypography.bodySmall.copyWith(
                                              color: isDark ? Colors.white70 : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TimelineItem {
  final DateTime timestamp;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _TimelineItem({
    required this.timestamp,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
