import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class MoodOption {
  final IconData icon;
  final String label;
  final Color color;
  final int value;

  MoodOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.value,
  });
}

class MoodSelector extends StatelessWidget {
  final MoodOption mood;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodSelector({
    super.key,
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? mood.color.withValues(alpha: 0.2)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected ? mood.color : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              mood.icon,
              color: mood.color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              mood.label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected
                    ? mood.color
                    : theme.textTheme.labelMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
