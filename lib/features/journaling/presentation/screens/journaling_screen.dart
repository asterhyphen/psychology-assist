import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/smooth_widgets.dart';
import 'journal_history_screen.dart';

class JournalingScreen extends ConsumerStatefulWidget {
  const JournalingScreen({super.key});

  @override
  ConsumerState<JournalingScreen> createState() => _JournalingScreenState();
}

class _JournalingScreenState extends ConsumerState<JournalingScreen> {
  final _controller = TextEditingController();
  final _searchController = TextEditingController();
  final _editorFocusNode = FocusNode();

  JournalEntry? _editingEntry;
  String _query = '';
  bool _isSaving = false;
  String _autosaveStatus = 'Saved';
  Timer? _autosaveDebounceTimer;

  int _backspaceCount = 0;
  int _previousLength = 0;

  bool _isGibberish(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.length < 4) return false;

    final words = trimmed.split(RegExp(r'\s+'));
    int validWordCount = 0;
    final vowelRegex = RegExp(r'[aeiouAEIOU]');
    
    for (final word in words) {
      if (vowelRegex.hasMatch(word)) {
        validWordCount++;
      } else {
        final lower = word.toLowerCase();
        final commonNonVowelWords = {
          'by', 'my', 'cry', 'dry', 'fly', 'shh', 'sh', 'hm', 'hmm', 
          'tv', 'sms', 'gps', 'try', 'sky', 'why', 'gym', 'spy', 'shy', 
          'myth', 'lynx', 'rhythm'
        };
        if (commonNonVowelWords.contains(lower)) {
          validWordCount++;
        }
      }
    }
    return validWordCount == 0;
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _searchController.addListener(() {
      if (mounted) {
        setState(() => _query = _searchController.text.trim().toLowerCase());
      }
    });
  }

  void _showMessage(String message, {bool success = false}) {
    if (success) {
      AppSnackBar.showSuccess(context, message: message);
    } else {
      AppSnackBar.showInfo(context, message: message);
    }
  }

  @override
  void dispose() {
    _autosaveDebounceTimer?.cancel();
    _controller.dispose();
    _searchController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
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
        _autosaveStatus = 'Saving...';
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

  Future<void> _autosaveNoteSilently({bool? isShared}) async {
    final notes = _controller.text.trim();
    if (notes.isEmpty) return;

    try {
      final notifier = ref.read(appSessionProvider.notifier);
      final sharingState = isShared ?? (_editingEntry?.sharedWithPsychologist ?? false);
      if (_editingEntry == null) {
        notifier.addJournalEntry(notes);
        final list = ref.read(appSessionProvider).journalEntries;
        if (list.isNotEmpty) {
          _editingEntry = list.last;
          if (sharingState) {
            notifier.updateJournalEntry(_editingEntry!.copyWith(sharedWithPsychologist: true));
          }
        }
      } else {
        notifier.updateJournalEntry(
          _editingEntry!.copyWith(
            content: notes,
            sharedWithPsychologist: sharingState,
          ),
        );
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

  Future<void> _saveNote({bool isShared = false}) async {
    _autosaveDebounceTimer?.cancel();
    if (_isSaving) return;

    final notes = _controller.text.trim();
    if (notes.isEmpty) {
      AppSnackBar.showInfo(
        context,
        title: 'Empty Reflection',
        message: 'Write down some thoughts first before saving.',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(appSessionProvider.notifier);
      if (_editingEntry == null) {
        // Create new
        final entry = JournalEntry(
          createdAt: DateTime.now(),
          content: notes,
          sharedWithPsychologist: isShared,
        );
        notifier.addJournalEntry(entry.content);
        // Find the entry and update its sharing state
        final list = ref.read(appSessionProvider).journalEntries;
        if (list.isNotEmpty && isShared) {
          notifier.updateJournalEntry(list.last.copyWith(sharedWithPsychologist: true));
        }
        _updateWritingDrift(notes);
      } else {
        // Update existing
        notifier.updateJournalEntry(
          _editingEntry!.copyWith(
            content: notes,
            sharedWithPsychologist: isShared,
          ),
        );
      }

      _backspaceCount = 0;
      _previousLength = notes.length;

      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          title: _editingEntry == null ? 'Reflection Saved' : 'Reflection Updated',
          message: 'Your wellness journal has been synced securely.',
        );
        _startNewNoteWithoutSheet();
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          title: 'Sync Failed',
          message: 'Could not save your notes. Please check local storage.',
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

  void _startNewNoteWithoutSheet() {
    _autosaveDebounceTimer?.cancel();
    setState(() {
      _editingEntry = null;
      _controller.clear();
      _backspaceCount = 0;
      _previousLength = 0;
      _autosaveStatus = 'Saved';
    });
  }

  void _openEditorSheet({JournalEntry? entry}) {
    _autosaveDebounceTimer?.cancel();
    if (entry != null) {
      setState(() {
        _editingEntry = entry;
        _controller.text = entry.content;
        _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
        _backspaceCount = 0;
        _previousLength = _controller.text.length;
        _autosaveStatus = 'Saved';
      });
    } else {
      _startNewNoteWithoutSheet();
    }

    // Launch fullscreen Editor dialog sheet
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 360),
      pageBuilder: (context, animation, secondaryAnimation) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final scheme = Theme.of(context).colorScheme;
        var shareState = _editingEntry?.sharedWithPsychologist ?? false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final wordCount = _controller.text.trim().isEmpty
                ? 0
                : _controller.text.trim().split(RegExp(r'\s+')).length;

            return Scaffold(
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              body: SafeArea(
                child: Column(
                  children: [
                    // Editor Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _autosaveNoteSilently();
                                  Navigator.of(context).pop();
                                  setState(() {}); // Rebuild main screen list
                                },
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _editingEntry == null ? 'Write Reflection' : 'Edit Reflection',
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          
                          // Autosave Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0FA58A).withOpacity(0.08),
                              border: Border.all(
                                color: const Color(0xFF0FA58A).withOpacity(0.2),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _autosaveStatus,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0FA58A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Editor Text Field
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                focusNode: _editorFocusNode,
                                autofocus: true,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                onChanged: (text) {
                                  setModalState(() {});
                                },
                                style: TextStyle(
                                  fontSize: 17,
                                  height: 1.55,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'How are you feeling today? Put your stream of consciousness into words...',
                                  hintStyle: TextStyle(
                                    color: isDark ? Colors.white30 : Colors.black38,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SmoothCard(
                                  borderRadius: 14,
                                  backgroundColor: isDark
                                      ? const Color(0xFF8B5CF6).withOpacity(0.08)
                                      : const Color(0xFF8B5CF6).withOpacity(0.05),
                                  borderColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.lightbulb_outline_rounded,
                                        color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Not sure what to write? Try starting with how your body feels right now.',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white70 : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton(
                                        onPressed: () {
                                          setModalState(() {
                                            _controller.text = 'Right now, my body feels... and my mind is...';
                                            _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'Use Template',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              crossFadeState: _isGibberish(_controller.text)
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 300),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Editor Footer Toolbar
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1B263B).withOpacity(0.3) : Colors.black.withOpacity(0.02),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                          width: 1.0,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$wordCount words | ${_controller.text.length} chars',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                          
                          // Psychologist Share Toggle
                          Row(
                            children: [
                              Icon(
                                Icons.share_outlined,
                                size: 14,
                                color: shareState ? const Color(0xFF0FA58A) : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Share with provider',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: shareState ? const Color(0xFF0FA58A) : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Switch.adaptive(
                                value: shareState,
                                activeColor: const Color(0xFF0FA58A),
                                onChanged: (val) {
                                  setModalState(() {
                                    shareState = val;
                                  });
                                  _autosaveNoteSilently(isShared: val);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(curve),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  void _openReaderSheet(JournalEntry entry) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return StatefulBuilder(
          builder: (context, setModalState) {
            final wordCount = entry.content.trim().isEmpty
                ? 0
                : entry.content.trim().split(RegExp(r'\s+')).length;

            return Align(
              alignment: Alignment.center,
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: SmoothCard(
                    borderRadius: 24,
                    elevation: 24,
                    backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderColor: const Color(0xFF0FA58A).withOpacity(0.3),
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reader Header row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0FA58A).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.menu_book_rounded,
                                    color: Color(0xFF0FA58A),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Logged Reflection',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Date display
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              _dateFor(entry.createdAt),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Full Reflection text (Scrollable)
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.35,
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              entry.content,
                              style: TextStyle(
                                fontSize: 15.5,
                                height: 1.55,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Sharing control toggle
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: entry.sharedWithPsychologist
                                ? const Color(0xFF10B981).withOpacity(0.06)
                                : Colors.white.withOpacity(0.04),
                            border: Border.all(
                              color: entry.sharedWithPsychologist
                                  ? const Color(0xFF10B981).withOpacity(0.24)
                                  : Colors.white.withOpacity(0.08),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    entry.sharedWithPsychologist ? Icons.verified_outlined : Icons.lock_outline_rounded,
                                    size: 16,
                                    color: entry.sharedWithPsychologist ? const Color(0xFF10B981) : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    entry.sharedWithPsychologist ? 'Shared with therapist' : 'Private reflection',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: entry.sharedWithPsychologist ? const Color(0xFF10B981) : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Switch.adaptive(
                                value: entry.sharedWithPsychologist,
                                activeColor: const Color(0xFF10B981),
                                onChanged: (val) {
                                  final updated = entry.copyWith(sharedWithPsychologist: val);
                                  ref.read(appSessionProvider.notifier).updateJournalEntry(updated);
                                  _showMessage(
                                    val ? 'Reflection shared with care provider.' : 'Reflection set to private.',
                                    success: true,
                                  );
                                  setModalState(() {
                                    entry = updated;
                                  });
                                  setState(() {}); // Rebuild main screen list
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Action Buttons (Edit, Delete)
                        Row(
                          children: [
                            // Delete
                            OutlinedButton.icon(
                              onPressed: () async {
                                final delete = await _confirmDelete();
                                if (delete) {
                                  ref.read(appSessionProvider.notifier).removeJournalEntry(entry);
                                  Navigator.of(context).pop();
                                  _showMessage('Reflection deleted successfully.', success: true);
                                  setState(() {});
                                }
                              },
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 16),
                              label: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(
                                  color: Colors.red.withOpacity(0.3),
                                  width: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Edit
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0FA58A), Color(0xFF8B5CF6)],
                                  ),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _openEditorSheet(entry: entry);
                                  },
                                  icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 18),
                                  label: const Text(
                                    'Edit Reflection',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1.0).animate(curve),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  Future<bool> _confirmDelete() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Reflection?'),
            content: const Text('Are you sure you want to permanently delete this wellness journal entry? This action is irreversible.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF0FA58A), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0FA58A).withValues(alpha: 0.24),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _openEditorSheet(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          foregroundColor: Colors.white,
          child: const Icon(Icons.note_add_rounded, size: 24),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Dynamic Premium Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0FA58A), Color(0xFF8B5CF6)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Wellness Journal',
                                style: AppTypography.headingMedium.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Capture your thoughts, log wellness patterns, and securely sync with your psychologist.',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? Colors.white.withValues(alpha: 0.48) : Colors.black54,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Interactive Search Card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B222E) : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: isDark ? Colors.white30 : Colors.black38,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search reflections...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white30 : Colors.black38,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          child: Icon(
                            Icons.close_rounded,
                            color: isDark ? Colors.white30 : Colors.black38,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Journal Entries List / Empty State ──
            if (entries.isEmpty) ...[
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0FA58A).withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.history_edu_rounded,
                            color: Color(0xFF0FA58A),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'No Reflections Logged',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _query.isNotEmpty
                              ? 'No entries match your search query.'
                              : 'Write down your first wellness reflection now to analyze stress trends.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white38 : Colors.black45,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 112),
                sliver: SliverList.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final title = _titleFor(entry);
                    final preview = _previewFor(entry);
                    final isShared = entry.sharedWithPsychologist;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _openReaderSheet(entry),
                        child: SmoothCard(
                          borderRadius: 22,
                          backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.72),
                          borderColor: isShared
                              ? const Color(0xFF10B981).withValues(alpha: 0.24)
                              : theme.colorScheme.primary.withValues(alpha: 0.15),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date & Sharing Badges
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 13,
                                        color: isDark ? Colors.white38 : Colors.black38,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _dateFor(entry.createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white38 : Colors.black45,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Share status capsule
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isShared
                                          ? const Color(0xFF10B981).withValues(alpha: 0.08)
                                          : Colors.white.withValues(alpha: 0.04),
                                      border: Border.all(
                                        color: isShared
                                            ? const Color(0xFF10B981).withValues(alpha: 0.24)
                                            : Colors.white.withValues(alpha: 0.08),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isShared ? Icons.verified_outlined : Icons.lock_outline_rounded,
                                          size: 11,
                                          color: isShared ? const Color(0xFF10B981) : Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isShared ? 'Shared' : 'Private',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            color: isShared ? const Color(0xFF10B981) : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Title Text
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Text snippet preview
                              Text(
                                preview,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: isDark ? Colors.white54 : Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
