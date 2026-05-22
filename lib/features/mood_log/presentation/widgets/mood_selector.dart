part of '../screens/mood_log_screen.dart';

class _MoodSelector extends StatefulWidget {
  final _MoodOption mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodSelector({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MoodSelector> createState() => _MoodSelectorState();
}
