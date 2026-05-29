import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/smooth_widgets.dart';

class TypingTestScreen extends ConsumerStatefulWidget {
  const TypingTestScreen({super.key});

  @override
  ConsumerState<TypingTestScreen> createState() => _TypingTestScreenState();
}

class _TypingTestScreenState extends ConsumerState<TypingTestScreen> 
    with SingleTickerProviderStateMixin {
    
  static const _prompt =
      'Take a slow breath and focus only on the next word. Writing steadily can help organize thoughts, soften tension, and bring attention back to the present moment.';

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _timer;
  DateTime? _startTime;
  int _elapsedSeconds = 0;
  int _backspaceCount = 0;
  int _previousLength = 0;
  bool _isFinished = false;

  // Breathing Guide Animation
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    // Initialize subtle 4-second cycle breathing animation
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _stopTimer();
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _breathingController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _onTextChanged() {
    if (_isFinished) return;

    final text = _controller.text;
    if (_startTime == null && _normalize(text).isNotEmpty) {
      _startTime = DateTime.now();
      _startTimer();
    }

    if (text.length < _previousLength) {
      _backspaceCount++;
    }
    _previousLength = text.length;

    if (_isComplete(text)) {
      _finishTest();
    } else {
      setState(() {});
    }
  }

  void _startTimer() {
    if (_timer?.isActive ?? false) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isFinished) return;
      setState(() => _elapsedSeconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _finishTest() {
    if (_isFinished) return;

    _isFinished = true;
    _stopTimer();
    _focusNode.unfocus();

    final elapsed = _elapsedForResult();
    final wpm = _calculateWpm(elapsed);
    final accuracy = _calculateAccuracy();
    
    final result = _TypingResult(
      wpm: wpm,
      accuracy: accuracy,
      corrections: _backspaceCount,
      elapsedSeconds: elapsed,
      insight: _buildInsight(
        wpm: wpm,
        accuracy: accuracy,
        corrections: _backspaceCount,
      ),
    );

    _elapsedSeconds = elapsed;

    var stressScore = 0.0;
    if (result.wpm < 30) stressScore += 0.4;
    if (result.wpm < 50) stressScore += 0.2;
    if (result.corrections > 5) stressScore += 0.2;
    if (result.corrections > 10) stressScore += 0.3;
    if (result.accuracy < 90) stressScore += 0.2;

    stressScore = stressScore.clamp(0.0, 1.0);

    final profile = ref.read(appSessionProvider).profile;
    if (profile != null) {
      ref.read(appSessionProvider.notifier).updateProfile(
            profile.copyWith(
              driftIndex: (profile.driftIndex + stressScore) / 2.0,
            ),
          );
    }

    HapticFeedback.mediumImpact();
    
    // Trigger the stunning centered reflection modal dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showCompletionDialog(result);
      }
    });

    setState(() {});
  }

  void _showCompletionDialog(_TypingResult result) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Mindful Reflection',
      barrierColor: Colors.black.withValues(alpha: 0.62),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.zero,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: _PremiumReportCard(
                    result: result,
                    onRetry: () {
                      Navigator.of(context).pop();
                      _resetTest();
                    },
                    onDone: () {
                      Navigator.of(context).pop(); // Dismiss Dialog
                      Navigator.of(context).pop(); // Return from Screen
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _resetTest() {
    _stopTimer();
    _controller.clear();
    setState(() {
      _startTime = null;
      _elapsedSeconds = 0;
      _backspaceCount = 0;
      _previousLength = 0;
      _isFinished = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  bool _isComplete(String typed) => _normalize(typed) == _normalize(_prompt);

  String _normalize(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  int _elapsedForResult() {
    final startedAt = _startTime;
    if (startedAt == null) return 1;
    return DateTime.now().difference(startedAt).inSeconds.clamp(1, 3600);
  }

  int _calculateWpm([int? elapsed]) {
    final seconds = (elapsed ?? _elapsedSeconds).clamp(1, 3600);
    final normalized = _normalize(_controller.text);
    final typedWords = normalized.isEmpty
        ? 0
        : normalized.split(RegExp(r'\s+')).length;
    return (typedWords / (seconds / 60)).round();
  }

  double _calculateAccuracy() {
    final typed = _normalize(_controller.text);
    final prompt = _normalize(_prompt);
    if (typed.isEmpty) return 0;

    var correct = 0;
    for (var i = 0; i < typed.length && i < prompt.length; i++) {
      if (typed[i] == prompt[i]) correct++;
    }
    return (correct / typed.length * 100).clamp(0, 100);
  }

  String _buildInsight({
    required int wpm,
    required double accuracy,
    required int corrections,
  }) {
    if (accuracy >= 95 && corrections <= 3) {
      return 'Your focus looked steady and calm. Keep using this slower, deliberate rhythm when your mind feels busy.';
    }
    if (corrections >= 10) {
      return 'Frequent corrections can show rushing or distraction. Take a slow breath before the next attempt and let each word arrive one at a time.';
    }
    if (accuracy < 70) {
      return 'Focus drift showed up during this round. That is useful feedback, not a failure. Try relaxing your shoulders and continuing at a gentler pace.';
    }
    if (wpm < 25) {
      return 'Your pace was measured and reflective. If it felt effortful, pause for one breath before restarting.';
    }
    return 'Your typing rhythm was balanced. Small errors are normal; noticing them without tension is part of the exercise.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final displayedWpm = _calculateWpm();
    final displayedAccuracy = _calculateAccuracy();
    final displayedCorrections = _backspaceCount;
    final displayedSeconds = _elapsedSeconds;
    final progress = (_normalize(_controller.text).length / _normalize(_prompt).length)
        .clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing Stress Test'),
        centerTitle: true,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 580),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min, // Make column tight and centered vertically
              children: [
                // Elegant central circular breathing guide
                Center(
                  child: AnimatedBuilder(
                    animation: _breathingController,
                    builder: (context, child) {
                      final value = _breathingController.value;
                      final scale = 1.0 + (value * 0.15); // Scale from 1.0 to 1.15
                      final text = value < 0.5 ? 'Hold & Inhale...' : 'Pause & Exhale...';

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Concentric glowing halo 2
                              Transform.scale(
                                scale: scale * 1.28,
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF0FA58A).withValues(alpha: 0.05),
                                    border: Border.all(
                                      color: const Color(0xFF0FA58A).withValues(alpha: 0.1),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                              // Concentric glowing halo 1
                              Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 82,
                                  height: 82,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF0FA58A).withValues(alpha: 0.12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0FA58A).withValues(alpha: 0.22),
                                        blurRadius: 18,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Central Circle
                              Container(
                                width: 68,
                                height: 68,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF0FA58A), Color(0xFF14B8A6)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.spa_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            text,
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // Prompt Glassmorphic Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF14B8A6), Color(0xFF0B7A66)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0FA58A).withValues(alpha: 0.16),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19.0,
                        fontWeight: FontWeight.w600,
                        height: 1.65,
                      ),
                      children: _buildPromptSpans(context),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Live metrics arranged horizontally in a sleek premium stats bar
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161D26) : scheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: scheme.subtleBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _CompactStat(label: 'Time', value: '${displayedSeconds}s', icon: Icons.timer_outlined),
                      _CompactStat(label: 'Speed', value: '$displayedWpm WPM', icon: Icons.speed_rounded),
                      _CompactStat(label: 'Accuracy', value: '${displayedAccuracy.round()}%', icon: Icons.gps_fixed_rounded),
                      _CompactStat(label: 'Fixes', value: '$displayedCorrections', icon: Icons.keyboard_backspace_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                
                // Typing input card with focus glow
                SmoothCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(12),
                  borderColor: scheme.subtleBorder,
                  backgroundColor: isDark ? const Color(0xFF161D26) : scheme.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AnimatedBuilder(
                        animation: _breathingAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _focusNode.hasFocus
                                  ? [
                                      BoxShadow(
                                        color: scheme.primary.withValues(
                                          alpha: 0.12 + (_breathingAnimation.value * 0.08),
                                        ),
                                        blurRadius: 10 + (_breathingAnimation.value * 6),
                                        spreadRadius: 0.5 + (_breathingAnimation.value * 1.0),
                                      )
                                    ]
                                  : [],
                            ),
                            child: child,
                          );
                        },
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          enabled: !_isFinished,
                          autocorrect: false,
                          enableSuggestions: false,
                          smartDashesType: SmartDashesType.disabled,
                          smartQuotesType: SmartQuotesType.disabled,
                          autofocus: true,
                          minLines: 3,
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          cursorColor: scheme.primary,
                          cursorWidth: 3,
                          cursorRadius: const Radius.circular(4),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.55,
                            color: scheme.onSurface,
                            fontSize: 14.5,
                          ),
                          contextMenuBuilder: (context, editableTextState) {
                            final List<ContextMenuButtonItem> buttonItems =
                                editableTextState.contextMenuButtonItems;
                            buttonItems.removeWhere((item) =>
                                item.type == ContextMenuButtonType.paste);
                            return AdaptiveTextSelectionToolbar.buttonItems(
                              anchors: editableTextState.contextMenuAnchors,
                              buttonItems: buttonItems,
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Match the breathing rhythm & type here...',
                            hintStyle: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.38),
                              fontWeight: FontWeight.w400,
                            ),
                            suffixIcon: _controller.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Reset',
                                    onPressed: _resetTest,
                                    icon: Icon(Icons.close_rounded, color: scheme.mutedText),
                                  ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF1C2430)
                                : scheme.surfaceContainerHighest.withValues(alpha: 0.25),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: scheme.subtleBorder,
                                width: 1.1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: scheme.primary,
                                width: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Action controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Tiny progress bar
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 4,
                                  backgroundColor: scheme.faintTrack,
                                  valueColor: AlwaysStoppedAnimation(scheme.primary),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: _resetTest,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  minimumSize: const Size(60, 34),
                                ),
                                child: const Text('Reset'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                onPressed: _finishTest,
                                style: FilledButton.styleFrom(
                                  backgroundColor: scheme.primary,
                                  foregroundColor: scheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  minimumSize: const Size(80, 34),
                                ),
                                child: const Text('Finish'),
                              ),
                            ],
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
      ),
    );
  }

  List<TextSpan> _buildPromptSpans(BuildContext context) {
    final typed = _controller.text;
    final spans = <TextSpan>[];
    
    final selectionOffset = _controller.selection.baseOffset;
    final currentIndex = (selectionOffset < 0 ? typed.length : selectionOffset)
        .clamp(0, _prompt.length);

    for (var i = 0; i < _prompt.length; i++) {
      final isCurrent = i == currentIndex && !_isFinished;
      final hasTyped = i < typed.length;
      final isWrong = hasTyped && typed[i] != _prompt[i];

      spans.add(
        TextSpan(
          text: _prompt[i],
          style: TextStyle(
            color: isWrong
                ? const Color(0xFFFFB0B0)
                : hasTyped
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.52),
            backgroundColor: isCurrent
                ? Colors.white.withValues(alpha: 0.28)
                : Colors.transparent,
            decoration: isWrong ? TextDecoration.underline : null,
            decorationColor: const Color(0xFFFFB0B0),
            decorationThickness: 2.0,
            fontWeight: hasTyped ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      );
    }

    if (typed.length > _prompt.length) {
      spans.add(
        TextSpan(
          text: typed.substring(_prompt.length),
          style: const TextStyle(
            color: Color(0xFFFFB0B0),
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFFFFB0B0),
            decorationThickness: 2.0,
          ),
        ),
      );
    }

    return spans;
  }
}

