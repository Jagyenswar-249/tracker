import '../../domain/entities/cadence.dart';
import '../../domain/entities/progress_entry.dart';
import '../../domain/entities/progress_event.dart';
import '../../domain/entities/work.dart';
import '../../domain/period/period_math.dart';

abstract final class SeedData {
  static List<Work> getWorks() {
    final now = DateTime.now();
    final todayStr = ymd(now);

    return [
      Work(
        id: 'work-1',
        title: 'Write methods section',
        notes: 'Cover baseline models and ablation study',
        colorArgb: 0xFF2EC4B6, // lagoon
        cadence: Cadence.daily,
        weekdayMask: 127,
        startDate: '2026-08-01',
        effort: 2,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ),
      Work(
        id: 'work-2',
        title: 'Gym & Mobility',
        notes: 'Upper body power + 15 min mobility flow',
        colorArgb: 0xFF5BD68A, // kelp
        cadence: Cadence.daily,
        weekdayMask: 62, // Tue-Sat
        startDate: '2026-08-01',
        effort: 1,
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Work(
        id: 'work-3',
        title: 'Deep Reading',
        notes: 'Read 2 research papers or 20 book pages',
        colorArgb: 0xFF5AB8FF, // sky
        cadence: Cadence.daily,
        weekdayMask: 127,
        startDate: '2026-08-01',
        effort: 1,
        sortOrder: 2,
        createdAt: now,
        updatedAt: now,
      ),
      Work(
        id: 'work-4',
        title: 'Client Sprint Deliverables',
        notes: 'Ship v1.2 release artifacts & test suite',
        colorArgb: 0xFFFFC24B, // saffron
        cadence: Cadence.weekly,
        weekdayMask: 127,
        startDate: '2026-08-01',
        effort: 3,
        sortOrder: 3,
        createdAt: now,
        updatedAt: now,
      ),
      Work(
        id: 'work-5',
        title: 'Weekly Systems Review',
        notes: 'Inbox zero, plan sprints, archive logs',
        colorArgb: 0xFF9B8CFF, // orchid
        cadence: Cadence.weekly,
        weekdayMask: 127,
        startDate: '2026-08-01',
        effort: 1,
        sortOrder: 4,
        createdAt: now,
        updatedAt: now,
      ),
      Work(
        id: 'work-6',
        title: 'Language Practice (Spanish)',
        notes: '30 min conversational podcast / flashcards',
        colorArgb: 0xFFFF8FD0, // rose
        cadence: Cadence.weekly,
        weekdayMask: 127,
        startDate: '2026-08-01',
        effort: 1,
        sortOrder: 5,
        createdAt: now,
        updatedAt: now,
      ),
      Work(
        id: 'work-7',
        title: 'Monthly Financial Audit',
        notes: 'Reconcile accounts, check investments, update budget',
        colorArgb: 0xFFD9C5A0, // sand
        cadence: Cadence.monthly,
        weekdayMask: 127,
        startDate: '2026-08-01',
        effort: 2,
        sortOrder: 6,
        createdAt: now,
        updatedAt: now,
      ),
      Work(
        id: 'work-8',
        title: 'Portfolio & Case Studies Refresh',
        notes: 'Update interactive design prototypes and writeups',
        colorArgb: 0xFF2EC4B6, // lagoon
        cadence: Cadence.monthly,
        weekdayMask: 127,
        startDate: '2026-08-01',
        effort: 3,
        sortOrder: 7,
        createdAt: now,
        updatedAt: now,
      ),
      Work(
        id: 'work-9',
        title: 'Tax Filing Preparation',
        notes: 'Gather receipts and send to accountant',
        colorArgb: 0xFFFF6B81, // coral
        cadence: Cadence.once,
        dueDate: todayStr,
        startDate: todayStr,
        effort: 2,
        sortOrder: 8,
        createdAt: now,
        updatedAt: now,
      ),
      Work(
        id: 'work-10',
        title: 'Conference Paper Submission',
        notes: 'Submit final camera-ready PDF',
        colorArgb: 0xFFFF6B81, // coral
        cadence: Cadence.once,
        dueDate: ymd(now.subtract(const Duration(days: 2))), // overdue
        startDate: '2026-08-15',
        effort: 3,
        sortOrder: 9,
        createdAt: now,
        updatedAt: now,
      ),
      Work(
        id: 'work-11',
        title: 'Home Office Acoustic Treatment',
        notes: 'Mount acoustic panels on rear wall',
        colorArgb: 0xFF5BD68A, // kelp
        cadence: Cadence.once,
        dueDate: ymd(now.add(const Duration(days: 4))),
        startDate: todayStr,
        effort: 1,
        sortOrder: 10,
        createdAt: now,
        updatedAt: now,
      ),
      Work(
        id: 'work-12',
        title: 'Design Liquid Glass UI Kit',
        notes: 'Complete Flutter shaders and gesture specs',
        colorArgb: 0xFF9B8CFF, // orchid
        cadence: Cadence.daily,
        weekdayMask: 127,
        startDate: '2026-08-01',
        effort: 2,
        sortOrder: 11,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  static List<ProgressEntry> getHistoricalEntries() {
    final now = DateTime.now();
    final entries = <ProgressEntry>[];
    final works = getWorks();

    // Generate 8 weeks (56 days) of past daily/weekly progress
    for (var d = 0; d < 56; d++) {
      final day = DateTime(now.year, now.month, now.day - d);
      final dayStr = ymd(day);

      for (final w in works) {
        if (w.cadence == Cadence.daily && w.isWeekdayActive(day.weekday)) {
          final percent = d == 0
              ? (w.id == 'work-1' ? 45 : (w.id == 'work-2' ? 100 : (w.id == 'work-12' ? 80 : 0)))
              : ((d * 17 + w.title.length * 13) % 5 == 0 ? 100 : ((d * 23 + w.title.length * 7) % 100));

          entries.add(ProgressEntry(
            id: 'pe_${w.id}_$dayStr',
            workId: w.id,
            periodStart: dayStr,
            percent: percent,
            updatedAt: day,
          ));
        }
      }
    }

    // Weekly works progress for past 8 weeks
    for (var w = 0; w < 8; w++) {
      final weekStart = weekStartOf(DateTime(now.year, now.month, now.day - (w * 7)));
      final weekStr = ymd(weekStart);

      for (final work in works.where((item) => item.cadence == Cadence.weekly)) {
        final percent = w == 0 ? 65 : ((w * 31 + work.title.length * 11) % 100);
        entries.add(ProgressEntry(
          id: 'pe_${work.id}_$weekStr',
          workId: work.id,
          periodStart: weekStr,
          percent: percent,
          updatedAt: weekStart,
        ));
      }
    }

    // Monthly works progress
    final curMonth = DateTime(now.year, now.month, 1);
    final prevMonth = DateTime(now.year, now.month - 1, 1);

    for (final work in works.where((item) => item.cadence == Cadence.monthly)) {
      entries.add(ProgressEntry(
        id: 'pe_${work.id}_${ymd(curMonth)}',
        workId: work.id,
        periodStart: ymd(curMonth),
        percent: 50,
        updatedAt: curMonth,
      ));
      entries.add(ProgressEntry(
        id: 'pe_${work.id}_${ymd(prevMonth)}',
        workId: work.id,
        periodStart: ymd(prevMonth),
        percent: 85,
        updatedAt: prevMonth,
      ));
    }

    return entries;
  }
}
