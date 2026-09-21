import 'period_math.dart';

int calculateStreak({
  required Map<String, double> dailyRollups, // keyed by 'YYYY-MM-DD'
  required DateTime today,
  double threshold = 80.0,
}) {
  var streak = 0;
  var current = dateOnly(today);

  // If today has activity and meets threshold, count it
  final todayKey = ymd(current);
  final todayRollup = dailyRollups[todayKey];

  if (todayRollup != null && todayRollup >= threshold) {
    streak++;
    current = DateTime(current.year, current.month, current.day - 1);
  } else {
    // If today hasn't met the threshold yet, streak is measured from yesterday backwards
    current = DateTime(current.year, current.month, current.day - 1);
  }

  // Count consecutive successful past days
  while (true) {
    final key = ymd(current);
    final val = dailyRollups[key];
    if (val != null && val >= threshold) {
      streak++;
      current = DateTime(current.year, current.month, current.day - 1);
    } else {
      break;
    }
  }

  return streak;
}
