import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';

/// How badly a market wants this crop today.
enum DemandLevel { high, medium, low }

/// Outcome of the crop photo check. Deliberately three plain states —
/// never a disease taxonomy, never a probability vector.
enum HealthStatus { healthy, possibleDisease, needsAttention }

/// Whether what the farmer is looking at came from the network or from
/// the last saved copy on the phone.
enum DataFreshness { live, cached }

enum VehicleType { miniTruck, tempo, pickup, tractorTrailer, sharedTruck }

enum AppLanguage { english, tamil, hindi }

enum MarketType { uzhavarSandhai, regulatedMandi, privateBuyer, fpo }

/// How the farmer wants the market list ordered. `bestValue` is the app's own
/// recommendation; the other two exist so the farmer can check its working.
enum MarketSort { bestValue, price, distance }

// ---------------------------------------------------------------------------

extension DemandLevelX on DemandLevel {
  String get labelKey => switch (this) {
        DemandLevel.high => 'demand.high',
        DemandLevel.medium => 'demand.medium',
        DemandLevel.low => 'demand.low',
      };

  /// Shape carries the meaning too — never colour alone.
  IconData get icon => switch (this) {
        DemandLevel.high => Icons.trending_up_rounded,
        DemandLevel.medium => Icons.trending_flat_rounded,
        DemandLevel.low => Icons.trending_down_rounded,
      };

  Color get color => switch (this) {
        DemandLevel.high => AppColors.success,
        DemandLevel.medium => AppColors.warning,
        DemandLevel.low => AppColors.textSecondary,
      };

  Color get softColor => switch (this) {
        DemandLevel.high => AppColors.successSoft,
        DemandLevel.medium => AppColors.warningSoft,
        DemandLevel.low => AppColors.neutralSoft,
      };

  /// 0..1 — used by the small three-bar demand meter.
  double get strength => switch (this) {
        DemandLevel.high => 1.0,
        DemandLevel.medium => 0.6,
        DemandLevel.low => 0.3,
      };
}

extension HealthStatusX on HealthStatus {
  String get labelKey => switch (this) {
        HealthStatus.healthy => 'health.healthy',
        HealthStatus.possibleDisease => 'health.possibleDisease',
        HealthStatus.needsAttention => 'health.needsAttention',
      };

  IconData get icon => switch (this) {
        HealthStatus.healthy => Icons.verified_rounded,
        HealthStatus.possibleDisease => Icons.report_problem_rounded,
        HealthStatus.needsAttention => Icons.info_rounded,
      };

  Color get color => switch (this) {
        HealthStatus.healthy => AppColors.success,
        HealthStatus.possibleDisease => AppColors.warning,
        HealthStatus.needsAttention => AppColors.info,
      };

  Color get softColor => switch (this) {
        HealthStatus.healthy => AppColors.successSoft,
        HealthStatus.possibleDisease => AppColors.warningSoft,
        HealthStatus.needsAttention => AppColors.infoSoft,
      };

  /// The dot that sits beside the label — 🟢 / 🟠 / 🔵 in the brief.
  String get dot => switch (this) {
        HealthStatus.healthy => '🟢',
        HealthStatus.possibleDisease => '🟠',
        HealthStatus.needsAttention => '🔵',
      };
}

extension DataFreshnessX on DataFreshness {
  String get labelKey => switch (this) {
        DataFreshness.live => 'freshness.live',
        DataFreshness.cached => 'freshness.saved',
      };

  IconData get icon => switch (this) {
        DataFreshness.live => Icons.cloud_done_rounded,
        DataFreshness.cached => Icons.cloud_off_rounded,
      };

  Color get color => switch (this) {
        DataFreshness.live => AppColors.success,
        DataFreshness.cached => AppColors.warning,
      };
}

extension VehicleTypeX on VehicleType {
  String get labelKey => switch (this) {
        VehicleType.miniTruck => 'vehicle.miniTruck',
        VehicleType.tempo => 'vehicle.tempo',
        VehicleType.pickup => 'vehicle.pickup',
        VehicleType.tractorTrailer => 'vehicle.tractorTrailer',
        VehicleType.sharedTruck => 'vehicle.sharedTruck',
      };

  IconData get icon => switch (this) {
        VehicleType.miniTruck => Icons.local_shipping_rounded,
        VehicleType.tempo => Icons.airport_shuttle_rounded,
        VehicleType.pickup => Icons.fire_truck_rounded,
        VehicleType.tractorTrailer => Icons.agriculture_rounded,
        VehicleType.sharedTruck => Icons.groups_rounded,
      };

  String get emoji => switch (this) {
        VehicleType.miniTruck => '🚚',
        VehicleType.tempo => '🚐',
        VehicleType.pickup => '🛻',
        VehicleType.tractorTrailer => '🚜',
        VehicleType.sharedTruck => '🚛',
      };
}

extension AppLanguageX on AppLanguage {
  /// Shown in its own script so a Tamil speaker can find it without reading English.
  String get nativeName => switch (this) {
        AppLanguage.english => 'English',
        AppLanguage.tamil => 'தமிழ்',
        AppLanguage.hindi => 'हिन्दी',
      };

  String get englishName => switch (this) {
        AppLanguage.english => 'English',
        AppLanguage.tamil => 'Tamil',
        AppLanguage.hindi => 'Hindi',
      };

  String get code => switch (this) {
        AppLanguage.english => 'en',
        AppLanguage.tamil => 'ta',
        AppLanguage.hindi => 'hi',
      };
}

extension MarketSortX on MarketSort {
  String get labelKey => switch (this) {
        MarketSort.bestValue => 'market.sort.best',
        MarketSort.price => 'market.sort.price',
        MarketSort.distance => 'market.sort.distance',
      };

  IconData get icon => switch (this) {
        MarketSort.bestValue => Icons.auto_awesome_rounded,
        MarketSort.price => Icons.payments_outlined,
        MarketSort.distance => Icons.near_me_rounded,
      };
}

extension MarketTypeX on MarketType {
  String get labelKey => switch (this) {
        MarketType.uzhavarSandhai => 'marketType.uzhavarSandhai',
        MarketType.regulatedMandi => 'marketType.regulatedMandi',
        MarketType.privateBuyer => 'marketType.privateBuyer',
        MarketType.fpo => 'marketType.fpo',
      };

  IconData get icon => switch (this) {
        MarketType.uzhavarSandhai => Icons.storefront_rounded,
        MarketType.regulatedMandi => Icons.account_balance_rounded,
        MarketType.privateBuyer => Icons.handshake_rounded,
        MarketType.fpo => Icons.groups_2_rounded,
      };

  Color get color => switch (this) {
        MarketType.uzhavarSandhai => AppColors.primary,
        MarketType.regulatedMandi => AppColors.sky,
        MarketType.privateBuyer => AppColors.earth,
        MarketType.fpo => AppColors.soil,
      };
}
