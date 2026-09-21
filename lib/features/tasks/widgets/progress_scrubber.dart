import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../../core/haptics/haptics.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/glass/glass_surface.dart';
import '../../../core/glass/glass_tier.dart';

class ProgressScrubber extends StatefulWidget {
  final int initialPercent; // 0..100
  final Color workColor;
  final String workTitle;
  final int snapStep; // 1, 5, 10 (default 5)
  final ValueChanged<int>? onChanged; // live updates
  final ValueChanged<int>? onChangeEnd; // commit on drag release
  final double height; // 14 default, 20 on detail page

  const ProgressScrubber({
    super.key,
    required this.initialPercent,
    required this.workColor,
    required this.workTitle,
    this.snapStep = 5,
    this.onChanged,
    this.onChangeEnd,
    this.height = 14.0,
  });

  @override
  State<ProgressScrubber> createState() => _ProgressScrubberState();
}

class _ProgressScrubberState extends State<ProgressScrubber>
    with SingleTickerProviderStateMixin {
  late double _rawPercent; // 0.0 .. 100.0 (smooth liquid)
  late int _snappedPercent; // 0 .. 100 (snapped integer)
  bool _isDragging = false;
  double _dragStartY = 0.0;
  double _lastDragX = 0.0;
  DateTime? _lastTapTime;

  late AnimationController _overflowController;
  late Animation<double> _overflowAnimation;

  @override
  void initState() {
    super.initState();
    _snappedPercent = widget.initialPercent.clamp(0, 100);
    _rawPercent = _snappedPercent.toDouble();

    _overflowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _overflowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _overflowController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(covariant ProgressScrubber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!selfDragging && oldWidget.initialPercent != widget.initialPercent) {
      _snappedPercent = widget.initialPercent.clamp(0, 100);
      _rawPercent = _snappedPercent.toDouble();
    }
  }

  bool get selfDragging => _isDragging;

  @override
  void dispose() {
    _overflowController.dispose();
    super.dispose();
  }

  int _snapValue(double raw) {
    final step = widget.snapStep <= 0 ? 5 : widget.snapStep;
    var snapped = (raw / step).round() * step;

    // Magnetic detents at 0, 25, 50, 75, 100 (pull ±2%)
    for (final detent in const [0, 25, 50, 75, 100]) {
      if ((raw - detent).abs() <= 2.0) {
        snapped = detent;
        break;
      }
    }

    return snapped.clamp(0, 100);
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragStartY = details.globalPosition.dy;
      _lastDragX = details.globalPosition.dx;
    });
  }

  void _onDragUpdate(DragUpdateDetails details, double trackWidth) {
    if (trackWidth <= 0) return;

    final dx = details.globalPosition.dx - _lastDragX;
    _lastDragX = details.globalPosition.dx;

    // Precision scrub scaling factor based on vertical distance away from the bar
    final verticalDistance = (details.globalPosition.dy - _dragStartY).abs();
    final double speedFactor;
    if (verticalDistance <= 40.0) {
      speedFactor = 1.0;
    } else if (verticalDistance <= 100.0) {
      speedFactor = 0.5;
    } else {
      speedFactor = 0.25;
    }

    final deltaPercent = (dx / trackWidth) * 100.0 * speedFactor;
    final newRaw = (_rawPercent + deltaPercent).clamp(0.0, 100.0);
    final newSnapped = _snapValue(newRaw);

    if (newSnapped != _snappedPercent) {
      // Crossed a step -> trigger haptic
      if (newSnapped == 100) {
        BrimHaptics.successPattern();
        _overflowController.forward(from: 0.0);
      } else if (newSnapped == 25 || newSnapped == 50 || newSnapped == 75) {
        BrimHaptics.lightImpact();
      } else {
        BrimHaptics.selectionClick();
      }
      widget.onChanged?.call(newSnapped);
    }

    setState(() {
      _rawPercent = newRaw;
      _snappedPercent = newSnapped;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _rawPercent = _snappedPercent.toDouble();
    });
    widget.onChangeEnd?.call(_snappedPercent);
  }

  void _handleThumbTap() {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds < 350) {
      // Double tap thumb -> set 100%
      BrimHaptics.successPattern();
      _overflowController.forward(from: 0.0);
      setState(() {
        _snappedPercent = 100;
        _rawPercent = 100.0;
      });
      widget.onChangeEnd?.call(100);
      _lastTapTime = null;
    } else {
      _lastTapTime = now;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;
    final fraction = (_rawPercent / 100.0).clamp(0.0, 1.0);
    final thumbPositionFraction = (_snappedPercent / 100.0).clamp(0.0, 1.0);

    return Semantics(
      slider: true,
      label: 'Progress, ${widget.workTitle}',
      value: '$_snappedPercent percent',
      increasedValue: '${(_snappedPercent + widget.snapStep).clamp(0, 100)} percent',
      decreasedValue: '${(_snappedPercent - widget.snapStep).clamp(0, 100)} percent',
      onIncrease: () {
        final newVal = (_snappedPercent + widget.snapStep).clamp(0, 100);
        setState(() {
          _snappedPercent = newVal;
          _rawPercent = newVal.toDouble();
        });
        widget.onChangeEnd?.call(newVal);
      },
      onDecrease: () {
        final newVal = (_snappedPercent - widget.snapStep).clamp(0, 100);
        setState(() {
          _snappedPercent = newVal;
          _rawPercent = newVal.toDouble();
        });
        widget.onChangeEnd?.call(newVal);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;
          const thumbWidth = 36.0;
          const thumbHeight = 24.0;
          final usableWidth = (trackWidth - thumbWidth).clamp(0.0, double.infinity);
          final thumbLeft = thumbPositionFraction * usableWidth;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              // 1. Inset Track with Liquid Fill
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: _onDragStart,
                onHorizontalDragUpdate: (d) => _onDragUpdate(d, usableWidth),
                onHorizontalDragEnd: _onDragEnd,
                child: Container(
                  height: widget.height,
                  width: trackWidth,
                  decoration: BoxDecoration(
                    color: colors.track,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: colors.rimSoft, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Stack(
                      children: [
                        // Liquid fill bar
                        FractionallySizedBox(
                          widthFactor: fraction,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.workColor.withOpacity(0.75),
                                  widget.workColor,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.workColor.withOpacity(0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Magnetic detent indicators
                        if (_isDragging)
                          Positioned.fill(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(width: 2),
                                _buildDetentTick(colors),
                                _buildDetentTick(colors),
                                _buildDetentTick(colors),
                                const SizedBox(width: 2),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Draggable Glass Lens Thumb
              Positioned(
                left: thumbLeft,
                child: GestureDetector(
                  onTap: _handleThumbTap,
                  onHorizontalDragStart: _onDragStart,
                  onHorizontalDragUpdate: (d) => _onDragUpdate(d, usableWidth),
                  onHorizontalDragEnd: _onDragEnd,
                  child: GlassSurface(
                    width: thumbWidth,
                    height: thumbHeight,
                    shape: const GlassShape.capsule(),
                    tint: widget.workColor,
                    tierOverride: GlassTier.liquid,
                    child: Center(
                      child: Container(
                        width: 14,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Floating percentage bubble while dragging
              if (_isDragging)
                Positioned(
                  left: (thumbLeft + (thumbWidth / 2) - 24).clamp(0.0, trackWidth - 48),
                  top: -42,
                  child: GlassSurface(
                    width: 48,
                    height: 30,
                    shape: const GlassShape.capsule(),
                    tint: widget.workColor,
                    tierOverride: GlassTier.frost,
                    child: Center(
                      child: Text(
                        '$_snappedPercent%',
                        style: BrimTypography.micro(colors.text).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetentTick(BrimColors colors) {
    return Container(
      width: 2,
      height: 6,
      decoration: BoxDecoration(
        color: colors.specular.withOpacity(0.6),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