class _CompactStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _CompactStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: scheme.primary.withValues(alpha: 0.8)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
                fontSize: 11.5,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.mutedText,
                fontSize: 8.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PremiumReportCard extends StatelessWidget {
  final _TypingResult result;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  const _PremiumReportCard({
    required this.result,
    required this.onRetry,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SmoothCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      backgroundColor: isDark ? const Color(0xFF161C24) : scheme.surface,
      borderColor: scheme.primary.withValues(alpha: 0.22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.spa_rounded,
                  color: scheme.primary,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Wellness Reflection',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Your pacing and focus diagnostics',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.mutedText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _ReportMetric(label: 'Pace', value: '${result.wpm} WPM', icon: Icons.speed_rounded),
              _ReportMetric(label: 'Accuracy', value: '${result.accuracy.round()}%', icon: Icons.gps_fixed_rounded),
              _ReportMetric(label: 'Corrections', value: '${result.corrections}', icon: Icons.keyboard_backspace_rounded),
              _ReportMetric(label: 'Time', value: '${result.elapsedSeconds}s', icon: Icons.timer_outlined),
            ],
          ),
          const SizedBox(height: 16),
          
          // Insight
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: scheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mindful Insight',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        result.insight,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.8),
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Retry Test'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onDone,
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReportMetric({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 102,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2430) : scheme.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: scheme.primary.withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.mutedText,
                    fontSize: 8.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingResult {
  final int wpm;
  final double accuracy;
  final int corrections;
  final int elapsedSeconds;
  final String insight;

  const _TypingResult({
    required this.wpm,
    required this.accuracy,
    required this.corrections,
    required this.elapsedSeconds,
    required this.insight,
  });
}
