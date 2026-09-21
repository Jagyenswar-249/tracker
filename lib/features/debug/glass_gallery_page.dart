import 'package:flutter/material.dart';
import '../../core/glass/glass_button.dart';
import '../../core/glass/glass_segmented_control.dart';
import '../../core/glass/glass_surface.dart';
import '../../core/glass/glass_tier.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/aurora_background.dart';
import '../../domain/entities/cadence.dart';

class GlassGalleryPage extends StatefulWidget {
  const GlassGalleryPage({super.key});

  @override
  State<GlassGalleryPage> createState() => _GlassGalleryPageState();
}

class _GlassGalleryPageState extends State<GlassGalleryPage> {
  Cadence _cadence = Cadence.daily;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;

    return AuroraBackground(
      activeView: _cadence,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Glass Gallery', style: BrimTypography.headline(colors.text)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colors.text),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Liquid Tier (High Refraction)', style: BrimTypography.label(colors.lagoon)),
              const SizedBox(height: 12),
              GlassSurface(
                shape: const GlassShape.capsule(),
                tint: colors.lagoon,
                tierOverride: GlassTier.liquid,
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text('Liquid Glass Capsule', style: BrimTypography.body(colors.text)),
                ),
              ),

              const SizedBox(height: 24),

              Text('Frost Tier (Backdrop Blur σ=14)', style: BrimTypography.label(colors.saffron)),
              const SizedBox(height: 12),
              GlassSurface(
                shape: const GlassShape.rounded(Rad.card),
                tint: colors.saffron,
                tierOverride: GlassTier.frost,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Frost Card Surface', style: BrimTypography.headline(colors.text)),
                    const SizedBox(height: 6),
                    Text('Used for work cards, hero summary panels, and dialog sheets.',
                        style: BrimTypography.body(colors.textSoft)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text('Solid Tier (Fallback / High Contrast)', style: BrimTypography.label(colors.coral)),
              const SizedBox(height: 12),
              GlassSurface(
                shape: const GlassShape.rounded(Rad.card),
                tint: colors.coral,
                tierOverride: GlassTier.solid,
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text('Solid Tinted Surface with Specular Rim',
                      style: BrimTypography.body(colors.text)),
                ),
              ),

              const SizedBox(height: 24),

              Text('Glass Segmented Control', style: BrimTypography.label(colors.orchid)),
              const SizedBox(height: 12),
              GlassSegmentedControl(
                selected: _cadence,
                onSelected: (val) => setState(() => _cadence = val),
              ),

              const SizedBox(height: 24),

              Text('Glass Buttons', style: BrimTypography.label(colors.textSoft)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Primary',
                      variant: GlassButtonVariant.primary,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GlassButton(
                      label: 'Destructive',
                      variant: GlassButtonVariant.destructive,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
