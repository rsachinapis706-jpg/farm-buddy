import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';

/// The five places a farmer can go.
///
/// A floating rounded bar rather than an edge-to-edge Material bar: it reads
/// as one object, keeps the cream background visible at the edges, and gives
/// every destination a 56dp-tall target with a permanently visible label.
class FbBottomNavigation extends StatelessWidget {
  const FbBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.labels,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Exactly five labels, already localised.
  final List<String> labels;

  static const List<IconData> _icons = <IconData>[
    Icons.home_rounded,
    Icons.storefront_rounded,
    Icons.groups_rounded,
    Icons.local_shipping_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          0,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.rXl,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.nav,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(_icons.length, (int index) {
            final bool selected = index == currentIndex;
            final String label =
                index < labels.length ? labels[index] : '';
            return Expanded(
              child: Semantics(
                selected: selected,
                button: true,
                label: label,
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: AppRadius.rLg,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primarySoft
                                : Colors.transparent,
                            borderRadius: AppRadius.rPill,
                          ),
                          child: Icon(
                            _icons[index],
                            size: 23,
                            color: selected
                                ? AppColors.primaryDark
                                : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          label,
                          style: AppText.caption.copyWith(
                            fontSize: 11,
                            height: 1.1,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected
                                ? AppColors.primaryDark
                                : AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
