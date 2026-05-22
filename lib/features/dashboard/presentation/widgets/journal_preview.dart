part of '../screens/stats_screen.dart';

class _JournalPreview extends StatelessWidget {
  final MoodEntry entry;

  const _JournalPreview({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.label,
                style: AppTypography.labelLarge,
              ),
              Text(
                '${entry.createdAt.day}/${entry.createdAt.month}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.lightSubtext,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.note.isEmpty ? 'No note added.' : entry.note,
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}
