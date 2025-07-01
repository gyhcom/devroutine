import 'package:hive/hive.dart';
import '../models/routine_model.dart';
import '../../domain/models/result.dart';
import '../../domain/models/failure.dart';

abstract class RoutineLocalDataSource {
  Future<Result<List<RoutineModel>>> getRoutines();
  Future<Result<RoutineModel?>> getRoutineById(String id);
  Future<Result<void>> saveRoutine(RoutineModel routine);
  Future<Result<void>> updateRoutine(RoutineModel routine);
  Future<Result<void>> deleteRoutine(String id);
  Future<Result<List<RoutineModel>>> getActiveRoutines();
  Future<Result<List<RoutineModel>>> getRoutinesByCategory(String category);
  Future<Result<List<RoutineModel>>> searchRoutines(String query);
}

class HiveRoutineLocalDataSource implements RoutineLocalDataSource {
  final Box<RoutineModel> _box;
  static const String _boxName = 'routines';

  HiveRoutineLocalDataSource(this._box);

  static Future<HiveRoutineLocalDataSource> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RoutineModelAdapter());
    }
    final box = await Hive.openBox<RoutineModel>(_boxName);
    return HiveRoutineLocalDataSource(box);
  }

  @override
  Future<Result<List<RoutineModel>>> getRoutines() async {
    try {
      final routines = _box.values.toList();
      return Success(routines);
    } catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<RoutineModel?>> getRoutineById(String id) async {
    try {
      final routine = _box.get(id);
      return Success(routine);
    } catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> saveRoutine(RoutineModel routine) async {
    try {
      await _box.put(routine.id, routine);
      return const Success(null);
    } catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateRoutine(RoutineModel routine) async {
    try {
      await _box.put(routine.id, routine);
      return const Success(null);
    } catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteRoutine(String id) async {
    try {
      await _box.delete(id);
      return const Success(null);
    } catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<RoutineModel>>> getActiveRoutines() async {
    try {
      final routines =
          _box.values.where((routine) => routine.isActive).toList();
      return Success(routines);
    } catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<RoutineModel>>> getRoutinesByCategory(
      String category) async {
    try {
      final routines =
          _box.values.where((routine) => routine.category == category).toList();
      return Success(routines);
    } catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<RoutineModel>>> searchRoutines(String query) async {
    try {
      final lowercaseQuery = query.toLowerCase();
      final routines = _box.values.where((routine) {
        return routine.title.toLowerCase().contains(lowercaseQuery) ||
            (routine.memo?.toLowerCase().contains(lowercaseQuery) ?? false) ||
            routine.tags
                .any((tag) => tag.toLowerCase().contains(lowercaseQuery));
      }).toList();
      return Success(routines);
    } catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }
}
