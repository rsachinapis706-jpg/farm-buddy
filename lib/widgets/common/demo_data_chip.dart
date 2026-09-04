import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_buddy/core/constants/app_config.dart';
import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/providers/app_providers.dart';

/// Marks sample content honestly.
///
/// Judges should never have to guess whether a number is real. When the app
/// is wired to live mandi feeds, flip [AppConfig.isDemoMode] and every one of
/// these disappears.
class DemoDataChip extends ConsumerWidget {
  const DemoDataChip({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!AppConfig.isDemoMode) return const SizedBox.shrink();
    final AppStrings s = ref.watch(stringsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.neutralSoft,
        borderRadius: AppRadius.rPill,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.science_outlined, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            label ?? s('common.demoData'),
            style: AppText.caption.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
