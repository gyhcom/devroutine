import '../entities/routine.dart';
import '../models/result.dart';

abstract class RoutineRepository {
  Future<Result<List<Routine>>> getRoutines();
  Future<Result<Routine?>> getRoutineById(String id);
  Future<Result<void>> saveRoutine(Routine routine);
  Future<Result<void>> updateRoutine(Routine routine);
  Future<Result<void>> deleteRoutine(String id);
  Future<Result<List<Routine>>> getActiveRoutines();
  Future<Result<List<Routine>>> getRoutinesByCategory(String category);
  Future<Result<List<Routine>>> searchRoutines(String query);
}
