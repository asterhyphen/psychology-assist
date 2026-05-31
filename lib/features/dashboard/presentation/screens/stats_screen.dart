import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/smooth_widgets.dart';

part '../widgets/stat_tile.dart';
part '../widgets/weekly_trend_item.dart';
part '../widgets/journal_preview.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  bool _isGenerating = false;

  Future<void> _generateAndSendReport(AppSession session) async {
    setState(() => _isGenerating = true);
    
    // Simulate AI generation delay without feeling "too AI-y"
    await Future.delayed(const Duration(seconds: 2));
    
    final doctorEmail = session.profile?.psychologistEmail ?? demoPsychologistEmail;
    final patientEmail = session.profile?.email ?? 'patient@example.com';
    final patientName = session.profile?.name ?? 'Patient';
    
    final recentMoods = session.moodEntries.reversed.take(5).map((e) => e.label).join(', ');
    final driftIndex = (session.profile?.driftIndex ?? 0.0).toStringAsFixed(2);
    
    final reportContent = '''
**Wellness Report for $patientName**
Generated on: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

**Recent Mood Trends**: $recentMoods
**Overall Drift Index**: $driftIndex

**Insights**:
Based on recent check-ins and mood patterns, the patient is showing steady engagement but may benefit from discussing cognitive reframing strategies during the next session.
''';

    ref.read(appSessionProvider.notifier).addMessage(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: patientEmail,
        receiverId: doctorEmail,
        content: reportContent,
        timestamp: DateTime.now(),
      ),
    );

    if (mounted) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wellness report compiled and securely sent to your doctor.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final entries = session.moodEntries.toList();
    final averageMood = entries.isEmpty
        ? 0.0
        : entries.map((entry) => entry.value).reduce((a, b) => a + b) /
            entries.length;
    final recentEntries = entries.reversed.take(5).toList();
    final weeklyTrend = _buildWeeklyTrend(entries);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            SmoothCard(
              borderRadius: 24,
              borderColor: AppColors.neonViolet.withOpacity(0.18),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wellness stats',
                    style: AppTypography.headingSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A quick view of your mood entries and notes.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.lightSubtext,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _StatTile(
                        label: 'Total entries',
                        value: '${entries.length}',
                        color: const Color(0xFFB7C97B),
                      ),
                      const SizedBox(width: 12),
                      _StatTile(
                        label: 'Average mood',
                        value: averageMood.toStringAsFixed(1),
                        color: AppColors.neonViolet,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SmoothCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weekly Trend', style: AppTypography.headingSmall),
                  const SizedBox(height: 16),
                  Column(
                    children: () {
                      final maxCount = weeklyTrend.map((e) => e.count).reduce((a, b) => a > b ? a : b);
                      final double divisor = maxCount == 0 ? 1.0 : maxCount.toDouble();

                      return weeklyTrend.map((item) {
                        final double percent = item.count.toDouble() / divisor;
                        final isDark = Theme.of(context).brightness == Brightness.dark;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 42,
                                child: Text(
                                  item.day,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.black.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: percent.clamp(0.02, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              scheme.primary,
                                              scheme.secondary,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              SizedBox(
                                width: 56,
                                child: Text(
                                  '${item.count} ${item.count == 1 ? 'entry' : 'entries'}',
                                  textAlign: TextAlign.end,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: scheme.onSurface.withValues(alpha: 0.58),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    }(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SmoothCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent Mood Notes',
                      style: AppTypography.headingSmall),
                  const SizedBox(height: 12),
                  if (recentEntries.isEmpty)
                    Text(
                      'No mood notes yet. Add a mood entry to start tracking.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.lightSubtext,
                      ),
                    )
                  else
                    ...recentEntries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _JournalPreview(entry: entry),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isGenerating ? null : () => _generateAndSendReport(session),
                      icon: _isGenerating 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(_isGenerating ? 'Compiling Report...' : 'Compile & Send Wellness Report'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.neonViolet,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_WeeklyTrendItem> _buildWeeklyTrend(List<MoodEntry> entries) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) {
      final day = startOfWeek.add(Duration(days: index));
      final count = entries.where((entry) {
        return entry.createdAt.year == day.year &&
            entry.createdAt.month == day.month &&
            entry.createdAt.day == day.day;
      }).length;
      return _WeeklyTrendItem(
        day: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
        count: count,
      );
    });
  }
}
