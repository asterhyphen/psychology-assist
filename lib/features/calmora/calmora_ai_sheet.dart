import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/ollama_service.dart';

class CalmoraAiSheet extends ConsumerStatefulWidget {
  const CalmoraAiSheet({super.key});

  @override
  ConsumerState<CalmoraAiSheet> createState() => _CalmoraAiSheetState();
}

class _CalmoraAiSheetState extends ConsumerState<CalmoraAiSheet> {
  final _controller = TextEditingController();
  final _endpoint = Uri.parse('http://10.16.209.73:8000/chat');
  String _chatHistory = 'CalmoraAI: Hello! I am CalmoraAI, your privacy-focused assistant. Let\'s explore what\'s on your mind together.\n\n';
  String _aiContext = 'You are Calmora, a concise mental wellness assistant. Use Cognitive Behavioral Therapy (CBT) guided responses. Focus on cognitive restructuring, identifying cognitive distortions, and gentle behavioral activation. Be warm, practical, non-clinical, and suggest emergency help for crisis risk.\n\n';
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
      final errorNote = '(Quantized model is configured for $_selectedModel, but Ollama is not reachable. Start Ollama on port 8000 or update the endpoint.)';
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
      return 'Thank you for sharing that. It\'s completely normal to have complex feelings. Let\'s explore the thought behind the emotion—what\'s the main story your mind is telling you right now?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: isDark 
                  ? scheme.surface.withValues(alpha: 0.65)
                  : scheme.surface.withValues(alpha: 0.85),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.25),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Stack(
              children: [
                // Glowing orb background effect
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  scheme.primary.withValues(alpha: 0.8),
                                  scheme.tertiary.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CalmoraAI',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                    foreground: Paint()..shader = LinearGradient(
                                      colors: [scheme.primary, scheme.tertiary],
                                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                                  ),
                                ),
                                Text(
                                  'Privacy-Focused Chatbot',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: scheme.onSurface.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close,
                              color: scheme.onSurface.withValues(alpha: 0.4),
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: scheme.onSurface.withValues(alpha: 0.05),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Response area
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 120, maxHeight: 250),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? Colors.black.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: scheme.onSurface.withValues(alpha: 0.05),
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
                                    'Mixing the masalas together for the perfect dish',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurface.withValues(alpha: 0.5),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : SingleChildScrollView(
                                child: Text(
                                  _chatHistory.trim(),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      // Input
                      Container(
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
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
                            hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.4)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
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
                                  ),
                                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
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
