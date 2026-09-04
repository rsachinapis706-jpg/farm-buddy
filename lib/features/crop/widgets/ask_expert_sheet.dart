import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/widgets/buttons/primary_button.dart';
import 'package:farm_buddy/widgets/common/fb_sheet.dart';

/// The escape hatch from the crop check.
///
/// The app is honest that a photo is guidance, not a diagnosis — so "Ask
/// Expert" has to lead somewhere real. Two routes a farmer in Tamil Nadu
/// actually has: the block agriculture officer, and the Kisan Call Centre.
Future<void> showAskExpertSheet(
  BuildContext context, {
  required String title,
}) {
  return showFbSheet<void>(
    context: context,
    title: title,
    child: const _AskExpertBody(),
  );
}

class _AskExpertBody extends ConsumerWidget {
  const _AskExpertBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(s('expert.body'), style: AppText.bodySm),
        const SizedBox(height: AppSpacing.md),

        FbSheetRow(
          icon: Icons.person_pin_circle_outlined,
          label: s('expert.officer'),
          detail: s('expert.officerSub'),
          onTap: () => _request(context, ref, s),
        ),
        FbSheetRow(
          icon: Icons.support_agent_rounded,
          label: s('expert.helpline'),
          detail: s('expert.helplineSub'),
          tone: AppColors.sky,
          onTap: () => _request(context, ref, s),
        ),

        const SizedBox(height: AppSpacing.sm),
        PrimaryButton(
          label: s('health.askExpert'),
          icon: Icons.call_outlined,
          onPressed: () => _request(context, ref, s),
        ),

        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(
              Icons.info_outline_rounded,
              size: 15,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(s('health.disclaimer'), style: AppText.caption),
            ),
          ],
        ),
      ],
    );
  }

  void _request(BuildContext context, WidgetRef ref, AppStrings s) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s('expert.requested'))),
    );
  }
}
