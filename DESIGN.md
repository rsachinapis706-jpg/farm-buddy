# Farm Buddy — Design System

*Google Maps simplicity + modern fintech clarity + agricultural warmth.*

Every value here is implemented in `lib/core/theme/`. Nothing in the app hard-codes a
colour, a font size or a spacing number.

---

## 1. Principles

1. **One loud thing per screen.** A farmer should never have to work out which button is
   *the* button. There is exactly one filled primary CTA per screen wherever possible.
2. **Show the reasoning.** A recommendation a farmer cannot interrogate is one they will
   not act on. Every ranked result carries a "Why this is recommended" card.
3. **Money, not metrics.** Screens end in rupees, not in scores. Take-home value beats
   headline price everywhere in the product.
4. **Never fail — age instead.** No network error is ever shown. The app says how old
   the information is and keeps working.
5. **Colour is never the only signal.** Every status carries an icon and a word.
6. **Translate-proof layouts.** Nothing is sized to fit an English string.

---

## 2. Brand

**FARM BUDDY** — *The right decision. At the right time.*

The mark is a **leaf whose base tapers into a location pin**, with a gold seed at its
heart, and a tiny sprout inside the seed.

- **Leaf** — growth, the crop.
- **Pin** — place, the market, "near you".
- **Gold seed + sprout** — the buddy: the small bit of help that starts things.

One silhouette, two colours, no detail below 24px. Drawn in
`lib/widgets/brand/farm_buddy_logo.dart` with a `CustomPainter`, so the same code renders
the 24px header mark, the splash mark and a launcher icon.

The wordmark sets **FARM** at weight 800 and **BUDDY** at 400, so the lockup has a centre
of gravity and reads correctly even at small sizes.

---

## 3. Colour

### Brand

| Token | Hex | Use |
|---|---|---|
| `primary` | `#2F7A4F` | CTAs, active nav, ranked-first accents |
| `primaryDark` | `#1B5233` | Text on light green, hero gradient end |
| `primaryLight` | `#5FA97C` | Illustration mid-tones, borders |
| `primarySoft` | `#E4F1E8` | Tinted fills, selected pills |
| `primarySofter` | `#F1F8F3` | Section backgrounds, "why" card |

### Canvas

| Token | Hex | Use |
|---|---|---|
| `background` | `#FBF8F1` | Every scaffold. Warm cream, easier than white in sun |
| `surface` | `#FFFFFF` | Cards |
| `surfaceAlt` | `#F4F0E5` | Inset blocks, skeletons, quiet chips |
| `border` | `#E7E1D3` | Hairlines |
| `borderStrong` | `#D6CEBB` | Outlined buttons, dividers that must be seen |

### Text

| Token | Hex | Contrast on cream |
|---|---|---|
| `textPrimary` | `#14301F` | 13.6:1 — AAA |
| `textSecondary` | `#56685C` | 6.1:1 — AA |
| `textMuted` | `#8A9990` | 3.3:1 — captions only, never body |

### Earthy secondaries

`earth #C0653C` (terracotta) · `soil #8B6B4A` · `harvest #E3A03A` (grain gold) ·
`sky #3C7EA6`

Used for accents, illustration and category colour only — never for a primary action.

### Semantic

`success #2E9E5B` · `warning #D9862B` · `danger #C2402C` · `info #3C7EA6`,
each with a soft companion for badge backgrounds.

### Depth

Two gradients only, both two-stop:

- `heroGreen` — the "Sell My Crop" card and the group-sale headline.
- `leafSheen` — the logo body and illustration foliage.

No third gradient exists in the app.

---

## 4. Type

Platform font on purpose (`fontFamily: null`). No font files ship, the app starts
instantly, and Tamil and Devanagari shape correctly on every device with no download.

| Style | Size / weight | Use |
|---|---|---|
| `display` | 32 / 800 | Group-sale headline number |
| `h1` | 26 / 700 | Screen titles on tall screens |
| `h2` | 22 / 700 | Header titles, card titles |
| `h3` | 19 / 700 | Section headers |
| `titleLg` | 18 / 600 | Card names |
| `title` | 17 / 600 | Tile titles |
| `body` | 16 / 400 | **Minimum body size in the app** |
| `bodySm` | 14 / 400 | Supporting copy |
| `label` | 13 / 700 | Badges |
| `caption` | 12 / 500 | Metadata, freshness |
| `priceLg / priceMd / priceSm` | 30 / 24 / 18, weight 800 | Money, always the heaviest thing on screen |

