import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/smooth_widgets.dart';
import '../../../../core/widgets/app_snackbar.dart';

class WeeklyReportScreen extends ConsumerStatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  ConsumerState<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends ConsumerState<WeeklyReportScreen> {
  bool _isGenerating = false;
  bool _reportGenerated = false;
  int _generationStep = 0;

  final List<String> _steps = [
    'Scanning weekly mood logs...',
    'Analyzing backspace rate and typing signals...',
    'Evaluating stress and drift index parameters...',
    'Structuring clinical recommendations...',
  ];

  void _generateReport() async {
    setState(() {
      _isGenerating = true;
      _generationStep = 0;
    });

    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        setState(() {
          _generationStep = i + 1;
        });
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isGenerating = false;
        _reportGenerated = true;
      });
      AppSnackBar.showSuccess(
        context,
        title: 'Report Compiled',
        message: 'Your weekly AI clinical analysis is ready.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final session = ref.watch(appSessionProvider);
    final profile = session.profile;

    // Calculate dynamic values based on provider session data
    final currentDrift = profile?.driftIndex ?? 0.18;
    final driftPercent = (currentDrift * 100).toInt();

    // Avg Mood Calculation: mapping out of 5 to out of 10
    double avgMood = 6.0;
    if (session.moodEntries.isNotEmpty) {
      final sum = session.moodEntries.map((e) => e.value).reduce((a, b) => a + b);
      avgMood = (sum / session.moodEntries.length) * 2.0;
    }

    // Journal entries counted by mood entry notes
    final journalCount = session.moodEntries.where((e) => e.note != null && e.note!.isNotEmpty).length;

    // Clinical diagnostics mapping based on Drift Index
    String statusTitle;
    Color statusColor;
    String reportSummary;
    List<String> recommendations;

    if (currentDrift < 0.35) {
      statusTitle = 'Stable Coherence';
      statusColor = const Color(0xFF10B981);
      reportSummary = 'Excellent emotional coherence has been maintained. Your active engagement with guided breathing has reinforced autonomic resilience, keeping your stress index under 30%. Typing cadence dynamics reflect healthy cognitive focus with zero signs of performance strain.';
      recommendations = [
        'Maintain current routine of guided box breathing',
        'Log mood check-ins daily to sustain long-term bio-feedback records',
        'Engage in weekly high-intensity calmora exercises'
      ];
    } else if (currentDrift < 0.65) {
      statusTitle = 'Mild Stress Fluctuation';
      statusColor = const Color(0xFFF59E0B);
      reportSummary = 'Mild stress anomalies have been logged. Cognitive fatigue was observed via a slightly elevated backspace rate (8%) in AI Chat. Emotional entries indicate fluctuating energy levels. We highly recommend incorporating physiological sighs into your daily routine to balance vagal tone.';
      recommendations = [
        'Practice Physiological Sigh breathing twice daily',
        'Initiate a 5-minute typing stress test session mid-week',
        'Schedule a light check-in conversation with your counselor'
      ];
    } else {
      statusTitle = 'Elevated Cognitive Friction';
      statusColor = const Color(0xFFEF4444);
      reportSummary = 'Elevated cognitive and emotional tension was observed. Your Drift Index indicates high stress levels. Backspace rates and prolonged typing pauses reflect severe mental fatigue. We strongly advise taking a proactive break, practicing 4-7-8 breathing, and scheduling a check-in.';
      recommendations = [
        'Engage in deep 4-7-8 breathing for 10 minutes immediately',
        'Pause active typing logs for a dedicated mental-health break',
        'Schedule a clinical consultation appointment with Dr. Panipuri'
      ];
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Weekly report'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Atmospheric Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
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
          // Ambient soft glowing background bubbles
          Positioned(
            top: -100,
            left: -100,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary.withValues(alpha: isDark ? 0.08 : 0.04),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                  child: const SizedBox(),
                ),
              ),
            ),
          ),

          // Scrollable layout
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Mockup Header Card: "Weekly AI Report"
                  SmoothCard(
                    backgroundColor: scheme.surface.withValues(alpha: 0.72),
                    borderColor: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.15),
                    borderRadius: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: scheme.primary.withValues(alpha: 0.22),
                              width: 1.0,
                            ),
                          ),
                          child: Icon(
                            Icons.description_outlined,
                            color: scheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weekly AI Report',
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Full mental health summary generated by AI',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : scheme.onSurface.withOpacity(0.54),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Mockup 3-Box Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildReportMetricBox(
                          label: 'Avg Drift',
                          valueWidget: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Icon(
                                Icons.trending_down_rounded,
                                color: statusColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$driftPercent',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: statusColor,
                                ),
                              ),
                              Text(
                                '/100',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white24 : Colors.black26,
                                ),
                              ),
                            ],
                          ),
                          isDark: isDark,
                          scheme: scheme,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildReportMetricBox(
                          label: 'Avg Mood',
                          valueWidget: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                avgMood.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: scheme.secondary,
                                ),
                              ),
                              Text(
                                '/10',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white24 : Colors.black26,
                                ),
                              ),
                            ],
                          ),
                          isDark: isDark,
                          scheme: scheme,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildReportMetricBox(
                          label: 'Journals',
                          valueWidget: Text(
                            '$journalCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          isDark: isDark,
                          scheme: scheme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 3. Generation Card & Compiled Summary Results
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 360),
                    child: _isGenerating
                        ? _buildLoadingCard(isDark, scheme)
                        : _reportGenerated
                            ? _buildReportResultCard(
                                isDark: isDark,
                                scheme: scheme,
                                statusTitle: statusTitle,
                                statusColor: statusColor,
                                reportSummary: reportSummary,
                                recommendations: recommendations,
                              )
                            : _buildGeneratePromptCard(isDark, scheme),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportMetricBox({
    required String label,
    required Widget valueWidget,
    required bool isDark,
    required ColorScheme scheme,
  }) {
    return SmoothCard(
      backgroundColor: scheme.surface.withValues(alpha: 0.72),
      borderColor: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.15),
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white38 : scheme.onSurface.withOpacity(0.54),
            ),
          ),
          const SizedBox(height: 8),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildGeneratePromptCard(bool isDark, ColorScheme scheme) {
    return SmoothCard(
      backgroundColor: scheme.surface.withValues(alpha: 0.72),
      borderColor: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.15),
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withValues(alpha: 0.08),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.16),
                width: 1.0,
              ),
            ),
            child: Icon(
              Icons.auto_awesome_outlined,
              color: scheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Generate your weekly mental health report',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : scheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'AI analyses your Drift Index, mood logs, journal entries, and typing stress to produce a clinical-grade summary.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: isDark ? Colors.white38 : scheme.onSurface.withOpacity(0.54),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _generateReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : scheme.primary,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: const Text(
              'Generate Report',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(bool isDark, ColorScheme scheme) {
    return SmoothCard(
      backgroundColor: scheme.surface.withValues(alpha: 0.72),
      borderColor: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.15),
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Compiling AI Analysis',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _generationStep > 0 && _generationStep <= _steps.length
                    ? _steps[_generationStep - 1]
                    : 'Initializing diagnostics...',
                key: ValueKey<int>(_generationStep),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportResultCard({
    required bool isDark,
    required ColorScheme scheme,
    required String statusTitle,
    required Color statusColor,
    required String reportSummary,
    required List<String> recommendations,
  }) {
    return SmoothCard(
      backgroundColor: scheme.surface.withValues(alpha: 0.72),
      borderColor: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.15),
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status indicator dot + statusTitle
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.36),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                statusTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main summary text
          Text(
            reportSummary,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? Colors.white.withOpacity(0.72) : scheme.onSurface.withOpacity(0.78),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: scheme.onSurface.withOpacity(0.08)),
          const SizedBox(height: 18),

          // Recommendation Label
          Text(
            'Recommended Clinical Actions',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          // List of recommendations
          ...recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: statusColor,
                      size: 15,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: isDark ? Colors.white60 : scheme.onSurface.withOpacity(0.68),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 20),
          Divider(height: 1, color: scheme.onSurface.withOpacity(0.08)),
          const SizedBox(height: 18),

          // Export & Share Row buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    AppSnackBar.showInfo(context, title: 'Share Report', message: 'Ready to share report with Dr. Panipuri.');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: const Text('Share'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    AppSnackBar.showSuccess(context, title: 'Export Complete', message: 'Weekly Report exported as PDF successfully.');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Export PDF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
