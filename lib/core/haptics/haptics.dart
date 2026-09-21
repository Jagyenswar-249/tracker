import 'package:flutter/services.dart';

abstract final class BrimHaptics {
  static bool enabled = true;
  static int _lastTickTimestamp = 0;

  static void selectionClick() {
    if (!enabled) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    // Rate limit to 1 per 40ms during rapid scrub
    if (now - _lastTickTimestamp < 40) return;
    _lastTickTimestamp = now;
    HapticFeedback.selectionClick();
  }

  static void lightImpact() {
    if (!enabled) return;
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
  }

  static Future<void> successPattern() async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.lightImpact();
  }
}
