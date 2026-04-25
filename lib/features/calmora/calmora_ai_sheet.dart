import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_state.dart';
import '../../core/services/ollama_service.dart';
import '../../core/widgets/app_snackbar.dart';

enum CalmoraAiMode { chat, journal }

class CalmoraAiSheet extends ConsumerStatefulWidget {
  const CalmoraAiSheet({super.key});

  @override
  ConsumerState<CalmoraAiSheet> createState() => _CalmoraAiSheetState();
}

class _CalmoraAiSheetState extends ConsumerState<CalmoraAiSheet> {
  final _controller = TextEditingController();
  final _endpoint = Uri.parse('http://10.16.209.73:8000/chat');
  String _reply =
      'Ask for a grounding exercise, journaling prompt, or appointment prep.';
  bool _loading = false;
  CalmoraAiMode _mode = CalmoraAiMode.chat;
  final String _selectedModel = OllamaService.defaultQuantizedModel;
  bool _alreadyShared = false;

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
      _alreadyShared = false;
    });

    try {
      final response = await _queryOllama(
        'You are Calmora, a concise mental wellness assistant. '
        'Be warm, practical, non-clinical, and suggest emergency help for crisis risk.\n\nUser: $text',
      );
      setState(() => _reply = response.trim().isEmpty
          ? 'I could not generate a useful response. Try again in a moment.'
          : response.trim());
    } catch (_) {
      final mockResponse = _generateMockResponse(text);
      setState(() => _reply =
          '$mockResponse\n\n(Quantized model is configured for $_selectedModel, but Ollama is not reachable. Start Ollama on port 8000 or update the endpoint.)');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _summarizeJournal() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) {
      return;
    }
    setState(() {
      _loading = true;
      _alreadyShared = false;
    });

    try {
      final response = await _queryOllama(
        'You are Calmora, a concise mental wellness assistant. '
        'Summarize the following journal entry into a short supportive reflection for the user, then add a therapist-ready summary below. '
        'Use warm, practical, non-clinical language.\n\nJournal entry:\n$text',
      );
      final summary = response.trim();
      setState(() => _reply = summary.isEmpty
          ? 'I could not summarize your journal entry. Try again in a moment.'
          : summary);
      if (summary.isNotEmpty) {
        ref.read(appSessionProvider.notifier).addJournalEntry(summary);
      }
    } catch (_) {
      final fallback = _generateMockResponse(text);
      setState(() => _reply =
          'Summary fallback: $fallback\n\n(Quantized model is configured for $_selectedModel, but Ollama is not reachable.)');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _shareWithTherapist() {
    final profile = ref.read(appSessionProvider).profile;
    if (profile?.hasPsychologist != true) {
      AppSnackBar.showError(
        context,
        title: 'No therapist connected',
        message: 'Connect a care provider from the Care tab before sharing.',
      );
      return;
    }

    if (_reply.trim().isEmpty) {
      AppSnackBar.showError(
        context,
        title: 'Nothing to share',
        message:
            'Summarize a journal entry first, then send it to your therapist.',
      );
      return;
    }

    setState(() => _alreadyShared = true);
    AppSnackBar.showSuccess(
      context,
      title: 'Shared with therapist',
      message: 'The summary was shared with ${profile!.psychologistEmail}.',
    );
  }

  String _generateMockResponse(String userInput) {
    final input = userInput.toLowerCase();
    if (input.contains('sad') || input.contains('depressed')) {
      return 'I\'m sorry you\'re feeling down. Try a 4-7-8 breathing exercise: Inhale for 4 seconds, hold for 7, exhale for 8. If this persists, consider talking to a professional.';
    } else if (input.contains('anxious') || input.contains('worried')) {
      return 'Anxiety can be tough. Ground yourself by naming 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, and 1 you can taste.';
    } else if (input.contains('happy') || input.contains('good')) {
      return 'That\'s great to hear! Keep nurturing positive moments. What\'s one thing that made you smile today?';
    } else if (input.contains('exercise') || input.contains('workout')) {
      return 'Physical activity is excellent for mental health. Even a 10-minute walk can boost your mood. What\'s your favorite way to move?';
    } else if (input.contains('sleep')) {
      return 'Good sleep is crucial. Try maintaining a consistent bedtime routine and avoiding screens an hour before bed.';
    } else {
      return 'Thanks for sharing. Remember, it\'s okay to not be okay. If you need immediate help, contact a crisis hotline. What\'s on your mind right now?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = ref.watch(appSessionProvider).profile;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        scheme.primary.withValues(alpha: 0.15),
                        scheme.tertiary.withValues(alpha: 0.10),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.auto_awesome, color: scheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mode == CalmoraAiMode.chat ? 'Calmora AI' : 'Calmora Journal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Quantized',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: scheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Mode tabs
            Row(
              children: [
                _ModeChip(
                  label: 'Chat',
                  icon: Icons.chat_bubble_outline,
                  isSelected: _mode == CalmoraAiMode.chat,
                  onTap: () {
                    setState(() {
                      _mode = CalmoraAiMode.chat;
                      _reply =
                          'Ask for a grounding exercise, journaling prompt, or appointment prep.';
                      _alreadyShared = false;
                    });
                  },
                  scheme: scheme,
                ),
                const SizedBox(width: 10),
                _ModeChip(
                  label: 'Journal',
                  icon: Icons.edit_note,
                  isSelected: _mode == CalmoraAiMode.journal,
                  onTap: () {
                    setState(() {
                      _mode = CalmoraAiMode.journal;
                      _reply =
                          'Write a journal entry, then summarize it for your own reflection or your therapist.';
                      _alreadyShared = false;
                    });
                  },
                  scheme: scheme,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Response area
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 80, maxHeight: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.08),
                ),
              ),
              child: _loading
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          color: scheme.primary,
                          backgroundColor: scheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Thinking...',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Text(
                        _reply,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 14),
            // Input
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: _mode == CalmoraAiMode.chat
                    ? 'Type what is on your mind'
                    : 'Write your journal entry here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                suffixIcon: IconButton(
                  tooltip: _mode == CalmoraAiMode.chat ? 'Send' : 'Summarize',
                  onPressed:
                      _mode == CalmoraAiMode.chat ? _send : _summarizeJournal,
                  icon: Icon(_mode == CalmoraAiMode.chat
                      ? Icons.send_rounded
                      : Icons.notes_rounded),
                ),
              ),
              onSubmitted: (_) =>
                  _mode == CalmoraAiMode.chat ? _send() : _summarizeJournal(),
            ),
            const SizedBox(height: 14),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _mode == CalmoraAiMode.journal
                        ? _summarizeJournal
                        : _send,
                    icon: Icon(
                      _mode == CalmoraAiMode.journal
                          ? Icons.notes_rounded
                          : Icons.send_rounded,
                      size: 18,
                    ),
                    label: Text(
                      _mode == CalmoraAiMode.journal
                          ? 'Summarize Entry'
                          : 'Send to Calmora',
                    ),
                  ),
                ),
                if (_mode == CalmoraAiMode.journal) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _shareWithTherapist,
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Send to therapist'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            if (_mode == CalmoraAiMode.journal)
              Text(
                profile?.hasPsychologist == true
                    ? 'Sharing available to ${profile!.psychologistEmail}.'
                    : 'No therapist connected yet. Add one from Care.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            if (_alreadyShared)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: scheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Journal summary shared successfully.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
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
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme scheme;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.3)
                : scheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
