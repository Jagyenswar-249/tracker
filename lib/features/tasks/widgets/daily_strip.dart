import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class DailyStrip extends StatelessWidget {
  final List<double> dailyAverages; // 7 values (0..100)
  final Color accentColor;

  const DailyStrip({
    super.key,
    required this.dailyAverages,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;
    final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final avg = i < dailyAverages.length ? dailyAverages[i] : 0.0;
        final fraction = (avg / 100.0).clamp(0.0, 1.0);

        return Column(
          children: [
            Text(
              dayNames[i],
              style: BrimTypography.micro(colors.textSoft).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.track,
                border: Border.all(
                  color: colors.rimSoft,
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Container(
                  width: 18 * fraction,
                  height: 18 * fraction,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avg > 0
                        ? accentColor.withOpacity(0.3 + 0.7 * fraction)
                        : Colors.transparent,
                    boxShadow: avg > 0
                        ? [
                            BoxShadow(
                              color: accentColor.withOpacity(0.4),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
