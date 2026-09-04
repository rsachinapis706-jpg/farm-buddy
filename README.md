# 🌿 FARM BUDDY

### The right decision. At the right time.

A farmer-first mobile app for **Smart India Hackathon 2026**.

> We don't just give farmers information. We turn it into a simple action.

The farmer gives four things — **Crop + Quantity + Photo + Location** — and gets back
one clear recommendation: *where to sell, for how much, and how to get it there.*

---

## The one journey that matters

```
Open App → Add Crop → Photo → Location → Check → Best Market → Act
```

Every screen in this build serves that line. Nothing else was added.

---

## What is in this repository

This is the **complete Flutter frontend**: 13 screens, a full component system, a
three-language interface, and a swappable mock data layer. It runs today, offline,
on any Android phone, with no API keys, no billing account and no backend.

| | |
|---|---|
| **Screens** | 13 (splash, onboarding ×3, login, home, add crop, crop health, best market, market details, nearby farmers, group sale, transport, profile) |
| **Reusable components** | 28 |
| **Languages** | English · தமிழ் · हिन्दी (291 keys each, 100% coverage) |
| **Third-party UI packages** | none |
| **Image assets** | none — every illustration, the logo, the map and the charts are drawn in code |
| **Font assets** | two, both required: Noto Sans Tamil + Noto Sans Devanagari (see below) |
| **Tests** | 5 suites, 44 tests, covering formatting, translations, ranking, sorting, records and layout |

### Verified

Built and run against **Flutter 3.47.2 / Dart 3.13.2**:

```
flutter analyze   ->  No issues found!
flutter test      ->  All tests passed!  (44/44)
flutter build web ->  ✓ Built build/web
```

### What a sceptic can poke at

The recommendation is only worth something if it can be challenged, so the
Best Market screen is adjustable in place:

- **Change the crop** — six chips, and the ranking recomputes.
- **Change the quantity** — 100 kg to 2 tonnes. At 2,000 kg the small FPO
  centre stops being able to take the load, and drops.
- **Re-order by raw price or raw distance** — and watch the app's own pick
  move. Sorting by *Nearest* puts SRV Traders first; the recommendation puts
  Uzhavar Sandhai first. If those ever agreed, the control would be
  decorative — `test/interaction_test.dart` asserts they don't.

When the list is sorted by raw price or distance, **nothing gets a medal**.
A podium badge is the app saying "this is my recommendation", and it would be
dishonest to show one over a list the app didn't order.

Actions leave a record rather than a message that vanishes: selling adds to
**Profile → My Sales** with its take-home value, booking adds to **My
Transport**, and the counters on Profile move.

### Why no assets and no map SDK

Both are deliberate product decisions, not shortcuts:

- **Drawn illustrations and logo** (`CustomPainter`) — sharp at every density, tiny APK,
  and it is impossible for the demo to fail with a missing-asset error on a judge's phone.
- **Drawn map** (`MapPreview`) — a farmer needs *"where is this, roughly, relative to me?"*,
  not a house number. A drawn map answers that with no connection, no API key, no billing
  account, and it never shows a grey tile grid on a weak signal.

### The two fonts are not an exception to that — they are a bug fix

Android and iOS carry system Tamil and Devanagari faces, so the app needs no font files
there. Flutter's **web** renderer carries only Latin glyphs and cannot borrow the browser's
fonts — so on the web, every Tamil and Hindi string rendered as **empty boxes** until Noto
Sans Tamil and Noto Sans Devanagari were bundled. For a trilingual app that is a
correctness bug, not a nicety.

The fallback is declared on every token in `AppText`, not on the theme, because widgets
that supply their own text style — buttons above all — never consult `textTheme`. Emoji
then need the opposite treatment: an explicit fallback list stops the web renderer reaching
for its own colour-emoji font, so every emoji goes through `EmojiText`, which deliberately
sets `inherit: false`. Both halves are needed; drop either and something turns into boxes.

---

## Run it

```bash
flutter pub get
flutter run -d chrome
```

That is the quickest way to see it — no emulator, no phone, no Android SDK. For a
device, `flutter run` with a phone attached.

Platform folders (`android/`, `ios/`, `web/`) are not in this zip — see
**[SETUP.md](SETUP.md)** for the one command that generates them.

```bash
flutter test
```

---

## The three things judges usually ask

**1. Why should a farmer trust the recommendation?**

Because the app shows its reasoning. Every ranked market carries a **"Why this is
recommended"** card, and each tick maps to a real term in the scoring formula in
[`lib/models/market.dart`](lib/models/market.dart):

```dart
score = netValue × demandBoost × distancePenalty × capacityPenalty
```

Net value — not the headline price — leads. A ₹2 higher price 40 km away loses to a
closer buyer once the trip is paid for, and the app says so out loud.

**2. Where is the AI, and why can't I see it?**

On the Crop Health screen, and that is exactly the point. The farmer sees a status, a
plain sentence (*"We are 92% sure"*) and two or three things to do today. There is no
model name, no probability distribution, no "inference" anywhere in the UI. Swapping the
mock in [`lib/services/crop_service.dart`](lib/services/crop_service.dart) for a real
on-device model changes one method and zero screens.

**3. What happens with no signal?**

Nothing breaks. The app never shows a network error to a farmer — it shows *how old* the
information is (`Live · updated just now` / `Saved copy · updated 10 min ago`) and keeps
working. Turn it on yourself: **Profile → Offline demo**.

---

## Design language

| Token | Value | Why |
|---|---|---|
| Primary | `#2F7A4F` soft leaf green | Agricultural, calm, not corporate |
| Canvas | `#FBF8F1` warm cream | Readable in sunlight, softer than white |
| Text | `#14301F` dark green | High contrast without harsh black |
| Body size | 16px minimum | Read at arm's length, outdoors |
| Touch target | 48dp min, 56dp CTAs | Works with rough or wet hands |
| Corners | 12 / 16 / 20 / 28 | Rounded, friendly, consistent |

Full specification in **[DESIGN.md](DESIGN.md)**.
Component hierarchy and implementation plan in **[ARCHITECTURE.md](ARCHITECTURE.md)**.
The binding contract every file was built against is **[CONTRACT.md](CONTRACT.md)**.

---

## Accessibility, deliberately

- Status is **never colour alone** — every badge carries an icon *and* a word.
- System font scaling is honoured up to 1.4×, and the layout is tested at that size.
- Icon-only controls all carry tooltips; decorative art is hidden from screen readers.
- Tap targets never drop below 48dp.
- Error messages are sentences a person would say, never a stack trace.

---

## Demo data

All sample content is Coimbatore-district realistic and **labelled in the UI with a
"Demo data" chip**. Judges should never have to guess which numbers are real.
Set `AppConfig.isDemoMode = false` and every chip disappears.

Crops: Tomato 🍅 · Onion 🧅 · Potato 🥔 · Banana 🍌 · Paddy 🌾 · Coconut 🥥

---

## Project structure

```
lib/
├── core/
│   ├── theme/          design tokens + Material 3 theme
│   ├── constants/      app config and demo switches
│   ├── l10n/           en / ta / hi string tables
│   ├── router/         GoRouter, all routes in one file
│   └── utils/          ₹ / km / kg formatting, responsive helpers
├── models/             plain immutable data classes
├── services/           mock data layer — swap for a real API here
├── providers/          Riverpod state
├── widgets/            the design system (buttons, cards, states, brand, art)
└── features/           one folder per screen
```

Built with Flutter · Dart · Material 3 · Riverpod · GoRouter.
