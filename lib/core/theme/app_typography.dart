import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';

/// Type scale. Deliberately large — this app is read at arm's length,
/// outdoors, often by someone who does not read small print comfortably.
///
/// `fontFamily` is intentionally never set: we use the platform font, so the
/// app ships no Latin font files and starts instantly.
///
/// Every style does carry [indic] as its fallback, and that is not optional.
/// Android and iOS have system Tamil and Devanagari faces, but Flutter's web
/// renderer has none and cannot borrow the browser's — without this, every
/// Tamil and Hindi string on the web renders as empty boxes. The fallback is
/// set on each token rather than on the theme because widgets that supply
/// their own text style (buttons, most notably) never consult `textTheme`.
abstract final class AppText {
  /// Scripts the platform font may not cover. Latin still resolves to the
  /// platform face first; these only catch glyphs it cannot draw.
  static const List<String> indic = <String>[
    'NotoSansTamil',
    'NotoSansDevanagari',
  ];

  static const TextStyle display = TextStyle(
    fontSize: 32,
    height: 1.15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    fontFamilyFallback: indic,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 26,
    height: 1.20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    fontFamilyFallback: indic,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamilyFallback: indic,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 19,
    height: 1.30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamilyFallback: indic,
  );

  static const TextStyle titleLg = TextStyle(
    fontSize: 18,
    height: 1.30,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamilyFallback: indic,
  );

  static const TextStyle title = TextStyle(
    fontSize: 17,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamilyFallback: indic,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamilyFallback: indic,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamilyFallback: indic,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamilyFallback: indic,
  );

  static const TextStyle bodySmStrong = TextStyle(
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamilyFallback: indic,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    height: 1.30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
    fontFamilyFallback: indic,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    fontFamilyFallback: indic,
  );

  // ------------------------------------------------------------- money
  static const TextStyle priceLg = TextStyle(
    fontSize: 30,
    height: 1.10,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    fontFamilyFallback: indic,
  );

  static const TextStyle priceMd = TextStyle(
    fontSize: 24,
    height: 1.10,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    fontFamilyFallback: indic,
  );

  static const TextStyle priceSm = TextStyle(
    fontSize: 18,
    height: 1.15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamilyFallback: indic,
  );

  static const TextStyle button = TextStyle(
    fontSize: 17,
    height: 1.20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    fontFamilyFallback: indic,
  );
}
