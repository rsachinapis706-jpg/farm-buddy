import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/formatters.dart';
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/providers/app_providers.dart';

/// "Live · updated just now" / "Saved copy · updated 10 min ago".
///
/// The offline-first promise in one component: the farmer is told how old a
/// number is instead of being shown a failure. There is no error state here
/// on purpose.
class FreshnessChip extends ConsumerWidget {
  const FreshnessChip({
    super.key,
    required this.updatedAt,
    this.freshness,
    this.compact = false,
  });

  final DateTime updatedAt;

  /// Defaults to the app-wide freshness derived from connectivity.
  final DataFreshness? freshness;

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);
    final DataFreshness state = freshness ?? ref.watch(freshnessProvider);

    final parts = Fmt.relativeParts(updatedAt);
    final String relative = s.withArgs(parts.$1, <String, String>{'n': parts.$2});

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(state.icon, size: 14, color: state.color),
        const SizedBox(width: AppSpacing.xxs),
        Flexible(
          child: Text(
            compact
                ? relative
                : '${s(state.labelKey)} · ${s.withArgs('freshness.updated', <String, String>{'time': relative})}',
            style: AppText.caption.copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
