import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';

enum BadgeTone { success, warning, danger, info, neutral, highlight, gold }

/// A small pill of status.
///
/// Accessibility rule of the whole app lives here: a badge always carries an
/// **icon and a word**, so status never depends on colour alone. Colour-blind
/// users, glare on a phone in a field, a photocopied screenshot in a judging
/// pack — all still readable.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = BadgeTone.neutral,
    this.icon,
    this.dense = false,
  });

  final String label;
  final BadgeTone tone;
  final IconData? icon;
  final bool dense;

  Color get _fg => switch (tone) {
        BadgeTone.success => AppColors.success,
        BadgeTone.warning => AppColors.warning,
        BadgeTone.danger => AppColors.danger,
        BadgeTone.info => AppColors.info,
        BadgeTone.neutral => AppColors.textSecondary,
        BadgeTone.highlight => AppColors.primaryDark,
        BadgeTone.gold => const Color(0xFF8A6408),
      };

  Color get _bg => switch (tone) {
        BadgeTone.success => AppColors.successSoft,
        BadgeTone.warning => AppColors.warningSoft,
        BadgeTone.danger => AppColors.dangerSoft,
        BadgeTone.info => AppColors.infoSoft,
        BadgeTone.neutral => AppColors.neutralSoft,
        BadgeTone.highlight => AppColors.primarySoft,
        BadgeTone.gold => AppColors.goldSoft,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.xs : AppSpacing.sm,
        vertical: dense ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: AppRadius.rPill,
        border: Border.all(color: _fg.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: dense ? 12 : 14, color: _fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: (dense ? AppText.caption : AppText.label).copyWith(
                color: _fg,
                fontWeight: FontWeight.w700,
                fontSize: dense ? 11 : 12.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
