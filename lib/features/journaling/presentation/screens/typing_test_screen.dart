import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/smooth_widgets.dart';

class TypingTestScreen extends ConsumerStatefulWidget {
  const TypingTestScreen({super.key});

  @override
  ConsumerState<TypingTestScreen> createState() => _TypingTestScreenState();
}

class _TypingTestScreenState extends ConsumerState<TypingTestScreen> {
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
  _TypingResult? _finalResult;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _stopTimer();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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
    _finalResult = result;

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

    HapticFeedback.lightImpact();
    AppSnackBar.showSuccess(
      context,
      title: 'Test completed',
      message: 'WPM: ${result.wpm} | Accuracy: ${result.accuracy.round()}%',
    );
    setState(() {});
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
      _finalResult = null;
    });
    _focusNode.requestFocus();
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

    return Scaffold(
      appBar: AppBar(title: const Text('Typing Stress Test')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final result = _finalResult;
            final displayedWpm = result?.wpm ?? _calculateWpm();
            final displayedAccuracy = result?.accuracy ?? _calculateAccuracy();
            final displayedCorrections = result?.corrections ?? _backspaceCount;
            final displayedSeconds = result?.elapsedSeconds ?? _elapsedSeconds;
            final progress = result == null
                ? (_normalize(_controller.text).length /
                        _normalize(_prompt).length)
                    .clamp(0.0, 1.0)
                : 1.0;

            final heroPanel = _HeroPanel(
              elapsedSeconds: displayedSeconds,
              wpm: displayedWpm,
              accuracy: displayedAccuracy,
              progress: progress,
              backspaces: displayedCorrections,
            );
            final workspace = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TypingWorkspace(
                  prompt: _prompt,
                  controller: _controller,
                  focusNode: _focusNode,
                  isFinished: _isFinished,
                  onReset: _resetTest,
                  onFinish: _finishTest,
                ),
                if (result != null) ...[
                  const SizedBox(height: 16),
                  _CompletionCard(result: result, onRestart: _resetTest),
                ],
              ],
            );
            final content = [
              heroPanel,
              workspace,
            ];

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 280, child: content.first),
                        const SizedBox(width: 16),
                        Expanded(child: content.last),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        content.first,
                        const SizedBox(height: 16),
                        content.last,
                      ],
                    ),
            );
          },
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: _isFinished
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetTest,
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Restart Test'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final int elapsedSeconds;
  final int wpm;
  final double accuracy;
  final double progress;
  final int backspaces;

  const _HeroPanel({
    required this.elapsedSeconds,
    required this.wpm,
    required this.accuracy,
    required this.progress,
    required this.backspaces,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SmoothCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      backgroundColor: scheme.surface.withValues(alpha: 0.82),
      borderColor: scheme.primary.withValues(alpha: 0.14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.keyboard_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mindful focus',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Notice your pace, breathe through mistakes, and finish whenever you have enough signal.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.mutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: scheme.faintTrack,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricPill(label: 'Time', value: '${elapsedSeconds}s'),
              _MetricPill(label: 'WPM', value: '$wpm'),
              _MetricPill(label: 'Accuracy', value: '${accuracy.round()}%'),
              _MetricPill(label: 'Corrections', value: '$backspaces'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  final _TypingResult result;
  final VoidCallback onRestart;

  const _CompletionCard({
    required this.result,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SmoothCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      backgroundColor: const Color(0xFF20B486).withValues(alpha: 0.10),
      borderColor: const Color(0xFF20B486).withValues(alpha: 0.28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF20B486).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF20B486),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Typing test complete',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricPill(label: 'Final WPM', value: '${result.wpm}'),
              _MetricPill(
                label: 'Accuracy',
                value: '${result.accuracy.round()}%',
              ),
              _MetricPill(label: 'Corrections', value: '${result.corrections}'),
              _MetricPill(label: 'Time', value: '${result.elapsedSeconds}s'),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.spa_outlined,
                  color: scheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.insight,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.74),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
              FilledButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Restart Test'),
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetricPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.mutedText,
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

class _TypingWorkspace extends StatelessWidget {
  final String prompt;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFinished;
  final VoidCallback onReset;
  final VoidCallback onFinish;

  const _TypingWorkspace({
    required this.prompt,
    required this.controller,
    required this.focusNode,
    required this.isFinished,
    required this.onReset,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SmoothCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      borderColor: scheme.subtleBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mindful passage',
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Move naturally, correct what you notice, and press Finish Test whenever you want a reflection.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.62),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.26),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.subtleBorder),
            ),
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.65,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
                children: _buildPromptSpans(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: !isFinished,
            autocorrect: false,
            enableSuggestions: false,
            smartDashesType: SmartDashesType.disabled,
            smartQuotesType: SmartQuotesType.disabled,
            autofocus: true,
            minLines: 3,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            contextMenuBuilder: (context, editableTextState) {
              return const SizedBox.shrink();
            },
            cursorColor: scheme.primary,
            cursorWidth: 3,
            cursorRadius: const Radius.circular(4),
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
            decoration: InputDecoration(
              hintText: 'Start typing here...',
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Reset',
                      onPressed: onReset,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: isFinished ? null : onReset,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
              FilledButton.icon(
                onPressed: isFinished ? null : onFinish,
                icon: const Icon(Icons.flag_rounded),
                label: const Text('Finish Test'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildPromptSpans(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final typed = controller.text;
    final spans = <TextSpan>[];
    final selectionOffset = controller.selection.baseOffset;
    final currentIndex = (selectionOffset < 0 ? typed.length : selectionOffset)
        .clamp(0, prompt.length);

    for (var i = 0; i < prompt.length; i++) {
      final isCurrent = i == currentIndex && !isFinished;
      final hasTyped = i < typed.length;
      final isWrong = hasTyped && typed[i] != prompt[i];

      spans.add(
        TextSpan(
          text: prompt[i],
          style: TextStyle(
            color: isWrong
                ? scheme.error.withValues(alpha: 0.88)
                : hasTyped
                    ? scheme.onSurface
                    : scheme.onSurface.withValues(alpha: 0.46),
            backgroundColor: isCurrent
                ? scheme.primary.withValues(alpha: 0.14)
                : Colors.transparent,
            decoration: isWrong ? TextDecoration.underline : null,
            decorationColor: scheme.error,
            decorationThickness: 1.5,
          ),
        ),
      );
    }

    if (typed.length > prompt.length) {
      spans.add(
        TextSpan(
          text: typed.substring(prompt.length),
          style: TextStyle(
            color: scheme.error.withValues(alpha: 0.88),
            decoration: TextDecoration.underline,
            decorationColor: scheme.error,
            decorationThickness: 1.5,
          ),
        ),
      );
    }

    return spans;
  }
}
