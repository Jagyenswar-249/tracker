import 'package:flutter/material.dart';

abstract final class Sp {
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s48 = 48.0;

  static const double screenSidePadding = 20.0;
  static const double contentBottomPadding = 112.0;
}

abstract final class Rad {
  static const double card = 28.0;
  static const double sheet = 36.0;
  static const double chip = 22.0;
  static const double button = 28.0;
  static const double capsule = 999.0;
}

abstract final class Dur {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 180);
  static const Duration slow = Duration(milliseconds: 280);
  static const Duration hero = Duration(milliseconds: 420);
  static const Duration countTween = Duration(milliseconds: 300);
  static const Duration undoToast = Duration(seconds: 4);
}
