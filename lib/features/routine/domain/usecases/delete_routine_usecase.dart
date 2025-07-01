import '../repositories/routine_repository.dart';

class DeleteRoutineUseCase {
  final RoutineRepository _repository;

  DeleteRoutineUseCase(this._repository);

  Future<void> execute(String id) async {
    await _repository.deleteRoutine(id);
  }
}
