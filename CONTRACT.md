# FARM BUDDY — BINDING DESIGN & CODE CONTRACT

> Every file in this project MUST conform to this document. Names, signatures and
> tokens here are BINDING. Do not invent alternative names. Do not rename fields.
> If you need something not listed here, build it INSIDE your own file — never
> change a shared API.

App: **FARM BUDDY** · Tagline: **"The right decision. At the right time."**
Audience: Indian farmers. Low tech-familiarity, weak connectivity, regional languages.
Feel: *Google Maps simplicity + modern fintech clarity + agricultural warmth.*

North-star journey (must be obvious in the UI):
`Open App -> Add Crop -> Photo -> Location -> Analyze -> Best Market -> Act`

---

## 0. GLOBAL CODING RULES (non-negotiable)

1. Flutter + Dart, **Material 3** (`useMaterial3: true`), **flutter_riverpod**, **go_router**.
2. Every file starts with the imports it needs. Use **package imports**:
   `import 'package:farm_buddy/core/theme/app_colors.dart';` — never relative `../..`.
3. Screens that read state are `ConsumerWidget` or `ConsumerStatefulWidget`
   (`import 'package:flutter_riverpod/flutter_riverpod.dart';`).
   Pure presentational widgets are plain `StatelessWidget`.
4. **No hard-coded colors.** Only `AppColors.*`. **No hard-coded text sizes.** Only `AppText.*`.
   **No magic numbers for spacing.** Only `AppSpacing.*` / `AppRadius.*`.
5. **No network calls, no Google Maps SDK, no Firebase, no google_fonts.**
   Maps are `MapPreview` (a CustomPainter). Charts are `PriceTrendChart` (a CustomPainter).
6. **No asset images.** Illustrations come from `lib/widgets/illustrations/`.
7. Every user-visible string goes through the localisation helper (Section 4).
   Pattern: `final s = ref.watch(stringsProvider);` then `s('home.greeting')`.
   If a key is missing it falls back to English, then to the key itself — never crashes.
8. Accessibility: minimum touch target **48dp** (primary CTAs **56dp**).
   Status is **never colour-only** — always colour + icon + text.
   Wrap decorative painters in `ExcludeSemantics`; give icon-only buttons a `tooltip`.
9. Layout must survive long translated strings: use `Expanded`/`Flexible` inside `Row`s,
   allow `maxLines: 2` + `TextOverflow.ellipsis` on titles, never fix a width to fit text.
10. Responsive: never a fixed page width. Use `LayoutBuilder`/`MediaQuery` where needed.
    Content max width 560 on wide screens via `ResponsiveCenter` (Section 5).
11. `const` everywhere possible. No `print()`. No `late` without initialisation in the same
    lifecycle. No `!` on a nullable unless guarded on the line above.
12. Null-safety strict. Every model field is `final`. Every constructor is `const` where possible.
13. Animations: subtle only (150–350ms, `Curves.easeOut`). No parallax, no confetti.

---

## 1. COLOUR TOKENS — `lib/core/theme/app_colors.dart`

```dart
abstract final class AppColors {
  // Brand — soft leaf green
  static const Color primary       = Color(0xFF2F7A4F);
  static const Color primaryDark   = Color(0xFF1B5233);
  static const Color primaryLight  = Color(0xFF5FA97C);
  static const Color primarySoft   = Color(0xFFE4F1E8); // tinted fills
  static const Color primarySofter = Color(0xFFF1F8F3);

  // Warm cream canvas
  static const Color background = Color(0xFFFBF8F1);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF4F0E5);
  static const Color border     = Color(0xFFE7E1D3);
  static const Color borderStrong = Color(0xFFD6CEBB);

  // Text — dark green for importance
  static const Color textPrimary   = Color(0xFF14301F);
  static const Color textSecondary = Color(0xFF56685C);
  static const Color textMuted     = Color(0xFF8A9990);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Earthy secondaries
  static const Color earth   = Color(0xFFC0653C); // terracotta
  static const Color soil    = Color(0xFF8B6B4A);
  static const Color harvest = Color(0xFFE3A03A); // grain gold
  static const Color sky     = Color(0xFF3C7EA6);

  // Semantic
  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFD9862B);
  static const Color danger  = Color(0xFFC2402C);
  static const Color info    = Color(0xFF3C7EA6);
  static const Color successSoft = Color(0xFFE2F4E8);
  static const Color warningSoft = Color(0xFFFBF0DE);
  static const Color dangerSoft  = Color(0xFFFAE7E3);
  static const Color infoSoft    = Color(0xFFE4EFF6);
  static const Color neutralSoft = Color(0xFFF0EDE3);

  // Medals for market ranking
  static const Color gold   = Color(0xFFD4A017);
  static const Color silver = Color(0xFF9AA0A6);
  static const Color bronze = Color(0xFFB07A46);

  // Map canvas (drawn, not tiled)
  static const Color mapLand  = Color(0xFFEFF3E7);
  static const Color mapField = Color(0xFFE2EAD5);
  static const Color mapRoad  = Color(0xFFFFFFFF);
  static const Color mapWater = Color(0xFFCFE0EA);

  static const Color scrim = Color(0x3314301F);
}
```

