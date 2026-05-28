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
import '../../../calmora/presentation/screens/calmora_ai_sheet.dart';
import '../../../mood_log/presentation/screens/mood_log_screen.dart';
import 'stats_screen.dart';

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
            top: -120,
            left: -120,
            child: IgnorePointer(
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0FA58A).withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.08 : 0.05,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 85, sigmaY: 85),
                  child: const SizedBox(),
                ),
              ),
            ),
          ),
          // Mid-right soft ambient indigo glow
          Positioned(
            top: 280,
            right: -150,
            child: IgnorePointer(
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B5CF6).withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.06 : 0.04,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 95, sigmaY: 95),
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
                  _buildAiBanner(context, scheme),
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

                // ── Weekly Mood Trend Card ──
                _SectionLabel(title: 'Mood Trend', scheme: scheme),
                const SizedBox(height: 10),
                SmoothCard(
                  backgroundColor: scheme.surface.withValues(alpha: 0.72),
                  borderColor: scheme.primary.withValues(alpha: 0.12),
                  elevation: 0,
                  borderRadius: 20,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'This Week',
                            style: AppTypography.labelLarge.copyWith(
                              color: scheme.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${session.moodEntries.length} saved',
                              style: AppTypography.labelSmall.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(
                          7,
                          (i) => _MoodBar(
                            height: _heightForDay(session.moodEntries, i),
                            label: [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun'
                            ][i],
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ── Quick Insights Card ──
                _SectionLabel(title: 'Insights', scheme: scheme),
                const SizedBox(height: 10),
                SmoothCard(
                  backgroundColor: scheme.surface.withValues(alpha: 0.72),
                  borderColor: scheme.secondary.withValues(alpha: 0.12),
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
        borderColor: scheme.primary.withValues(alpha: 0.10),
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
            IconButton.filledTonal(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const StatsScreen(),
                  ),
                );
              },
              icon: Icon(
                Icons.insights_outlined,
                color: scheme.primary,
              ),
              tooltip: 'View stats',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiBanner(BuildContext context, ColorScheme scheme) {
    return GestureDetector(
      onTap: () => _showAiChat(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF0FA58A), Color(0xFF1D4ED8)], // Richer teal-to-blue transition
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.26),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0FA58A).withValues(alpha: 0.22),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFF1D4ED8).withValues(alpha: 0.14),
              blurRadius: 18,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hey, Try CalmoraAI',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your private, intelligent wellness companion.',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
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
}

/// Section label widget
