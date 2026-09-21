import 'package:flutter/foundation.dart';
import '../../domain/entities/cadence.dart';
import '../../domain/entities/period_snapshot.dart';
import '../../domain/period/period_math.dart';
import '../../domain/usecases/set_progress.dart';
import '../../domain/usecases/watch_period_snapshot.dart';
import '../../domain/usecases/work_usecases.dart';

class TasksController extends ChangeNotifier {
  final WatchPeriodSnapshot _watchPeriodSnapshot;
  final SetProgress _setProgress;
  final ArchiveWork _archiveWork;
  final DeleteWork _deleteWork;

  Cadence _view = Cadence.daily;
  DateTime _anchorDate = DateTime.now();
  PeriodSnapshot? _snapshot;
  bool _isLoading = true;
  String? _error;

  TasksController({
    required WatchPeriodSnapshot watchPeriodSnapshot,
    required SetProgress setProgress,
    required ArchiveWork archiveWork,
    required DeleteWork deleteWork,
  })  : _watchPeriodSnapshot = watchPeriodSnapshot,
        _setProgress = setProgress,
        _archiveWork = archiveWork,
        _deleteWork = deleteWork {
    load();
  }

  Cadence get view => _view;
  DateTime get anchorDate => _anchorDate;
  PeriodSnapshot? get snapshot => _snapshot;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> setView(Cadence newView) async {
    if (_view == newView) return;
    _view = newView;
    _anchorDate = DateTime.now();
    notifyListeners();
    await load();
  }

  void previousPeriod() {
    _anchorDate = shiftPeriod(_view, _anchorDate, -1);
    notifyListeners();
    load();
  }

  void nextPeriod() {
    _anchorDate = shiftPeriod(_view, _anchorDate, 1);
    notifyListeners();
    load();
  }

  void jumpToCurrent() {
    _anchorDate = DateTime.now();
    notifyListeners();
    load();
  }

  void setAnchorDate(DateTime date, {Cadence? targetView}) {
    _anchorDate = date;
    if (targetView != null) {
      _view = targetView;
    }
    notifyListeners();
    load();
  }

  Future<void> updateProgress(String workId, int percent) async {
    if (_snapshot == null) return;
    final periodStart = _snapshot!.periodStart;
    await _setProgress(
      workId: workId,
      periodStart: periodStart,
      percent: percent,
    );
    await load();
  }

  Future<void> archive(String workId) async {
    await _archiveWork(workId);
    await load();
  }

  Future<void> delete(String workId) async {
    await _deleteWork(workId);
    await load();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snap = await _watchPeriodSnapshot.execute(
        view: _view,
        anchorDate: _anchorDate,
      );
      _snapshot = snap;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
