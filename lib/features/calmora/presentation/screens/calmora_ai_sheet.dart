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
                      // Beautiful Scrollable Message Panel
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          minHeight: 180,
                          maxHeight: 320,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF131A26).withValues(alpha: 0.6)
                              : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.12),
                          ),
                        ),
                        child: SingleChildScrollView(
                          reverse: true, // Auto scroll to bottom
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ..._chatHistory
                                  .split('\n\n')
                                  .map((b) => b.trim())
                                  .where((b) => b.isNotEmpty)
                                  .map((bubble) {
                                final isUser = bubble.startsWith('You:');
                                final cleanContent = isUser
                                    ? bubble.replaceFirst('You:', '').trim()
                                    : bubble.replaceFirst('CalmoraAI:', '').trim();

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment: isUser
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!isUser) ...[
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: scheme.primary.withValues(alpha: 0.16),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.auto_awesome,
                                            size: 14,
                                            color: scheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isUser
                                                ? scheme.secondary.withValues(alpha: 0.14)
                                                : scheme.primary.withValues(
                                                    alpha: isDark ? 0.18 : 0.08,
                                                  ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: const Radius.circular(16),
                                              topRight: const Radius.circular(16),
                                              bottomLeft: isUser
                                                  ? const Radius.circular(16)
                                                  : const Radius.circular(4),
                                              bottomRight: isUser
                                                  ? const Radius.circular(4)
                                                  : const Radius.circular(16),
                                            ),
                                            border: Border.all(
                                              color: isUser
                                                  ? scheme.secondary.withValues(alpha: 0.22)
                                                  : scheme.primary.withValues(alpha: 0.16),
                                            ),
                                          ),
                                          child: Text(
                                            cleanContent,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: scheme.onSurface,
                                              height: 1.45,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isUser) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: scheme.secondary.withValues(alpha: 0.16),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.person,
                                            size: 14,
                                            color: scheme.secondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }),
                              if (_loading) ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: scheme.primary.withValues(alpha: 0.16),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.auto_awesome,
                                        size: 14,
                                        color: scheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: scheme.primary.withValues(
                                          alpha: isDark ? 0.18 : 0.08,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                          bottomLeft: Radius.circular(4),
                                          bottomRight: Radius.circular(16),
                                        ),
                                        border: Border.all(
                                          color: scheme.primary.withValues(alpha: 0.16),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              valueColor:
                                                  AlwaysStoppedAnimation(Color(0xFF0FA58A)),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Calmora is reflecting...',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: scheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Premium Glowing Input field
                      Container(
                        decoration: BoxDecoration(
                          color: scheme.surface.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.24),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withValues(
                                alpha: isDark ? 0.16 : 0.04,
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
                              horizontal: 18,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
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
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: scheme.primary.withValues(alpha: 0.35),
                                        blurRadius: 6,
                                      ),
                                    ],
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
