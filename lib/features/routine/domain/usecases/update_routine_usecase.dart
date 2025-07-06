import '../entities/routine.dart';
import '../repositories/routine_repository.dart';
import '../models/result.dart';
import '../models/failure.dart';

class UpdateRoutineUseCase {
  final RoutineRepository _repository;

  UpdateRoutineUseCase(this._repository);

  Future<Result<void>> execute(Routine routine) async {
    try {
      await _repository.updateRoutine(routine);
      return const Success(null);
    } catch (e) {
      return ResultFailure(Failure.storage(e.toString()));
    }
  }
}
