import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/formatters.dart';
import 'package:farm_buddy/models/crop.dart';
import 'package:farm_buddy/widgets/common/emoji_text.dart';

/// A crop, pickable. Used in the crop chooser sheet and in "My Crops".
class CropCard extends StatelessWidget {
  const CropCard({
    super.key,
    required this.crop,
    this.displayName,
    this.quantityKg,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.showPrice = true,
  });

  final Crop crop;

  /// Localised crop name; falls back to the English name on the model.
  final String? displayName;

  final double? quantityKg;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;
  final bool showPrice;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: onTap != null,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySofter : AppColors.surface,
          borderRadius: AppRadius.rLg,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primarySoft
                          : AppColors.surfaceAlt,
                      borderRadius: AppRadius.rMd,
                    ),
                    child: EmojiText(crop.emoji, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          displayName ?? crop.name,
                          style: AppText.titleLg,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          quantityKg != null
                              ? Fmt.kilos(quantityKg!)
                              : crop.seasonHint,
                          style: AppText.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (trailing != null)
                    trailing!
                  else if (selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 26,
                    )
                  else if (showPrice)
                    Text(
                      '~${Fmt.pricePerKg(crop.indicativePricePerKg)}',
                      style: AppText.bodySmStrong
                          .copyWith(color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
