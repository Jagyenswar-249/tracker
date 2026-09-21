import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/glass/glass_surface.dart';
import '../../core/glass/glass_tier.dart';
import '../../core/haptics/haptics.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/aurora_background.dart';
import '../../domain/entities/cadence.dart';
import '../../domain/period/period_math.dart';
import '../tasks/tasks_controller.dart';
import '../tasks/widgets/work_card.dart';

class CalendarPage extends StatefulWidget {
  final TasksController controller;
  final VoidCallback onOpenEditor;
  final void Function(DateTime date) onOpenDay;

  const CalendarPage({
    super.key,
    required this.controller,
    required this.onOpenEditor,
    required this.onOpenDay,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;

    return AuroraBackground(
      activeView: Cadence.daily,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Calendar Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Sp.screenSidePadding,
                  16.0,
                  Sp.screenSidePadding,
                  12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Calendar', style: BrimTypography.title(colors.text)),
                    const SizedBox(height: 12),

                    // Month Navigator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            BrimHaptics.selectionClick();
                            setState(() {
                              _selectedMonth = DateTime(
                                _selectedMonth.year,
                                _selectedMonth.month - 1,
                                1,
                              );
                            });
                          },
                          child: GlassSurface(
                            width: 36,
                            height: 36,
                            shape: const GlassShape.circle(),
                            tierOverride: GlassTier.frost,
                            child: Icon(Icons.chevron_left, color: colors.text),
                          ),
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(_selectedMonth),
                          style: BrimTypography.headline(colors.text).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            BrimHaptics.selectionClick();
                            setState(() {
                              _selectedMonth = DateTime(
                                _selectedMonth.year,
                                _selectedMonth.month + 1,
                                1,
                              );
                            });
                          },
                          child: GlassSurface(
                            width: 36,
                            height: 36,
                            shape: const GlassShape.circle(),
                            tierOverride: GlassTier.frost,
                            child: Icon(Icons.chevron_right, color: colors.text),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Month Heatmap Grid
                    _buildMonthHeatmap(colors),

                    const SizedBox(height: 20),

                    // Selected Day Details Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('EEE, d MMM').format(_selectedDay),
                          style: BrimTypography.headline(colors.text).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            BrimHaptics.lightImpact();
                            widget.onOpenDay(_selectedDay);
                          },
                          child: GlassSurface(
                            shape: const GlassShape.capsule(),
                            tint: colors.lagoon,
                            tierOverride: GlassTier.liquid,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 6.0,
                            ),
                            child: Text(
                              'Open day ›',
                              style: BrimTypography.label(colors.text).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Work items for selected day
            _buildSelectedDayList(colors),

            const SliverToBoxAdapter(
              child: SizedBox(height: Sp.contentBottomPadding),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeatmap(BrimColors colors) {
    final firstDayOfWeek = _selectedMonth.weekday; // 1 = Mon .. 7 = Sun
    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return GlassSurface(
      shape: const GlassShape.rounded(Rad.card),
      tierOverride: GlassTier.frost,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Weekday Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayNames
                .map((n) => Text(
                      n,
                      style: BrimTypography.micro(colors.textSoft).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),

          // Day Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42, // 6 weeks max
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final dayOffset = index - (firstDayOfWeek - 1);
              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return const SizedBox.shrink();
              }

              final dayNum = dayOffset + 1;
              final dayDate =
                  DateTime(_selectedMonth.year, _selectedMonth.month, dayNum);
              final isSelected = ymd(dayDate) == ymd(_selectedDay);

              // Pseudo completion rate calculation for heatmap cell color
              final pseudoPercent = (dayNum * 19) % 100;
              final opacity = (0.15 + (pseudoPercent / 100.0) * 0.75)
                  .clamp(0.15, 0.90);

              return GestureDetector(
                onTap: () {
                  BrimHaptics.selectionClick();
                  setState(() => _selectedDay = dayDate);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.lagoon.withOpacity(opacity),
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2.0)
                        : Border.all(color: colors.rimSoft, width: 1.0),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colors.lagoon.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNum',
                      style: BrimTypography.micro(
                        isSelected ? Colors.white : colors.text,
                      ).copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayList(BrimColors colors) {
    final snapshot = widget.controller.snapshot;
    final items = snapshot?.items ?? [];

    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Text(
            'No works scheduled for this day.',
            style: BrimTypography.body(colors.textSoft),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.screenSidePadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return WorkCard(
              item: item,
              onPercentChanged: (val) =>
                  widget.controller.updateProgress(item.work.id, val),
              onTap: () {
                widget.onOpenDay(_selectedDay);
              },
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}
