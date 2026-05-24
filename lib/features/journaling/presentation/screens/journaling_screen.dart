import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_state.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../widgets/journal_editor_pane.dart';
import '../widgets/notes_sidebar.dart';
import 'journal_history_screen.dart';

class JournalingScreen extends ConsumerStatefulWidget {
  const JournalingScreen({super.key});

  @override
  ConsumerState<JournalingScreen> createState() => _JournalingScreenState();
}

class _JournalingScreenState extends ConsumerState<JournalingScreen> {
  final _controller = TextEditingController();
  final _searchController = TextEditingController();
  JournalEntry? _editingEntry;
  String _query = '';
  bool _isSaving = false;

  int _backspaceCount = 0;
  int _previousLength = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  void _onTextChanged() {
    final currentLength = _controller.text.length;
    if (currentLength < _previousLength) {
      _backspaceCount++;
    }
    _previousLength = currentLength;
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_isSaving) return;

    final notes = _controller.text.trim();
    if (notes.isEmpty) {
      AppSnackBar.showInfo(
        context,
        title: 'Nothing to save',
        message: 'Write something first, then save the note.',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(appSessionProvider.notifier);
      if (_editingEntry == null) {
        notifier.addJournalEntry(notes);
        _updateWritingDrift(notes);
      } else {
        notifier.updateJournalEntry(_editingEntry!.copyWith(content: notes));
      }

      _backspaceCount = 0;
      _previousLength = notes.length;

      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          title: _editingEntry == null ? 'Note saved' : 'Note updated',
          message: 'Your journal is up to date.',
        );
        _startNewNote();
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          title: 'Save failed',
          message: 'Could not save your note. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _updateWritingDrift(String notes) {
    final profile = ref.read(appSessionProvider).profile;
    if (profile == null) return;

    double stressFactor = 0.0;
    if (_backspaceCount > 10) stressFactor += 0.1;
    if (_backspaceCount > 20) stressFactor += 0.2;
    if (notes.length < 50 && _backspaceCount > 5) stressFactor += 0.2;

    if (stressFactor > 0) {
      final newDriftIndex = (profile.driftIndex + stressFactor).clamp(0.0, 1.0);
      ref.read(appSessionProvider.notifier).updateProfile(
            profile.copyWith(driftIndex: newDriftIndex),
          );
    }
  }

  void _startNewNote() {
    setState(() {
      _editingEntry = null;
      _controller.clear();
      _backspaceCount = 0;
      _previousLength = 0;
    });
  }

  void _selectEntry(JournalEntry entry) {
    setState(() {
      _editingEntry = entry;
      _controller.text = entry.content;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
      _backspaceCount = 0;
      _previousLength = _controller.text.length;
    });
  }

  List<JournalEntry> _filteredEntries(List<JournalEntry> entries) {
    final newestFirst = entries.reversed.toList();
    if (_query.isEmpty) return newestFirst;
    return newestFirst
        .where((entry) => entry.content.toLowerCase().contains(_query))
        .toList();
  }

  String _titleFor(JournalEntry entry) {
    final firstLine = entry.content
        .split('\n')
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => 'Untitled note');
    return firstLine.length > 44
        ? '${firstLine.substring(0, 44)}...'
        : firstLine;
  }

  String _previewFor(JournalEntry entry) {
    final compact = entry.content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.isEmpty) return 'No additional text';
    return compact.length > 96 ? '${compact.substring(0, 96)}...' : compact;
  }

  String _dateFor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDay = DateTime(date.year, date.month, date.day);
    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    if (entryDay == today) return 'Today, $time';
    if (entryDay == yesterday) return 'Yesterday, $time';
    return '${date.day}/${date.month}/${date.year}, $time';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final entries =
        _filteredEntries(ref.watch(appSessionProvider).journalEntries);
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'New note',
            onPressed: _startNewNote,
            icon: const Icon(Icons.note_add_outlined),
          ),
          IconButton(
            tooltip: 'History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const JournalHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _saveNote,
              icon: _isSaving
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, size: 18),
              label: Text(_editingEntry == null ? 'Save' : 'Update'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: isWide
            ? Row(
                children: [
                  SizedBox(
                    width: 330,
                    child: NotesSidebar(
                      entries: entries,
                      selectedEntry: _editingEntry,
                      searchController: _searchController,
                      titleFor: _titleFor,
                      previewFor: _previewFor,
                      dateFor: _dateFor,
                      onSelect: _selectEntry,
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    color: scheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                  Expanded(
                    child: JournalEditorPane(
                      controller: _controller,
                      editingEntry: _editingEntry,
                      onNewNote: _startNewNote,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  SizedBox(
                    height: 258,
                    child: NotesSidebar(
                      entries: entries,
                      selectedEntry: _editingEntry,
                      searchController: _searchController,
                      titleFor: _titleFor,
                      previewFor: _previewFor,
                      dateFor: _dateFor,
                      onSelect: _selectEntry,
                      compact: true,
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: scheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                  Expanded(
                    child: JournalEditorPane(
                      controller: _controller,
                      editingEntry: _editingEntry,
                      onNewNote: _startNewNote,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
