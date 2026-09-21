import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/typography.dart';
import '../../../core/glass/glass_surface.dart';
import '../../../core/glass/glass_tier.dart';
import '../../../domain/entities/cadence.dart';
import '../../../domain/entities/period_snapshot.dart';
import 'daily_strip.dart';
import 'weekly_bars.dart';

class PeriodSummaryPanel extends StatelessWidget {
  final PeriodSnapshot snapshot;

  const PeriodSummaryPanel({
    super.key,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;

    final (accentColor, periodLabel) = switch (snapshot.view) {
      Cadence.daily => (colors.lagoon, 'of today'),
      Cadence.weekly => (colors.saffron, 'of this week'),
      Cadence.monthly => (colors.orchid, 'of this month'),
      Cadence.once => (colors.lagoon, 'total'),
    };

    final percentRounded = snapshot.overall.round();

    return GlassSurface(
      shape: const GlassShape.rounded(Rad.card),
      tint: accentColor,
      tierOverride: GlassTier.frost,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Big Number & Circular Gauge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$percentRounded',
                        style: BrimTypography.display(colors.text),
                      ),
                      Text(
                        '%',
                        style: BrimTypography.title(colors.textSoft).copyWith(
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    periodLabel,
                    style: BrimTypography.label(colors.textSoft),
                  ),
                ],
              ),

              // Animated Radial Gauge
              SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Track
                    CustomPaint(
                      size: const Size(68, 68),
                      painter: RingPainter(
                        progress: snapshot.overall / 100.0,
                        accentColor: accentColor,
                        trackColor: colors.track,
                      ),
                    ),
                    Icon(
                      snapshot.overall >= 100 ? Icons.check : Icons.water_drop,
                      size: 20,
                      color: accentColor,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: colors.rimSoft, height: 1),
          const SizedBox(height: 14),

          // Row 2: Four compact stats (Done, Left, Overdue, Streak)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(
                label: 'Done',
                value: '${snapshot.doneCount}/${snapshot.totalCount}',
                colors: colors,
              ),
              _buildStat(
                label: 'Left',
                value: '${snapshot.leftCount}',
                colors: colors,
              ),
              _buildStat(
                label: 'Overdue',
                value: '${snapshot.overdueCount}',
                colors: colors,
                isWarning: snapshot.overdueCount > 0,
              ),
              _buildStat(
                label: 'Streak',
                value: '🔥 ${snapshot.streak}d',
                colors: colors,
              ),
            ],
          ),

          // Row 3: Daily strip or Weekly bars for higher views
          if (snapshot.view == Cadence.weekly &&
              snapshot.summaryStrips.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(color: colors.rimSoft, height: 1),
            const SizedBox(height: 12),
            DailyStrip(
              dailyAverages: snapshot.summaryStrips,
              accentColor: accentColor,
            ),
          ] else if (snapshot.view == Cadence.monthly &&
              snapshot.summaryStrips.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(color: colors.rimSoft, height: 1),
            const SizedBox(height: 12),
            WeeklyBars(
              weeklyAverages: snapshot.summaryStrips,
              accentColor: accentColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat({
    required String label,
    required String value,
    required BrimColors colors,
    bool isWarning = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: BrimTypography.headline(
            isWarning ? colors.coral : colors.text,
          ).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: BrimTypography.micro(colors.textSoft),
        ),
      ],
    );
  }
}

class RingPainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final Color trackColor;

  RingPainter({
    required this.progress,
    required this.accentColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.trackColor != trackColor;
  }
}