## 2. TYPE / SPACING / RADIUS / SHADOW

`lib/core/theme/app_typography.dart`

```dart
abstract final class AppText {
  static const TextStyle display   = TextStyle(fontSize: 32, height: 1.15, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5);
  static const TextStyle h1        = TextStyle(fontSize: 26, height: 1.20, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3);
  static const TextStyle h2        = TextStyle(fontSize: 22, height: 1.25, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const TextStyle h3        = TextStyle(fontSize: 19, height: 1.30, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const TextStyle titleLg   = TextStyle(fontSize: 18, height: 1.30, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle title     = TextStyle(fontSize: 17, height: 1.35, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle body      = TextStyle(fontSize: 16, height: 1.45, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static const TextStyle bodyStrong= TextStyle(fontSize: 16, height: 1.45, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle bodySm    = TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static const TextStyle bodySmStrong = TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle label     = TextStyle(fontSize: 13, height: 1.30, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.2);
  static const TextStyle caption   = TextStyle(fontSize: 12, height: 1.35, fontWeight: FontWeight.w500, color: AppColors.textMuted);
  // Money — confident, tight
  static const TextStyle priceLg   = TextStyle(fontSize: 30, height: 1.10, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5);
  static const TextStyle priceMd   = TextStyle(fontSize: 24, height: 1.10, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3);
  static const TextStyle priceSm   = TextStyle(fontSize: 18, height: 1.15, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const TextStyle button    = TextStyle(fontSize: 17, height: 1.20, fontWeight: FontWeight.w700, letterSpacing: 0.1);
}
```

`lib/core/theme/app_spacing.dart` — contains ALL THREE classes below in this one file:

```dart
abstract final class AppSpacing {
  static const double xxs = 4, xs = 8, sm = 12, md = 16, lg = 20, xl = 24, xxl = 32, xxxl = 40, huge = 48;
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets card   = EdgeInsets.all(16);
  static const double bottomNavClearance = 96; // bottom padding so the nav never covers content
}
abstract final class AppRadius {
  static const double sm = 12, md = 16, lg = 20, xl = 28, pill = 999;
  static const BorderRadius rSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius rMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius rLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius rXl = BorderRadius.all(Radius.circular(xl));
}
abstract final class AppShadows {
  static const List<BoxShadow> card   = [BoxShadow(color: Color(0x0F14301F), blurRadius: 16, offset: Offset(0, 4))];
  static const List<BoxShadow> raised = [BoxShadow(color: Color(0x1A14301F), blurRadius: 24, offset: Offset(0, 8))];
  static const List<BoxShadow> nav    = [BoxShadow(color: Color(0x1414301F), blurRadius: 20, offset: Offset(0, -4))];
}
```

`lib/core/theme/app_theme.dart` — `abstract final class AppTheme { static ThemeData get light; }`
Light theme only (`themeMode: ThemeMode.light`). `ColorScheme.fromSeed(seedColor: AppColors.primary)`
then `.copyWith(...)` the tokens above. Set `scaffoldBackgroundColor: AppColors.background`, and
Material 3 `filledButtonTheme` / `outlinedButtonTheme` / `inputDecorationTheme` / `bottomSheetTheme` /
`snackBarTheme` consistent with the tokens. `fontFamily` is left NULL on purpose (platform font —
no download, works offline).

