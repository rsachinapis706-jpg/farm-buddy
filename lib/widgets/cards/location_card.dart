import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';

/// "📍 Current Location — Sulur, Coimbatore   [Change]"
class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.title,
    required this.address,
    this.onChange,
    this.changeLabel,
    this.icon = Icons.place_outlined,
    this.isDetecting = false,
  });

  final String title;
  final String address;
  final VoidCallback? onChange;
  final String? changeLabel;
  final IconData icon;
  final bool isDetecting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: AppRadius.rMd,
            ),
            child: isDetecting
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : Icon(icon, color: AppColors.primaryDark, size: 21),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: AppText.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  address,
                  style: AppText.bodyStrong.copyWith(fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onChange != null) ...<Widget>[
            const SizedBox(width: AppSpacing.xs),
            TextButton(
              onPressed: onChange,
              style: TextButton.styleFrom(
                minimumSize: const Size(48, AppSpacing.touchTarget),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
              child: Text(
                changeLabel ?? 'Change',
                style: AppText.bodySmStrong.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
