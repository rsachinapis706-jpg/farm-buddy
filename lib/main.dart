import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_buddy/app.dart';

/// FARM BUDDY — "The right decision. At the right time."
///
/// Smart India Hackathon 2026. Frontend build: every screen is real, the data
/// layer is a swappable mock (see `lib/services/`), and the UI never depends
/// on a network call to stay usable.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only: this is a one-handed, in-the-field app.
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: FarmBuddyApp(),
    ),
  );
}
