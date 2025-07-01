import '../entities/routine.dart';
import '../repositories/routine_repository.dart';

class UpdateRoutineUseCase {
  final RoutineRepository _repository;

  UpdateRoutineUseCase(this._repository);

  Future<void> execute(Routine routine) async {
    await _repository.updateRoutine(routine);
  }
}
