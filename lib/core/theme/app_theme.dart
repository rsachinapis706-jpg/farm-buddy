import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';

/// Material 3 theme wired to the Farm Buddy tokens.
///
/// Light only, on purpose: the app is used outdoors in daylight and a single
/// well-tuned surface set keeps contrast predictable for every farmer.
abstract final class AppTheme {
  /// Scripts the platform font may not cover. Defined once on [AppText] so a
  /// token and the theme can never drift apart.
  static const List<String> indicFallback = AppText.indic;

  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.harvest,
      onSecondary: AppColors.textPrimary,
      secondaryContainer: AppColors.harvestSoft,
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: AppColors.earth,
      onTertiary: AppColors.textOnPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: AppColors.dangerSoft,
      onErrorContainer: AppColors.danger,
      outline: AppColors.border,
      outlineVariant: AppColors.borderStrong,
      shadow: AppColors.shadowMedium,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      // Platform font on purpose — nothing to download, and on Android/iOS the
      // system face already shapes Tamil and Devanagari correctly.
      fontFamily: null,
      // The web renderer has no system fonts to fall back to, so the bundled
      // Noto faces cover Tamil and Devanagari. Latin still resolves to the
      // platform font first; these only catch glyphs it cannot draw.
      fontFamilyFallback: AppTheme.indicFallback,
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.h2,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.borderStrong,
          disabledForegroundColor: Colors.white,
          minimumSize: const Size(64, AppSpacing.ctaHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          textStyle: AppText.button,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.rLg),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(64, AppSpacing.ctaHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          textStyle: AppText.button,
          side: const BorderSide(color: AppColors.borderStrong, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.rLg),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(48, AppSpacing.touchTarget),
          textStyle: AppText.bodyStrong,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppText.body.copyWith(color: AppColors.textMuted),
        labelStyle: AppText.bodySmStrong,
        floatingLabelStyle: AppText.bodySmStrong.copyWith(color: AppColors.primary),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide: BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide: BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide: BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide: BorderSide(color: AppColors.danger, width: 2),
        ),
        errorStyle: AppText.bodySm.copyWith(color: AppColors.danger),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.borderStrong,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppText.bodySm.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        insetPadding: const EdgeInsets.all(AppSpacing.md),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.primarySoft,
        labelStyle: AppText.bodySmStrong,
        side: BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rPill),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primarySoft,
        circularTrackColor: AppColors.primarySoft,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: const BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: AppRadius.rSm,
        ),
        textStyle: AppText.caption.copyWith(color: Colors.white),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primarySoft,
        thumbColor: AppColors.primary,
        trackHeight: 6,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primarySoft,
        selectionHandleColor: AppColors.primary,
      ),
    );
  }

  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppText.display,
    displayMedium: AppText.h1,
    headlineLarge: AppText.h1,
    headlineMedium: AppText.h2,
    headlineSmall: AppText.h3,
    titleLarge: AppText.titleLg,
    titleMedium: AppText.title,
    titleSmall: AppText.bodySmStrong,
    bodyLarge: AppText.body,
    bodyMedium: AppText.bodySm,
    bodySmall: AppText.caption,
    labelLarge: AppText.label,
    labelMedium: AppText.caption,
    labelSmall: AppText.caption,
  );
}
