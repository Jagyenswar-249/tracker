import 'dart:convert';
import '../../domain/entities/work.dart';
import '../../domain/repositories/work_repository.dart';
import '../../domain/repositories/progress_repository.dart';

class ExportService {
  final WorkRepository _workRepository;
  final ProgressRepository _progressRepository;

  ExportService(this._workRepository, this._progressRepository);

  Future<String> exportToJson() async {
    final works = await _workRepository.watchAllWorks().first;
    final events = await _progressRepository.getRecentEvents(limit: 1000);

    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'works': works.map((w) => w.toJson()).toList(),
      'events': events.map((e) => e.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<bool> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final worksJson = data['works'] as List<dynamic>? ?? [];

      for (final w in worksJson) {
        final work = Work.fromJson(w as Map<String, dynamic>);
        await _workRepository.createWork(work);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
