import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/widgets/common/emoji_text.dart';

/// One of the four square shortcuts under the hero card on Home.
///
/// Big emoji, big title, one line of plain explanation. The whole tile is the
/// touch target — there is no small chevron to hunt for.
class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = AppColors.primary,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    // MergeSemantics rather than Semantics + ExcludeSemantics: the tile must
    // stay *activatable* by a screen reader, so the InkWell keeps its own tap
    // semantics and the title/subtitle merge into a single spoken node.
    return MergeSemantics(
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.rLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.rLg,
          child: Container(
            constraints: const BoxConstraints(minHeight: 132),
            decoration: BoxDecoration(
              borderRadius: AppRadius.rLg,
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.card,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: AppRadius.rMd,
                  ),
                  child: EmojiText(emoji, size: 24),
                ),
                const SizedBox(height: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppText.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppText.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
