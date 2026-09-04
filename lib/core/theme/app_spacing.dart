import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';

/// One rhythm for the whole app: everything is a multiple of 4.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;

  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets card = EdgeInsets.all(16);
  static const EdgeInsets cardLg = EdgeInsets.all(20);

  /// Bottom padding for scrollable content so the floating nav never covers
  /// the last card — sized for the nav at 1.4x text scale plus a gesture bar.
  static const double bottomNavClearance = 124;

  /// Minimum accessible touch target.
  static const double touchTarget = 48;

  /// Height of a primary call-to-action.
  static const double ctaHeight = 56;
}

abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static const BorderRadius rSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius rMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius rLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius rXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius rPill = BorderRadius.all(Radius.circular(pill));
}

/// Soft, low, warm shadows. Depth comes from layering, never from heavy blur.
abstract final class AppShadows {
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(color: AppColors.shadowSoft, blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> raised = <BoxShadow>[
    BoxShadow(color: AppColors.shadowMedium, blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: AppColors.shadowSoft, blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> hero = <BoxShadow>[
    BoxShadow(color: Color(0x3B1B5233), blurRadius: 28, offset: Offset(0, 12)),
  ];

  static const List<BoxShadow> nav = <BoxShadow>[
    BoxShadow(color: Color(0x1414301F), blurRadius: 20, offset: Offset(0, -4)),
  ];

  static const List<BoxShadow> none = <BoxShadow>[];
}
