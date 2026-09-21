import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/cadence.dart';
import '../theme/colors.dart';

class AuroraBackground extends StatefulWidget {
  final Widget child;
  final Cadence activeView;

  const AuroraBackground({
    super.key,
    required this.child,
    this.activeView = Cadence.daily,
  });

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat(reverse: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final viewAccent = switch (widget.activeView) {
      Cadence.daily => colors.lagoon,
      Cadence.weekly => colors.saffron,
      Cadence.monthly => colors.orchid,
      Cadence.once => colors.lagoon,
    };

    return Stack(
      children: [
        // Base gradient background
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.bg, colors.bgDeep],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Animated radial aurora blobs
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              final sinT = math.sin(t * 2 * math.pi);
              final cosT = math.cos(t * 2 * math.pi);

              final baseOpacity = isDark ? 0.22 : 0.40;

              return Stack(
                children: [
                  // Blob 1: Active view accent (Top-left)
                  Positioned(
                    top: -60 + 30 * sinT,
                    left: -80 + 25 * cosT,
                    child: _buildBlob(
                      color: viewAccent,
                      size: 380,
                      opacity: baseOpacity + 0.08,
                    ),
                  ),

                  // Blob 2: Orchid (Right)
                  Positioned(
                    top: 180 - 40 * cosT,
                    right: -120 + 30 * sinT,
                    child: _buildBlob(
                      color: colors.orchid,
                      size: 340,
                      opacity: baseOpacity,
                    ),
                  ),

                  // Blob 3: Coral (Bottom-left)
                  Positioned(
                    bottom: 120 + 35 * sinT,
                    left: -100 - 20 * cosT,
                    child: _buildBlob(
                      color: colors.coral,
                      size: 320,
                      opacity: baseOpacity - 0.04,
                    ),
                  ),

                  // Blob 4: Saffron (Bottom-right)
                  Positioned(
                    bottom: -80 - 30 * cosT,
                    right: -50 + 25 * sinT,
                    child: _buildBlob(
                      color: colors.saffron,
                      size: 360,
                      opacity: baseOpacity - 0.03,
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // Content
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }

  Widget _buildBlob({
    required Color color,
    required double size,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(opacity.clamp(0.0, 1.0)),
            color.withOpacity(opacity * 0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}
