import 'package:flutter/material.dart';
import '../../domain/entities/cadence.dart';
import '../haptics/haptics.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'glass_surface.dart';
import 'glass_tier.dart';

class GlassSegmentedControl extends StatelessWidget {
  final Cadence selected;
  final ValueChanged<Cadence> onSelected;

  const GlassSegmentedControl({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;

    final accentColor = switch (selected) {
      Cadence.daily => colors.lagoon,
      Cadence.weekly => colors.saffron,
      Cadence.monthly => colors.orchid,
      Cadence.once => colors.lagoon,
    };

    final selectedIndex = switch (selected) {
      Cadence.daily => 0,
      Cadence.weekly => 1,
      Cadence.monthly => 2,
      Cadence.once => 0,
    };

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.track,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.rimSoft, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 8) / 3;

          return Stack(
            children: [
              // Sliding active glass lens
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: const SpringCurve(),
                left: selectedIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: GlassSurface(
                  shape: const GlassShape.capsule(),
                  tint: accentColor,
                  tierOverride: GlassTier.liquid,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withOpacity(0.55),
                          accentColor.withOpacity(0.25),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Segment text buttons
              Row(
                children: [
                  _buildSegment(
                    label: 'Daily',
                    isSelected: selected == Cadence.daily,
                    onTap: () {
                      BrimHaptics.selectionClick();
                      onSelected(Cadence.daily);
                    },
                    colors: colors,
                  ),
                  _buildSegment(
                    label: 'Weekly',
                    isSelected: selected == Cadence.weekly,
                    onTap: () {
                      BrimHaptics.selectionClick();
                      onSelected(Cadence.weekly);
                    },
                    colors: colors,
                  ),
                  _buildSegment(
                    label: 'Monthly',
                    isSelected: selected == Cadence.monthly,
                    onTap: () {
                      BrimHaptics.selectionClick();
                      onSelected(Cadence.monthly);
                    },
                    colors: colors,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSegment({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required BrimColors colors,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: BrimTypography.label(
              isSelected ? colors.text : colors.textSoft,
            ).copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class SpringCurve extends Curve {
  const SpringCurve();

  @override
  double transformInternal(double t) {
    // Smooth overshoot spring
    return 1 - (1 - t) * (1 - t) * ((1.70158 + 1) * (1 - t) - 1.70158);
  }
}