## 3. MODELS — `lib/models/`

`enums.dart`

```dart
enum DemandLevel { high, medium, low }
enum HealthStatus { healthy, possibleDisease, needsAttention }
enum DataFreshness { live, cached }
enum VehicleType { miniTruck, tempo, pickup, tractorTrailer, sharedTruck }
enum AppLanguage { english, tamil, hindi }
enum MarketType { uzhavarSandhai, regulatedMandi, privateBuyer, fpo }
```

Each enum gets an extension exposing: `String get labelKey` (an l10n key such as `'demand.high'`),
`IconData get icon`, `Color get color`, `Color get softColor` where meaningful.
`AppLanguage` also gets `String get nativeName` ("English" / "தமிழ்" / "हिन्दी") and `String get code`.

`crop.dart`

```dart
class Crop {
  final String id, name, emoji, seasonHint;
  final double indicativePricePerKg;
  const Crop({required this.id, required this.name, required this.emoji,
              required this.seasonHint, required this.indicativePricePerKg});
}

class CropListing {
  final String id;
  final Crop crop;
  final double quantityKg;
  final String? photoPath;
  final String locationName;
  final DateTime createdAt;
  const CropListing({required this.id, required this.crop, required this.quantityKg,
                     this.photoPath, required this.locationName, required this.createdAt});
  CropListing copyWith({Crop? crop, double? quantityKg, String? photoPath, String? locationName});
}
```

`market.dart`

```dart
class Market {
  final String id, name;
  final MarketType type;
  final String area;                 // "Singanallur, Coimbatore"
  final double pricePerKg;
  final double yesterdayPricePerKg;
  final double distanceKm;
  final DemandLevel demand;
  final int requiredQuantityKg;
  final int todaysArrivalsKg;
  final double travelCostEstimate;
  final String openHours;            // "6:00 AM – 1:00 PM"
  final List<double> priceHistory;   // 7 values, oldest -> newest
  final List<String> reasonKeys;     // l10n keys, e.g. 'reason.goodPrice'
  final double mapX, mapY;           // 0..1 normalised position on MapPreview
  final DateTime updatedAt;
  const Market({ /* all of the above, all required except none */ });

  double get priceChangePercent;                                   // vs yesterday
  bool   get isPriceUp;
  double expectedValue(double quantityKg) => pricePerKg * quantityKg;
  double netValue(double quantityKg) => expectedValue(quantityKg) - travelCostEstimate;
  bool   acceptsQuantity(double quantityKg) => quantityKg <= requiredQuantityKg;
}
```

`farmer.dart`

```dart
class NearbyFarmer {
  final String id, name, village;
  final double distanceKm;
  final String cropName, cropEmoji;
  final double quantityKg;
  final int avatarSeed;
  final List<String> tagKeys;
  final bool isConnected;
  final double rating;
  const NearbyFarmer({ ... });
  NearbyFarmer copyWith({bool? isConnected});
}

class GroupSaleOpportunity {
  final String cropName, cropEmoji;
  final int farmerCount;
  final double totalQuantityKg, betterPricePerKg, soloPricePerKg;
  final List<NearbyFarmer> members;
  const GroupSaleOpportunity({ ... });
  double get extraEarning;   // (betterPricePerKg - soloPricePerKg) * totalQuantityKg
}
```

`transport.dart`

```dart
class TransportRoute {
  final String pickupName, pickupSub, destinationName, destinationSub;
  final double distanceKm;
  final int durationMinutes;
  final double estimatedCost;
  const TransportRoute({ ... });
}

class TransportOption {
  final String id, providerName, driverName;
  final VehicleType type;
  final int capacityKg;
  final double price;
  final int etaMinutes;
  final bool isAvailable;
  final double rating;
  final bool isShared;
  final double? savingAmount;
  final int? sharingFarmerCount;
  const TransportOption({ ... });
}
```

`crop_health.dart`

```dart
class HealthAdvice {
  final String titleKey, bodyKey;
  final IconData icon;
  const HealthAdvice({required this.titleKey, required this.bodyKey, required this.icon});
}

class CropHealthResult {
  final String cropName, cropEmoji;
  final HealthStatus status;
  final double confidence;          // 0.0 – 1.0
  final String summaryKey;
  final List<HealthAdvice> advice;
  final String? imagePath;
  final DateTime analyzedAt;
  const CropHealthResult({ ... });
  int get confidencePercent;
}
```

