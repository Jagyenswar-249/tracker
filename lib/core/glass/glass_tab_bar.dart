import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../haptics/haptics.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'glass_surface.dart';
import 'glass_tier.dart';

class GlassTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;

  const GlassTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;

    final tabs = [
      (PhosphorIcons.squaresFour(), PhosphorIcons.squaresFour(PhosphorIconsStyle.fill), 'Tasks'),
      (PhosphorIcons.calendar(), PhosphorIcons.calendar(PhosphorIconsStyle.fill), 'Calendar'),
      (PhosphorIcons.chartBar(), PhosphorIcons.chartBar(PhosphorIconsStyle.fill), 'Insights'),
      (PhosphorIcons.gear(), PhosphorIcons.gear(PhosphorIconsStyle.fill), 'Settings'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Main floating navigation bar
          Expanded(
            child: GlassSurface(
              height: 64,
              shape: const GlassShape.capsule(),
              tierOverride: GlassTier.liquid,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(tabs.length, (index) {
                  final (regularIcon, fillIcon, title) = tabs[index];
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      BrimHaptics.selectionClick();
                      onTabSelected(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.lagoon.withOpacity(0.22)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? fillIcon : regularIcon,
                            size: 22,
                            color: isSelected ? colors.lagoon : colors.textSoft,
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Text(
                              title,
                              style: BrimTypography.label(colors.text).copyWith(
                                color: colors.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Liquid '+' button
          GestureDetector(
            onTap: () {
              BrimHaptics.lightImpact();
              onAddPressed();
            },
            child: GlassSurface(
              width: 56,
              height: 56,
              shape: const GlassShape.circle(),
              tint: colors.lagoon,
              tierOverride: GlassTier.liquid,
              child: Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        colors.lagoon,
                        colors.lagoon.withOpacity(0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.lagoon.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
