import 'package:flutter/material.dart';

@immutable
class BrimColors extends ThemeExtension<BrimColors> {
  final Color bg;
  final Color bgDeep;
  final Color text;
  final Color textSoft;
  final Color lagoon;
  final Color coral;
  final Color saffron;
  final Color orchid;
  final Color kelp;
  final Color sky;
  final Color rose;
  final Color sand;
  final Color glassA;
  final Color glassB;
  final Color frostBg;
  final Color rimLight;
  final Color rimSoft;
  final Color shadow;
  final Color track;
  final Color specular;

  const BrimColors({
    required this.bg,
    required this.bgDeep,
    required this.text,
    required this.textSoft,
    required this.lagoon,
    required this.coral,
    required this.saffron,
    required this.orchid,
    required this.kelp,
    required this.sky,
    required this.rose,
    required this.sand,
    required this.glassA,
    required this.glassB,
    required this.frostBg,
    required this.rimLight,
    required this.rimSoft,
    required this.shadow,
    required this.track,
    required this.specular,
  });

  static const dark = BrimColors(
    bg: Color(0xFF0B1622),
    bgDeep: Color(0xFF10263A),
    text: Color(0xFFEAF7F6),
    textSoft: Color(0xFF9DB4BF),
    lagoon: Color(0xFF2EC4B6),
    coral: Color(0xFFFF6B81),
    saffron: Color(0xFFFFC24B),
    orchid: Color(0xFF9B8CFF),
    kelp: Color(0xFF5BD68A),
    sky: Color(0xFF5AB8FF),
    rose: Color(0xFFFF8FD0),
    sand: Color(0xFFD9C5A0),
    glassA: Color(0x2BFFFFFF), // 17% white
    glassB: Color(0x0DFFFFFF), // 5% white
    frostBg: Color(0x12FFFFFF), // 7% white
    rimLight: Color(0x99FFFFFF), // 60% white
    rimSoft: Color(0x1AFFFFFF), // 10% white
    shadow: Color(0x4D000000), // 30% black
    track: Color(0x4D000000), // 30% black
    specular: Color(0x3DFFFFFF), // 24% white
  );

  static const light = BrimColors(
    bg: Color(0xFFEEF6F5),
    bgDeep: Color(0xFFD9EAE8),
    text: Color(0xFF0B1F2A),
    textSoft: Color(0xFF3F5A66),
    lagoon: Color(0xFF1FA89B),
    coral: Color(0xFFE8506A),
    saffron: Color(0xFFD99A1E),
    orchid: Color(0xFF7E6CF0),
    kelp: Color(0xFF39B06B),
    sky: Color(0xFF2E97E8),
    rose: Color(0xFFE86EB0),
    sand: Color(0xFFC0AC85),
    glassA: Color(0xB3FFFFFF), // 70% white
    glassB: Color(0x4DFFFFFF), // 30% white
    frostBg: Color(0x85FFFFFF), // 52% white
    rimLight: Color(0xFAFFFFFF), // 98% white
    rimSoft: Color(0xB3FFFFFF), // 70% white
    shadow: Color(0x29143C50),
    track: Color(0x1C0B1F2A),
    specular: Color(0xB3FFFFFF), // 70% white
  );

  @override
  BrimColors copyWith({
    Color? bg,
    Color? bgDeep,
    Color? text,
    Color? textSoft,
    Color? lagoon,
    Color? coral,
    Color? saffron,
    Color? orchid,
    Color? kelp,
    Color? sky,
    Color? rose,
    Color? sand,
    Color? glassA,
    Color? glassB,
    Color? frostBg,
    Color? rimLight,
    Color? rimSoft,
    Color? shadow,
    Color? track,
    Color? specular,
  }) {
    return BrimColors(
      bg: bg ?? this.bg,
      bgDeep: bgDeep ?? this.bgDeep,
      text: text ?? this.text,
      textSoft: textSoft ?? this.textSoft,
      lagoon: lagoon ?? this.lagoon,
      coral: coral ?? this.coral,
      saffron: saffron ?? this.saffron,
      orchid: orchid ?? this.orchid,
      kelp: kelp ?? this.kelp,
      sky: sky ?? this.sky,
      rose: rose ?? this.rose,
      sand: sand ?? this.sand,
      glassA: glassA ?? this.glassA,
      glassB: glassB ?? this.glassB,
      frostBg: frostBg ?? this.frostBg,
      rimLight: rimLight ?? this.rimLight,
      rimSoft: rimSoft ?? this.rimSoft,
      shadow: shadow ?? this.shadow,
      track: track ?? this.track,
      specular: specular ?? this.specular,
    );
  }

  @override
  BrimColors lerp(ThemeExtension<BrimColors>? other, double t) {
    if (other is! BrimColors) return this;
    return BrimColors(
      bg: Color.lerp(bg, other.bg, t)!,
      bgDeep: Color.lerp(bgDeep, other.bgDeep, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSoft: Color.lerp(textSoft, other.textSoft, t)!,
      lagoon: Color.lerp(lagoon, other.lagoon, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      saffron: Color.lerp(saffron, other.saffron, t)!,
      orchid: Color.lerp(orchid, other.orchid, t)!,
      kelp: Color.lerp(kelp, other.kelp, t)!,
      sky: Color.lerp(sky, other.sky, t)!,
      rose: Color.lerp(rose, other.rose, t)!,
      sand: Color.lerp(sand, other.sand, t)!,
      glassA: Color.lerp(glassA, other.glassA, t)!,
      glassB: Color.lerp(glassB, other.glassB, t)!,
      frostBg: Color.lerp(frostBg, other.frostBg, t)!,
      rimLight: Color.lerp(rimLight, other.rimLight, t)!,
      rimSoft: Color.lerp(rimSoft, other.rimSoft, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      track: Color.lerp(track, other.track, t)!,
      specular: Color.lerp(specular, other.specular, t)!,
    );
  }
}
