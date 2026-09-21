import '../entities/cadence.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseYmd(String s) {
  final parts = s.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

DateTime weekStartOf(DateTime d, {int weekStart = DateTime.monday}) {
  final day = dateOnly(d);
  final back = (day.weekday - weekStart + 7) % 7;
  return DateTime(day.year, day.month, day.day - back);
}

DateTime periodStartFor(
  Cadence c,
  DateTime anchor, {
  int weekStart = DateTime.monday,
  DateTime? workStart,
}) {
  final d = dateOnly(anchor);
  switch (c) {
    case Cadence.daily:
      return d;
    case Cadence.weekly:
      return weekStartOf(d, weekStart: weekStart);
    case Cadence.monthly:
      return DateTime(d.year, d.month, 1);
    case Cadence.once:
      return workStart != null ? dateOnly(workStart) : d;
  }
}

DateTime shiftPeriod(Cadence c, DateTime start, int delta) {
  final d = dateOnly(start);
  switch (c) {
    case Cadence.daily:
      return DateTime(d.year, d.month, d.day + delta);
    case Cadence.weekly:
      return DateTime(d.year, d.month, d.day + 7 * delta);
    case Cadence.monthly:
      return DateTime(d.year, d.month + delta, 1);
    case Cadence.once:
      return d;
  }
}

DateTime periodEndFor(
  Cadence c,
  DateTime start, {
  int weekStart = DateTime.monday,
}) {
  final s = dateOnly(start);
  switch (c) {
    case Cadence.daily:
      return s;
    case Cadence.weekly:
      return DateTime(s.year, s.month, s.day + 6);
    case Cadence.monthly:
      // Last day of month is Day 0 of next month
      return DateTime(s.year, s.month + 1, 0);
    case Cadence.once:
      return s;
  }
}
