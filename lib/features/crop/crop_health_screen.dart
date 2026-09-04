import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/core/router/app_router.dart';
import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/formatters.dart';
import 'package:farm_buddy/core/utils/responsive.dart';
import 'package:farm_buddy/features/crop/widgets/ask_expert_sheet.dart';
import 'package:farm_buddy/models/crop.dart';
import 'package:farm_buddy/models/crop_health.dart';
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/providers/crop_providers.dart';
import 'package:farm_buddy/widgets/buttons/primary_button.dart';
import 'package:farm_buddy/widgets/buttons/secondary_button.dart';
import 'package:farm_buddy/widgets/cards/recommendation_card.dart';
import 'package:farm_buddy/widgets/common/app_header.dart';
import 'package:farm_buddy/widgets/common/crop_photo.dart';
import 'package:farm_buddy/widgets/common/demo_data_chip.dart';
import 'package:farm_buddy/widgets/common/emoji_text.dart';
import 'package:farm_buddy/widgets/states/empty_state.dart';
import 'package:farm_buddy/widgets/states/error_state.dart';
import 'package:farm_buddy/widgets/states/loading_state.dart';

/// The crop check, translated into actions.
///
/// There is no model name on this screen, no probability distribution, no
/// "inference". A status, a plain-language confidence line, and two or three
/// things to do today. That is the entire contract with the farmer.
class CropHealthScreen extends ConsumerWidget {
  const CropHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);
    final CropListing? listing = ref.watch(currentListingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: s('health.title'),
        onBack: () =>
            context.canPop() ? context.pop() : context.go(AppRoutes.home),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.xs),
            child: Center(child: DemoDataChip()),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: (listing == null || !listing.hasPhoto)
            ? _NoPhoto(strings: s)
            : _Result(strings: s, listing: listing),
      ),
    );
  }
}

class _NoPhoto extends StatelessWidget {
  const _NoPhoto({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: EmptyState(
          icon: Icons.photo_camera_outlined,
          title: strings('health.noPhoto'),
          message: strings('health.noPhotoBody'),
          actionLabel: strings('health.addPhoto'),
          onAction: () => context.push(AppRoutes.addCrop),
        ),
      ),
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.strings, required this.listing});

  final AppStrings strings;
  final CropListing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CropHealthResult> result = ref.watch(cropHealthProvider);

    return result.when(
      loading: () => Center(
        child: LoadingState(
          message:
              '${strings('health.analyzing')}\n${strings('health.analyzingBody')}',
        ),
      ),
      error: (Object error, StackTrace stack) => Center(
        child: ErrorState(
          title: strings('state.errorTitle'),
          message: strings('state.errorBody'),
          retryLabel: strings('common.retry'),
          onRetry: () => ref.invalidate(cropHealthProvider),
        ),
      ),
      data: (CropHealthResult data) =>
          _ResultBody(strings: strings, result: data, listing: listing),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    required this.strings,
    required this.result,
    required this.listing,
  });

  final AppStrings strings;
  final CropHealthResult result;
  final CropListing listing;

  @override
  Widget build(BuildContext context) {
    final AppStrings s = strings;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: <Widget>[
        ResponsiveCenter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CropPhoto(
                path: result.imagePath ?? listing.photoPath,
                height: 220,
              ),

              const SizedBox(height: AppSpacing.md),

              // ------------------------------------------ verdict card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: result.status.softColor,
                  borderRadius: AppRadius.rLg,
                  border: Border.all(color: result.status.color.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        EmojiText(result.cropEmoji, size: 26),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            s(listing.crop.nameKey),
                            style: AppText.h2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        EmojiText(result.status.dot, size: 15),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: <Widget>[
                        Icon(result.status.icon, color: result.status.color),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            s(result.status.labelKey),
                            style: AppText.h2.copyWith(color: result.status.color),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(s(result.summaryKey), style: AppText.bodySm),

                    const SizedBox(height: AppSpacing.md),

                    // ------------------------------- confidence, in words
                    Text(
                      s.withArgs('health.sureLine', <String, String>{
                        'percent': '${result.confidencePercent}',
                      }),
                      style: AppText.bodySmStrong,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: result.confidence,
                        minHeight: 8,
                        backgroundColor: Colors.white,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(result.status.color),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            s.withArgs('health.checkedAt', <String, String>{
                              'time': Fmt.relative(result.analyzedAt),
                            }),
                            style: AppText.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ------------------------------------------ what to do
              Text(s('health.whatToDo'), style: AppText.h3),
              const SizedBox(height: AppSpacing.sm),
              for (int i = 0; i < result.advice.length; i++)
                RecommendationCard(
                  index: i + 1,
                  icon: result.advice[i].icon,
                  title: s(result.advice[i].titleKey),
                  body: s(result.advice[i].bodyKey),
                ),

              const SizedBox(height: AppSpacing.xs),

              // ------------------------------------------ ask expert
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.skySoft,
                  borderRadius: AppRadius.rLg,
                  border: Border.all(color: AppColors.sky.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.rMd,
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: AppColors.sky,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(s('health.askExpert'), style: AppText.titleLg),
                          Text(s('health.askExpertBody'), style: AppText.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                label: s('health.askExpert'),
                icon: Icons.call_outlined,
                foreground: AppColors.sky,
                onPressed: () =>
                    showAskExpertSheet(context, title: s('expert.title')),
              ),

              const SizedBox(height: AppSpacing.lg),
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

              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: s('health.findMarket'),
                icon: Icons.storefront_rounded,
                onPressed: () => context.go(AppRoutes.markets),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
