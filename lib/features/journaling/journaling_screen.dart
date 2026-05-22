import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_state.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/smooth_widgets.dart';
import '../../app/home_screen.dart';
import 'journal_history_screen.dart';

class JournalingScreen extends ConsumerStatefulWidget {
  const JournalingScreen({super.key});

  @override
  ConsumerState<JournalingScreen> createState() => _JournalingScreenState();
}

class _JournalingScreenState extends ConsumerState<JournalingScreen> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // No longer loading existing content - each entry is new
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveNotes() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final notes = _controller.text.trim();
      if (notes.isNotEmpty) {
        ref.read(appSessionProvider.notifier).addJournalEntry(notes);
      }

      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          title: 'Notes saved',
          message: 'Your journal entry has been saved.',
        );
        // Clear content and navigate back
        _controller.clear();
        ref.read(selectedTabProvider.notifier).state = 0;
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          title: 'Save failed',
          message: 'Could not save your notes. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Notes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const JournalHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history_outlined),
            tooltip: 'View history',
          ),
          TextButton(
            onPressed: _isSaving ? null : _saveNotes,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Personal Notes',
              style: AppTypography.headingMedium.copyWith(
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Write down your thoughts, feelings, or anything you want to remember. These notes are private and stored locally.',
              style: AppTypography.bodySmall.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SmoothCard(
                backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
                borderColor: const Color(0xFFB7C97B).withValues(alpha: 0.2),
                borderRadius: 16,
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Start writing your thoughts here...',
                    border: InputBorder.none,
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color:
                          theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                    ),
                  ),
                  style: AppTypography.bodyMedium.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
