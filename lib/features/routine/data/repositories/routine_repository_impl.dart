import '../../domain/entities/routine.dart';
import '../../domain/models/result.dart';
import '../../domain/repositories/routine_repository.dart';
import '../datasources/routine_local_datasource.dart';
import '../models/routine_model.dart';
import '../../domain/models/failure.dart';

class RoutineRepositoryImpl implements RoutineRepository {
  final RoutineLocalDataSource _localDataSource;

  // 자동 백업 설정
  static const int _backupInterval = 10; // 10개 작업마다 백업
  int _operationCount = 0;

  RoutineRepositoryImpl(this._localDataSource);

  Future<void> _performAutoBackup() async {
    _operationCount++;
    if (_operationCount >= _backupInterval) {
      _operationCount = 0;
      try {
        await _localDataSource.backupData();
        // print('🔄 Auto backup completed');
      } catch (e) {
        // print('⚠️ Auto backup failed: $e');
      }
    }
  }

  @override
  Future<Result<List<Routine>>> getRoutines() async {
    try {
      final result = await _localDataSource.getRoutines();
      return result.map(
        success: (routines) => Success(
          routines.map((model) => model.toEntity()).toList(),
        ),
        failure: (failure) => ResultFailure(failure),
      );
    } catch (e) {
      return ResultFailure(StorageFailure('루틴 목록을 불러오는 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<Routine?>> getRoutineById(String id) async {
    try {
      final result = await _localDataSource.getRoutineById(id);
      return result.map(
        success: (routine) => Success(routine?.toEntity()),
        failure: (failure) => ResultFailure(failure),
      );
    } catch (e) {
      return ResultFailure(StorageFailure('루틴을 불러오는 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<void>> saveRoutine(Routine routine) async {
    try {
      final model = RoutineModel.fromEntity(routine);
      final result = await _localDataSource.saveRoutine(model);

      // 자동 백업 수행
      await _performAutoBackup();

      return result;
    } catch (e) {
      return ResultFailure(StorageFailure('루틴 저장 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<void>> updateRoutine(Routine routine) async {
    try {
      final model = RoutineModel.fromEntity(routine);
      final result = await _localDataSource.updateRoutine(model);

      // 자동 백업 수행
      await _performAutoBackup();

      return result;
    } catch (e) {
      return ResultFailure(StorageFailure('루틴 수정 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<void>> deleteRoutine(String id) async {
    try {
      final result = await _localDataSource.deleteRoutine(id);

      // 자동 백업 수행
      await _performAutoBackup();

      return result;
    } catch (e) {
      return ResultFailure(StorageFailure('루틴 삭제 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<List<Routine>>> getActiveRoutines() async {
    try {
      final result = await _localDataSource.getActiveRoutines();
      return result.map(
        success: (routines) => Success(
          routines.map((model) => model.toEntity()).toList(),
        ),
        failure: (failure) => ResultFailure(failure),
      );
    } catch (e) {
      return ResultFailure(StorageFailure('활성 루틴 목록을 불러오는 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<List<Routine>>> getRoutinesByCategory(String category) async {
    try {
      final result = await _localDataSource.getRoutinesByCategory(category);
      return result.map(
        success: (routines) => Success(
          routines.map((model) => model.toEntity()).toList(),
        ),
        failure: (failure) => ResultFailure(failure),
      );
    } catch (e) {
      return ResultFailure(
          StorageFailure('카테고리별 루틴 목록을 불러오는 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<List<Routine>>> searchRoutines(String query) async {
    try {
      final result = await _localDataSource.searchRoutines(query);
      return result.map(
        success: (routines) => Success(
          routines.map((model) => model.toEntity()).toList(),
        ),
        failure: (failure) => ResultFailure(failure),
      );
    } catch (e) {
      return ResultFailure(StorageFailure('루틴 검색 중 오류가 발생했습니다: $e'));
    }
  }

  // 수동 백업 메서드
  Future<Result<void>> backupData() async {
    try {
      return await _localDataSource.backupData();
    } catch (e) {
      return ResultFailure(StorageFailure('데이터 백업 중 오류가 발생했습니다: $e'));
    }
  }

  // 데이터 복원 메서드
  Future<Result<void>> restoreData() async {
    try {
      return await _localDataSource.restoreData();
    } catch (e) {
      return ResultFailure(StorageFailure('데이터 복원 중 오류가 발생했습니다: $e'));
    }
  }
}
