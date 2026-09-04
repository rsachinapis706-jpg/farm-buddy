import 'package:flutter/material.dart';

/// Farm Buddy colour system.
///
/// Warm, agricultural, high-contrast. Soft leaf green leads, cream carries the
/// canvas, dark green does the talking. Earthy secondaries add depth without
/// ever tipping into neon or "fintech dashboard" territory.
abstract final class AppColors {
  // ---------------------------------------------------------------- brand
  static const Color primary = Color(0xFF2F7A4F);
  static const Color primaryDark = Color(0xFF1B5233);
  static const Color primaryDeep = Color(0xFF123A24);
  static const Color primaryLight = Color(0xFF5FA97C);
  static const Color primarySoft = Color(0xFFE4F1E8);
  static const Color primarySofter = Color(0xFFF1F8F3);

  // ------------------------------------------------------- warm canvas
  static const Color background = Color(0xFFFBF8F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF4F0E5);
  static const Color border = Color(0xFFE7E1D3);
  static const Color borderStrong = Color(0xFFD6CEBB);

  // ------------------------------------------------------------- text
  static const Color textPrimary = Color(0xFF14301F);
  static const Color textSecondary = Color(0xFF56685C);
  static const Color textMuted = Color(0xFF8A9990);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ---------------------------------------------- earthy secondaries
  static const Color earth = Color(0xFFC0653C);
  static const Color earthSoft = Color(0xFFF7E7DE);
  static const Color soil = Color(0xFF8B6B4A);
  static const Color harvest = Color(0xFFE3A03A);
  static const Color harvestSoft = Color(0xFFFBEFD8);
  static const Color sky = Color(0xFF3C7EA6);
  static const Color skySoft = Color(0xFFE4EFF6);

  // --------------------------------------------------------- semantic
  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFD9862B);
  static const Color danger = Color(0xFFC2402C);
  static const Color info = Color(0xFF3C7EA6);
  static const Color successSoft = Color(0xFFE2F4E8);
  static const Color warningSoft = Color(0xFFFBF0DE);
  static const Color dangerSoft = Color(0xFFFAE7E3);
  static const Color infoSoft = Color(0xFFE4EFF6);
  static const Color neutralSoft = Color(0xFFF0EDE3);

  // ------------------------------------------------- ranking medals
  static const Color gold = Color(0xFFD4A017);
  static const Color goldSoft = Color(0xFFFBF0D2);
  static const Color silver = Color(0xFF8E9AA3);
  static const Color silverSoft = Color(0xFFEDF1F3);
  static const Color bronze = Color(0xFFB07A46);
  static const Color bronzeSoft = Color(0xFFF6EADF);

  // ---------------------------------------------- drawn map canvas
  static const Color mapLand = Color(0xFFEFF3E7);
  static const Color mapField = Color(0xFFE2EAD5);
  static const Color mapFieldAlt = Color(0xFFD8E4C8);
  static const Color mapRoad = Color(0xFFFFFFFF);
  static const Color mapRoadEdge = Color(0xFFE6E1D2);
  static const Color mapWater = Color(0xFFCFE0EA);

  static const Color scrim = Color(0x3314301F);
  static const Color shadowSoft = Color(0x0F14301F);
  static const Color shadowMedium = Color(0x1A14301F);

  // ------------------------------------------------- depth helpers
  /// Vertical wash used on hero surfaces. Two stops only — depth, not disco.
  static const LinearGradient heroGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF35875A), Color(0xFF1B5233)],
  );

  /// Warm sunlit wash for illustration skies.
  static const LinearGradient skyWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFFFDF6E6), Color(0xFFF3F6EA)],
  );

  /// Leaf body gradient — gives the logo and illustrations a lit face.
  static const LinearGradient leafSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF5FA97C), Color(0xFF2F7A4F)],
  );
}
