import 'package:flutter_test/flutter_test.dart';
import 'package:brim/data/repositories/progress_repository_impl.dart';
import 'package:brim/data/repositories/work_repository_impl.dart';
import 'package:brim/domain/entities/cadence.dart';
import 'package:brim/domain/entities/work.dart';
import 'package:brim/domain/usecases/set_progress.dart';

void main() {
  group('SetProgress Use Case Tests', () {
    test('updates entry and appends to event log in one transaction', () async {
      final now = DateTime.now();
      final work = Work(
        id: 'w-1',
        title: 'Deep Reading',
        colorArgb: 0xFF2EC4B6,
        cadence: Cadence.daily,
        startDate: '2026-09-21',
        createdAt: now,
        updatedAt: now,
      );

      final workRepo = WorkRepositoryImpl(initialWorks: [work]);
      final progressRepo = ProgressRepositoryImpl(workRepository: workRepo);
      final setProgress = SetProgress(progressRepo);

      await setProgress(
        workId: 'w-1',
        periodStart: '2026-09-21',
        percent: 60,
      );

      final entry = await progressRepo.getEntry('w-1', '2026-09-21');
      expect(entry?.percent, 60);

      final events = await progressRepo.getRecentEvents();
      expect(events.length, 1);
      expect(events.first.workId, 'w-1');
      expect(events.first.fromPercent, 0);
      expect(events.first.toPercent, 60);
    });

    test('clamps percent between 0 and 100', () async {
      final now = DateTime.now();
      final work = Work(
        id: 'w-2',
        title: 'Gym',
        colorArgb: 0xFF5BD68A,
        cadence: Cadence.daily,
        startDate: '2026-09-21',
        createdAt: now,
        updatedAt: now,
      );

      final workRepo = WorkRepositoryImpl(initialWorks: [work]);
      final progressRepo = ProgressRepositoryImpl(workRepository: workRepo);
      final setProgress = SetProgress(progressRepo);

      await setProgress(
        workId: 'w-2',
        periodStart: '2026-09-21',
        percent: 150,
      );

      final entry = await progressRepo.getEntry('w-2', '2026-09-21');
      expect(entry?.percent, 100);
    });
  });
}
