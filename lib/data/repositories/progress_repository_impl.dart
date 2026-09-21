import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../domain/entities/progress_entry.dart';
import '../../domain/entities/progress_event.dart';
import '../../domain/period/rollup.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/repositories/work_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final Map<String, ProgressEntry> _entries = {}; // key: "workId_periodStart"
  final List<ProgressEvent> _events = [];
  final WorkRepository _workRepository;
  final _entriesController = StreamController<List<ProgressEntry>>.broadcast();

  ProgressRepositoryImpl({
    required WorkRepository workRepository,
    List<ProgressEntry>? initialEntries,
    List<ProgressEvent>? initialEvents,
  }) : _workRepository = workRepository {
    if (initialEntries != null) {
      for (final e in initialEntries) {
        _entries['${e.workId}_${e.periodStart}'] = e;
      }
    }
    if (initialEvents != null) {
      _events.addAll(initialEvents);
    }
  }

  @override
  Stream<List<ProgressEntry>> watchEntriesForPeriod(String periodStart) {
    return _entriesController.stream.map(
      (list) => list.where((e) => e.periodStart == periodStart).toList(),
    );
  }

  @override
  Future<ProgressEntry?> getEntry(String workId, String periodStart) async {
    return _entries['${workId}_$periodStart'];
  }

  @override
  Future<Map<String, int>> getPercentsForWorks(
      List<String> workIds, String periodStart) async {
    final result = <String, int>{};
    for (final id in workIds) {
      final entry = _entries['${id}_$periodStart'];
      result[id] = entry?.percent ?? 0;
    }
    return result;
  }

  @override
  Future<void> setProgress({
    required String workId,
    required String periodStart,
    required int percent,
  }) async {
    final key = '${workId}_$periodStart';
    final oldEntry = _entries[key];
    final fromPercent = oldEntry?.percent ?? 0;

    final entry = ProgressEntry(
      id: oldEntry?.id ?? const Uuid().v4(),
      workId: workId,
      periodStart: periodStart,
      percent: percent.clamp(0, 100),
      updatedAt: DateTime.now(),
    );

    _entries[key] = entry;

    // Append event to append-only log
    final event = ProgressEvent(
      id: const Uuid().v4(),
      workId: workId,
      periodStart: periodStart,
      fromPercent: fromPercent,
      toPercent: percent,
      at: DateTime.now(),
    );
    _events.add(event);

    _entriesController.add(_entries.values.toList());
  }

  @override
  Future<List<ProgressEvent>> getRecentEvents({int limit = 50}) async {
    final sorted = List<ProgressEvent>.from(_events)
      ..sort((a, b) => b.at.compareTo(a.at));
    return sorted.take(limit).toList();
  }

  @override
  Future<Map<String, double>> getDailyRollups({
    required String fromDate,
    required String toDate,
  }) async {
    final rollups = <String, double>{};

    // Find all unique daily periods in entries
    final dailyPeriodStarts = _entries.values
        .map((e) => e.periodStart)
        .where((ps) => ps.compareTo(fromDate) >= 0 && ps.compareTo(toDate) <= 0)
        .toSet();

    for (final ps in dailyPeriodStarts) {
      final entriesForDay =
          _entries.values.where((e) => e.periodStart == ps).toList();
      final items = <({int effort, int percent})>[];

      for (final e in entriesForDay) {
        final w = await _workRepository.getWorkById(e.workId);
        if (w != null) {
          items.add((effort: w.effort, percent: e.percent));
        }
      }

      if (items.isNotEmpty) {
        rollups[ps] = rollup(items);
      }
    }

    return rollups;
  }

  @override
  Future<List<ProgressEntry>> getHistoryForWork(String workId,
      {int limit = 14}) async {
    final entries = _entries.values
        .where((e) => e.workId == workId)
        .toList()
      ..sort((a, b) => b.periodStart.compareTo(a.periodStart));
    return entries.take(limit).toList();
  }
}
