import '../repositories/progress_repository.dart';

class SetProgress {
  final ProgressRepository _progressRepository;

  const SetProgress(this._progressRepository);

  Future<void> call({
    required String workId,
    required String periodStart,
    required int percent,
  }) async {
    final clamped = percent.clamp(0, 100);
    await _progressRepository.setProgress(
      workId: workId,
      periodStart: periodStart,
      percent: clamped,
    );
  }
}
