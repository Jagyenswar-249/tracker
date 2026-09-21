import 'cadence.dart';
import 'work.dart';

class WorkWithProgress {
  final Work work;
  final int percent; // 0..100
  final bool isOverdue;

  const WorkWithProgress({
    required this.work,
    required this.percent,
    this.isOverdue = false,
  });

  bool get isDone => percent >= 100;
}

class PeriodSnapshot {
  final Cadence view;
  final String periodStart; // 'YYYY-MM-DD'
  final List<WorkWithProgress> items;
  final double overall; // 0..100 weighted rollup
  final int doneCount;
  final int totalCount;
  final int overdueCount;
  final int streak; // consecutive days
  final String? nextDue;
  final List<double> summaryStrips; // 7 daily averages for Weekly, 4-5 weekly averages for Monthly

  const PeriodSnapshot({
    required this.view,
    required this.periodStart,
    required this.items,
    required this.overall,
    required this.doneCount,
    required this.totalCount,
    required this.overdueCount,
    required this.streak,
    this.nextDue,
    this.summaryStrips = const [],
  });

  int get leftCount => totalCount - doneCount;
}
