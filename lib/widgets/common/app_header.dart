import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/widgets/brand/farm_buddy_logo.dart';

/// Standard screen header: big title, optional quiet subtitle, a generous
/// 48dp back target and room for one or two actions.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions,
    this.showLogo = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showLogo;

  /// Headroom on purpose: the system font can be scaled to 1.4x, and a fixed
  /// 64dp header would overflow once a translated two-line title grows.
  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 68 : 92);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: <Widget>[
            if (onBack != null)
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.textPrimary,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                iconSize: 24,
                constraints: const BoxConstraints(
                  minWidth: AppSpacing.touchTarget,
                  minHeight: AppSpacing.touchTarget,
                ),
              )
            else
              const SizedBox(width: AppSpacing.xs),
            if (showLogo) ...<Widget>[
              const FarmBuddyLogo(size: 30),
              const SizedBox(width: AppSpacing.xs),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    style: AppText.h2,
                    maxLines: subtitle == null ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppText.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (actions != null) ...actions!,
            const SizedBox(width: AppSpacing.xxs),
          ],
        ),
      ),
    );
  }
}
