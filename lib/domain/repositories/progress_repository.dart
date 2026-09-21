import '../entities/progress_entry.dart';
import '../entities/progress_event.dart';

abstract class ProgressRepository {
  Stream<List<ProgressEntry>> watchEntriesForPeriod(String periodStart);
  Future<ProgressEntry?> getEntry(String workId, String periodStart);
  Future<Map<String, int>> getPercentsForWorks(
      List<String> workIds, String periodStart);
  Future<void> setProgress({
    required String workId,
    required String periodStart,
    required int percent,
  });
  Future<List<ProgressEvent>> getRecentEvents({int limit = 50});
  Future<Map<String, double>> getDailyRollups(
      {required String fromDate, required String toDate});
  Future<List<ProgressEntry>> getHistoryForWork(String workId, {int limit = 14});
}
