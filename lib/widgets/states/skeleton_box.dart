import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/widgets/common/fb_card.dart';

/// A quiet grey block used while real content is on its way.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.height = 16, this.width, this.radius = 8});

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Card-shaped placeholder used by list screens so the page does not jump
/// when the real cards arrive.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.lines = 3});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return FbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              SkeletonBox(height: 44, width: 44, radius: 14),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SkeletonBox(height: 14, width: 140),
                    SizedBox(height: AppSpacing.xs),
                    SkeletonBox(height: 12, width: 90),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (int i = 0; i < lines; i++) ...<Widget>[
            SkeletonBox(height: 12, width: i.isEven ? double.infinity : 180),
            const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}
