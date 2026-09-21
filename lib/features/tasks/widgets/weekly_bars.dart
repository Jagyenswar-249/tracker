import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class WeeklyBars extends StatelessWidget {
  final List<double> weeklyAverages; // 4 to 5 values
  final Color accentColor;

  const WeeklyBars({
    super.key,
    required this.weeklyAverages,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(weeklyAverages.length, (i) {
        final avg = weeklyAverages[i];
        final fraction = (avg / 100.0).clamp(0.0, 1.0);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              children: [
                Text(
                  'W${i + 1}',
                  style: BrimTypography.micro(colors.textSoft).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.track,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.rimSoft, width: 1.0),
                  ),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      FractionallySizedBox(
                        heightFactor: fraction,
                        widthFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            gradient: LinearGradient(
                              colors: [
                                accentColor.withOpacity(0.9),
                                accentColor,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${avg.round()}%',
                  style: BrimTypography.micro(colors.text).copyWith(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
