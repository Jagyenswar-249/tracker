import 'package:flutter/material.dart';
import '../../core/glass/glass_surface.dart';
import '../../core/glass/glass_tier.dart';
import '../../core/haptics/haptics.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/aurora_background.dart';
import '../../domain/entities/cadence.dart';

enum InsightsRange { fourWeeks, threeMonths, year }

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  InsightsRange _range = InsightsRange.fourWeeks;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;

    return AuroraBackground(
      activeView: Cadence.monthly,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Sp.screenSidePadding,
            16.0,
            Sp.screenSidePadding,
            Sp.contentBottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Insights', style: BrimTypography.title(colors.text)),
              const SizedBox(height: 16),

              // Range Segmented Control
              _buildRangeSelector(colors),
              const SizedBox(height: 16),

              // Completion Rate Trend Card
              _buildTrendCard(colors),
              const SizedBox(height: 14),

              // Streak & Best Weekday Dual Card
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Streak',
                      value: '6 days',
                      subtitle: 'Active now 🔥',
                      colors: colors,
                      accentColor: colors.coral,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Best weekday',
                      value: 'Tuesday',
                      subtitle: '82% average',
                      colors: colors,
                      accentColor: colors.kelp,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Category Breakdown Card
              _buildCategorySplitCard(colors),
              const SizedBox(height: 14),

              // Most Neglected Works Card
              _buildNeglectedCard(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangeSelector(BrimColors colors) {
    final options = [
      (InsightsRange.fourWeeks, '4 weeks'),
      (InsightsRange.threeMonths, '3 months'),
      (InsightsRange.year, 'Year'),
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.track,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.rimSoft),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = _range == opt.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                BrimHaptics.selectionClick();
                setState(() => _range = opt.$1);
              },
              child: GlassSurface(
                shape: const GlassShape.capsule(),
                tint: isSelected ? colors.orchid : null,
                tierOverride: isSelected ? GlassTier.liquid : GlassTier.frost,
                child: Center(
                  child: Text(
                    opt.$2,
                    style: BrimTypography.micro(
                      isSelected ? colors.text : colors.textSoft,
                    ).copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendCard(BrimColors colors) {
    return GlassSurface(
      shape: const GlassShape.rounded(Rad.card),
      tint: colors.orchid,
      tierOverride: GlassTier.frost,
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Completion rate',
                    style: BrimTypography.headline(colors.text).copyWith(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('Overall progress trend',
                      style: BrimTypography.micro(colors.textSoft)),
                ],
              ),
              Row(
                children: [
                  Text('68%',
                      style: BrimTypography.headline(colors.text).copyWith(
                        fontSize: 22,
                      )),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_upward, size: 14, color: colors.kelp),
                  Text('6%',
                      style: BrimTypography.micro(colors.kelp).copyWith(
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Trend Chart Bars
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [42, 58, 65, 71, 62, 85, 91, 78, 88].map((val) {
                final frac = val / 100.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 24,
                      height: 64 * frac,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: [
                            colors.orchid,
                            colors.orchid.withOpacity(0.35),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required BrimColors colors,
    required Color accentColor,
  }) {
    return GlassSurface(
      shape: const GlassShape.rounded(Rad.card),
      tint: accentColor,
      tierOverride: GlassTier.frost,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: BrimTypography.micro(colors.textSoft)),
          const SizedBox(height: 6),
          Text(
            value,
            style: BrimTypography.headline(colors.text).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle,
              style: BrimTypography.micro(accentColor).copyWith(
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  Widget _buildCategorySplitCard(BrimColors colors) {
    final categories = [
      ('Research & Thesis', 0.78, colors.lagoon),
      ('Health & Fitness', 0.61, colors.kelp),
      ('Client Deliverables', 0.85, colors.saffron),
      ('Language & Reading', 0.45, colors.rose),
    ];

    return GlassSurface(
      shape: const GlassShape.rounded(Rad.card),
      tierOverride: GlassTier.frost,
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('By category',
              style: BrimTypography.headline(colors.text).copyWith(
                fontSize: 16,
              )),
          const SizedBox(height: 16),
          ...categories.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cat.$1, style: BrimTypography.label(colors.text)),
                      Text('${(cat.$2 * 100).round()}%',
                          style: BrimTypography.label(colors.textSoft)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.track,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: cat.$2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: cat.$3,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNeglectedCard(BrimColors colors) {
    return GlassSurface(
      shape: const GlassShape.rounded(Rad.card),
      tint: colors.coral,
      tierOverride: GlassTier.frost,
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Most neglected works',
            style: BrimTypography.headline(colors.text).copyWith(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '• Language Practice (Spanish) — 22% average this month\n• Tax Filing Preparation — Due soon\n• Deep Reading — Missed 3 days this week',
            style: BrimTypography.body(colors.textSoft).copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
