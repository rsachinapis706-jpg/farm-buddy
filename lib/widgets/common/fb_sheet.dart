import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';

/// The one bottom sheet used across the app.
///
/// Every "tell me more" in Farm Buddy opens one of these rather than pushing a
/// screen: the farmer keeps their place, and a single swipe closes it. It sizes
/// to its content and caps at 85% of the screen, so a short sheet stays short.
Future<T?> showFbSheet<T>({
  required BuildContext context,
  required String title,
  String? subtitle,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      maxWidth: 560,
    ),
    builder: (BuildContext context) => FbSheetBody(
      title: title,
      subtitle: subtitle,
      child: child,
    ),
  );
}

class FbSheetBody extends StatelessWidget {
  const FbSheetBody({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: AppText.h2, maxLines: 2),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xxs),
              Text(subtitle!, style: AppText.bodySm, maxLines: 3),
            ],
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: SingleChildScrollView(child: child),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tappable row inside a sheet: icon, label, optional detail, chevron.
class FbSheetRow extends StatelessWidget {
  const FbSheetRow({
    super.key,
    required this.icon,
    required this.label,
    this.detail,
    this.onTap,
    this.tone,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String? detail;
  final VoidCallback? onTap;
  final Color? tone;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Color accent = tone ?? AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.rMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.rMd,
          child: Container(
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: AppRadius.rMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: AppRadius.rSm,
                  ),
                  child: Icon(icon, size: 20, color: accent),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        label,
                        style: AppText.bodyStrong,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (detail != null)
                        Text(
                          detail!,
                          style: AppText.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (onTap != null)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
