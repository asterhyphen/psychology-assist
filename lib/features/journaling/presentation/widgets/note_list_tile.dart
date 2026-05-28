import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    final unselectedBgColor = isDark 
        ? const Color(0xFF1B222E) 
        : scheme.surface.withValues(alpha: 0.72);

    final selectedBgColor = isDark 
        ? scheme.primary.withValues(alpha: 0.16) 
        : scheme.primary.withValues(alpha: 0.08);

    final unselectedBorderColor = isDark 
        ? scheme.subtleBorder 
        : scheme.outlineVariant.withValues(alpha: 0.4);

    final selectedBorderColor = scheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          decoration: BoxDecoration(
            color: selected ? selectedBgColor : unselectedBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? selectedBorderColor : unselectedBorderColor,
              width: selected ? 1.6 : 1.1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Stack(
            children: [
              if (selected)
                Positioned(
                  left: 0,
                  top: 14,
                  bottom: 14,
                  child: Container(
                    width: 3.5,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(selected ? 14 : 12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelLarge.copyWith(
                              color: selected ? scheme.primary : scheme.onSurface,
                              fontWeight: selected ? FontWeight.bold : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (shared)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.verified_user_outlined,
                              size: 14,
                              color: scheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: scheme.mutedText,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      date,
                      style: AppTypography.captionSmall.copyWith(
                        color: scheme.mutedText.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
