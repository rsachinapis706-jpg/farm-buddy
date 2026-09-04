# Getting Farm Buddy running

Takes about three minutes. You need Flutter 3.19 or newer (`flutter --version`).

---

## Step 1 — generate the platform folders

This zip contains `lib/`, `test/`, `pubspec.yaml` and the docs. It does **not** contain
`android/` or `ios/`, because those are machine-generated and would balloon the download.

### Option A — safest (recommended)

Create a fresh Flutter app, then drop this project's source into it:

```bash
flutter create farm_buddy --org com.farmbuddy --platforms=android,ios
```

Then copy these from the zip into the new `farm_buddy/` folder, replacing what is there:

```
lib/                    (replace the whole folder)
test/                   (replace the whole folder)
pubspec.yaml            (replace)
analysis_options.yaml   (replace)
```

### Option B — in place

```bash
cd farm_buddy
flutter create . --org com.farmbuddy --platforms=android,ios
```

⚠️ Before running this, keep a copy of `lib/main.dart`. `flutter create` may regenerate
the default counter-app `main.dart`; if it does, restore ours from the zip.

---

## Step 2 — install packages

```bash
flutter pub get
```

Four dependencies, all standard:

| Package | Why |
|---|---|
| `flutter_riverpod` | state management |
| `go_router` | navigation, including the 5-tab shell |
| `intl` | locale-aware number handling |
| `image_picker` | the "Take Photo" step on Add Crop |

---

## Step 3 — run

```bash
flutter run
```

Or press **Run** in Android Studio / VS Code with a device or emulator selected.

```bash
flutter test        # 4 suites, all green
flutter analyze     # should report no issues
```

---

## Platform notes

**Android** — works with no extra configuration. `image_picker` uses the system camera
and gallery intents, so no manifest permissions are needed.

**iOS** — add these two keys to `ios/Runner/Info.plist`, or the camera step will crash
on a real device:

```xml
<key>NSCameraUsageDescription</key>
<string>Farm Buddy uses your camera to check your crop from a photo.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Farm Buddy needs your photos so you can pick an existing crop photo.</string>
```

**Web** — supported, and the fastest way to demo without a phone:

```bash
flutter run -d chrome
```

Displaying a captured photo is the one place the platforms genuinely differ — a file path
on mobile, a `blob:` URL in a browser. That split lives in
`lib/widgets/common/platform/photo_view.dart` behind a conditional export, so no screen
ever learns which platform it is on and `dart:io` never reaches a web build.

For a demo that looks like a phone, open Chrome DevTools (F12) → device toolbar → pick any
phone preset. The layout is built for 390dp and holds from there up to a tablet.

**No camera on your emulator?** Tap *Take Photo* anyway — the app catches the failure,
falls back to a built-in drawn sample photo, and tells you it did. The whole journey stays
demonstrable on a bare emulator.

---

## Two-minute demo script

1. **Splash → onboarding → login.** On the login screen, tap **தமிழ்**. The whole app is
   now Tamil, before signing in. Tap **Continue**.
2. **Home.** Point out the single loud action and the four shortcuts. Tap **Find Best
   Market**.
3. **Add Crop.** Tomato · 500 kg · Take Photo · location is already filled.
   Tap **Find My Best Option**.
4. **Crop Health.** A status, a plain confidence line, three things to do. Note there is
   no model name or probability anywhere. Tap **Find Best Market**.
5. **Best Places to Sell.** The ranked cards. Open **Why this is recommended** —
   this is the trust moment. Tap the gold card.
6. **Market Details.** Scroll to *"Your money, step by step"*: sale value, minus the trip,
   equals take-home. Tap **Sell Here**.
7. **Transport.** The trip, the cost, and the shared truck that saves ₹700.
8. **Profile → Offline demo.** Flip it on, go back to Markets: no error, just
   *"Saved copy · updated 10 min ago"*.

---

## Where to plug in a real backend

Every screen reads from `lib/services/`. Replace these four files and nothing else changes:

| File | Replace with |
|---|---|
| `market_service.dart` | Agmarknet / e-NAM mandi price feed |
| `crop_service.dart` | on-device TFLite crop-health model |
| `farmer_service.dart` | your farmer directory API |
| `transport_service.dart` | a logistics partner API |

`lib/services/mock_data.dart` can then be deleted outright.
