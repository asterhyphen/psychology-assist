import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/smooth_widgets.dart';

part '../widgets/mood_option.dart';
part '../widgets/mood_selector.dart';

class MoodLogScreen extends ConsumerStatefulWidget {
  const MoodLogScreen({super.key});

  @override
  ConsumerState<MoodLogScreen> createState() => _MoodLogScreenState();
}

class _MoodLogScreenState extends ConsumerState<MoodLogScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedMoodIndex;
  final _journalController = TextEditingController();
  late AnimationController _animationController;

  final List<_MoodOption> _moods = [
    _MoodOption(
      icon: Icons.sentiment_very_dissatisfied,
      label: 'Terrible',
      color: AppColors.error,
      value: 1,
    ),
    _MoodOption(
      icon: Icons.sentiment_dissatisfied,
      label: 'Poor',
      color: AppColors.warning,
      value: 2,
    ),
    _MoodOption(
      icon: Icons.sentiment_neutral,
      label: 'Neutral',
      color: AppColors.info,
      value: 3,
    ),
    _MoodOption(
      icon: Icons.sentiment_satisfied_alt,
      label: 'Good',
      color: AppColors.success,
      value: 4,
    ),
    _MoodOption(
      icon: Icons.sentiment_very_satisfied,
      label: 'Excellent',
      color: AppColors.neonViolet,
      value: 5,
    ),
  ];

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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _journalController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submitMood() {
    if (_selectedMoodIndex == null) {
      AppSnackBar.showError(
        context,
        title: 'Pick a mood',
        message: 'Please select a mood to continue.',
        duration: const Duration(milliseconds: 2000),
      );
      return;
    }

    final mood = _moods[_selectedMoodIndex!];
    ref.read(appSessionProvider.notifier).addMoodEntry(
          MoodEntry(
            createdAt: DateTime.now(),
            value: mood.value,
            label: mood.label,
            note: _journalController.text.trim(),
          ),
        );

    setState(() {
      _selectedMoodIndex = null;
      _journalController.clear();
    });

    AppSnackBar.showSuccess(
      context,
      title: 'Mood saved',
      message: 'Your entry is saved as a mood note.',
      duration: const Duration(milliseconds: 1400),
    );
  }

  IconData _getMoodIcon(int value) {
    switch (value) {
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied_alt;
      case 5:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Color _getMoodColor(int value) {
    switch (value) {
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.info;
      case 4:
        return AppColors.success;
      case 5:
        return AppColors.neonViolet;
      default:
        return AppColors.info;
    }
  }

  Widget _buildTruncatedText(String text) {
    const maxLength = 200;
    if (text.length <= maxLength) {
      return Text(
        text,
        style: AppTypography.bodyMedium.copyWith(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      );
    }

    final truncatedText = text.substring(0, maxLength);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$truncatedText...',
          style: AppTypography.bodyMedium.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Full Entry'),
                content: SingleChildScrollView(
                  child: Text(
                    text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
          child: Text(
            'Read more',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neonViolet,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final session = ref.watch(appSessionProvider);
    final entries = session.moodEntries.reversed.toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Log Your Mood'),
        automaticallyImplyLeading: Navigator.of(context).canPop(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                'Mood Check-In',
                style: AppTypography.displayMedium.copyWith(
                  color: theme.textTheme.displayMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Capture your mood, thoughts, and calm reflections in one place.',
                style: AppTypography.bodySmall.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SmoothCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select your feeling',
                      style: AppTypography.labelLarge.copyWith(
                        color: theme.textTheme.labelLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: List.generate(
                          _moods.length,
                          (index) => Padding(
                            padding: EdgeInsets.only(
                              left: index == 0 ? 0 : 10,
                              right: index == _moods.length - 1 ? 0 : 0,
                            ),
                            child: _MoodSelector(
                              mood: _moods[index],
                              isSelected: _selectedMoodIndex == index,
                              onTap: () {
                                setState(() {
                                  _selectedMoodIndex = index;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_selectedMoodIndex != null)
                      Text(
                        'Feeling ${_moods[_selectedMoodIndex!].label.toLowerCase()}',
                        style: AppTypography.labelLarge.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SmoothCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a Note',
                      style: AppTypography.headingSmall.copyWith(
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Capture a quick thought, reflection, or detail from your day.',
                      style: AppTypography.bodySmall.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _journalController,
                      minLines: 6,
                      maxLines: null,
                      onChanged: (text) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Write freely — this is your private space.',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary.withValues(alpha: 0.12),
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.8,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1C2430)
                            : theme.colorScheme.surface,
                      ),
                      style: AppTypography.bodyMedium.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
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
                                  setState(() {
                                    _journalController.text = 'Today, I am feeling... because...';
                                    _journalController.selection = TextSelection.collapsed(offset: _journalController.text.length);
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
                      crossFadeState: _isGibberish(_journalController.text)
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your entries are private* and stored locally on this device.',
                      style: AppTypography.captionSmall.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: SmoothButton(
                  onPressed: _submitMood,
                  label: 'Save Mood Entry',
                  backgroundColor: theme.colorScheme.primary,
                  textColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              if (entries.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Mood Notes',
                      style: AppTypography.headingSmall.copyWith(
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...entries.take(5).map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF161D26).withValues(alpha: 0.72)
                                    : theme.colorScheme.surface.withValues(alpha: 0.84),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _getMoodColor(entry.value).withValues(alpha: 0.22),
                                  width: 0.8,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 96,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            _getMoodColor(entry.value),
                                            _getMoodColor(entry.value).withValues(alpha: 0.4),
                                          ],
                                        ),
                                      ),
                                    ),
                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      _getMoodIcon(entry.value),
                                                      color: _getMoodColor(entry.value),
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      entry.label,
                                                      style: AppTypography.labelLarge,
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '${entry.createdAt.day}/${entry.createdAt.month} ${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}',
                                                  style: AppTypography.bodySmall.copyWith(
                                                    color: theme.textTheme.bodySmall?.color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            _buildTruncatedText(entry.note.isEmpty
                                                ? 'No additional note provided.'
                                                : entry.note),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                  ],
                )
              else
                SmoothCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(18),
                  backgroundColor:
                      theme.colorScheme.surface.withValues(alpha: 0.72),
                  child: Text(
                    'No mood notes yet. Save a mood entry to start building your notes.',
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mood option data class
class _MoodSelectorState extends State<_MoodSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant _MoodSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.04).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        ),
        child: Container(
          width: 76,
          height: 102,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.mood.color.withValues(alpha: 0.16)
                : Colors.transparent,
            border: Border.all(
              color: widget.isSelected
                  ? widget.mood.color
                  : Theme.of(context).dividerColor.withValues(alpha: 0.4),
              width: widget.isSelected ? 2.5 : 1,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.mood.color.withValues(alpha: 0.32),
                      blurRadius: 14,
                      spreadRadius: 0.5,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected
                      ? widget.mood.color.withValues(alpha: 0.12)
                      : Colors.transparent,
                ),
                child: Icon(
                  widget.mood.icon,
                  color: widget.isSelected
                      ? widget.mood.color
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                  size: 34,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.mood.label,
                style: AppTypography.labelSmall.copyWith(
                  color: widget.isSelected
                      ? widget.mood.color
                      : Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.76),
                  fontWeight:
                      widget.isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 10.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
