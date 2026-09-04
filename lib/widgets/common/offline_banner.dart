import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/formatters.dart';
import 'package:farm_buddy/providers/app_providers.dart';

/// Shown at the top of a screen when there is no connection.
///
/// Deliberately calm: it states what the farmer is looking at and how old it
/// is. No red, no dialog, no "Retry" that fails again — the app keeps working.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool online = ref.watch(isOnlineProvider);
    if (online) return const SizedBox.shrink();

    final AppStrings s = ref.watch(stringsProvider);
    final DateTime synced = ref.watch(lastSyncedProvider);
    final parts = Fmt.relativeParts(synced);
    final String relative = s.withArgs(parts.$1, <String, String>{'n': parts.$2});

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: AppRadius.rMd,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.cloud_off_rounded, size: 20, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  s('state.offline'),
                  style: AppText.bodySmStrong.copyWith(color: AppColors.textPrimary),
                ),
                Text(
                  '${s('state.offlineBody')} ${s.withArgs('freshness.updated', <String, String>{'time': relative})}',
                  style: AppText.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
