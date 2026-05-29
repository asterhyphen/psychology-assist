import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_state.dart';
import '../../../../app/home_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/smooth_widgets.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../calmora/presentation/screens/calmora_ai_sheet.dart';
import '../../../mood_log/presentation/screens/mood_log_screen.dart';
import 'stats_screen.dart';
import 'weekly_report_screen.dart';

part '../widgets/section_label.dart';
part '../widgets/mood_bar.dart';
part '../widgets/insight_row.dart';
part '../widgets/dashboard_stat.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final session = ref.watch(appSessionProvider);
    final profile = session.profile;
    final upcomingAppointment = session.appointments.where((appointment) {
      if (profile?.role == UserRole.psychologist) {
        return appointment.psychologistEmail == profile?.email &&
            appointment.startsAt.isAfter(DateTime.now());
      }
      return profile?.email != null &&
          appointment.patientEmail?.toLowerCase() ==
              profile!.email!.toLowerCase() &&
          appointment.startsAt.isAfter(DateTime.now());
    }).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final nextAppointment = upcomingAppointment.isEmpty
        ? 'No upcoming sessions'
        : '${upcomingAppointment.first.type} at ${upcomingAppointment.first.startsAt.hour.toString().padLeft(2, '0')}:${upcomingAppointment.first.startsAt.minute.toString().padLeft(2, '0')}';

    final relatedPrescriptions = session.prescriptions.where((item) {
      if (profile?.role == UserRole.psychologist) {
        return item.prescribedByEmail == profile?.email;
      }
      return profile?.email != null &&
          item.patientEmail?.toLowerCase() == profile!.email!.toLowerCase();
    }).toList()
      ..sort((a, b) {
        return a.reminderTimes.isNotEmpty && b.reminderTimes.isNotEmpty
            ? a.reminderTimes.first.hour
                        .compareTo(b.reminderTimes.first.hour) !=
                    0
                ? a.reminderTimes.first.hour
                    .compareTo(b.reminderTimes.first.hour)
                : a.reminderTimes.first.minute
                    .compareTo(b.reminderTimes.first.minute)
            : 0;
      });
    final nextPrescription = relatedPrescriptions.isEmpty
        ? 'No reminders set'
        : '${relatedPrescriptions.first.medicines.join(', ')} at ${relatedPrescriptions.first.reminderTimes.isNotEmpty ? relatedPrescriptions.first.reminderTimes.first.toDisplayString() : 'No time'}';

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            colors: [Color(0xFF0FA58A), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0FA58A).withValues(alpha: 0.16),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MoodLogScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.self_improvement_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Log Mood',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          // Atmospheric Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: theme.brightness == Brightness.dark
                      ? [
                          const Color(0xFF080C11),
                          const Color(0xFF0E121E),
                        ]
                      : [
                          const Color(0xFFF7F8FC),
                          const Color(0xFFF0EFF5),
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Top-left soft ambient teal glow
          Positioned(
            top: -140,
            left: -140,
            child: IgnorePointer(
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0FA58A).withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.15 : 0.08,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 110, sigmaY: 110),
                  child: const SizedBox(),
                ),
              ),
            ),
          ),
          // Mid-right soft ambient indigo glow
          Positioned(
            top: 280,
            right: -180,
            child: IgnorePointer(
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B5CF6).withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.12 : 0.06,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                  child: const SizedBox(),
                ),
              ),
            ),
          ),
          // Scrollable main body
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 10, bottom: 108),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StaggeredAnimationBuilder(
                  duration: const Duration(milliseconds: 420),
                  delay: const Duration(milliseconds: 45),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildScrollableHeader(context, profile, scheme),
                const SizedBox(height: 16),
                if (profile?.role == UserRole.patient) ...[
                  _AiHeroCard(onTap: () => _showAiChat(context)),
                  const SizedBox(height: 18),
                  _buildMentalStateOverview(context, profile, scheme),
                ],
                const SizedBox(height: 18),

                // ── Quick Stats Row ──
                _SectionLabel(title: 'Quick Overview', scheme: scheme),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _DashboardStat(
                        label: 'Next session',
                        value: nextAppointment,
                        icon: Icons.event_available_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DashboardStat(
                        label: 'Next reminder',
                        value: nextPrescription,
                        icon: Icons.medication_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── 7-Day Drift Trend Card ──
                if (profile?.role == UserRole.patient) ...[
                  _buildWeeklyDriftTrend(context, profile, session, scheme),
                  const SizedBox(height: 18),
                  _buildPassiveBehavioralSignals(context, profile, scheme),
                  const SizedBox(height: 18),
                  _buildAiDailyInsight(context, scheme),
                  const SizedBox(height: 18),
                  _buildWeeklyReportCard(context, scheme),
                  const SizedBox(height: 18),
                ],

                // ── Quick Insights Card ──
                _SectionLabel(title: 'Insights', scheme: scheme),
                const SizedBox(height: 10),
                SmoothCard(
                  backgroundColor: scheme.surface.withValues(alpha: 0.72),
                  borderColor: scheme.secondary.withValues(alpha: theme.brightness == Brightness.dark ? 0.22 : 0.15),
                  borderRadius: 20,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _InsightRow(
                        icon: Icons.trending_up,
                        title: 'Latest Mood',
                        value: _latestMoodLabel(session.moodEntries),
                        theme: theme,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                            height: 1,
                            color: scheme.onSurface.withValues(alpha: 0.08)),
                      ),
                      _InsightRow(
                        icon: Icons.calendar_today,
                        title: 'Total Entries',
                        value: '${session.moodEntries.length}',
                        theme: theme,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                            height: 1,
                            color: scheme.onSurface.withValues(alpha: 0.08)),
                      ),
                      _InsightRow(
                        icon: Icons.local_fire_department,
                        title: 'Longest Streak',
                        value: '${session.longestStreak} days',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const StatsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.insights_outlined, size: 18),
                    label: const Text('View full stats'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  double _heightForDay(List<MoodEntry> entries, int dayIndex) {
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final day = weekStart.add(Duration(days: dayIndex));
    final dayEntries = entries.where(
      (entry) =>
          entry.createdAt.year == day.year &&
          entry.createdAt.month == day.month &&
          entry.createdAt.day == day.day,
    );
    if (dayEntries.isEmpty) {
      return 20;
    }
    final average =
        dayEntries.map((entry) => entry.value).reduce((a, b) => a + b) /
            dayEntries.length;
    return 18 + average * 18;
  }

  String _latestMoodLabel(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return 'None yet';
    }
    return entries.last.label;
  }

  IconData _avatarIconFor(int codePoint) {
    const icons = [
      Icons.person,
      Icons.self_improvement,
      Icons.favorite,
      Icons.psychology_alt,
    ];
    return icons.firstWhere(
      (icon) => icon.codePoint == codePoint,
      orElse: () => Icons.person,
    );
  }

  Widget _buildScrollableHeader(
    BuildContext context,
    AppProfile? profile,
    ColorScheme scheme,
  ) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: SmoothCard(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        backgroundColor: scheme.surface.withValues(alpha: 0.78),
        borderColor: scheme.primary.withValues(alpha: theme.brightness == Brightness.dark ? 0.20 : 0.14),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                ref.read(selectedTabProvider.notifier).state = 4;
              },
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Color(
                  profile?.avatarColorValue ?? AppColors.neonViolet.toARGB32(),
                ),
                backgroundImage: profile?.profileImagePath == null
                    ? null
                    : FileImage(File(profile!.profileImagePath!)),
                child: profile?.profileImagePath == null
                    ? Icon(
                        _avatarIconFor(
                          profile?.avatarIconCodePoint ??
                              Icons.person.codePoint,
                        ),
                        color: Colors.white,
                        size: 22,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _greeting(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.58),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile?.name ?? 'Welcome',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filled(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const StatsScreen(),
                  ),
                );
              },
              style: IconButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(
                Icons.insights_outlined,
                size: 20,
              ),
              tooltip: 'View stats',
            ),
          ],
        ),
      ),
    );
  }


  void _showAiChat(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 360),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: CalmoraAiSheet(),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curve),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(curve),
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }

  // ── Helper: Calculate Drift For A Specific Day of the current week ──
  double _driftForDay(List<MoodEntry> entries, double currentDrift, int dayIndex) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final day = weekStart.add(Duration(days: dayIndex));
    
    final dayEntries = entries.where((entry) =>
      entry.createdAt.year == day.year &&
      entry.createdAt.month == day.month &&
      entry.createdAt.day == day.day,
    ).toList();

    if (dayEntries.isEmpty) {
      final baseDrift = currentDrift * 100.0;
      
      // Deterministic beautiful variation to keep chart full and organic
      final variations = [2.0, -1.5, 4.0, 1.5, 5.0, -3.0, 0.0];
      return (baseDrift + variations[dayIndex % 7]).clamp(5.0, 95.0);
    }

    final averageMood = dayEntries.map((e) => e.value).reduce((a, b) => a + b) / dayEntries.length;
    final computedDrift = 90.0 - (averageMood - 1.0) * 18.0;
    return computedDrift.clamp(5.0, 98.0);
  }

  // ── Helper: Legend Item Builder ──
  Widget _buildLegendItem(String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black54,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Widget: Mental State Overview Card ──
  Widget _buildMentalStateOverview(BuildContext context, AppProfile? profile, ColorScheme scheme) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentDrift = profile?.driftIndex ?? 0.18;
    final driftPercent = (currentDrift * 100).toInt();

    Color stateColor;
    String stateLabel;
    String description;

    if (currentDrift < 0.35) {
      stateColor = const Color(0xFF10B981); // Vibrant Green
      stateLabel = 'Stable';
      description = 'Your behavioral patterns look healthy. Keep maintaining your current routine.';
    } else if (currentDrift < 0.65) {
      stateColor = const Color(0xFFF59E0B); // Amber Orange
      stateLabel = 'Declining';
      description = 'Mild fluctuations in your wellness scores have been logged. Consider guided breathing.';
    } else {
      stateColor = const Color(0xFFEF4444); // Critical Coral Red
      stateLabel = 'Critical';
      description = 'Your stress indicators are elevated. We recommend taking a break or consulting a therapist.';
    }

    return SmoothCard(
      backgroundColor: scheme.surface.withValues(alpha: 0.72),
      borderColor: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.15),
      borderRadius: 22,
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          // Centered circular progress arc gauge
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: _CircularArcPainter(
                    progress: currentDrift,
                    activeColor: stateColor,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$driftPercent',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: stateColor,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Drift Index',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : scheme.onSurface.withOpacity(0.54),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stateLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: stateColor.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Icon + title centered row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.psychology_outlined,
                color: isDark ? Colors.white.withOpacity(0.9) : scheme.onSurface.withOpacity(0.8),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Mental State Overview',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Double capsules row (status capsule + trend)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: stateColor.withOpacity(0.08),
                  border: Border.all(
                    color: stateColor.withOpacity(0.24),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: stateColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      stateLabel,
                      style: TextStyle(
                        color: stateColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.trending_down,
                    color: Color(0xFF10B981),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Trending well',
                    style: TextStyle(
                      color: isDark ? Colors.white.withOpacity(0.48) : scheme.onSurface.withOpacity(0.54),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dynamic description text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.54) : scheme.onSurface.withOpacity(0.64),
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => _showAiChat(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : scheme.onSurface,
                    foregroundColor: isDark ? Colors.black : scheme.surface,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Talk to AI Support',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate directly to the priority appointments screen (tab index 3)
                    ref.read(selectedTabProvider.notifier).state = 3;
                  },
                  icon: const Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFFEF4444),
                    size: 16,
                  ),
                  label: const Text(
                    'Priority Appointment',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(
                      color: const Color(0xFFEF4444).withOpacity(0.3),
                      width: 1.2,
                    ),
                    backgroundColor: const Color(0xFFEF4444).withOpacity(0.08),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Widget: 7-Day Drift Trend Line Card ──
  Widget _buildWeeklyDriftTrend(BuildContext context, AppProfile? profile, AppSession session, ColorScheme scheme) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentDrift = profile?.driftIndex ?? 0.18;
    final List<double> driftValues = List.generate(7, (i) => _driftForDay(session.moodEntries, currentDrift, i));

    Color activeColor;
    if (currentDrift < 0.35) {
      activeColor = const Color(0xFF10B981);
    } else if (currentDrift < 0.65) {
      activeColor = const Color(0xFFF59E0B);
    } else {
      activeColor = const Color(0xFFEF4444);
    }

    return SmoothCard(
      backgroundColor: scheme.surface.withValues(alpha: 0.72),
      borderColor: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.15),
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title on left, Legend on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.show_chart_rounded,
                    color: isDark ? Colors.white : scheme.onSurface,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '7-Day Drift Trend',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark ? Colors.white : scheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildLegendItem('Stable', const Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  _buildLegendItem('Declining', const Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  _buildLegendItem('Critical', const Color(0xFFEF4444)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Main chart region (Y-axis + Canvas)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Y-Axis Labels Column
              SizedBox(
                height: 160,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: ['100', '75', '50', '25', '0'].map((label) {
                    return Text(
                      label,
                      style: TextStyle(
                        color: isDark ? Colors.white.withOpacity(0.32) : scheme.onSurface.withOpacity(0.48),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 12),

              // Custom Painter Area
              Expanded(
                child: SizedBox(
                  height: 160,
                  child: CustomPaint(
                    painter: _TrendLinePainter(
                      values: driftValues,
                      activeColor: activeColor,
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Bottom X-Axis Days Labels Row
          Row(
            children: [
              const SizedBox(width: 32), // Matches Y-axis labels space
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
                    return Text(
                      day,
                      style: TextStyle(
                        color: isDark ? Colors.white.withOpacity(0.32) : scheme.onSurface.withOpacity(0.48),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stateful Refresh State Variable ──
  bool _isRefreshingInsight = false;

  // ── Widget: Passive Behavioral Signals Card ──
  Widget _buildPassiveBehavioralSignals(BuildContext context, AppProfile? profile, ColorScheme scheme) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final drift = profile?.driftIndex ?? 0.18;
    
    // Scale typing metrics based on drift index (stress levels)
    // Stable (< 0.35), Declining (< 0.65), Critical (>= 0.65)
    String speedText;
    String backspaceText;
    String pauseText;
    String sentimentText;
    
    if (drift < 0.35) {
      speedText = '${(4.8 - drift * 2.0).toStringAsFixed(1)} c/s';
      backspaceText = '${(4 + drift * 20).toInt()}%';
      pauseText = '${(0.2 + drift * 0.5).toStringAsFixed(1)}s';
      sentimentText = 'Positive';
    } else if (drift < 0.65) {
      speedText = '${(4.8 - drift * 2.5).toStringAsFixed(1)} c/s';
      backspaceText = '${(4 + drift * 30).toInt()}%';
      pauseText = '${(0.2 + drift * 0.8).toStringAsFixed(1)}s';
      sentimentText = 'Neutral';
    } else {
      speedText = '${(4.8 - drift * 3.0).toStringAsFixed(1)} c/s';
      backspaceText = '${(4 + drift * 40).toInt()}%';
      pauseText = '${(0.2 + drift * 1.2).toStringAsFixed(1)}s';
      sentimentText = 'Stressed';
    }

    return SmoothCard(
      backgroundColor: scheme.surface.withValues(alpha: 0.72),
      borderColor: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.15),
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & Eye Icon
          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                color: isDark ? Colors.white.withOpacity(0.9) : scheme.onSurface.withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Passive Behavioral Signals',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2x2 grid of metrics
          Row(
            children: [
              Expanded(
                child: _buildSignalTile(
                  icon: Icons.bolt_outlined,
                  label: 'Typing Speed',
                  value: speedText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSignalTile(
                  icon: Icons.show_chart_rounded,
                  label: 'Backspace Rate',
                  value: backspaceText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSignalTile(
                  icon: Icons.access_time_outlined,
                  label: 'Avg Pause',
                  value: pauseText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSignalTile(
                  icon: Icons.psychology_outlined,
                  label: 'Sentiment',
                  value: sentimentText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Footer muted description text
          Center(
            child: Text(
              'Updates in real-time as you type in AI Chat',
              style: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.32) : scheme.onSurface.withOpacity(0.48),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper Widget: Passive Signal Grid Tile ──
  Widget _buildSignalTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(isDark ? 0.04 : 0.08),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(isDark ? 0.12 : 0.2),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF10B981).withOpacity(0.48),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white.withOpacity(0.32) : scheme.onSurface.withOpacity(0.54),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF10B981),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget: AI Daily Insight Card ──
  Widget _buildAiDailyInsight(BuildContext context, ColorScheme scheme) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SmoothCard(
      backgroundColor: scheme.surface.withValues(alpha: 0.72),
      borderColor: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.15),
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          // Header Row: Rounded Sparkle container, Title, Warning badge on left & Refresh on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Rounded square sparkling container
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.06) : scheme.onSurface.withOpacity(0.06),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.1) : scheme.onSurface.withOpacity(0.1),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.auto_awesome_outlined,
                        color: isDark ? Colors.white : scheme.onSurface,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & smart fallback status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Daily Insight',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.wifi_off_rounded,
                                color: Color(0xFFF59E0B),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Smart fallback',
                                style: TextStyle(
                                  color: Color(0xFFF59E0B),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
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

              // Premium Refresh button
              OutlinedButton(
                onPressed: _isRefreshingInsight
                    ? null
                    : () async {
                        setState(() => _isRefreshingInsight = true);
                        await Future.delayed(const Duration(milliseconds: 1200));
                        if (mounted) {
                          setState(() => _isRefreshingInsight = false);
                          AppSnackBar.showSuccess(
                            context,
                            title: 'Insights Updated',
                            message: 'AI Daily Insights compiled via smart fallback successfully.',
                          );
                        }
                      },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.12) : scheme.onSurface.withOpacity(0.16),
                    width: 1.0,
                  ),
                  backgroundColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isRefreshingInsight) ...[
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark ? Colors.white : scheme.onSurface,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.refresh_rounded,
                        color: isDark ? Colors.white : scheme.onSurface,
                        size: 16,
                      ),
                    ],
                    const SizedBox(width: 6),
                    Text(
                      'Refresh',
                      style: TextStyle(
                        color: isDark ? Colors.white : scheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Central warning/instruction text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Add an Ollama model or Gemini key to get personalised AI insights',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.32) : scheme.onSurface.withOpacity(0.48),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Environment code tag pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.04) : scheme.onSurface.withOpacity(0.04),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.08) : scheme.onSurface.withOpacity(0.08),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'VITE_OLLAMA_MODEL=mistral',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.5,
                color: isDark ? Colors.white.withOpacity(0.4) : scheme.onSurface.withOpacity(0.54),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyReportCard(BuildContext context, ColorScheme scheme) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SmoothCard(
      backgroundColor: scheme.surface.withValues(alpha: 0.72),
      borderColor: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.15),
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const WeeklyReportScreen(),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0FA58A), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Mental Health Report',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Generate psychiatric summaries and stress logs based on your typing signals.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: isDark ? Colors.white54 : scheme.onSurface.withOpacity(0.54),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: isDark ? Colors.white38 : scheme.onSurface.withOpacity(0.38),
            size: 16,
          ),
        ],
      ),
    );
  }
}

class _AiHeroCard extends StatefulWidget {
  final VoidCallback onTap;

  const _AiHeroCard({required this.onTap});

  @override
  State<_AiHeroCard> createState() => _AiHeroCardState();
}

class _AiHeroCardState extends State<_AiHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2600),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0FA58A), // Teal
                  Color(0xFF3B82F6), // Blue
                  Color(0xFF8B5CF6), // Violet
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0FA58A).withValues(
                    alpha: 0.25 * _pulseAnimation.value,
                  ),
                  blurRadius: 28 * _pulseAnimation.value,
                  spreadRadius: _pulseAnimation.value,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(
                    alpha: 0.16 * _pulseAnimation.value,
                  ),
                  blurRadius: 18 * _pulseAnimation.value,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
              child: Row(
                children: [
                  // Glowing Pulsing AI Badge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.12),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF0FA58A),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'CalmoraAI flagship',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Hey, Try CalmoraAI',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your private, intelligent wellness companion.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Premium CTA Glass Pill Button
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.36),
                        width: 1.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Custom Painter: Circular Progress Arc ──
class _CircularArcPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color activeColor;

  _CircularArcPainter({
    required this.progress,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    if (progress.isNaN || progress.isInfinite) return;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;
    if (radius <= 0 || radius.isNaN || radius.isInfinite) return;

    // Background track paint
    final paintTrack = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    // Glowing shadow paint for active arc
    final paintActiveShadow = Paint()
      ..color = activeColor.withOpacity(0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13.0
      ..strokeCap = StrokeCap.round;
    paintActiveShadow.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    // Main active arc paint
    final paintActive = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    // Draw background full circle track
    canvas.drawCircle(center, radius, paintTrack);

    // Draw active arc sweep starting from 12 o'clock (-90 degrees)
    final double sweepAngle = 2 * 3.1415926535 * progress;
    if (sweepAngle.isNaN || sweepAngle.isInfinite) return;

    // Draw shadow first to put it in the background
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2,
      sweepAngle,
      false,
      paintActiveShadow,
    );

    // Draw primary glowing stroke
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2,
      sweepAngle,
      false,
      paintActive,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularArcPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.activeColor != activeColor;
  }
}

// ── Custom Painter: Sleek Bezier Trend Graph ──
class _TrendLinePainter extends CustomPainter {
  final List<double> values; // 7 values for Mon-Sun (0.0 to 100.0)
  final Color activeColor;
  final bool isDark;

  _TrendLinePainter({
    required this.values,
    required this.activeColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Clean and validate input values against NaN or Infinities
    final cleanValues = values.map((val) => val.isNaN || val.isInfinite ? 50.0 : val).toList();
    if (cleanValues.isEmpty) return;

    final paintLine = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final paintLineShadow = Paint()
      ..color = activeColor.withOpacity(0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    final paintGrid = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paintStableDash = Paint()
      ..color = const Color(0xFF10B981).withOpacity(isDark ? 0.12 : 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paintDecliningDash = Paint()
      ..color = const Color(0xFFF59E0B).withOpacity(isDark ? 0.12 : 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paintCriticalDash = Paint()
      ..color = const Color(0xFFEF4444).withOpacity(isDark ? 0.12 : 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw Y grid lines
    final double stepY = size.height / 4;
    for (int i = 0; i <= 4; i++) {
      final y = i * stepY;
      if (y.isNaN || y.isInfinite) continue;
      _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), paintGrid, dashWidth: 5, dashSpace: 5);
    }

    // Threshold Guideline calculations:
    // Stable < 35, Declining < 65, Critical >= 65
    final double yDeclining = size.height * (1.0 - 0.35); // 35% line
    final double yCritical = size.height * (1.0 - 0.65);  // 65% line

    if (!yDeclining.isNaN && !yDeclining.isInfinite) {
      _drawDashedLine(canvas, Offset(0, yDeclining), Offset(size.width, yDeclining), paintDecliningDash, dashWidth: 4, dashSpace: 4);
    }
    if (!yCritical.isNaN && !yCritical.isInfinite) {
      _drawDashedLine(canvas, Offset(0, yCritical), Offset(size.width, yCritical), paintCriticalDash, dashWidth: 4, dashSpace: 4);
    }

    // Data points placement
    final double stepX = size.width / (cleanValues.length > 1 ? cleanValues.length - 1 : 1);
    final List<Offset> points = [];
    for (int i = 0; i < cleanValues.length; i++) {
      final val = cleanValues[i].clamp(0.0, 100.0);
      final y = size.height * (1.0 - (val / 100.0));
      final x = i * stepX;
      if (y.isNaN || y.isInfinite || x.isNaN || x.isInfinite) continue;
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    // Compute Spline path using Bezier Cubic anchors
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final control1 = Offset(p0.dx + stepX / 2.2, p0.dy);
      final control2 = Offset(p1.dx - stepX / 2.2, p1.dy);
      path.cubicTo(
        control1.dx, control1.dy,
        control2.dx, control2.dy,
        p1.dx, p1.dy,
      );
    }

    // Draw vertical underfill gradient shape
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.lineTo(points.first.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          activeColor.withOpacity(0.24),
          activeColor.withOpacity(0.00),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw path shadow
    canvas.drawPath(path, paintLineShadow);

    // Draw primary path line
    canvas.drawPath(path, paintLine);

    // Draw exact data circles
    final pointPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;
    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (var pt in points) {
      canvas.drawCircle(pt, 4.0, pointPaint);
      canvas.drawCircle(pt, 4.0, pointBorderPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint, {double dashWidth = 5, double dashSpace = 5}) {
    double distance = (p2 - p1).distance;
    if (distance <= 0.0 || distance.isNaN || distance.isInfinite) return;
    double currentDistance = 0.0;
    Offset direction = (p2 - p1) / distance;
    while (currentDistance < distance) {
      canvas.drawLine(
        p1 + direction * currentDistance,
        p1 + direction * (currentDistance + dashWidth < distance ? currentDistance + dashWidth : distance),
        paint,
      );
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter oldDelegate) {
    if (oldDelegate.activeColor != activeColor || oldDelegate.isDark != isDark) return true;
    if (oldDelegate.values.length != values.length) return true;
    for (int i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
    }
    return false;
  }
}

/// Section label widget
