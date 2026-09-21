import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/cadence.dart';
import '../../domain/entities/work.dart';
import '../../domain/period/period_math.dart';
import '../../domain/repositories/work_repository.dart';

class WorkRepositoryImpl implements WorkRepository {
  final Map<String, Work> _works = {};
  final _worksController = StreamController<List<Work>>.broadcast();
  static const String _storageKey = 'brim_works_data';

  WorkRepositoryImpl({List<Work>? initialWorks}) {
    if (initialWorks != null && initialWorks.isNotEmpty) {
      for (final w in initialWorks) {
        _works[w.id] = w;
      }
    }
    _initFromStorage();
  }

  Future<void> _initFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final item in list) {
          final w = Work.fromJson(item as Map<String, dynamic>);
          _works[w.id] = w;
        }
      }
    } catch (_) {}
    _notify();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _works.values.map((w) => w.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (_) {}
  }

  void _notify() {
    _worksController.add(_works.values.where((w) => !w.isDeleted).toList());
  }

  @override
  Stream<List<Work>> watchAllWorks() {
    return _worksController.stream;
  }

  @override
  Stream<List<Work>> watchActiveWorks() {
    return _worksController.stream.map(
      (list) => list.where((w) => !w.isArchived && !w.isDeleted).toList(),
    );
  }

  @override
  Future<Work?> getWorkById(String id) async {
    final work = _works[id];
    if (work == null || work.isDeleted) return null;
    return work;
  }

  @override
  Future<void> createWork(Work work) async {
    final newId = work.id.isEmpty ? const Uuid().v4() : work.id;
    final now = DateTime.now();
    final newWork = work.copyWith(
      id: newId,
      startDate: work.startDate.isEmpty ? ymd(now) : work.startDate,
      createdAt: now,
      updatedAt: now,
    );
    _works[newWork.id] = newWork;
    await _persist();
    _notify();
  }

  @override
  Future<void> updateWork(Work work) async {
    _works[work.id] = work.copyWith(updatedAt: DateTime.now());
    await _persist();
    _notify();
  }

  @override
  Future<void> archiveWork(String id) async {
    final w = _works[id];
    if (w != null) {
      _works[id] = w.copyWith(
        archivedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _persist();
      _notify();
    }
  }

  @override
  Future<void> unarchiveWork(String id) async {
    final w = _works[id];
    if (w != null) {
      _works[id] = w.copyWith(
        archivedAt: null,
        updatedAt: DateTime.now(),
      );
      await _persist();
      _notify();
    }
  }

  @override
  Future<void> deleteWork(String id) async {
    final w = _works[id];
    if (w != null) {
      _works[id] = w.copyWith(
        deletedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _persist();
      _notify();
    }
  }

  @override
  Future<List<Work>> getWorksForPeriod({
    required Cadence view,
    required String periodStart,
    required String periodEnd,
    required DateTime anchorDate,
  }) async {
    final anchorWeekday = anchorDate.weekday; // 1 (Mon) .. 7 (Sun)
    final todayStr = ymd(DateTime.now());

    final activeWorks = _works.values.where((w) {
      if (w.isDeleted || w.isArchived) return false;
      if (w.startDate.compareTo(periodEnd) > 0) return false;

      // Cadence filtering rule:
      if (w.cadence == view) {
        if (view == Cadence.daily) {
          // Check if weekday mask matches the anchor date's weekday
          return w.isWeekdayActive(anchorWeekday);
        }
        return true;
      }

      // One-offs due in this period
      if (w.cadence == Cadence.once && w.dueDate != null) {
        final due = w.dueDate!;
        final inRange = due.compareTo(periodStart) >= 0 && due.compareTo(periodEnd) <= 0;
        if (inRange) return true;

        // Overdue one-offs stay visible in today's daily view
        if (view == Cadence.daily &&
            periodStart == todayStr &&
            due.compareTo(todayStr) < 0) {
          return true;
        }
      }

      return false;
    }).toList();

    activeWorks.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return activeWorks;
  }
}
