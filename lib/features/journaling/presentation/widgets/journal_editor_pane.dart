import 'package:flutter/material.dart';
import '../../../../app/app_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/smooth_widgets.dart';

class JournalEditorPane extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final JournalEntry? editingEntry;
  final VoidCallback onNewNote;
  final VoidCallback? onSave;
  final bool isSaving;
  final bool isCompact;
  final String autosaveStatus;

  const JournalEditorPane({
    super.key,
    required this.controller,
    this.focusNode,
    required this.editingEntry,
    required this.onNewNote,
    this.onSave,
    this.isSaving = false,
    this.isCompact = false,
    this.autosaveStatus = 'Saved',
  });

  @override
  State<JournalEditorPane> createState() => _JournalEditorPaneState();
}

class _JournalEditorPaneState extends State<JournalEditorPane>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _isFocused = false;
  int _wordCount = 0;

  // Breathing focus pulse animation
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_updateWordCount);
    _updateWordCount();

    // Loopable slow 4-second breathing controller
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void didUpdateWidget(JournalEditorPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChange);
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_updateWordCount);
    _breathingController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  void _updateWordCount() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) {
      setState(() => _wordCount = 0);
    } else {
      setState(() => _wordCount = text.split(RegExp(r'\s+')).length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Premium wellness palette: Warm ivory paper in light, desaturated slate in dark
    final padColor = isDark 
        ? const Color(0xFF161C24) 
        : const Color(0xFFFDFBF7);
    
    final baseBorderColor = isDark 
        ? scheme.outline.withValues(alpha: 0.15) 
        : const Color(0xFFEFEBE4);
    
    final activeBorderColor = scheme.primary;
    final hasText = widget.controller.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, widget.isCompact ? 8 : 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Expanded parchment notebook container with loopable breathing glow
          Expanded(
            flex: widget.isCompact ? 0 : 1,
            child: AnimatedBuilder(
              animation: _breathingAnimation,
              builder: (context, child) {
                return Container(
                  height: widget.isCompact ? 132 : null,
                  decoration: BoxDecoration(
                    color: padColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _isFocused ? activeBorderColor : baseBorderColor, 
                      width: _isFocused ? 1.6 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(
                          alpha: _isFocused 
                              ? (isDark 
                                  ? (0.05 + _breathingAnimation.value * 0.05) 
                                  : (0.03 + _breathingAnimation.value * 0.03)) 
                              : 0.015,
                        ),
                        blurRadius: _isFocused ? (14 + _breathingAnimation.value * 8) : 6,
                        spreadRadius: _isFocused ? (_breathingAnimation.value * 0.8) : 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Text Area Input that stretches fully
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        maxLines: widget.isCompact ? 4 : null,
                        expands: !widget.isCompact,
                        textAlignVertical: TextAlignVertical.top,
                        keyboardType: TextInputType.multiline,
                        cursorColor: scheme.primary,
                        cursorWidth: 2.5,
                        cursorRadius: const Radius.circular(4),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurface,
                          height: 1.6,
                          fontSize: 14.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Breathe in, and write down your private thoughts here...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: scheme.mutedText.withValues(alpha: 0.45),
                            fontStyle: FontStyle.italic,
                          ),
                          filled: false,
                        ),
                      ),
                    ),
                  ),
                  
                  // Sticky bottom action bar inside the card
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B222E) : const Color(0xFFF9F6F0),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                      border: Border(
                        top: BorderSide(color: baseBorderColor),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        // Autosave Status Badge
                        _AutosaveStatusBadge(status: widget.autosaveStatus),
                        const SizedBox(width: 12),
                        
                        // Word Count
                        Text(
                          '$_wordCount words',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.mutedText.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Primary Save Button - only visible if text exists
                        AnimatedOpacity(
                          opacity: hasText ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 180),
                          child: hasText
                              ? SizedBox(
                                  height: 32,
                                  child: SmoothButton(
                                    onPressed: widget.onSave ?? () {},
                                    label: widget.editingEntry == null ? 'Save' : 'Update',
                                    backgroundColor: scheme.primary,
                                    textColor: scheme.onPrimary,
                                    isLoading: widget.isSaving,
                                    borderRadius: 8,
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AutosaveStatusBadge extends StatelessWidget {
  final String status;

  const _AutosaveStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    IconData icon;
    String text;
    Color color;

    switch (status) {
      case 'Saving...':
        icon = Icons.sync_rounded;
        text = 'Saving...';
        color = scheme.primary;
        break;
      case 'Typing...':
        icon = Icons.edit_note_rounded;
        text = 'Unsaved';
        color = scheme.mutedText.withValues(alpha: 0.8);
        break;
      case 'Empty':
        icon = Icons.spa_outlined;
        text = 'Mindful space';
        color = scheme.mutedText.withValues(alpha: 0.65);
        break;
      case 'Error':
        icon = Icons.error_outline_rounded;
        text = 'Save Failed';
        color = scheme.error;
        break;
      case 'Saved':
      default:
        icon = Icons.check_circle_outline_rounded;
        text = 'Autosaved';
        color = scheme.primary.withValues(alpha: 0.95);
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == 'Saving...')
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation(Color(0xFF0FA58A)),
            ),
          )
        else
          Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}
