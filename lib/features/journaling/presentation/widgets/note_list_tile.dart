import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class NoteListTile extends StatelessWidget {
  final String title;
  final String preview;
  final String date;
  final bool selected;
  final bool shared;
  final VoidCallback onTap;

  const NoteListTile({
    super.key,
    required this.title,
    required this.preview,
    required this.date,
    required this.selected,
    required this.shared,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.6)
          : scheme.surface.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? scheme.primary.withValues(alpha: 0.35)
                  : scheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMedium.copyWith(
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                  ),
                  if (shared)
                    Icon(
                      Icons.verified_outlined,
                      size: 16,
                      color: scheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.78),
                  height: 1.35,
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: AppTypography.caption.copyWith(
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.58),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
