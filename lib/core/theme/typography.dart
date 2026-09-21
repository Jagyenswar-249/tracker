import 'package:flutter/material.dart';

abstract final class BrimTypography {
  static const String displayFont = 'Bricolage Grotesque';
  static const String bodyFont = 'Figtree';

  static TextStyle display(Color color) => TextStyle(
        fontFamily: displayFont,
        fontSize: 56.0,
        height: 1.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle title(Color color) => TextStyle(
        fontFamily: displayFont,
        fontSize: 28.0,
        height: 32.0 / 28.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle headline(Color color) => TextStyle(
        fontFamily: displayFont,
        fontSize: 18.0,
        height: 24.0 / 18.0,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle body(Color color) => TextStyle(
        fontFamily: bodyFont,
        fontSize: 15.0,
        height: 22.0 / 15.0,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle label(Color color) => TextStyle(
        fontFamily: bodyFont,
        fontSize: 13.0,
        height: 18.0 / 13.0,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle micro(Color color) => TextStyle(
        fontFamily: bodyFont,
        fontSize: 11.0,
        height: 14.0 / 11.0,
        fontWeight: FontWeight.w500,
        color: color,
      );
}
