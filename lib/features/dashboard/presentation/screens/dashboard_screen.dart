import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_state.dart';
import '../../../../app/home_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/smooth_widgets.dart';
import '../../../../core/widgets/animations.dart';
import '../../../calmora/presentation/screens/calmora_ai_sheet.dart';
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
      duration: const Duration(milliseconds: 800),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(selectedTabProvider.notifier).state = 1;
        },
        icon: const Icon(Icons.mood_outlined),
        label: const Text('Log mood'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 18, bottom: 112),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: StaggeredAnimationBuilder(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 80),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildScrollableHeader(context, profile, scheme),
                const SizedBox(height: 22),
                if (profile?.role == UserRole.patient) ...[
                  _buildAiBanner(context, scheme),
                ],
                const SizedBox(height: 20),

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
                const SizedBox(height: 20),

                // ── Weekly Mood Trend Card ──
                _SectionLabel(title: 'Mood Trend', scheme: scheme),
                const SizedBox(height: 10),
                SmoothCard(
                  backgroundColor: scheme.surface.withValues(alpha: 0.72),
                  borderColor: scheme.primary.withValues(alpha: 0.12),
                  elevation: 0,
                  borderRadius: 20,
                  padding: const EdgeInsets.all(20),
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
                      const SizedBox(height: 20),
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
                const SizedBox(height: 20),

                // ── Quick Insights Card ──
                _SectionLabel(title: 'Insights', scheme: scheme),
                const SizedBox(height: 10),
                SmoothCard(
                  backgroundColor: scheme.surface.withValues(alpha: 0.72),
                  borderColor: scheme.secondary.withValues(alpha: 0.12),
                  borderRadius: 20,
                  padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 24),

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
                        profile?.avatarIconCodePoint ?? Icons.person.codePoint,
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
              children: [
                Text(
                  _greeting(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  profile?.name ?? 'Welcome',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const StatsScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.insights_outlined,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
            tooltip: 'View stats',
          ),
        ],
      ),
    );
  }

  Widget _buildAiBanner(BuildContext context, ColorScheme scheme) {
    return GestureDetector(
      onTap: () => _showAiChat(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              scheme.primary,
              scheme.tertiary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your private, intelligent wellness companion.',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
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
      transitionDuration: const Duration(milliseconds: 500),
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
          curve: Curves.easeOutBack,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curve),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(curve),
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