`user_profile.dart`

```dart
class FarmerProfile {
  final String name, village, district, phone;
  final List<String> crops;
  final int totalListings, totalTransactions;
  final double totalEarnings;
  final String memberSince;
  final double rating;
  const FarmerProfile({ ... });
}
```

`market_insight.dart`

```dart
class MarketInsight {
  final String cropName, cropEmoji;
  final double pricePerKg, changePercent, distanceKm;
  final DemandLevel demand;
  final DateTime updatedAt;
  const MarketInsight({ ... });
  bool get isUp;
}
```

## 4. LOCALISATION — `lib/core/l10n/app_strings.dart`

```dart
class AppStrings {
  final AppLanguage language;
  const AppStrings(this.language);
  String call(String key);                                  // usage: s('home.greeting')
  String withArgs(String key, Map<String, String> args);    // replaces {name} style tokens
  String plural(String key, num n);                         // key + '.one' / '.other', {n} placeholder
  static const Map<String, String> en = { ... };
  static const Map<String, String> ta = { ... };
  static const Map<String, String> hi = { ... };
}
```

Lookup order: current language map -> `en` -> the key itself. NEVER throws.
Placeholders use `{braces}`: `'home.greeting': 'Good morning, {name}'`.

## 5. UTILITIES — `lib/core/utils/`

`formatters.dart`

```dart
abstract final class Fmt {
  static String rupees(num v);          // 16000 -> "₹16,000"     (Indian grouping: 1,86,400)
  static String rupeesCompact(num v);   // 16000 -> "₹16K"
  static String pricePerKg(num v);      // 32    -> "₹32/kg"
  static String km(num v);              // 12.4  -> "12.4 km" ; 12.0 -> "12 km"
  static String quantity(num kg);       // 500 -> "500 kg" ; 1850 -> "1,850 kg" ; 2000 -> "2 tonnes"
  static String percent(num v);         // 8.2   -> "8.2%"
  static String signedPercent(num v);   // -3    -> "-3%"  (caller adds the arrow icon)
  static String minutes(int m);         // 95    -> "1 hr 35 min"
  static String relative(DateTime t);   // -> "just now" / "10 min ago" / "2 hr ago" / "yesterday"
}
```

The rupee symbol is the literal character `₹` in source (UTF-8 is fine).

`responsive.dart`

```dart
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({super.key, required this.child, this.maxWidth = 560, this.padding = AppSpacing.screen});
}
extension ContextSize on BuildContext {
  bool get isCompactHeight;  double get screenW;  double get screenH;
}
```

`lib/core/constants/app_config.dart`

```dart
abstract final class AppConfig {
  static const String appName  = 'FARM BUDDY';
  static const String tagline  = 'The right decision. At the right time.';
  static const bool isDemoMode = true;                            // renders the "Demo data" chip
  static const Duration fakeLatency = Duration(milliseconds: 900);
  static const String defaultLocation = 'Coimbatore, Tamil Nadu';
}
```

## 6. SERVICES & PROVIDERS

`lib/services/mock_data.dart` — `abstract final class MockData { ... }` with static members:
`crops`, `markets`, `nearbyFarmers`, `groupSale`, `transportOptions`, `transportRoute`,
`profile`, `todayInsight`, `healthyResult`, `diseasedResult`.
All data is Coimbatore-district realistic. Every screen that shows it renders `DemoDataChip` once.

Services (plain classes, async, `await Future.delayed(AppConfig.fakeLatency)`):

```dart
// market_service.dart
class MarketService {
  Future<List<Market>> rankedMarketsFor(Crop crop, double quantityKg);
  Future<Market> byId(String id);
  Future<MarketInsight> todayInsight();
}
// crop_service.dart
class CropService {
  List<Crop> allCrops();
  Future<CropHealthResult> analyze(CropListing listing);
}
// farmer_service.dart
class FarmerService {
  Future<List<NearbyFarmer>> nearby({String? cropFilter});
  Future<GroupSaleOpportunity> groupSale();
}
// transport_service.dart
class TransportService {
  Future<TransportRoute> route();
  Future<List<TransportOption>> options(double quantityKg);
}
```

