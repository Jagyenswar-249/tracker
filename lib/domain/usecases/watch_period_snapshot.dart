import '../entities/cadence.dart';
import '../entities/period_snapshot.dart';
import '../period/period_math.dart';
import '../period/rollup.dart';
import '../period/streak.dart';
import '../repositories/progress_repository.dart';
import '../repositories/work_repository.dart';

class WatchPeriodSnapshot {
  final WorkRepository _workRepository;
  final ProgressRepository _progressRepository;

  const WatchPeriodSnapshot(this._workRepository, this._progressRepository);

  Future<PeriodSnapshot> execute({
    required Cadence view,
    required DateTime anchorDate,
    int weekStart = 1,
    double streakThreshold = 80.0,
  }) async {
    final startDt = periodStartFor(view, anchorDate, weekStart: weekStart);
    final endDt = periodEndFor(view, startDt, weekStart: weekStart);
    final periodStartStr = ymd(startDt);
    final periodEndStr = ymd(endDt);

    final works = await _workRepository.getWorksForPeriod(
      view: view,
      periodStart: periodStartStr,
      periodEnd: periodEndStr,
      anchorDate: anchorDate,
    );

    final workIds = works.map((w) => w.id).toList();
    final progressMap = await _progressRepository.getPercentsForWorks(
        workIds, periodStartStr);

    final todayStr = ymd(DateTime.now());
    final items = <WorkWithProgress>[];

    for (final w in works) {
      final percent = progressMap[w.id] ?? 0;
      final isOverdue = w.cadence == Cadence.once &&
          w.dueDate != null &&
          w.dueDate!.compareTo(todayStr) < 0 &&
          percent < 100;

      items.add(WorkWithProgress(
        work: w,
        percent: percent,
        isOverdue: isOverdue,
      ));
    }

    final overall = rollup(items.map((i) => (
          effort: i.work.effort,
          percent: i.percent,
        )));

    final doneCount = items.where((i) => i.isDone).length;
    final overdueCount = items.where((i) => i.isOverdue).length;

    // Daily rollups for streak & summary strips
    final past30DaysStr = ymd(DateTime.now().subtract(const Duration(days: 30)));
    final rollupsMap = await _progressRepository.getDailyRollups(
      fromDate: past30DaysStr,
      toDate: todayStr,
    );

    final streak = calculateStreak(
      dailyRollups: rollupsMap,
      today: DateTime.now(),
      threshold: streakThreshold,
    );

    // Build read-only strips
    final summaryStrips = <double>[];
    if (view == Cadence.weekly) {
      // 7 days of the week
      for (var i = 0; i < 7; i++) {
        final dayDt = DateTime(startDt.year, startDt.month, startDt.day + i);
        final dayStr = ymd(dayDt);
        summaryStrips.add(rollupsMap[dayStr] ?? 0.0);
      }
    } else if (view == Cadence.monthly) {
      // 4 to 5 weeks in the month
      var curWeek = weekStartOf(startDt, weekStart: weekStart);
      final monthEnd = endDt;
      while (!curWeek.isAfter(monthEnd)) {
        var weekSum = 0.0;
        var dayCount = 0;
        for (var d = 0; d < 7; d++) {
          final day = DateTime(curWeek.year, curWeek.month, curWeek.day + d);
          if (day.month == startDt.month) {
            final val = rollupsMap[ymd(day)];
            if (val != null) {
              weekSum += val;
              dayCount++;
            }
          }
        }
        summaryStrips.add(dayCount > 0 ? (weekSum / dayCount) : 0.0);
        curWeek = DateTime(curWeek.year, curWeek.month, curWeek.day + 7);
      }
    }

    return PeriodSnapshot(
      view: view,
      periodStart: periodStartStr,
      items: items,
      overall: overall,
      doneCount: doneCount,
      totalCount: items.length,
      overdueCount: overdueCount,
      streak: streak,
      nextDue: items.where((i) => !i.isDone).firstOrNull?.work.title,
      summaryStrips: summaryStrips,
    );
  }
}
