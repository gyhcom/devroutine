import '../entities/routine.dart';
import '../models/result.dart';
import '../repositories/routine_repository.dart';

class GetRoutinesUseCase {
  final RoutineRepository _repository;

  GetRoutinesUseCase(this._repository);

  Future<Result<List<Routine>>> execute() async {
    return await _repository.getRoutines();
  }
}
