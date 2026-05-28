import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_state.dart';
import '../../../../core/theme/app_theme.dart';
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
  
  final _searchFocusNode = FocusNode();
  final _editorFocusNode = FocusNode();
  
  JournalEntry? _editingEntry;
  String _query = '';
  bool _isSaving = false;
  bool _isSearching = false;
  bool _isEditorFocused = false;
  int _selectedSegment = 1; // 0: Reflections (list), 1: Write Pad (editor)
  String _autosaveStatus = 'Empty';
  Timer? _autosaveDebounceTimer;

  int _backspaceCount = 0;
  int _previousLength = 0;

  @override
  void initState() {
    super.initState();
    
    _controller.addListener(_onTextChanged);
    
    _searchController.addListener(() {
      if (mounted) {
        setState(() => _query = _searchController.text.trim().toLowerCase());
      }
    });

    _editorFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isEditorFocused = _editorFocusNode.hasFocus;
          if (_isEditorFocused) {
            _selectedSegment = 1; // Auto switch to Editor tab if typing is active
          }
        });
      }
    });

    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _onTextChanged() {
    final text = _controller.text.trim();
    final currentLength = _controller.text.length;
    if (currentLength < _previousLength) {
      _backspaceCount++;
    }
    _previousLength = currentLength;

    if (text.isNotEmpty && !_isSaving) {
      setState(() {
        _autosaveStatus = 'Typing...';
      });
      _autosaveDebounceTimer?.cancel();
      _autosaveDebounceTimer = Timer(const Duration(seconds: 2), () {
        _autosaveNoteSilently();
      });
    } else if (text.isEmpty) {
      setState(() {
        _autosaveStatus = 'Empty';
      });
    }
  }

  Future<void> _autosaveNoteSilently() async {
    final notes = _controller.text.trim();
    if (notes.isEmpty) return;

    setState(() {
      _autosaveStatus = 'Saving...';
    });

    try {
      final notifier = ref.read(appSessionProvider.notifier);
      if (_editingEntry == null) {
        notifier.addJournalEntry(notes);
        // Find the newly added entry (last one) to make it the active editing entry
        final list = ref.read(appSessionProvider).journalEntries;
        if (list.isNotEmpty) {
          _editingEntry = list.last;
        }
      } else {
        notifier.updateJournalEntry(_editingEntry!.copyWith(content: notes));
      }
      
      if (mounted) {
        setState(() {
          _autosaveStatus = 'Saved';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _autosaveStatus = 'Error';
        });
      }
    }
  }

  @override
  void dispose() {
    _autosaveDebounceTimer?.cancel();
    _controller.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    _autosaveDebounceTimer?.cancel();
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
        setState(() {
          _isSaving = false;
          _autosaveStatus = 'Saved';
        });
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
    _autosaveDebounceTimer?.cancel();
    setState(() {
      _editingEntry = null;
      _controller.clear();
      _backspaceCount = 0;
      _previousLength = 0;
      _selectedSegment = 1; // Default switch to write pad for new note
      _autosaveStatus = 'Empty';
    });
    
    // Focus Editor and dismiss search
    _isSearching = false;
    _searchController.clear();
    _query = '';
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _editorFocusNode.requestFocus();
      }
    });
  }

  void _selectEntry(JournalEntry entry) {
    _autosaveDebounceTimer?.cancel();
    setState(() {
      _editingEntry = entry;
      _controller.text = entry.content;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
      _backspaceCount = 0;
      _previousLength = _controller.text.length;
      _selectedSegment = 1; // Focus write pad to edit selected note
      _autosaveStatus = 'Saved';
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _editorFocusNode.requestFocus();
      }
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
    final isDark = theme.brightness == Brightness.dark;
    
    final entries =
        _filteredEntries(ref.watch(appSessionProvider).journalEntries);
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B222E) : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    hintStyle: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              )
            : const Text('Notes'),
        centerTitle: false,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _query = '';
                  });
                },
              )
            : null,
        actions: [
          if (!_isSearching) ...[
            IconButton(
              tooltip: 'New note',
              onPressed: _startNewNote,
              icon: const Icon(Icons.note_add_rounded),
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
              icon: const Icon(Icons.history_rounded),
            ),
            IconButton(
              tooltip: 'Search',
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _searchFocusNode.requestFocus();
                  }
                });
              },
              icon: const Icon(Icons.search_rounded),
            ),
          ],
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
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
                      focusNode: _editorFocusNode,
                      editingEntry: _editingEntry,
                      onNewNote: _startNewNote,
                      onSave: _saveNote,
                      isSaving: _isSaving,
                      isCompact: false,
                      autosaveStatus: _autosaveStatus,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Segmented Tabs Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B222E) : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: scheme.subtleBorder),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _SegmentButton(
                              label: 'Reflections',
                              icon: Icons.menu_book_rounded,
                              selected: _selectedSegment == 0,
                              onTap: () {
                                setState(() {
                                  _selectedSegment = 0;
                                });
                                _editorFocusNode.unfocus();
                              },
                            ),
                            const SizedBox(width: 4),
                            _SegmentButton(
                              label: 'Write Pad',
                              icon: Icons.edit_note_rounded,
                              selected: _selectedSegment == 1,
                              onTap: () {
                                setState(() {
                                  _selectedSegment = 1;
                                });
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) {
                                    _editorFocusNode.requestFocus();
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Main Body split view
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Upper 40% height list of reflections (only shown if Editor is not focused to optimize space)
                        if (!_isEditorFocused && _selectedSegment == 0)
                          Expanded(
                            child: NotesSidebar(
                              entries: entries,
                              selectedEntry: _editingEntry,
                              searchController: _searchController,
                              titleFor: _titleFor,
                              previewFor: _previewFor,
                              dateFor: _dateFor,
                              onSelect: _selectEntry,
                              compact: false,
                            ),
                          ),
                          
                        if (!_isEditorFocused && _selectedSegment == 1)
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.32,
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
                        
                        // Lower 60% height Editor (takes 100% height when typing)
                        if (_selectedSegment == 1 || _isEditorFocused)
                          Expanded(
                            child: JournalEditorPane(
                              controller: _controller,
                              focusNode: _editorFocusNode,
                              editingEntry: _editingEntry,
                              onNewNote: _startNewNote,
                              onSave: _saveNote,
                              isSaving: _isSaving,
                              isCompact: false,
                              autosaveStatus: _autosaveStatus,
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

class _SegmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? (isDark ? scheme.primary.withValues(alpha: 0.18) : scheme.primary.withValues(alpha: 0.08))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected ? scheme.primary : scheme.mutedText,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: selected ? scheme.primary : scheme.mutedText,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          // Subtle active tab indicator line
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 40 : 0,
            height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.secondary],
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.5),
                        blurRadius: 4,
                      )
                    ]
                  : [],
            ),
          ),
        ],
      ),
    );
  }
}