`lib/providers/app_providers.dart`

```dart
final languageProvider   = StateProvider<AppLanguage>((ref) => AppLanguage.english);
final stringsProvider    = Provider<AppStrings>((ref) => AppStrings(ref.watch(languageProvider)));
final isOnlineProvider   = StateProvider<bool>((ref) => true);
final lastSyncedProvider = StateProvider<DateTime>((ref) => DateTime.now().subtract(const Duration(minutes: 10)));
final locationProvider   = StateProvider<String>((ref) => 'Coimbatore');
final profileProvider    = Provider<FarmerProfile>((ref) => MockData.profile);
```

`lib/providers/crop_providers.dart`

```dart
final cropServiceProvider = Provider<CropService>((ref) => CropService());
final allCropsProvider    = Provider<List<Crop>>((ref) => ref.watch(cropServiceProvider).allCrops());
class CurrentListingNotifier extends StateNotifier<CropListing?> { /* setCrop setQuantity setPhoto submit clear */ }
final currentListingProvider = StateNotifierProvider<CurrentListingNotifier, CropListing?>((ref) => CurrentListingNotifier());
final cropHealthProvider = FutureProvider.autoDispose<CropHealthResult>((ref) async { ... });
```

`market_providers.dart` -> `marketServiceProvider`, `rankedMarketsProvider`
(`FutureProvider.autoDispose<List<Market>>`), `marketByIdProvider`
(`FutureProvider.autoDispose.family<Market, String>`), `todayInsightProvider`
(`FutureProvider<MarketInsight>`).

`farmer_providers.dart` -> `farmerServiceProvider`, `farmerFilterProvider`
(`StateProvider<String>`, default `'all'`), `nearbyFarmersProvider`
(`FutureProvider.autoDispose<List<NearbyFarmer>>`), `groupSaleProvider`
(`FutureProvider<GroupSaleOpportunity>`), `connectedFarmerIdsProvider` (`StateProvider<Set<String>>`).

`transport_providers.dart` -> `transportServiceProvider`, `transportRouteProvider`, `transportOptionsProvider`.

Providers are declared in these files ONLY. Screens never declare a global provider.

## 7. WIDGET LIBRARY — BINDING CONSTRUCTORS

### `lib/widgets/buttons/primary_button.dart`

```dart
enum FbButtonSize { large, medium }
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed, this.icon,
    this.isLoading = false, this.expanded = true, this.size = FbButtonSize.large, this.tone});
  final String label; final VoidCallback? onPressed; final IconData? icon;
  final bool isLoading; final bool expanded; final FbButtonSize size; final Color? tone;
}
```

Height 56 (large) / 48 (medium). Filled `AppColors.primary`, radius `AppRadius.rLg`, white bold label.
Disabled when `onPressed == null` or `isLoading`. Loading shows a 20px white spinner + keeps the label.

### `lib/widgets/buttons/secondary_button.dart`

```dart
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, this.onPressed, this.icon,
    this.expanded = true, this.size = FbButtonSize.large});
}
```

Outlined: white fill, 1.5px `AppColors.borderStrong`, `AppColors.textPrimary` label.

### `lib/widgets/buttons/fb_icon_button.dart`

```dart
class FbIconButton extends StatelessWidget {
  const FbIconButton({super.key, required this.icon, required this.tooltip,
    this.onPressed, this.background, this.foreground});
}
```

48x48, circular, `AppColors.surface` background by default.

### `lib/widgets/common/status_badge.dart`

```dart
enum BadgeTone { success, warning, danger, info, neutral, highlight, gold }
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.tone = BadgeTone.neutral,
    this.icon, this.dense = false});
}
```

Pill, soft background + strong foreground, ALWAYS renders `icon` when provided
(colour is never the only signal).

### `lib/widgets/common/app_header.dart`

```dart
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key, required this.title, this.subtitle, this.onBack,
    this.actions, this.showLogo = false});
  @override Size get preferredSize => const Size.fromHeight(64);
}
```

Cream background, no elevation, 22px bold title, optional 13px subtitle, 48dp back target.

### `lib/widgets/common/section_header.dart`

```dart
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction, this.icon});
}
```

