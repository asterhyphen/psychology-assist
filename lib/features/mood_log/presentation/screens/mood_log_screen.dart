import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/smooth_widgets.dart';
import '../../domain/entities/mood_entry.dart';
import '../providers/mood_provider.dart';
import '../widgets/mood_selector.dart';

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

  final List<MoodOption> _moods = [
    MoodOption(
      icon: Icons.sentiment_very_dissatisfied,
      label: 'Terrible',
      color: AppColors.error,
      value: 1,
    ),
    MoodOption(
      icon: Icons.sentiment_dissatisfied,
      label: 'Poor',
      color: AppColors.warning,
      value: 2,
    ),
    MoodOption(
      icon: Icons.sentiment_neutral,
      label: 'Neutral',
      color: AppColors.info,
      value: 3,
    ),
    MoodOption(
      icon: Icons.sentiment_satisfied_alt,
      label: 'Good',
      color: AppColors.success,
      value: 4,
    ),
    MoodOption(
      icon: Icons.sentiment_very_satisfied,
      label: 'Excellent',
      color: AppColors.neonViolet,
      value: 5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
    ref.read(moodStateProvider.notifier).addEntry(
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
      message: 'Your entry is saved to your journal.',
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodState = ref.watch(moodStateProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Log Your Mood'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                'Journal & Mood Notes',
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
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        _moods.length,
                        (index) => MoodSelector(
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
                      decoration: InputDecoration(
                        hintText: 'Write freely — this is your private space.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      style: AppTypography.bodyMedium.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
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
              moodState.when(
                data: (entries) {
                  if (entries.isEmpty) return const SizedBox.shrink();
                  final recentEntries = entries.reversed.toList().take(5);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent mood entries',
                        style: AppTypography.headingSmall.copyWith(
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...recentEntries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SmoothCard(
                            borderRadius: 18,
                            padding: const EdgeInsets.all(16),
                            backgroundColor: theme.colorScheme.surface
                                .withValues(alpha: 0.8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      _getMoodIcon(entry.value),
                                      color: _getMoodColor(entry.value),
                                      size: 24,
                                    ),
                                    Text(
                                      entry.label,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: _getMoodColor(entry.value),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (entry.note.isNotEmpty)
                                  Text(
                                    entry.note,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error loading moods: $error'),
              ),
            ],
          ),
        ),
      ),
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
}
