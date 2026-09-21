import 'package:flutter/material.dart';
import '../haptics/haptics.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../glass/glass_surface.dart';
import '../glass/glass_tier.dart';

class UndoToast {
  static OverlayEntry? _currentEntry;

  static void show({
    required BuildContext context,
    required String message,
    required VoidCallback onUndo,
    Duration duration = const Duration(seconds: 4),
  }) {
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        final colors =
            Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;

        return Positioned(
          bottom: 96.0,
          left: 20.0,
          right: 20.0,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 16 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: GlassSurface(
                height: 52,
                shape: const GlassShape.capsule(),
                tierOverride: GlassTier.frost,
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      message,
                      style: BrimTypography.body(colors.text).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        BrimHaptics.lightImpact();
                        onUndo();
                        entry.remove();
                        _currentEntry = null;
                      },
                      child: Text(
                        'Undo',
                        style: BrimTypography.label(colors.lagoon).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    _currentEntry = entry;
    overlay.insert(entry);

    Future.delayed(duration, () {
      if (_currentEntry == entry) {
        entry.remove();
        _currentEntry = null;
      }
    });
  }
}
