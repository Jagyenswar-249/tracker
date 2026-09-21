import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'glass_tier.dart';

class GlassSurface extends StatelessWidget {
  final Widget child;
  final GlassShape shape;
  final Color? tint;
  final GlassEmphasis emphasis;
  final bool interactive;
  final GlassTier? tierOverride;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const GlassSurface({
    super.key,
    required this.child,
    this.shape = const GlassShape.capsule(),
    this.tint,
    this.emphasis = GlassEmphasis.regular,
    this.interactive = false,
    this.tierOverride,
    this.width,
    this.height,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve tier: override > default to liquid (or frost/solid when reduced transparency)
    final resolvedTier = tierOverride ?? GlassTier.liquid;

    final borderRadius = switch (shape) {
      GlassShapeCapsule() => BorderRadius.circular(999.0),
      GlassShapeRounded(radius: final r) => BorderRadius.circular(r),
      GlassShapeCircle() => BorderRadius.circular(999.0),
    };

    // Calculate background tint
    final baseBgColor = switch (resolvedTier) {
      GlassTier.liquid => isDark
          ? (tint != null ? Color.alphaBlend(tint!.withOpacity(0.18), colors.glassA) : colors.glassA)
          : (tint != null ? Color.alphaBlend(tint!.withOpacity(0.14), colors.glassA) : colors.glassA),
      GlassTier.frost => isDark
          ? (tint != null ? Color.alphaBlend(tint!.withOpacity(0.12), colors.frostBg) : colors.frostBg)
          : (tint != null ? Color.alphaBlend(tint!.withOpacity(0.08), colors.frostBg) : colors.frostBg),
      GlassTier.solid => isDark
          ? (tint != null ? Color.alphaBlend(tint!.withOpacity(0.25), colors.bgDeep) : colors.bgDeep)
          : (tint != null ? Color.alphaBlend(tint!.withOpacity(0.20), colors.bgDeep) : colors.bgDeep),
    };

    final blurSigma = switch (resolvedTier) {
      GlassTier.liquid => isDark ? 20.0 : 18.0,
      GlassTier.frost => 14.0,
      GlassTier.solid => 0.0,
    };

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: baseBgColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: resolvedTier == GlassTier.solid
              ? colors.rimSoft
              : colors.rimLight.withOpacity(isDark ? 0.35 : 0.65),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: resolvedTier == GlassTier.solid ? 8.0 : 24.0,
            offset: const Offset(0, 8),
          ),
          if (resolvedTier != GlassTier.solid)
            BoxShadow(
              color: colors.specular,
              blurRadius: 1.0,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: child,
    );

    if (blurSigma > 0) {
      content = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: content,
        ),
      );
    } else {
      content = ClipRRect(
        borderRadius: borderRadius,
        child: content,
      );
    }

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
