import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

abstract final class BrimTheme {
  static ThemeData darkTheme() {
    const colors = BrimColors.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.bg,
      fontFamily: BrimTypography.bodyFont,
      colorScheme: ColorScheme.dark(
        primary: colors.lagoon,
        secondary: colors.orchid,
        surface: colors.bgDeep,
        error: colors.coral,
      ),
      extensions: const [colors],
    );
  }

  static ThemeData lightTheme() {
    const colors = BrimColors.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.bg,
      fontFamily: BrimTypography.bodyFont,
      colorScheme: ColorScheme.light(
        primary: colors.lagoon,
        secondary: colors.orchid,
        surface: colors.bgDeep,
        error: colors.coral,
      ),
      extensions: const [colors],
    );
  }
}
