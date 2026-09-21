import '../entities/work.dart';
import '../repositories/work_repository.dart';

class CreateWork {
  final WorkRepository _workRepository;

  const CreateWork(this._workRepository);

  Future<void> call(Work work) async {
    await _workRepository.createWork(work);
  }
}

class UpdateWork {
  final WorkRepository _workRepository;

  const UpdateWork(this._workRepository);

  Future<void> call(Work work) async {
    await _workRepository.updateWork(work);
  }
}

class ArchiveWork {
  final WorkRepository _workRepository;

  const ArchiveWork(this._workRepository);

  Future<void> call(String workId) async {
    await _workRepository.archiveWork(workId);
  }
}

class DeleteWork {
  final WorkRepository _workRepository;

  const DeleteWork(this._workRepository);

  Future<void> call(String workId) async {
    await _workRepository.deleteWork(workId);
  }
}
