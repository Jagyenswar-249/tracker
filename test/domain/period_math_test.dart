import 'package:flutter_test/flutter_test.dart';
import 'package:brim/domain/entities/cadence.dart';
import 'package:brim/domain/period/period_math.dart';

void main() {
  group('Period Math Tests', () {
    test('dateOnly drops time components', () {
      final dt = DateTime(2026, 9, 21, 14, 30, 45);
      final result = dateOnly(dt);
      expect(result.year, 2026);
      expect(result.month, 9);
      expect(result.day, 21);
      expect(result.hour, 0);
      expect(result.minute, 0);
    });

    test('ymd formatting produces YYYY-MM-DD', () {
      final dt = DateTime(2026, 9, 5);
      expect(ymd(dt), '2026-09-05');
    });

    test('weekStartOf handles Monday start', () {
      // 2026-09-21 is Monday
      final monday = DateTime(2026, 9, 21);
      expect(ymd(weekStartOf(monday, weekStart: DateTime.monday)), '2026-09-21');

      // 2026-09-25 is Friday -> week start is Monday Sep 21
      final friday = DateTime(2026, 9, 25);
      expect(ymd(weekStartOf(friday, weekStart: DateTime.monday)), '2026-09-21');

      // 2026-09-27 is Sunday -> week start is Monday Sep 21
      final sunday = DateTime(2026, 9, 27);
      expect(ymd(weekStartOf(sunday, weekStart: DateTime.monday)), '2026-09-21');
    });

    test('weekStartOf handles Sunday start', () {
      // 2026-09-21 is Monday -> with Sunday start, week start is Sep 20
      final monday = DateTime(2026, 9, 21);
      expect(ymd(weekStartOf(monday, weekStart: DateTime.sunday)), '2026-09-20');
    });

    test('periodStartFor returns accurate start for all cadences', () {
      final anchor = DateTime(2026, 9, 21);

      expect(ymd(periodStartFor(Cadence.daily, anchor)), '2026-09-21');
      expect(ymd(periodStartFor(Cadence.weekly, anchor)), '2026-09-21');
      expect(ymd(periodStartFor(Cadence.monthly, anchor)), '2026-09-01');

      final workStart = DateTime(2026, 8, 15);
      expect(
        ymd(periodStartFor(Cadence.once, anchor, workStart: workStart)),
        '2026-08-15',
      );
    });

    test('shiftPeriod advances and regresses periods properly', () {
      final anchor = DateTime(2026, 9, 21);

      // Daily shift
      expect(ymd(shiftPeriod(Cadence.daily, anchor, 1)), '2026-09-22');
      expect(ymd(shiftPeriod(Cadence.daily, anchor, -1)), '2026-09-20');

      // Weekly shift (7 days)
      expect(ymd(shiftPeriod(Cadence.weekly, anchor, 1)), '2026-09-28');
      expect(ymd(shiftPeriod(Cadence.weekly, anchor, -1)), '2026-09-14');

      // Monthly shift
      expect(ymd(shiftPeriod(Cadence.monthly, anchor, 1)), '2026-10-01');
      expect(ymd(shiftPeriod(Cadence.monthly, anchor, -1)), '2026-08-01');
    });

    test('Leap year and month rollover calculations', () {
      // Leap year Feb 29, 2028
      final feb29 = DateTime(2028, 2, 29);
      expect(ymd(shiftPeriod(Cadence.daily, feb29, 1)), '2028-03-01');
      expect(ymd(shiftPeriod(Cadence.daily, feb29, -1)), '2028-02-28');

      // Year rollover Dec 31 -> Jan 1
      final dec31 = DateTime(2026, 12, 31);
      expect(ymd(shiftPeriod(Cadence.daily, dec31, 1)), '2027-01-01');
    });
  });
}
