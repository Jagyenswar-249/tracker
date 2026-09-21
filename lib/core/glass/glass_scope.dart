import 'package:flutter/material.dart';
import 'glass_tier.dart';

class GlassScope extends InheritedWidget {
  final GlassTier activeTier;
  final bool reduceMotion;
  final bool reduceTransparency;

  const GlassScope({
    super.key,
    required this.activeTier,
    this.reduceMotion = false,
    this.reduceTransparency = false,
    required super.child,
  });

  static GlassScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GlassScope>();
  }

  @override
  bool updateShouldNotify(GlassScope oldWidget) {
    return activeTier != oldWidget.activeTier ||
        reduceMotion != oldWidget.reduceMotion ||
        reduceTransparency != oldWidget.reduceTransparency;
  }
}
