import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';

/// One numbered thing to do, from the crop check.
///
/// The number matters: it turns advice into a short ordered list a farmer can
/// work through, instead of a wall of tips.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.index,
    required this.title,
    required this.body,
    this.icon = Icons.eco_outlined,
  });

  final int index;
  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppRadius.rMd,
                ),
                child: Icon(icon, size: 21, color: AppColors.primaryDark),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 17,
                  height: 17,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                  child: Text(
                    '$index',
                    style: AppText.caption.copyWith(
                      fontSize: 9.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(title, style: AppText.title),
                const SizedBox(height: 3),
                Text(body, style: AppText.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