System text scaling is honoured and clamped to **0.9× – 1.4×** so accessibility never
produces a broken layout.

---

## 5. Space, radius, elevation

**Spacing** — everything is a multiple of 4: `4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48`.
Screen gutter is 20. Card padding is 16.

**Radius** — `sm 12` (chips, insets) · `md 16` (inputs, icon tiles) · `lg 20` (cards,
buttons) · `xl 28` (hero cards, nav bar) · `pill`.

**Elevation** — depth comes from layering, never heavy blur:

| | Shadow | Use |
|---|---|---|
| `card` | y+4, blur 16, 6% | every card |
| `raised` | y+8, blur 24, 10% | the ranked-first market card |
| `hero` | y+12, blur 28, 23% green | the "Sell My Crop" card |
| `nav` | y−4, blur 20 | the floating bottom bar |

**Touch targets** — 48dp minimum, 56dp for primary CTAs.

---

## 6. Component system

### Buttons
`PrimaryButton` (56/48dp, filled, loading state keeps its label) ·
`SecondaryButton` (outlined; a disabled one keeps its colour because it usually means a
*state* like "Connected", not a dead control) · `FbIconButton` (48×48, always tooltipped).

### Surfaces
`FbCard` — the base every card composes: hairline border + soft shadow.

### Cards
`HeroActionCard` · `ActionTile` · `MarketCard` · `FarmerCard` · `CropCard` ·
`TransportCard` · `InsightCard` · `RecommendationCard` · `StatCard` / `StatRow` ·
`LocationCard` · `WhyCard`

`MarketCard` has two forms, and the difference *is* the recommendation: rank 1 is a tall
card with a gold medal, a BEST VALUE badge, the money spelled out and its own filled
button. Ranks 2 and 3 collapse to a compact row.

### Feedback
`StatusBadge` (7 tones, icon always rendered) · `FreshnessChip` · `OfflineBanner` ·
`DemoDataChip` · `EmptyState` · `LoadingState` + `LeafSpinner` · `ErrorState` ·
`SkeletonBox` / `SkeletonCard`

### Navigation
`AppHeader` (big title, optional subtitle, 48dp back target) · `SectionHeader` ·
`FbBottomNavigation` (floating pill bar, 5 destinations, labels always visible)

### Drawn graphics
`FarmBuddyLogo` + `FarmBuddyWordmark` · `MapPreview` + `MapMarker` · `PriceTrendChart` ·
`CropPhoto` · `CropInspectIllustration` · `MarketIllustration` · `TogetherIllustration` ·
`FieldScene`

All illustrations share one light source (upper-left), one skin tone and one ink colour,
so the cast looks like the same people across all three onboarding screens. Depth comes
from a lit face, a shaded flank and a single grounding shadow per object — 2.5D, not flat
stickers and not fake 3D.

---

## 7. Motion

Subtle only. 150–350ms, `Curves.easeOut`.

- Splash: mark scales in (`easeOutBack`), text fades up.
- Nav: the soft pill behind the active icon animates over 200ms.
- Onboarding dots stretch from 8 to 26px.
- `LeafSpinner`: three leaves rotating, each breathing slightly out of phase.

No parallax, no confetti, no hero flights between screens.

---

## 8. Language

English · தமிழ் · हिन्दी — 291 keys each, 100% coverage, verified by a test.

- Lookup order is **current language → English → the key itself**. A missing key can
  never throw or show a red screen.
- The language picker is reachable from the **login screen**, before the farmer is asked
  to read anything, and every option is written in its own script.
- Layouts never assume English length: titles allow 2 lines with ellipsis, rows use
  `Expanded`/`Flexible`, nothing is sized to fit a specific string.

---

## 9. Offline-first, visibly

There is no "network error" state in this app. Instead:

- `FreshnessChip` — `Live · updated just now` or `Saved copy · updated 10 min ago`.
- `OfflineBanner` — calm amber, states what you are looking at. Never a dialog.
- Cached and live information are always distinguishable, by icon and by words.

---

## 10. Accessibility checklist

- [x] Contrast: body text ≥ 6:1, primary text 13.6:1 on cream
- [x] Status never colour-only — icon + word on every badge
- [x] Touch targets ≥ 48dp; CTAs 56dp
- [x] Text scaling honoured to 1.4×, layout tested at that size
- [x] Icon-only controls carry tooltips
- [x] Decorative painters hidden with `ExcludeSemantics`
- [x] Tiles use `MergeSemantics` so they read as one node *and stay activatable*
- [x] Errors written as sentences, never as exceptions
