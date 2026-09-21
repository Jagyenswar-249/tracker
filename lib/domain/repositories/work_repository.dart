import '../entities/cadence.dart';
import '../entities/work.dart';

abstract class WorkRepository {
  Stream<List<Work>> watchAllWorks();
  Stream<List<Work>> watchActiveWorks();
  Future<Work?> getWorkById(String id);
  Future<void> createWork(Work work);
  Future<void> updateWork(Work work);
  Future<void> archiveWork(String id);
  Future<void> unarchiveWork(String id);
  Future<void> deleteWork(String id); // soft delete
  Future<List<Work>> getWorksForPeriod({
    required Cadence view,
    required String periodStart,
    required String periodEnd,
    required DateTime anchorDate,
  });
}
