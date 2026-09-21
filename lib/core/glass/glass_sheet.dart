import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import 'glass_surface.dart';
import 'glass_tier.dart';

class GlassSheet extends StatelessWidget {
  final Widget child;
  final Widget? title;

  const GlassSheet({
    super.key,
    required this.child,
    this.title,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    Widget? title,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassSheet(
        title: title,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.bgDeep.withOpacity(0.92),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Rad.sheet),
        ),
        border: Border(
          top: BorderSide(color: colors.rimLight, width: 1.0),
          left: BorderSide(color: colors.rimSoft, width: 1.0),
          right: BorderSide(color: colors.rimSoft, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 36.0,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Glass grabber pill
              GlassSurface(
                width: 48,
                height: 5,
                shape: const GlassShape.capsule(),
                tint: colors.textSoft,
                tierOverride: GlassTier.liquid,
                child: const SizedBox.shrink(),
              ),
              if (title != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: title!,
                ),
              ],
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 24.0),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
