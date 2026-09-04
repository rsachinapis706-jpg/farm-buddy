import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/widgets/buttons/primary_button.dart';

/// Nothing to show — but always with a way forward.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: AppColors.primarySofter,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 38, color: AppColors.primaryLight),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppText.h3, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(message, style: AppText.bodySm, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: actionLabel!,
              onPressed: onAction,
              expanded: false,
              size: FbButtonSize.medium,
            ),
          ],
        ],
      ),
    );
  }
}
