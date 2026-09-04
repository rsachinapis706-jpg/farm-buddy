import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/providers/app_providers.dart';

/// One language picker, reachable from Home and from Profile.
///
/// Each option is written in its own script so it can be found by someone who
/// cannot read the current language — the whole point of the feature.
Future<void> showLanguageSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    builder: (BuildContext context) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends ConsumerWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);
    final AppLanguage current = ref.watch(languageProvider);

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
            Text(s('profile.languageTitle'), style: AppText.h2),
            const SizedBox(height: AppSpacing.xxs),
            Text(s('profile.languageBody'), style: AppText.bodySm),
            const SizedBox(height: AppSpacing.lg),
            for (final AppLanguage lang in AppLanguage.values)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: _LanguageRow(
                  language: lang,
                  selected: lang == current,
                  onTap: () {
                    ref.read(languageProvider.notifier).state = lang;
                    Navigator.of(context).pop();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.primarySofter : AppColors.surface,
        borderRadius: AppRadius.rLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.rLg,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: AppRadius.rLg,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: AppRadius.rMd,
                  ),
                  child: Text(
                    language.code.toUpperCase(),
                    style: AppText.bodySmStrong,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        language.nativeName,
                        style: AppText.titleLg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        language.englishName,
                        style: AppText.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
