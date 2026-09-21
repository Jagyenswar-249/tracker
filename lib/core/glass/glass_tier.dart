enum GlassTier {
  liquid, // Refraction shader + blur + tint + rim + specular + interactive stretch
  frost,  // BackdropFilter (blur σ=14) + semi-transparent tint + rim light
  solid;  // Tinted opaque container + rim light (fallback for Reduce Transparency / low-end)
}

enum GlassEmphasis {
  subtle,
  regular,
  strong,
}

sealed class GlassShape {
  const GlassShape();
  const factory GlassShape.capsule() = GlassShapeCapsule;
  const factory GlassShape.rounded(double radius) = GlassShapeRounded;
  const factory GlassShape.circle() = GlassShapeCircle;
}

class GlassShapeCapsule extends GlassShape {
  const GlassShapeCapsule();
}

class GlassShapeRounded extends GlassShape {
  final double radius;
  const GlassShapeRounded(this.radius);
}

class GlassShapeCircle extends GlassShape {
  const GlassShapeCircle();
}
