import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_state.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/smooth_widgets.dart';



class TypingTestScreen extends ConsumerStatefulWidget {
  const TypingTestScreen({super.key});

  @override
  ConsumerState<TypingTestScreen> createState() => _TypingTestScreenState();
}

class _TypingTestScreenState extends ConsumerState<TypingTestScreen> {
  final _controller = TextEditingController();
  final String _prompt = "The quick brown fox jumps over the lazy dog. Writing helps to organize thoughts and soothe the mind. Take a deep breath and keep going.";
  int _backspaceCount = 0;
  DateTime? _startTime;
  bool _isFinished = false;
  int _previousLength = 0;
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    if (_isFinished) return;
    
    if (_startTime == null && _controller.text.isNotEmpty) {
      _startTime = DateTime.now();
      _startTimer();
    }

    final currentLength = _controller.text.length;
    if (currentLength < _previousLength) {
      _backspaceCount++;
    }
    _previousLength = currentLength;

    if (_controller.text.trim() == _prompt) {
      _finishTest();
    }
  }

  void _finishTest() {
    _isFinished = true;
    _timer?.cancel();
    
    final elapsed = DateTime.now().difference(_startTime!).inSeconds;
    final wpm = (_prompt.split(' ').length / (elapsed / 60)).round();
    
    // Calculate stress heuristic based on backspaces and slow WPM
    double stressScore = 0.0;
    if (wpm < 30) stressScore += 0.4;
    if (wpm < 50) stressScore += 0.2;
    if (_backspaceCount > 5) stressScore += 0.2;
    if (_backspaceCount > 10) stressScore += 0.3;
    
    stressScore = stressScore.clamp(0.0, 1.0);

    final profile = ref.read(appSessionProvider).profile;
    if (profile != null) {
      final newDriftIndex = (profile.driftIndex + stressScore) / 2.0;
      ref.read(appSessionProvider.notifier).updateProfile(
        profile.copyWith(driftIndex: newDriftIndex),
      );
    }

    AppSnackBar.showSuccess(
      context,
      title: 'Test Completed',
      message: 'WPM: $wpm | Backspaces: $_backspaceCount. Profile updated.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Typing Stress Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type the following text as quickly and accurately as possible. We analyze your typing pattern to assess stress levels.',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 16),
            SmoothCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                _prompt,
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            if (_startTime != null && !_isFinished)
              Text('Time: $_elapsedSeconds s', style: AppTypography.labelLarge),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                enabled: !_isFinished,
                decoration: const InputDecoration(
                  hintText: 'Start typing here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            if (_isFinished)
              Center(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
