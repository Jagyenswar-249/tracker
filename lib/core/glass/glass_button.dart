import 'package:flutter/material.dart';
import '../haptics/haptics.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'glass_surface.dart';
import 'glass_tier.dart';

enum GlassButtonVariant {
  primary,
  neutral,
  destructive,
}

class GlassButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final GlassButtonVariant variant;
  final double height;
  final bool isLoading;

  const GlassButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = GlassButtonVariant.primary,
    this.height = 48.0,
    this.isLoading = false,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed == null || widget.isLoading) return;
    if (widget.variant == GlassButtonVariant.destructive) {
      BrimHaptics.heavyImpact();
    } else {
      BrimHaptics.lightImpact();
    }
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;

    final (tintColor, textColor) = switch (widget.variant) {
      GlassButtonVariant.primary => (colors.lagoon, Colors.white),
      GlassButtonVariant.neutral => (colors.textSoft, colors.text),
      GlassButtonVariant.destructive => (colors.coral, Colors.white),
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GlassSurface(
          height: widget.height,
          shape: const GlassShape.capsule(),
          tint: tintColor,
          tierOverride: GlassTier.liquid,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 18, color: textColor),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: BrimTypography.label(textColor).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
