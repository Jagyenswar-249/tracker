import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/glass/glass_segmented_control.dart';
import '../../core/glass/glass_surface.dart';
import '../../core/glass/glass_tier.dart';
import '../../core/widgets/aurora_background.dart';
import '../../core/widgets/undo_toast.dart';
import '../../domain/entities/cadence.dart';
import '../work_detail/work_detail_page.dart';
import 'tasks_controller.dart';
import 'widgets/filter_chips.dart';
import 'widgets/period_navigator.dart';
import 'widgets/period_summary_panel.dart';
import 'widgets/work_card.dart';

class TasksPage extends StatefulWidget {
  final TasksController controller;
  final VoidCallback onOpenEditor;

  const TasksPage({
    super.key,
    required this.controller,
    required this.onOpenEditor,
  });

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  TaskFilter _selectedFilter = TaskFilter.all;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final snapshot = widget.controller.snapshot;

        return AuroraBackground(
          activeView: widget.controller.view,
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                // Header Area: Greeting & Title
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
                        Text(
                          'Good ${_getGreeting()}',
                          style: BrimTypography.body(colors.textSoft),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tasks',
                          style: BrimTypography.title(colors.text),
                        ),
                        const SizedBox(height: 16),

                        // Segmented View Control (Daily / Weekly / Monthly)
                        GlassSegmentedControl(
                          selected: widget.controller.view,
                          onSelected: (view) => widget.controller.setView(view),
                        ),
                        const SizedBox(height: 10),

                        // Period Navigator
                        PeriodNavigator(
                          view: widget.controller.view,
                          anchorDate: widget.controller.anchorDate,
                          onPrevious: widget.controller.previousPeriod,
                          onNext: widget.controller.nextPeriod,
                          onJumpToCurrent: widget.controller.jumpToCurrent,
                        ),
                        const SizedBox(height: 6),

                        // Hero Period Summary Panel
                        if (snapshot != null)
                          PeriodSummaryPanel(snapshot: snapshot),

                        const SizedBox(height: 12),

                        // Filter Chips
                        FilterChips(
                          selected: _selectedFilter,
                          onSelected: (filter) {
                            setState(() => _selectedFilter = filter);
                          },
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),

                // Content Area: Work Cards or Empty / Loading States
                if (widget.controller.isLoading && snapshot == null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: List.generate(
                          3,
                          (index) => Container(
                            height: 100,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: colors.frostBg,
                              borderRadius: BorderRadius.circular(Rad.card),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else if (snapshot != null) ...[
                  _buildWorksList(context, snapshot, colors),
                ],

                // Bottom padding so content is never hidden behind floating tab bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: Sp.contentBottomPadding),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorksList(
      BuildContext context, dynamic snapshot, BrimColors colors) {
    final filteredItems = snapshot.items.where((item) {
      switch (_selectedFilter) {
        case TaskFilter.all:
          return true;
        case TaskFilter.active:
          return !item.isDone;
        case TaskFilter.done:
          return item.isDone;
        case TaskFilter.overdue:
          return item.isOverdue;
      }
    }).toList();

    if (filteredItems.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
          child: GlassSurface(
            shape: const GlassShape.rounded(Rad.card),
            tierOverride: GlassTier.frost,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(
                  Icons.water_drop_outlined,
                  size: 44,
                  color: colors.lagoon.withOpacity(0.6),
                ),
                const SizedBox(height: 12),
                Text(
                  'Nothing scheduled for this period.',
                  style: BrimTypography.headline(colors.text).copyWith(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Add a work to start filling the glass vessel.',
                  textAlign: TextAlign.center,
                  style: BrimTypography.body(colors.textSoft),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: widget.onOpenEditor,
                  child: GlassSurface(
                    shape: const GlassShape.capsule(),
                    tint: colors.lagoon,
                    tierOverride: GlassTier.liquid,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      'Add work',
                      style: BrimTypography.label(colors.text).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.screenSidePadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = filteredItems[index];
            final previousPercent = item.percent;

            return WorkCard(
              item: item,
              onPercentChanged: (newPercent) {
                widget.controller.updateProgress(item.work.id, newPercent);
                UndoToast.show(
                  context: context,
                  message: 'Set to $newPercent%',
                  onUndo: () {
                    widget.controller.updateProgress(
                      item.work.id,
                      previousPercent,
                    );
                  },
                );
              },
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WorkDetailPage(
                      work: item.work,
                      currentPercent: item.percent,
                      onPercentChanged: (val) =>
                          widget.controller.updateProgress(item.work.id, val),
                      onArchive: () => widget.controller.archive(item.work.id),
                      onDelete: () => widget.controller.delete(item.work.id),
                    ),
                  ),
                );
              },
            );
          },
          childCount: filteredItems.length,
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}
