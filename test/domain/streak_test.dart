import 'package:flutter_test/flutter_test.dart';
import 'package:brim/domain/period/streak.dart';

void main() {
  group('Streak Calculation Tests', () {
    test('calculates consecutive successful days ending today', () {
      final today = DateTime(2026, 9, 21);
      final dailyRollups = {
        '2026-09-21': 85.0, // today meets 80% threshold
        '2026-09-20': 100.0,
        '2026-09-19': 80.0,
        '2026-09-18': 90.0,
        '2026-09-17': 40.0, // break
        '2026-09-16': 100.0,
      };

      final streak = calculateStreak(
        dailyRollups: dailyRollups,
        today: today,
        threshold: 80.0,
      );

      expect(streak, 4); // 21, 20, 19, 18
    });

    test('today in progress does not break streak from yesterday', () {
      final today = DateTime(2026, 9, 21);
      final dailyRollups = {
        '2026-09-21': 30.0, // today still in progress (<80%)
        '2026-09-20': 90.0,
        '2026-09-19': 100.0,
        '2026-09-18': 85.0,
      };

      final streak = calculateStreak(
        dailyRollups: dailyRollups,
        today: today,
        threshold: 80.0,
      );

      expect(streak, 3); // 20, 19, 18
    });

    test('returns 0 when yesterday failed and today has not succeeded', () {
      final today = DateTime(2026, 9, 21);
      final dailyRollups = {
        '2026-09-21': 20.0,
        '2026-09-20': 50.0,
      };

      final streak = calculateStreak(
        dailyRollups: dailyRollups,
        today: today,
        threshold: 80.0,
      );

      expect(streak, 0);
    });
  });
}
