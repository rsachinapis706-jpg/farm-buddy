import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/widgets/buttons/secondary_button.dart';

/// Something did not load.
///
/// Written like a person, not a stack trace: what happened, what the farmer is
/// seeing instead, and one button. Never a raw exception on screen.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    this.retryLabel,
    this.onRetry,
    this.icon = Icons.wifi_off_rounded,
  });

  final String title;
  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;

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
              color: AppColors.warningSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: AppColors.warning),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppText.h3, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(message, style: AppText.bodySm, textAlign: TextAlign.center),
          if (retryLabel != null && onRetry != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            SecondaryButton(
              label: retryLabel!,
              onPressed: onRetry,
              icon: Icons.refresh_rounded,
              expanded: false,
            ),
          ],
        ],
      ),
    );
  }
}
