import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';

/// Renders an emoji glyph — a crop, a medal, a vehicle, a status dot.
///
/// Deliberately `inherit: false`, and that is the whole point of this widget.
///
/// Every text token in this app declares an Indic `fontFamilyFallback` so
/// Tamil and Hindi render on the web, where the renderer has no system fonts
/// to borrow. But declaring an explicit fallback list *also* stops the web
/// renderer reaching for its own colour-emoji font: it walks the list, finds
/// no emoji glyph in Noto Tamil or Noto Devanagari, and draws an empty box.
///
/// Opting out of inheritance keeps both halves working — Indic text falls back
/// to the bundled Noto faces, emoji fall back to the platform's emoji font.
class EmojiText extends StatelessWidget {
  const EmojiText(this.emoji, {super.key, this.size = 24});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      textAlign: TextAlign.center,
      style: TextStyle(
        // No `fontFamilyFallback` here on purpose — see the class docs.
        inherit: false,
        fontSize: size,
        height: 1.2,
        // Ignored for colour emoji; set so a monochrome fallback still reads.
        color: AppColors.textPrimary,
      ),
    );
  }
}
