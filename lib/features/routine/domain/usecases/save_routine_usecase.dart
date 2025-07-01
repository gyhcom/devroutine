import '../entities/routine.dart';
import '../repositories/routine_repository.dart';

class SaveRoutineUseCase {
  final RoutineRepository _repository;

  SaveRoutineUseCase(this._repository);

  Future<void> execute(Routine routine) async {
    await _repository.saveRoutine(routine);
  }
}