### `lib/widgets/common/freshness_chip.dart`

```dart
class FreshnessChip extends StatelessWidget {
  const FreshnessChip({super.key, required this.updatedAt, this.freshness = DataFreshness.live});
}
```

Renders `"Live · updated just now"` or `"Saved copy · updated 10 min ago"` with a cloud / cloud-off icon.

### `lib/widgets/common/offline_banner.dart`

```dart
class OfflineBanner extends ConsumerWidget { const OfflineBanner({super.key}); }
```

Shows only when `isOnlineProvider` is false. Amber, icon + "You are offline. Showing saved information."
NEVER an error dialog.

### `lib/widgets/common/demo_data_chip.dart`

```dart
class DemoDataChip extends StatelessWidget { const DemoDataChip({super.key, this.label}); }
```

Tiny neutral pill: "Demo data". Only rendered when `AppConfig.isDemoMode`.

### `lib/widgets/common/map_preview.dart`

```dart
class MapMarker {
  const MapMarker({required this.x, required this.y, required this.label,
    this.isPrimary = false, this.rank, this.emoji});
  final double x, y;      // 0..1 within the map box
  final String label; final bool isPrimary; final int? rank; final String? emoji;
}
class MapPreview extends StatelessWidget {
  const MapPreview({super.key, this.height = 200, this.markers = const [],
    this.showYouAreHere = true, this.onTap, this.centerLabel, this.showRoute = false});
}
```

A CustomPainter drawing cream land, soft field patches, a river, white roads, then markers
(numbered pins for ranks, a blue dot for "you"). Rounded `AppRadius.rLg`, clipped.
`showRoute: true` draws a dashed line from the "you" dot to the primary marker.

### `lib/widgets/common/price_trend_chart.dart`

```dart
class PriceTrendChart extends StatelessWidget {
  const PriceTrendChart({super.key, required this.values, this.height = 120,
    this.labels, this.lineColor = AppColors.primary, this.showLastValueDot = true});
}
```

Smoothed line + soft gradient fill + a dot on the last point + 7 day letters underneath.
No axes, no gridlines beyond one faint baseline. No charting package.

### `lib/widgets/common/fb_card.dart`

```dart
class FbCard extends StatelessWidget {
  const FbCard({super.key, required this.child, this.padding = AppSpacing.card, this.onTap,
    this.background = AppColors.surface, this.borderColor, this.radius = AppRadius.rLg, this.shadows});
}
```

The base surface every card composes.

### `lib/widgets/cards/*.dart` — one class per file

```dart
// action_tile.dart  (the 4 home shortcuts)
class ActionTile extends StatelessWidget {
  const ActionTile({super.key, required this.emoji, required this.title,
    required this.subtitle, required this.onTap, this.accent = AppColors.primary});
}

// hero_action_card.dart  (the big "Sell My Crop" card)
class HeroActionCard extends StatelessWidget {
  const HeroActionCard({super.key, required this.title, required this.subtitle,
    required this.buttonLabel, required this.onPressed, this.footnote});
}

// market_card.dart
class MarketCard extends StatelessWidget {
  const MarketCard({super.key, required this.market, required this.quantityKg, required this.onTap,
    this.rank, this.isBest = false, this.rankLabel, this.demandLabel, this.badgeLabel,
    this.expectedValueLabel, this.actionLabel});
}
// Rank 1 = elevated card, gold medal chip, "BEST VALUE" badge, expected-value block, filled CTA.
// Rank 2/3 = compact row: medal, name, ₹/kg, distance, demand badge, chevron.

// farmer_card.dart
class FarmerCard extends StatelessWidget {
  const FarmerCard({super.key, required this.farmer, required this.onConnect,
    required this.onViewProfile, this.connectLabel, this.profileLabel, this.growingLabel});
}

// crop_card.dart
class CropCard extends StatelessWidget {
  const CropCard({super.key, required this.crop, this.quantityKg, this.trailing,
    this.onTap, this.selected = false});
}

// recommendation_card.dart
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key, required this.index, required this.title,
    required this.body, this.icon = Icons.eco_outlined});
}

// stat_card.dart
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value, this.icon,
    this.tone, this.caption});
}

// location_card.dart
class LocationCard extends StatelessWidget {
  const LocationCard({super.key, required this.title, required this.address, this.onChange,
    this.changeLabel, this.icon = Icons.place_outlined, this.isDetecting = false});
}

// transport_card.dart
class TransportCard extends StatelessWidget {
  const TransportCard({super.key, required this.option, required this.onRequest,
    this.requestLabel, this.capacityLabel, this.availableLabel, this.unavailableLabel,
    this.isSelected = false, this.onTap});
}

// insight_card.dart  (Today's Market Insight on Home)
class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.insight, required this.onViewDetails,
    this.title, this.actionLabel, this.demandLabel});
}

// why_card.dart  ("Why this is recommended")
class WhyCard extends StatelessWidget {
  const WhyCard({super.key, required this.title, required this.reasons});  // List<String>
}
```

