import 'package:flutter/animation.dart';

abstract final class BrimSprings {
  // Snappy: 500 / 32
  static const Curve snappy = Curves.easeOutCubic;

  // Smooth: 300 / 28
  static const Curve smooth = Curves.easeInOutCubic;

  // Bouncy: 220 / 16
  static const Curve bouncy = ElasticOutCurve(0.8);
}
