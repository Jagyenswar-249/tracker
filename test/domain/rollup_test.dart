import 'package:flutter_test/flutter_test.dart';
import 'package:brim/domain/period/rollup.dart';

void main() {
  group('Rollup Tests', () {
    test('returns 0.0 for empty items', () {
      expect(rollup([]), 0.0);
    });

    test('calculates unweighted average when all efforts equal 1', () {
      final items = [
        (effort: 1, percent: 50),
        (effort: 1, percent: 100),
      ];
      expect(rollup(items), 75.0);
    });

    test('calculates weighted average respecting effort weights', () {
      // Work A: effort 3, 100% -> 300
      // Work B: effort 1, 0%   -> 0
      // Total weight: 4. Rollup = 300 / 4 = 75%
      final items = [
        (effort: 3, percent: 100),
        (effort: 1, percent: 0),
      ];
      expect(rollup(items), 75.0);
    });

    test('handles 100% completion when all items done', () {
      final items = [
        (effort: 2, percent: 100),
        (effort: 3, percent: 100),
      ];
      expect(rollup(items), 100.0);
    });
  });
}
