import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/ollama_service.dart';

class CalmoraAiSheet extends ConsumerStatefulWidget {
  const CalmoraAiSheet({super.key});

  @override
  ConsumerState<CalmoraAiSheet> createState() => _CalmoraAiSheetState();
}

class _CalmoraAiSheetState extends ConsumerState<CalmoraAiSheet> {
  final _controller = TextEditingController();
  final _endpoint = Uri.parse('http://10.16.209.73:8000/chat');
  String _chatHistory =
      'CalmoraAI: Hello! I am CalmoraAI, your privacy-focused assistant. Let\'s explore what\'s on your mind together.\n\n';
  String _aiContext =
      'You are Calmora, a concise mental wellness assistant. Use Cognitive Behavioral Therapy (CBT) guided responses. Focus on cognitive restructuring, identifying cognitive distortions, and gentle behavioral activation. Be warm, practical, non-clinical, and suggest emergency help for crisis risk.\n\n';
  bool _loading = false;
  final String _selectedModel = OllamaService.defaultQuantizedModel;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _queryOllama(String prompt) async {
    final ai = OllamaService(endpoint: _endpoint);
    return await ai.summarize(prompt: prompt);
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) {
      return;
    }

    setState(() {
      _loading = true;
      _chatHistory += 'You: $text\n\n';
    });

    _controller.clear();

    try {
      _aiContext += 'User: $text\nCalmoraAI:';
      final response = await _queryOllama(_aiContext);

      final replyText = response.trim().isEmpty
          ? 'I could not generate a useful response. Try again in a moment.'
          : response.trim();

      _aiContext += ' $replyText\n\n';
      setState(() => _chatHistory += 'CalmoraAI: $replyText\n\n');
    } catch (_) {
      final mockResponse = _generateMockResponse(text);
      final errorNote =
          '(Quantized model is configured for $_selectedModel, but Ollama is not reachable. Start Ollama on port 8000 or update the endpoint.)';
      final fullReply = '$mockResponse\n\n$errorNote';

      _aiContext += ' $fullReply\n\n';
      setState(() => _chatHistory += 'CalmoraAI: $fullReply\n\n');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _generateMockResponse(String userInput) {
    final input = userInput.toLowerCase();
    if (input.contains('sad') || input.contains('depressed')) {
      return 'It sounds like you\'re carrying a heavy weight. Let\'s look at your thoughts right now. Are you perhaps engaging in "all-or-nothing" thinking? What\'s a small, gentle action you could take today to break the cycle?';
    } else if (input.contains('anxious') || input.contains('worried')) {
      return 'Anxiety often tells us a story about the worst-case scenario. Can we try to challenge that thought? Is there concrete evidence that the worst will happen, or is it a "what if"? Let\'s try to find a more balanced perspective.';
    } else if (input.contains('happy') || input.contains('good')) {
      return 'I\'m glad you\'re feeling positive! It\'s important to recognize and savor these moments. What specific thought or action helped you feel this way?';
    } else if (input.contains('overwhelmed') || input.contains('stress')) {
      return 'When we feel overwhelmed, our mind can "catastrophize." Let\'s break this down into smaller, manageable steps. What is one tiny thing you can focus on right now instead of the whole picture?';
    } else if (input.contains('worthless') || input.contains('failure')) {
      return 'That sounds like a very painful "labeling" thought. Remember, a single mistake or difficult moment doesn\'t define your worth. What would you say to a good friend who told you they felt this way?';
    } else {
      return 'Thank you for sharing that. It\'s completely normal to have complex feelings. Let\'s explore the thought behind the emotion. What\'s the main story your mind is telling you right now?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 18),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: isDark ? 0.16 : 0.10),
            blurRadius: 34,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? scheme.surface.withValues(alpha: 0.84)
                  : scheme.surface.withValues(alpha: 0.94),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.18),
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 76,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.08),
                      border: Border(
                        bottom: BorderSide(
                          color: scheme.primary.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              color: scheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CalmoraAI',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                Text(
                                  'Privacy-focused chatbot',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.58,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close_rounded,
                              color: scheme.onSurface.withValues(alpha: 0.62),
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  scheme.onSurface.withValues(alpha: 0.06),
                              fixedSize: const Size(40, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          minHeight: 132,
                          maxHeight: 280,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? scheme.surfaceContainerHighest.withValues(
                                  alpha: 0.24,
                                )
                              : scheme.surfaceContainerHighest.withValues(
                                  alpha: 0.52,
                                ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: scheme.onSurface.withValues(alpha: 0.07),
                          ),
                        ),
                        child: _loading
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: scheme.primary,
                                    strokeWidth: 3,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Thinking through a helpful response...',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurface.withValues(
                                        alpha: 0.58,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : SingleChildScrollView(
                                child: Text(
                                  _chatHistory.trim(),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.55,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                          color: scheme.surface.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: scheme.onSurface.withValues(alpha: 0.08),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.14 : 0.04,
                              ),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          style: theme.textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.42),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: IconButton(
                                tooltip: 'Send securely',
                                onPressed: _send,
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: scheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.send_rounded,
                                    color: scheme.onPrimary,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
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
}