### `lib/widgets/states/*.dart`

```dart
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.message,
    this.icon = Icons.inbox_outlined, this.actionLabel, this.onAction});
}
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message, this.height = 220});   // leaf spinner + calm message
}
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.title, required this.message,
    this.retryLabel, this.onRetry, this.icon = Icons.wifi_off_rounded});
}
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.height = 16, this.width, this.radius = 8});
}
```

### `lib/widgets/brand/farm_buddy_logo.dart`

```dart
class FarmBuddyLogo extends StatelessWidget {
  const FarmBuddyLogo({super.key, this.size = 96, this.showWordmark = false, this.onCream = false});
}
class FarmBuddyWordmark extends StatelessWidget {
  const FarmBuddyWordmark({super.key, this.fontSize = 28, this.color = AppColors.textPrimary});
}
```

Mark concept: a **leaf whose base tapers into a location-pin point**, with a small circular
"seed" cut-out — one green shape, one gold accent, nothing more. Drawn with `CustomPainter`
so it scales from a 24px header mark to a splash mark to an app icon.

### `lib/widgets/illustrations/*.dart` — CustomPainter scenes, no assets

```dart
class CropInspectIllustration extends StatelessWidget { const CropInspectIllustration({super.key, this.size = 240}); }  // farmer + magnifier over a plant
class MarketIllustration      extends StatelessWidget { const MarketIllustration({super.key, this.size = 240}); }       // stalls, crates, price tags
class TogetherIllustration    extends StatelessWidget { const TogetherIllustration({super.key, this.size = 240}); }     // two farmers + a truck
class FieldScene              extends StatelessWidget { const FieldScene({super.key, this.height = 180}); }             // rolling fields + sun (splash / auth)
```

### `lib/widgets/common/bottom_navigation.dart`

```dart
class FbBottomNavigation extends StatelessWidget {
  const FbBottomNavigation({super.key, required this.currentIndex, required this.onTap, required this.labels});
  final int currentIndex; final ValueChanged<int> onTap; final List<String> labels; // exactly 5
}
```

5 items: Home (`Icons.home_rounded`), Markets (`Icons.storefront_rounded`),
Farmers (`Icons.groups_rounded`), Transport (`Icons.local_shipping_rounded`),
Profile (`Icons.person_rounded`). Floating rounded bar, `AppShadows.nav`, 64dp tall,
active = green icon + green label + soft pill behind the icon. Labels always visible.

## 8. ROUTES — `lib/core/router/app_router.dart`

```dart
abstract final class AppRoutes {
  static const splash        = '/';
  static const onboarding    = '/onboarding';
  static const login         = '/login';
  static const home          = '/home';
  static const markets       = '/markets';
  static const farmers       = '/farmers';
  static const transport     = '/transport';
  static const profile       = '/profile';
  static const addCrop       = '/add-crop';
  static const cropHealth    = '/crop-health';
  static const marketDetails = '/market-details';   // push as '/market-details/$id'
  static const groupSale     = '/group-sale';
}
final goRouterProvider = Provider<GoRouter>((ref) => GoRouter(initialLocation: AppRoutes.splash, routes: [ ... ]));
```

`/home`, `/markets`, `/farmers`, `/transport`, `/profile` live inside a
`StatefulShellRoute.indexedStack` rendering `MainShell`. All other routes are top-level
(full screen, no bottom nav).

## 9. SCREEN CLASSES (one per file, exact names)

