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
  final _noteController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Clinical Psychologist',
    'Psychiatrist',
    'Therapist',
    'Counselor'
  ];

  final List<_DoctorSlot> _slots = [
    const _DoctorSlot(
      name: 'Dr. Marcus Webb',
      rating: 4.8,
      specialty: 'Psychiatrist',
      time: '2:30 PM',
      duration: '30 min',
      type: 'In-Person',
      email: 'marcus.webb@psychol.demo',
      isFull: false,
      dateHeader: 'Tomorrow',
      dateIndex: 0,
      initials: 'MW',
    ),
    const _DoctorSlot(
      name: 'Dr. Sarah Chen',
      rating: 4.9,
      specialty: 'Clinical Psychologist',
      time: '10:00 AM',
      duration: '50 min',
      type: 'Video',
      email: 'sarah.chen@psychol.demo',
      isFull: false,
      dateHeader: 'Tomorrow',
      dateIndex: 0,
      initials: 'SC',
    ),
    const _DoctorSlot(
      name: 'Dr. Priya Nair',
      rating: 4.7,
      specialty: 'Therapist',
      time: '11:00 AM',
      duration: '50 min',
      type: 'Video',
      email: 'priya.nair@psychol.demo',
      isFull: false,
      dateHeader: 'Wed, Apr 29',
      dateIndex: 1,
      initials: 'PN',
    ),
    const _DoctorSlot(
      name: 'Dr. James Okafor',
      rating: 4.6,
      specialty: 'Counselor',
      time: '4:00 PM',
      duration: '45 min',
      type: 'In-Person',
      email: 'james.okafor@psychol.demo',
      isFull: true,
      dateHeader: 'Wed, Apr 29',
      dateIndex: 1,
      initials: 'JO',
    ),
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool success = false}) {
    if (success) {
      AppSnackBar.showSuccess(context, message: message);
    } else {
      AppSnackBar.showInfo(context, message: message);
    }
  }

  Future<void> _bookSlot(_DoctorSlot slot) async {
    final profile = ref.read(appSessionProvider).profile;
    _noteController.clear();

    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.88,
              child: SmoothCard(
                borderRadius: 24,
                elevation: 24,
                backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderColor: const Color(0xFF0FA58A).withOpacity(0.3),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0FA58A).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Color(0xFF0FA58A),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Confirm Appointment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'You are booking a slot with:',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    slot.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    slot.specialty,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0FA58A),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        slot.dateHeader,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.schedule_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        '${slot.time} (${slot.duration})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SmoothTextField(
                    label: 'Add Note (Optional)',
                    hint: 'Share any details or symptoms with your care provider...',
                    controller: _noteController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      SmoothButton(
                        label: 'Confirm Booking',
                        backgroundColor: const Color(0xFF0FA58A),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curve),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    ) ?? false;

    if (!confirmed) return;

    // Parse the date index to actual date
    final date = slot.dateIndex == 0
        ? DateTime.now().add(const Duration(days: 1))
        : DateTime.now().add(const Duration(days: 2));

    // Parse Time
    final parts = slot.time.split(' ');
    final hm = parts[0].split(':');
    var hour = int.parse(hm[0]);
    final minute = int.parse(hm[1]);
    if (parts[1].toLowerCase() == 'pm' && hour < 12) {
      hour += 12;
    } else if (parts[1].toLowerCase() == 'am' && hour == 12) {
      hour = 0;
    }

    final startsAt = DateTime(date.year, date.month, date.day, hour, minute);

    ref.read(appSessionProvider.notifier).addAppointment(
      Appointment(
        psychologistEmail: slot.email,
        psychologistName: slot.name,
        patientName: profile?.name ?? 'Patient',
        patientEmail: profile?.email,
        startsAt: startsAt,
        type: slot.type == 'In-Person' ? 'In-person visit' : 'Video session',
        note: _noteController.text.trim(),
        confirmed: false,
        driftIndex: profile?.driftIndex ?? 0.0,
      ),
    );

    _showMessage('Appointment requested successfully!', success: true);
  }

  String _formatDateHeader(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, $month ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final profile = session.profile;
    final isPsychologist = profile?.role == UserRole.psychologist;
    
    final currentDrift = profile?.driftIndex ?? 0.18;
    final isPriorityActive = currentDrift >= 0.35 && !isPsychologist;
    final driftPercent = (currentDrift * 100).toInt();

    final appointments = session.appointments
        .where((appointment) => appointment.startsAt.isAfter(DateTime.now()))
        .toList()
        ..sort((a, b) => b.driftIndex.compareTo(a.driftIndex));

    final bookedEmails = appointments.map((a) => a.psychologistEmail.toLowerCase()).toSet();

    // Grouping & Sorting of Slots
    final filteredSlots = _slots.where((slot) {
      if (_selectedCategory == 'All') return true;
      return slot.specialty == _selectedCategory;
    }).toList();

    final sortedSlots = List<_DoctorSlot>.from(filteredSlots);
    if (isPriorityActive) {
      // Webb is sorted to the top
      sortedSlots.sort((a, b) {
        final aPriority = a.name == 'Dr. Marcus Webb';
        final bPriority = b.name == 'Dr. Marcus Webb';
        if (aPriority && !bPriority) return -1;
        if (!aPriority && bPriority) return 1;
        return a.dateIndex.compareTo(b.dateIndex);
      });
    } else {
      sortedSlots.sort((a, b) => a.dateIndex.compareTo(b.dateIndex));
    }

    // Build the dynamic Chronological slots list
    final List<Widget> listWidgets = [];
    String? lastHeader;

    final resolvedSlots = sortedSlots.map((slot) {
      if (slot.dateIndex == 0) {
        return slot; // Keep 'Tomorrow'
      } else {
        final futureDate = DateTime.now().add(Duration(days: slot.dateIndex + 1));
        return _DoctorSlot(
          name: slot.name,
          rating: slot.rating,
          specialty: slot.specialty,
          time: slot.time,
          duration: slot.duration,
          type: slot.type,
          email: slot.email,
          isFull: slot.isFull,
          dateHeader: _formatDateHeader(futureDate),
          dateIndex: slot.dateIndex,
          initials: slot.initials,
        );
      }
    }).toList();

    for (final slot in resolvedSlots) {
      if (slot.dateHeader != lastHeader) {
        lastHeader = slot.dateHeader;
        final groupCount = resolvedSlots.where((s) => s.dateHeader == lastHeader && !s.isFull).length;

        listWidgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              children: [
                Text(
                  slot.dateHeader,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$groupCount available',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white54
                          : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final isWebbPriority = slot.name == 'Dr. Marcus Webb' && isPriorityActive;
      final isAlreadyBooked = bookedEmails.contains(slot.email.toLowerCase());

      listWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: _PriorityGlowBorder(
            isPriority: isWebbPriority,
            child: SmoothCard(
              borderRadius: 22,
              backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
              borderColor: isWebbPriority
                  ? const Color(0xFFEF4444).withOpacity(0.48)
                  : (isAlreadyBooked
                      ? const Color(0xFF10B981).withOpacity(0.48)
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWebbPriority) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.08),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.3),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            color: Color(0xFFEF4444),
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '⚡ PRIORITY SLOT — ACCELERATED CARE',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isWebbPriority
                                ? [const Color(0xFFEF4444).withOpacity(0.18), const Color(0xFFF59E0B).withOpacity(0.18)]
                                : [const Color(0xFF0FA58A).withOpacity(0.16), const Color(0xFF3B82F6).withOpacity(0.12)],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          slot.initials,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isWebbPriority
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF0FA58A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  slot.name,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                                const SizedBox(width: 3),
                                Text(
                                  '${slot.rating}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              slot.specialty,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isWebbPriority
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF0FA58A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule_outlined,
                                    size: 13,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white.withOpacity(0.54)
                                        : Colors.black.withOpacity(0.54),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    slot.time,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white.withOpacity(0.68)
                                          : Colors.black.withOpacity(0.68),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    Icons.timelapse_outlined,
                                    size: 13,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white.withOpacity(0.54)
                                        : Colors.black.withOpacity(0.54),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    slot.duration,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white.withOpacity(0.68)
                                          : Colors.black.withOpacity(0.68),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: slot.type == 'Video'
                                          ? const Color(0xFF3B82F6).withOpacity(0.08)
                                          : const Color(0xFF10B981).withOpacity(0.08),
                                      border: Border.all(
                                        color: slot.type == 'Video'
                                            ? const Color(0xFF3B82F6).withOpacity(0.24)
                                            : const Color(0xFF10B981).withOpacity(0.24),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          slot.type == 'Video' ? Icons.videocam_outlined : Icons.location_on_outlined,
                                          size: 11,
                                          color: slot.type == 'Video' ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          slot.type,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: slot.type == 'Video' ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (slot.isFull) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Full',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withOpacity(0.24),
                            ),
                          ),
                        ),
                      ] else if (isAlreadyBooked) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Booked',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        FilledButton(
                          onPressed: () => _bookSlot(slot),
                          style: FilledButton.styleFrom(
                            backgroundColor: isWebbPriority
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF0FA58A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isWebbPriority) ...[
                                const Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                isWebbPriority ? 'Book Priority' : 'Book',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (sortedSlots.isEmpty) {
      listWidgets.add(
        Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No slots available in this category.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── Dynamic Smart Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Smart Appointments',
                              style: AppTypography.headingMedium.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isPriorityActive
                                  ? 'Priority booking active — slots sorted by urgency.'
                                  : 'Schedule guided mental health care dynamically.',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.48),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isPriorityActive) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.08),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withOpacity(0.24),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Critical',
                                style: TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Warn Banner ──
              if (isPriorityActive) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.06),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.24),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Drift Index $driftPercent — Critical. Priority slots shown first. Please book soon.',
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // ── Category Filter Chips ──
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selected: isSelected,
                          label: Text(category),
                          onSelected: (_) {
                            setState(() => _selectedCategory = category);
                          },
                          backgroundColor: Colors.transparent,
                          selectedColor: const Color(0xFF0FA58A),
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.12)
                                    : Colors.black.withOpacity(0.12)),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // ── Active Booking Slots ──
              SliverList(
                delegate: SliverChildListDelegate(listWidgets),
              ),

              // ── Future appointments header ──
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 28, 18, 12),
                  child: Text(
                    'Future appointments',
                    style: AppTypography.headingSmall,
                  ),
                ),
              ),

              // ── Future appointments list ──
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
                    padding: EdgeInsets.fromLTRB(18, 20, 18, 12),
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

class _DoctorSlot {
  final String name;
  final double rating;
  final String specialty;
  final String time;
  final String duration;
  final String type;
  final String email;
  final bool isFull;
  final String dateHeader;
  final int dateIndex;
  final String initials;

  const _DoctorSlot({
    required this.name,
    required this.rating,
    required this.specialty,
    required this.time,
    required this.duration,
    required this.type,
    required this.email,
    required this.isFull,
    required this.dateHeader,
    required this.dateIndex,
    required this.initials,
  });
}

class _PriorityGlowBorder extends StatefulWidget {
  final Widget child;
  final bool isPriority;

  const _PriorityGlowBorder({required this.child, required this.isPriority});

  @override
  State<_PriorityGlowBorder> createState() => _PriorityGlowBorderState();
}

class _PriorityGlowBorderState extends State<_PriorityGlowBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    if (widget.isPriority) {
      _controller.repeat(reverse: true);
    }
    _animation = Tween<double>(begin: 0.15, end: 0.65).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void didUpdateWidget(covariant _PriorityGlowBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPriority && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPriority && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPriority) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(_animation.value * 0.4),
                blurRadius: 12.0 * _animation.value,
                spreadRadius: 1.0 * _animation.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
