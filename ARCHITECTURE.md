# Farm Buddy — Architecture & Component Hierarchy

Flutter · Dart · Material 3 · Riverpod · GoRouter. No code generation, no build_runner.

---

## 1. Layers

```
features/     screens — widgets only, no business logic
   │  watch
   ▼
providers/    Riverpod state — the only place a provider is declared
   │  call
   ▼
services/     async data layer — the seam where a real API plugs in
   │  return
   ▼
models/       plain immutable classes, no JSON, no framework types
```

Rules that keep it honest:

- A screen never constructs a service directly; it watches a provider.
- A provider is **only** declared in `lib/providers/`. Screens never create globals.
- A model never imports Flutter, except where it exposes an `IconData` for the UI.
- `widgets/` never imports `features/` or `providers/` (with two deliberate exceptions:
  `OfflineBanner`, `FreshnessChip`, `DemoDataChip` and `language_sheet` read app-wide
  state, because they exist precisely to reflect it).

---

## 2. File map

```
lib/
├── main.dart                          entry, portrait lock, ProviderScope
├── app.dart                           MaterialApp.router, theme, text-scale clamp
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart            every colour in the product
│   │   ├── app_typography.dart        the type scale
│   │   ├── app_spacing.dart           AppSpacing + AppRadius + AppShadows
│   │   └── app_theme.dart             Material 3 wiring
│   ├── constants/app_config.dart      demo switches, fake latency
│   ├── l10n/app_strings.dart          en / ta / hi tables + safe lookup
│   ├── router/app_router.dart         AppRoutes + GoRouter, all routes
│   └── utils/
│       ├── formatters.dart            ₹ (Indian grouping), km, kg, time
│       └── responsive.dart            ResponsiveCenter, context helpers
│
├── models/          crop · market · farmer · transport · crop_health
│                    user_profile · market_insight · enums
│
├── services/        mock_data · market_service · crop_service
│                    farmer_service · transport_service
│
├── providers/       app_providers · crop_providers · market_providers
│                    farmer_providers · transport_providers
│
├── widgets/
│   ├── brand/           farm_buddy_logo
│   ├── illustrations/   illustration_utils + 4 scenes
│   ├── buttons/         primary · secondary · fb_icon_button
│   ├── cards/           11 cards
│   ├── common/          header · nav · badges · map · chart · photo · sheets
│   └── states/          empty · loading · error · skeleton
│
└── features/
    ├── splash/          onboarding/       auth/
    ├── shell/           home/             crop/   (add_crop, crop_health)
    ├── market/          (best_market, market_details)
    ├── farmers/         (nearby_farmers, group_sale)
    ├── transport/       profile/
```

---

## 3. Navigation

`StatefulShellRoute.indexedStack` gives each of the five tabs its own navigation stack,
so backing out of a market detail returns you to Markets, not to Home.

```
GoRouter
├── /                      SplashScreen           (auto-advances)
├── /onboarding            OnboardingScreen
├── /login                 LoginScreen
├── /add-crop              AddCropScreen          ─┐
├── /crop-health           CropHealthScreen        │ full screen,
├── /group-sale            GroupSaleScreen         │ no bottom nav
├── /market-details/:id    MarketDetailsScreen    ─┘
│
└── StatefulShellRoute.indexedStack → MainShell
    ├── /home        HomeScreen
    ├── /markets     BestMarketScreen
    ├── /farmers     NearbyFarmersScreen
    ├── /transport   TransportScreen
    └── /profile     ProfileScreen
```

`errorBuilder` renders a friendly `ErrorState` with a "Go to Home" button — a farmer
never sees a red screen.

---

## 4. State

| Provider | Type | Holds |
|---|---|---|
| `languageProvider` | `StateProvider<AppLanguage>` | current language |
| `stringsProvider` | `Provider<AppStrings>` | the resolved string table |
| `isOnlineProvider` | `StateProvider<bool>` | connectivity (toggleable in Profile) |
| `lastSyncedProvider` | `StateProvider<DateTime>` | drives "updated 10 min ago" |
| `freshnessProvider` | `Provider<DataFreshness>` | derived live/cached |
| `locationProvider` | `StateProvider<String>` | the farmer's place |
| `profileProvider` | `Provider<FarmerProfile>` | the user |
| `greetingKeyProvider` | `Provider<String>` | morning / afternoon / evening |
| `currentListingProvider` | `StateNotifierProvider<…, CropListing?>` | **the journey object** |
| `activeCropProvider` / `activeQuantityProvider` | `Provider` | safe defaults so no screen divides by zero |
| `cropHealthProvider` | `FutureProvider.autoDispose` | the photo check |
| `rankedMarketsProvider` | `FutureProvider.autoDispose` | ranked markets for the listing |
| `marketByIdProvider` | `FutureProvider.autoDispose.family` | one market |
| `todayInsightProvider` | `FutureProvider` | the Home card |
| `selectedMarketProvider` | `StateProvider<Market?>` | where the farmer chose to sell |
| `savedMarketIdsProvider` | `StateProvider<Set<String>>` | bookmarks |
| `farmerFilterProvider` / `nearbyFarmersProvider` / `groupSaleProvider` / `connectedFarmerIdsProvider` | | the Farmers tab |
| `transportRouteProvider` / `transportOptionsProvider` / `sharedTransportProvider` / `bookedTransportIdProvider` | | the Transport tab |

**`currentListingProvider` is the spine of the app.** Add Crop writes it; Crop Health,
Best Market and Transport all read from it. That is how four inputs on one screen become
a recommendation three screens later.

