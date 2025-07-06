import '../repositories/routine_repository.dart';
import '../models/result.dart';
import '../models/failure.dart';

class DeleteRoutineUseCase {
  final RoutineRepository _repository;

  DeleteRoutineUseCase(this._repository);

  Future<Result<void>> execute(String id) async {
    try {
      await _repository.deleteRoutine(id);
      return const Success(null);
    } catch (e) {
      return ResultFailure(Failure.storage(e.toString()));
    }
  }
}
