import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/haptics/haptics.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/glass/glass_surface.dart';
import '../../../core/glass/glass_tier.dart';
import '../../../domain/entities/cadence.dart';
import '../../../domain/period/period_math.dart';

class PeriodNavigator extends StatelessWidget {
  final Cadence view;
  final DateTime anchorDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onJumpToCurrent;

  const PeriodNavigator({
    super.key,
    required this.view,
    required this.anchorDate,
    required this.onPrevious,
    required this.onNext,
    required this.onJumpToCurrent,
  });

  bool get isCurrentPeriod {
    final now = DateTime.now();
    final currentStart = periodStartFor(view, now);
    final anchorStart = periodStartFor(view, anchorDate);
    return ymd(currentStart) == ymd(anchorStart);
  }

  String get periodLabel {
    final start = periodStartFor(view, anchorDate);
    final end = periodEndFor(view, start);

    switch (view) {
      case Cadence.daily:
        return DateFormat('EEE, d MMM').format(anchorDate);
      case Cadence.weekly:
        if (start.month == end.month) {
          return '${DateFormat('d').format(start)} – ${DateFormat('d MMM').format(end)}';
        } else {
          return '${DateFormat('d MMM').format(start)} – ${DateFormat('d MMM').format(end)}';
        }
      case Cadence.monthly:
        return DateFormat('MMMM yyyy').format(anchorDate);
      case Cadence.once:
        return 'All One-offs';
    }
  }

  String get currentChipLabel => switch (view) {
        Cadence.daily => 'Today',
        Cadence.weekly => 'This week',
        Cadence.monthly => 'This month',
        Cadence.once => 'Current',
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous period button
          GestureDetector(
            onTap: () {
              BrimHaptics.selectionClick();
              onPrevious();
            },
            child: GlassSurface(
              width: 36,
              height: 36,
              shape: const GlassShape.circle(),
              tierOverride: GlassTier.frost,
              child: Center(
                child: Icon(
                  Icons.chevron_left,
                  size: 20,
                  color: colors.text,
                ),
              ),
            ),
          ),

          // Period Title & Today jump chip
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                periodLabel,
                style: BrimTypography.headline(colors.text).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              if (!isCurrentPeriod) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    BrimHaptics.lightImpact();
                    onJumpToCurrent();
                  },
                  child: GlassSurface(
                    shape: const GlassShape.capsule(),
                    tint: colors.lagoon,
                    tierOverride: GlassTier.frost,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 4.0,
                    ),
                    child: Text(
                      currentChipLabel,
                      style: BrimTypography.micro(colors.lagoon).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Next period button
          GestureDetector(
            onTap: () {
              BrimHaptics.selectionClick();
              onNext();
            },
            child: GlassSurface(
              width: 36,
              height: 36,
              shape: const GlassShape.circle(),
              tierOverride: GlassTier.frost,
              child: Center(
                child: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colors.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
