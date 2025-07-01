import '../../domain/entities/routine.dart';
import '../../domain/models/result.dart';
import '../../domain/repositories/routine_repository.dart';
import '../datasources/routine_local_datasource.dart';
import '../models/routine_model.dart';

class RoutineRepositoryImpl implements RoutineRepository {
  final RoutineLocalDataSource _localDataSource;

  RoutineRepositoryImpl(this._localDataSource);

  @override
  Future<Result<List<Routine>>> getRoutines() async {
    final result = await _localDataSource.getRoutines();
    return result.map(
      success: (routines) => Success(
        routines.map((model) => model.toEntity()).toList(),
      ),
      failure: (failure) => ResultFailure(failure),
    );
  }

  @override
  Future<Result<Routine?>> getRoutineById(String id) async {
    final result = await _localDataSource.getRoutineById(id);
    return result.map(
      success: (routine) => Success(routine?.toEntity()),
      failure: (failure) => ResultFailure(failure),
    );
  }

  @override
  Future<Result<void>> saveRoutine(Routine routine) async {
    return await _localDataSource.saveRoutine(RoutineModel.fromEntity(routine));
  }

  @override
  Future<Result<void>> updateRoutine(Routine routine) async {
    return await _localDataSource
        .updateRoutine(RoutineModel.fromEntity(routine));
  }

  @override
  Future<Result<void>> deleteRoutine(String id) async {
    return await _localDataSource.deleteRoutine(id);
  }

  @override
  Future<Result<List<Routine>>> getActiveRoutines() async {
    final result = await _localDataSource.getActiveRoutines();
    return result.map(
      success: (routines) => Success(
        routines.map((model) => model.toEntity()).toList(),
      ),
      failure: (failure) => ResultFailure(failure),
    );
  }

  @override
  Future<Result<List<Routine>>> getRoutinesByCategory(String category) async {
    final result = await _localDataSource.getRoutinesByCategory(category);
    return result.map(
      success: (routines) => Success(
        routines.map((model) => model.toEntity()).toList(),
      ),
      failure: (failure) => ResultFailure(failure),
    );
  }

  @override
  Future<Result<List<Routine>>> searchRoutines(String query) async {
    final result = await _localDataSource.searchRoutines(query);
    return result.map(
      success: (routines) => Success(
        routines.map((model) => model.toEntity()).toList(),
      ),
      failure: (failure) => ResultFailure(failure),
    );
  }
}
