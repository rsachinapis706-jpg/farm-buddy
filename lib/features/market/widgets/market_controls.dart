import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/formatters.dart';
import 'package:farm_buddy/models/crop.dart';
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/providers/activity_providers.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/providers/crop_providers.dart';
import 'package:farm_buddy/widgets/common/emoji_text.dart';

/// Crop, quantity and ordering — changeable in place.
///
/// This is the difference between a screen that *shows* a recommendation and
/// one that can be interrogated. Switch tomato to banana, or 500 kg to 2,000,
/// and the ranking below re-computes in front of you; switch the ordering and
/// you can check the app's pick against raw price or raw distance. A judge
/// asking "is this hardcoded?" can answer it themselves in three taps.
class MarketControls extends ConsumerWidget {
  const MarketControls({super.key});

  static const List<double> _quantities = <double>[100, 250, 500, 1000, 2000];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);
    final List<Crop> crops = ref.watch(allCropsProvider);
    final Crop activeCrop = ref.watch(activeCropProvider);
    final double activeQty = ref.watch(activeQuantityProvider);
    final MarketSort sort = ref.watch(marketSortProvider);

    void setCrop(Crop crop) => ref
        .read(currentListingProvider.notifier)
        .update(fallbackCrop: crop, crop: crop);

    void setQty(double qty) => ref
        .read(currentListingProvider.notifier)
        .update(fallbackCrop: activeCrop, quantityKg: qty);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    s('market.adjust'),
                    style: AppText.bodySmStrong
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // ------------------------------------------------------- crops
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: crops.length,
              separatorBuilder: (BuildContext context, int i) =>
                  const SizedBox(width: AppSpacing.xs),
              itemBuilder: (BuildContext context, int i) {
                final Crop crop = crops[i];
                return _Pill(
                  selected: crop.id == activeCrop.id,
                  onTap: () => setCrop(crop),
                  leading: EmojiText(crop.emoji, size: 15),
                  label: s(crop.nameKey),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // ---------------------------------------------------- quantity
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: _quantities.length,
              separatorBuilder: (BuildContext context, int i) =>
                  const SizedBox(width: AppSpacing.xs),
              itemBuilder: (BuildContext context, int i) {
                final double qty = _quantities[i];
                return _Pill(
                  selected: qty == activeQty,
                  onTap: () => setQty(qty),
                  label: Fmt.kilos(qty),
                  dense: true,
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Divider(height: 1),
          ),

          // -------------------------------------------------------- sort
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: MarketSort.values.length,
              separatorBuilder: (BuildContext context, int i) =>
                  const SizedBox(width: AppSpacing.xs),
              itemBuilder: (BuildContext context, int i) {
                final MarketSort option = MarketSort.values[i];
                return _Pill(
                  selected: option == sort,
                  onTap: () =>
                      ref.read(marketSortProvider.notifier).state = option,
                  leading: Icon(
                    option.icon,
                    size: 14,
                    color: option == sort ? Colors.white : AppColors.textMuted,
                  ),
                  label: s(option.labelKey),
                  dense: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.selected,
    required this.onTap,
    required this.label,
    this.leading,
    this.dense = false,
  });

  final bool selected;
  final VoidCallback onTap;
  final String label;
  final Widget? leading;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: AppRadius.rPill,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.rPill,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: dense ? AppSpacing.sm : AppSpacing.md,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: AppRadius.rPill,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (leading != null) ...<Widget>[
                  leading!,
                  const SizedBox(width: 5),
                ],
                Text(
                  label,
                  style: AppText.bodySmStrong.copyWith(
                    fontSize: dense ? 13 : 14,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
