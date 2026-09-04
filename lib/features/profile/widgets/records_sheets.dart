import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/formatters.dart';
import 'package:farm_buddy/models/activity.dart';
import 'package:farm_buddy/models/crop.dart';
import 'package:farm_buddy/models/market.dart';
import 'package:farm_buddy/providers/activity_providers.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/providers/crop_providers.dart';
import 'package:farm_buddy/providers/market_providers.dart';
import 'package:farm_buddy/services/mock_data.dart';
import 'package:farm_buddy/widgets/common/emoji_text.dart';
import 'package:farm_buddy/widgets/common/fb_sheet.dart';
import 'package:farm_buddy/widgets/common/status_badge.dart';

/// The Profile menu used to be four rows that all led to a snackbar. Each one
/// now opens the real record behind it — which is also what makes selling and
/// booking feel like they happened.

Future<void> showSalesSheet(BuildContext context, String title) =>
    showFbSheet<void>(context: context, title: title, child: const _Sales());

Future<void> showBookingsSheet(BuildContext context, String title) =>
    showFbSheet<void>(context: context, title: title, child: const _Bookings());

Future<void> showSavedMarketsSheet(BuildContext context, String title) =>
    showFbSheet<void>(context: context, title: title, child: const _Saved());

Future<void> showMyCropsSheet(BuildContext context, String title) =>
    showFbSheet<void>(context: context, title: title, child: const _MyCrops());

Future<void> showInfoSheet(
  BuildContext context, {
  required String title,
  required String body,
}) {
  return showFbSheet<void>(
    context: context,
    title: title,
    child: Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(body, style: AppText.body),
    ),
  );
}

// ---------------------------------------------------------------- shared

class _Empty extends StatelessWidget {
  const _Empty({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primarySofter,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: AppColors.primaryLight),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: AppText.bodySm, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- sales

class _Sales extends ConsumerWidget {
  const _Sales();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);
    final List<SaleRecord> sales = ref.watch(salesProvider);

    if (sales.isEmpty) {
      return _Empty(
        message: s('records.empty.sales'),
        icon: Icons.receipt_long_rounded,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final SaleRecord sale in sales)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.rMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    EmojiText(sale.cropEmoji, size: 22),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        sale.marketName,
                        style: AppText.bodyStrong,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusBadge(
                      label: s('records.soldToday'),
                      tone: BadgeTone.success,
                      icon: Icons.check_circle_outline_rounded,
                      dense: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${Fmt.kilos(sale.quantityKg)} · ${Fmt.pricePerKg(sale.pricePerKg)}',
                  style: AppText.caption,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(s('records.tookHome'), style: AppText.bodySm),
                    ),
                    Text(
                      Fmt.rupees(sale.net),
                      style: AppText.priceSm
                          .copyWith(color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// -------------------------------------------------------------- bookings

class _Bookings extends ConsumerWidget {
  const _Bookings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);
    final List<BookingRecord> bookings = ref.watch(bookingsProvider);

    if (bookings.isEmpty) {
      return _Empty(
        message: s('records.empty.transport'),
        icon: Icons.local_shipping_outlined,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final BookingRecord b in bookings)
          FbSheetRow(
            icon: b.isShared ? Icons.groups_rounded : Icons.local_shipping_rounded,
            label: b.vehicleName,
            detail: b.destinationName.isEmpty
                ? Fmt.kilos(b.quantityKg)
                : '${b.destinationName} · ${Fmt.kilos(b.quantityKg)}',
            tone: b.isShared ? AppColors.harvest : AppColors.primary,
            trailing: Text(
              Fmt.rupees(b.price),
              style: AppText.priceSm.copyWith(color: AppColors.primaryDark),
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
        Text(s('records.bookedToday'), style: AppText.caption),
      ],
    );
  }
}

// ------------------------------------------------------------ saved markets

class _Saved extends ConsumerWidget {
  const _Saved();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);
    final Set<String> ids = ref.watch(savedMarketIdsProvider);

    if (ids.isEmpty) {
      return _Empty(
        message: s('records.empty.saved'),
        icon: Icons.bookmark_border_rounded,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final String id in ids)
          Builder(
            builder: (BuildContext context) {
              final Market m = MockData.marketById(id);
              return FbSheetRow(
                icon: Icons.storefront_rounded,
                label: m.name,
                detail: '${Fmt.pricePerKg(m.pricePerKg)} · ${Fmt.km(m.distanceKm)}',
                trailing: IconButton(
                  tooltip: s('common.close'),
                  icon: const Icon(Icons.bookmark_remove_outlined),
                  color: AppColors.textMuted,
                  onPressed: () {
                    final Set<String> next = <String>{...ids}..remove(id);
                    ref.read(savedMarketIdsProvider.notifier).state = next;
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}

// ------------------------------------------------------------- my crops

class _MyCrops extends ConsumerWidget {
  const _MyCrops();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);
    final List<Crop> crops = ref.watch(allCropsProvider);
    final List<String> mine = ref.watch(profileProvider).crops;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final Crop crop in crops)
          FbSheetRow(
            icon: mine.contains(crop.name)
                ? Icons.check_circle_rounded
                : Icons.circle_outlined,
            label: s(crop.nameKey),
            detail:
                '${crop.seasonHint} · ~${Fmt.pricePerKg(crop.indicativePricePerKg)}',
            tone: mine.contains(crop.name)
                ? AppColors.primary
                : AppColors.textMuted,
            trailing: EmojiText(crop.emoji, size: 20),
          ),
      ],
    );
  }
}