Because `selectedMarketProvider` feeds `transportRouteProvider`, choosing a market on
Market Details silently re-plans the trip before the farmer reaches the Transport tab.

---

## 5. Screen → component hierarchy

```
SplashScreen
└── Stack
    ├── FieldScene                       (drawn)
    └── FarmBuddyLogo → FarmBuddyWordmark → tagline

OnboardingScreen
└── PageView ×3
    ├── CropInspectIllustration | MarketIllustration | TogetherIllustration
    └── title + body + dots + PrimaryButton

LoginScreen
└── language pills · FarmBuddyLogo · 2 × TextField
    · PrimaryButton · SecondaryButton ×2 · FieldScene

MainShell
└── Scaffold(extendBody) + FbBottomNavigation

HomeScreen                               ← "what should I do today?"
└── ListView
    ├── header (logo · greeting · location · language)
    ├── OfflineBanner
    ├── HeroActionCard            "Sell My Crop"
    ├── _JourneyStrip             the 4-step promise
    ├── SectionHeader + ActionTile ×4     (2×2, IntrinsicHeight)
    └── SectionHeader + InsightCard → PriceTrendChart · StatusBadge · FreshnessChip

AddCropScreen                            ← crop + quantity + photo + location
└── progress bar
    ├── _SelectField  → crop sheet of CropCard
    ├── TextField + _QuantityChip ×4
    ├── _PhotoDropZone → ImagePicker → CropPhoto
    ├── LocationCard
    └── PrimaryButton  "Find My Best Option"

CropHealthScreen
└── CropPhoto
    ├── verdict card (status icon + dot + "We are 92% sure" + bar)
    ├── RecommendationCard ×3
    ├── Ask Expert card + SecondaryButton
    └── PrimaryButton  "Find Best Market"

BestMarketScreen                         ← the flagship
└── MapPreview (ranked pins + dashed route)
    ├── FreshnessChip + DemoDataChip
    ├── MarketCard(isBest)      gold medal · BEST VALUE · expected value · CTA
    ├── WhyCard                 "Why this is recommended"
    └── MarketCard ×n           compact rows

MarketDetailsScreen
└── header + StatusBadge ×2 + MapPreview
    ├── price card → PriceTrendChart + FreshnessChip
    ├── StatCard ×3     arrivals · wanted · distance
    ├── StatRow ×4      quantity → sale value − travel = take-home
    ├── WhyCard
    └── PrimaryButton "Sell Here" + SecondaryButton "Navigate"

NearbyFarmersScreen
└── MapPreview · _FilterChip ×6 · _GroupSaleBanner · FarmerCard ×n

GroupSaleScreen
└── hero (solo price → group price) · StatCard ×2
    · _MemberRow ×4 · how-it-works ×3 · PrimaryButton

TransportScreen
└── _RouteCard (farm → market) · StatCard ×3
    · _SharedTransportCard (saves ₹700) · TransportCard ×n

ProfileScreen
└── identity card · StatCard ×3 · crop badges
    · _MenuGroup ×2 (incl. language + offline toggle) · logout
```

---

## 6. The ranking, in full

`lib/models/market.dart`:

```dart
double score(double quantityKg) {
  final revenue          = netValue(quantityKg);              // price × qty − travel
  final demandBoost      = 1 + (demand.strength * 0.08);      // high 1.08 · med 1.05 · low 1.02
  final distancePenalty  = 1 - (distanceKm / 400).clamp(0, 0.25);
  final capacityPenalty  = acceptsQuantity(quantityKg) ? 1.0 : 0.75;
  return revenue * demandBoost * distancePenalty * capacityPenalty;
}
```

Four terms, each one a line the farmer can read on screen. Nothing here is a black box,
which is the entire reason the "Why this is recommended" card can exist.

For 500 kg of tomato it produces: Uzhavar Sandhai → SRV Traders → Mettupalayam → Kongu
FPO → Pollachi. Pollachi has high demand but is 41 km away, and the ₹2,100 trip drops it
to last. That is the product's whole argument in one result. Asserted in
`test/market_ranking_test.dart`.

---

## 7. Swapping in a real backend

The seam is `lib/services/`. Four files, one change each:

| File | Becomes |
|---|---|
| `market_service.dart` | Agmarknet / e-NAM price feed + a local cache |
| `crop_service.dart` | on-device TFLite model (`analyze()` is the only method) |
| `farmer_service.dart` | farmer directory API |
| `transport_service.dart` | logistics partner API |

Then delete `mock_data.dart` and set `AppConfig.isDemoMode = false`.
**No screen, widget, provider or model needs to change.**

Suggested order for the backend build:

1. Market prices — the highest-value real data, and it makes the flagship screen honest.
2. Crop health model — bundle a TFLite classifier; keep the UI's plain-language contract.
3. Farmer directory + auth — needs real identity and consent, so it lands third.
4. Transport — needs a partner, so it lands last.

---

## 8. Testing

```bash
flutter test
```

| Suite | Covers |
|---|---|
| `formatters_test.dart` | Indian digit grouping (1,86,400), ₹/km/kg/tonnes, relative time |
| `app_strings_test.dart` | 3-language coverage, key parity, missing-key fallback never throws |
| `market_ranking_test.dart` | the ranking order, net-value-beats-price, demo-data integrity |
| `widget_test.dart` | button behaviour, badge icon+word rule, MarketCard content, **layout at 1.4× text scale** |

The 1.4× test is the important one: it asserts no `RenderFlex` overflow at the largest
font size the app allows, which is where accessibility usually breaks a design.
