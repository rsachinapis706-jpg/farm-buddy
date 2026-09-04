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
import 'package:farm_buddy/features/profile/widgets/records_sheets.dart';
import 'package:farm_buddy/models/activity.dart';
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/providers/activity_providers.dart';
import 'package:farm_buddy/providers/location_providers.dart';
import 'package:farm_buddy/models/user_profile.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/providers/market_providers.dart';
import 'package:farm_buddy/widgets/cards/stat_card.dart';
import 'package:farm_buddy/widgets/common/app_header.dart';
import 'package:farm_buddy/widgets/common/language_sheet.dart';
import 'package:farm_buddy/widgets/common/status_badge.dart';

/// Who you are, what you have done, and the settings that actually matter to
/// a farmer: language and whether the app still works without a signal.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(
    BuildContext context,
    WidgetRef ref,
    AppStrings s,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rLg),
        title: Text(s('profile.logoutConfirm'), style: AppText.h3),
        content: Text(s('profile.logoutBody'), style: AppText.bodySm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(s('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(s('profile.logout')),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);
    final FarmerProfile profile = ref.watch(profileProvider);
    final AppLanguage language = ref.watch(languageProvider);
    final bool online = ref.watch(isOnlineProvider);
    final int savedMarkets = ref.watch(savedMarketIdsProvider).length;

    // The counters move when the farmer actually does something, so a demo
    // that sells a crop can be seen landing here.
    final List<SaleRecord> sales = ref.watch(salesProvider);
    final List<BookingRecord> bookings = ref.watch(bookingsProvider);
    final int totalSales = profile.totalTransactions + sales.length;
    final double totalEarned = profile.totalEarnings +
        sales.fold<double>(0, (double sum, SaleRecord r) => sum + r.net);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: s('profile.title'), showLogo: true),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.bottomNavClearance,
          ),
          children: <Widget>[
            ResponsiveCenter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // ----------------------------------------- identity
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.rXl,
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 64,
                              height: 64,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: AppRadius.rLg,
                                border: Border.all(
                                  color: AppColors.primaryLight,
                                ),
                              ),
                              child: Text(
                                profile.initials,
                                style: AppText.h2
                                    .copyWith(color: AppColors.primaryDark),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    profile.name,
                                    style: AppText.h3,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: <Widget>[
                                      const Icon(
                                        Icons.place_outlined,
                                        size: 14,
                                        color: AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          profile.location,
                                          style: AppText.caption,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    profile.phone,
                                    style: AppText.caption,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(
                              label: profile.rating.toStringAsFixed(1),
                              tone: BadgeTone.gold,
                              icon: Icons.star_rounded,
                              dense: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            s.withArgs('profile.member', <String, String>{
                              'date': profile.memberSince,
                            }),
                            style: AppText.caption,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // -------------------------------------------- stats
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: StatCard(
                          label: s('profile.listings'),
                          value: '${profile.totalListings}',
                          icon: Icons.list_alt_rounded,
                          compact: true,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: StatCard(
                          label: s('profile.transactions'),
                          value: '$totalSales',
                          icon: Icons.handshake_outlined,
                          compact: true,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: StatCard(
                          label: s('profile.earned'),
                          value: Fmt.rupeesCompact(totalEarned),
                          icon: Icons.account_balance_wallet_outlined,
                          tone: AppColors.success,
                          compact: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // -------------------------------------------- crops
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(s('profile.crops'), style: AppText.h3),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: <Widget>[
                      for (final String crop in profile.crops)
                        StatusBadge(
                          label: s('crop.${crop.toLowerCase()}'),
                          tone: BadgeTone.highlight,
                          icon: Icons.eco_outlined,
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // --------------------------------------------- menu
                  _MenuGroup(
                    children: <Widget>[
                      _MenuTile(
                        icon: Icons.grass_rounded,
                        label: s('profile.myCrops'),
                        trailing: '${profile.crops.length}',
                        onTap: () =>
                            showMyCropsSheet(context, s('profile.myCrops')),
                      ),
                      _MenuTile(
                        icon: Icons.receipt_long_rounded,
                        label: s('profile.mySales'),
                        trailing: '$totalSales',
                        onTap: () =>
                            showSalesSheet(context, s('profile.mySales')),
                      ),
                      _MenuTile(
                        icon: Icons.local_shipping_outlined,
                        label: s('profile.myTransport'),
                        trailing: '${bookings.length}',
                        onTap: () => showBookingsSheet(
                          context,
                          s('profile.myTransport'),
                        ),
                      ),
                      _MenuTile(
                        icon: Icons.bookmark_border_rounded,
                        label: s('profile.savedMarkets'),
                        trailing: '$savedMarkets',
                        onTap: () => showSavedMarketsSheet(
                          context,
                          s('profile.savedMarkets'),
                        ),
                        isLast: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  _MenuGroup(
                    children: <Widget>[
                      _MenuTile(
                        icon: Icons.translate_rounded,
                        label: s('profile.language'),
                        trailing: language.nativeName,
                        onTap: () => showLanguageSheet(context),
                      ),
                      _MenuTile(
                        icon: Icons.place_outlined,
                        label: s('profile.location'),
                        trailing: ref.watch(locationLabelProvider),
                        onTap: () => context.push(AppRoutes.locationSettings),
                      ),
                      // Offline demo: lets a judge see the cached-data
                      // behaviour without turning off mobile data.
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.wifi_off_rounded,
                              size: 21,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    s('profile.offlineMode'),
                                    style: AppText.bodyStrong,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    s('profile.offlineModeBody'),
                                    style: AppText.caption,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: !online,
                              onChanged: (bool value) => ref
                                  .read(isOnlineProvider.notifier)
                                  .state = !value,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, indent: AppSpacing.md),
                      _MenuTile(
                        icon: Icons.help_outline_rounded,
                        label: s('profile.help'),
                        onTap: () => showInfoSheet(
                          context,
                          title: s('profile.help'),
                          body: s('profile.helpBody'),
                        ),
                      ),
                      _MenuTile(
                        icon: Icons.info_outline_rounded,
                        label: s('profile.about'),
                        trailing: s('profile.version'),
                        onTap: () => showInfoSheet(
                          context,
                          title: s('profile.about'),
                          body: s('profile.aboutBody'),
                        ),
                        isLast: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  TextButton.icon(
                    onPressed: () => _confirmLogout(context, ref, s),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      minimumSize: const Size(48, AppSpacing.ctaHeight),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: Text(s('profile.logout')),
                  ),

                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    s('profile.version'),
                    style: AppText.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 21, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppText.bodyStrong,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) ...<Widget>[
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      trailing!,
                      style: AppText.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
                const SizedBox(width: AppSpacing.xxs),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: AppSpacing.md),
      ],
    );
  }
}