| File | Class |
|---|---|
| `features/splash/splash_screen.dart` | `SplashScreen` |
| `features/onboarding/onboarding_screen.dart` | `OnboardingScreen` |
| `features/auth/login_screen.dart` | `LoginScreen` |
| `features/shell/main_shell.dart` | `MainShell` |
| `features/home/home_screen.dart` | `HomeScreen` |
| `features/crop/add_crop_screen.dart` | `AddCropScreen` |
| `features/crop/crop_health_screen.dart` | `CropHealthScreen` |
| `features/market/best_market_screen.dart` | `BestMarketScreen` |
| `features/market/market_details_screen.dart` | `MarketDetailsScreen` — `const MarketDetailsScreen({super.key, required this.marketId})` |
| `features/farmers/nearby_farmers_screen.dart` | `NearbyFarmersScreen` |
| `features/farmers/group_sale_screen.dart` | `GroupSaleScreen` |
| `features/transport/transport_screen.dart` | `TransportScreen` |
| `features/profile/profile_screen.dart` | `ProfileScreen` |

`MainShell` signature: `const MainShell({super.key, required this.navigationShell})`
with `final StatefulNavigationShell navigationShell;`

## 10. DEMO DATA (use exactly these — Coimbatore district, Tamil Nadu)

Crops: Tomato 🍅 (₹28), Onion 🧅 (₹24), Potato 🥔 (₹22), Banana 🍌 (₹32), Paddy 🌾 (₹21), Coconut 🥥 (₹18).

Markets (ranked for 500 kg Tomato):

1. **Uzhavar Sandhai, Singanallur** — ₹32/kg · 12 km · HIGH · needs 1,200 kg · arrivals 4,200 kg · travel ₹850 · 6:00 AM – 1:00 PM
2. **SRV Traders, Annur** (private buyer) — ₹30/kg · 5 km · MEDIUM · needs 800 kg · arrivals 1,600 kg · travel ₹420
3. **Mettupalayam Regulated Market** — ₹29/kg · 8 km · MEDIUM · needs 2,500 kg · arrivals 6,800 kg · travel ₹610
4. **Pollachi Wholesale Mandi** — ₹27.5/kg · 41 km · HIGH · needs 5,000 kg · arrivals 12,400 kg · travel ₹2,100
5. **Kongu FPO Collection Centre, Sulur** — ₹26/kg · 9 km · LOW · needs 600 kg · arrivals 900 kg · travel ₹520

Farmers: Murugan S. (Sulur, 2.4 km, Tomato 300 kg), Lakshmi R. (Annur, 3.1 km, Tomato 450 kg),
Karthik M. (Kinathukadavu, 4.8 km, Tomato 600 kg), Selvi P. (Thondamuthur, 6.2 km, Onion 800 kg),
Ramasamy K. (Pollachi Road, 7.5 km, Banana 1,200 kg), Anitha D. (Sultanpet, 9.0 km, Paddy 2,000 kg).

Group sale: you (500 kg) + 3 farmers = **1,850 kg tomatoes**, price rises ₹32 -> ₹35/kg.

Transport: Mini Truck (Tata Ace, 1,500 kg, ₹2,200, 25 min, available),
Tempo (Mahindra Jeeto, 900 kg, ₹1,450, 18 min, available),
Pickup (Bolero, 1,200 kg, ₹1,850, 30 min, unavailable),
Shared Truck (Eicher 14ft, 4,000 kg, ₹1,500 your share, 40 min, 2 farmers sharing, saves ₹700).

Profile: **Murugan Sakthivel**, Sulur, Coimbatore, Tamil Nadu · +91 98••• ••210 ·
crops Tomato/Onion/Banana · 14 listings · 9 transactions · ₹1,86,400 earned · member since Mar 2024 · 4.8★.

Today's insight: Tomato ₹28/kg, +8% vs yesterday, demand HIGH, 12 km, updated 10 min ago.

Crop health (healthy): Tomato · Healthy · 92%.
Crop health (unhealthy): Tomato · Possible Disease · 87% — early-blight-like spotting.

## 11. TONE OF VOICE

Short sentences. Verbs first. No jargon. Never show model names, probabilities,
tensors, "inference", "confidence interval", or any ML vocabulary. Confidence is shown as
"We are 92% sure" with a plain bar. Every recommendation answers "what do I do now?".
