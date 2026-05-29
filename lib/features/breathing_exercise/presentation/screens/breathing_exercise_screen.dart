import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_state.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/smooth_widgets.dart';

class BreathingExerciseScreen extends ConsumerStatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  ConsumerState<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends ConsumerState<BreathingExerciseScreen>
    with TickerProviderStateMixin {
  
  Timer? _timer;
  late AnimationController _scaleController;
  
  int _selectedTechniqueIndex = 0;
  bool _isRecommending = false;
  bool _isRunning = false;
  
  int _currentPhaseIndex = 0; // 0=Inhale, 1=Hold1, 2=Exhale, 3=Hold2
  int _secondsRemaining = 0;
  int _cycleCount = 0;

  final List<_BreathingTechnique> _techniques = const [
    _BreathingTechnique(
      name: 'Box Breathing',
      pattern: '4-4-4-4 pattern',
      description: 'High stress, anxiety',
      longDescription: 'Equal counts. Used by Navy SEALs for acute stress.',
      inhaleSeconds: 4,
      holdSeconds1: 4,
      exhaleSeconds: 4,
      holdSeconds2: 4,
    ),
    _BreathingTechnique(
      name: '4-7-8 Breathing',
      pattern: '4-7-8 pattern',
      description: 'Panic, insomnia',
      longDescription: 'Dr. Andrew Weil technique. Promotes deep sleep and panic control.',
      inhaleSeconds: 4,
      holdSeconds1: 7,
      exhaleSeconds: 8,
      holdSeconds2: 0,
    ),
    _BreathingTechnique(
      name: 'Coherent Breathing',
      pattern: '5-5 pattern',
      description: 'General anxiety',
      longDescription: 'Resonant frequency breathing. Balances heart rate and anxiety.',
      inhaleSeconds: 5,
      holdSeconds1: 0,
      exhaleSeconds: 5,
      holdSeconds2: 0,
    ),
    _BreathingTechnique(
      name: 'Physiological Sigh',
      pattern: '2-1-8 pattern',
      description: 'Immediate relief',
      longDescription: 'Double inhale, single exhale. Rapidly reduces carbon dioxide and heart rate.',
      inhaleSeconds: 2,
      holdSeconds1: 1,
      exhaleSeconds: 8,
      holdSeconds2: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  void _startExercise() {
    final technique = _techniques[_selectedTechniqueIndex];
    setState(() {
      _isRunning = true;
      _currentPhaseIndex = 0;
      _cycleCount = 0;
      _secondsRemaining = technique.inhaleSeconds;
    });

    _runPhaseAnimation();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _startNextPhase();
      }
    });
  }

  void _stopExercise() {
    _timer?.cancel();
    _scaleController.animateTo(1.0, duration: const Duration(milliseconds: 360));
    setState(() {
      _isRunning = false;
      _currentPhaseIndex = 0;
      _secondsRemaining = 0;
      _cycleCount = 0;
    });
  }

  void _startNextPhase() {
    if (!_isRunning) return;

    final technique = _techniques[_selectedTechniqueIndex];
    int nextPhase = (_currentPhaseIndex + 1) % 4;

    // Loop to find the next valid phase (duration > 0)
    for (int i = 0; i < 4; i++) {
      final seconds = _getDurationForPhase(technique, nextPhase);
      if (seconds > 0) {
        break;
      }
      if (nextPhase == 0) {
        setState(() => _cycleCount++);
      }
      nextPhase = (nextPhase + 1) % 4;
    }

    setState(() {
      _currentPhaseIndex = nextPhase;
      _secondsRemaining = _getDurationForPhase(technique, _currentPhaseIndex);
    });

    _runPhaseAnimation();
  }

  void _runPhaseAnimation() {
    final duration = Duration(seconds: _secondsRemaining);
    if (_currentPhaseIndex == 0) {
      // Inhale: expand smooth scale
      _scaleController.animateTo(1.5, duration: duration, curve: Curves.easeInOutCubic);
    } else if (_currentPhaseIndex == 2) {
      // Exhale: contract smooth scale
      _scaleController.animateTo(1.0, duration: duration, curve: Curves.easeInOutCubic);
    }
  }

  int _getDurationForPhase(_BreathingTechnique technique, int phaseIndex) {
    switch (phaseIndex) {
      case 0: return technique.inhaleSeconds;
      case 1: return technique.holdSeconds1;
      case 2: return technique.exhaleSeconds;
      case 3: return technique.holdSeconds2;
      default: return 0;
    }
  }

  String _getLabelForPhase(int phaseIndex) {
    switch (phaseIndex) {
      case 0: return 'Inhale';
      case 1: return 'Hold';
      case 2: return 'Exhale';
      case 3: return 'Hold';
      default: return '';
    }
  }

  void _askAiRecommendation(AppProfile? profile) async {
    setState(() => _isRecommending = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final currentDrift = profile?.driftIndex ?? 0.18;
    final driftIndexPercent = (currentDrift * 100).toInt();

    int recommendedIndex;
    String reason;

    if (driftIndexPercent >= 65) {
      recommendedIndex = 3; // Physiological Sigh
      reason = 'Your Drift Index is high ($driftIndexPercent) indicating elevated stress. Physiological Sigh is recommended for rapid relief.';
    } else if (driftIndexPercent >= 35) {
      recommendedIndex = 1; // 4-7-8 Breathing
      reason = 'Your Drift Index is elevated ($driftIndexPercent). 4-7-8 breathing is recommended to restore calmness and deep focus.';
    } else {
      recommendedIndex = 0; // Box Breathing
      reason = 'Your Drift Index is stable ($driftIndexPercent). Box Breathing is recommended to maintain your calm wellness state.';
    }

    setState(() {
      _isRecommending = false;
      _selectedTechniqueIndex = recommendedIndex;
    });

    AppSnackBar.showSuccess(
      context,
      title: 'AI Recommendation',
      message: reason,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final session = ref.watch(appSessionProvider);
    final profile = session.profile;
    final driftPercent = ((profile?.driftIndex ?? 0.18) * 100).toInt();

    final activeTechnique = _techniques[_selectedTechniqueIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Breath Coach'),
        centerTitle: true,
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header Card ──
                SmoothCard(
                  backgroundColor: scheme.surface.withValues(alpha: 0.72),
                  borderColor: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.08),
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.16),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.air_rounded,
                          color: scheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Breath Coach',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'AI-guided breathing for stress relief',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: scheme.onSurface.withValues(alpha: 0.58),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── AI Recommendation Card ──
                SmoothCard(
                  backgroundColor: scheme.surface.withValues(alpha: 0.72),
                  borderColor: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.psychology_outlined,
                                color: scheme.onSurface.withValues(alpha: 0.9),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AI Recommendation',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            onPressed: _isRunning || _isRecommending
                                ? null
                                : () => _askAiRecommendation(profile),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(
                                color: scheme.primary.withOpacity(0.24),
                                width: 1.0,
                              ),
                            ),
                            icon: _isRecommending
                                ? SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: scheme.primary,
                                    ),
                                  )
                                : Icon(Icons.auto_awesome, size: 12, color: scheme.primary),
                            label: Text(
                              _isRecommending ? 'Analyzing...' : 'Ask AI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click "Ask AI" to get a personalised breathing recommendation based on your Drift Index ($driftPercent).',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withValues(alpha: 0.48),
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Selection Grid (2x2) ──
                Row(
                  children: [
                    Expanded(
                      child: _buildTechniqueCard(0),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTechniqueCard(1),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTechniqueCard(2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTechniqueCard(3),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Active Sequencer Panel ──
                SmoothCard(
                  backgroundColor: scheme.surface.withValues(alpha: 0.72),
                  borderColor: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
                  child: Column(
                    children: [
                      // Large guided breathing pulse circle
                      Center(
                        child: SizedBox(
                          width: 230,
                          height: 230,
                          child: AnimatedBuilder(
                            animation: _scaleController,
                            builder: (context, child) {
                              final double currentScale = _scaleController.value;
                              return Container(
                                width: 130 * currentScale,
                                height: 130 * currentScale,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF10B981).withValues(alpha: 0.04),
                                  border: Border.all(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.36),
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.18 * currentScale),
                                      blurRadius: 28 * currentScale,
                                      spreadRadius: 2 * currentScale,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.air_rounded,
                                        size: 28,
                                        color: const Color(0xFF10B981).withOpacity(0.85),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _isRunning ? _getLabelForPhase(_currentPhaseIndex) : 'Ready',
                                        style: TextStyle(
                                          color: scheme.onSurface,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      if (_isRunning) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_secondsRemaining}s',
                                          style: TextStyle(
                                            color: const Color(0xFF10B981).withOpacity(0.85),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Horizontal phase duration capsules
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildPhaseBox('Inhale', '${activeTechnique.inhaleSeconds}s', _isRunning && _currentPhaseIndex == 0),
                          const SizedBox(width: 8),
                          _buildPhaseBox('Hold', '${activeTechnique.holdSeconds1}s', _isRunning && _currentPhaseIndex == 1),
                          const SizedBox(width: 8),
                          _buildPhaseBox('Exhale', '${activeTechnique.exhaleSeconds}s', _isRunning && _currentPhaseIndex == 2),
                          const SizedBox(width: 8),
                          _buildPhaseBox('Hold', '${activeTechnique.holdSeconds2}s', _isRunning && _currentPhaseIndex == 3),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Start / Stop controller play pill button
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0FA58A), Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isRunning ? _stopExercise : _startExercise,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: Icon(
                              _isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: Text(
                              _isRunning ? 'Stop' : 'Start',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Bottom descriptive subtext
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            activeTechnique.longDescription,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.36),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildTechniqueCard(int index) {
    final technique = _techniques[index];
    final isSelected = _selectedTechniqueIndex == index;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _isRunning
          ? null
          : () {
              setState(() {
                _selectedTechniqueIndex = index;
              });
            },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF10B981).withValues(alpha: 0.06)
              : scheme.onSurface.withValues(alpha: isDark ? 0.02 : 0.035),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981)
                : scheme.onSurface.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    blurRadius: 12,
                    spreadRadius: 0.5,
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              technique.name,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              technique.pattern,
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurface.withValues(alpha: 0.48),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              technique.description,
              style: TextStyle(
                fontSize: 11.5,
                color: isSelected ? const Color(0xFF10B981) : scheme.onSurface.withValues(alpha: 0.36),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseBox(String label, String duration, bool isActive) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isActive 
            ? const Color(0xFF10B981).withValues(alpha: 0.08) 
            : scheme.onSurface.withValues(alpha: isDark ? 0.02 : 0.035),
        border: Border.all(
          color: isActive 
              ? const Color(0xFF10B981) 
              : scheme.onSurface.withValues(alpha: 0.08),
          width: isActive ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? scheme.onSurface : scheme.onSurface.withValues(alpha: 0.45),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            duration,
            style: TextStyle(
              color: isActive ? const Color(0xFF10B981) : scheme.onSurface.withValues(alpha: 0.7),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreathingTechnique {
  final String name;
  final String pattern;
  final String description;
  final String longDescription;
  final int inhaleSeconds;
  final int holdSeconds1;
  final int exhaleSeconds;
  final int holdSeconds2;

  const _BreathingTechnique({
    required this.name,
    required this.pattern,
    required this.description,
    required this.longDescription,
    required this.inhaleSeconds,
    required this.holdSeconds1,
    required this.exhaleSeconds,
    required this.holdSeconds2,
  });
}
