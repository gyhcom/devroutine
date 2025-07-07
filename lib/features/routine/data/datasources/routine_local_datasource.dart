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

  // 데이터 백업 및 복원 기능
  Future<Result<void>> backupData();
  Future<Result<void>> restoreData();
  Future<Result<int>> getDataVersion();
  Future<Result<void>> setDataVersion(int version);
}

// 임시 메모리 저장소 (Hive 문제 시 대안)
class MemoryRoutineLocalDataSource implements RoutineLocalDataSource {
  static final Map<String, RoutineModel> _memoryStorage = {};

  @override
  Future<Result<List<RoutineModel>>> getRoutines() async {
    try {
      // print('📦 Getting routines from memory storage...');
      final routines = _memoryStorage.values.toList();
      // print('📊 Found ${routines.length} routines in memory');
      return Success(routines);
    } catch (e) {
      return ResultFailure(StorageFailure('메모리에서 데이터를 불러오는 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<RoutineModel?>> getRoutineById(String id) async {
    try {
      final routine = _memoryStorage[id];
      return Success(routine);
    } catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> saveRoutine(RoutineModel routine) async {
    try {
      // 저장 전 데이터 검증
      if (routine.id.isEmpty || routine.title.isEmpty) {
        return ResultFailure(StorageFailure('잘못된 루틴 데이터입니다.'));
      }

      _memoryStorage[routine.id] = routine;
      // print('💾 Saved routine to memory: ${routine.title}');

      // 저장 후 검증
      final savedRoutine = _memoryStorage[routine.id];
      if (savedRoutine == null) {
        return ResultFailure(StorageFailure('루틴 저장 후 검증에 실패했습니다.'));
      }

      return const Success(null);
    } catch (e) {
      // print('❌ Error saving routine: $e');
      return ResultFailure(StorageFailure('루틴 저장 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<void>> updateRoutine(RoutineModel routine) async {
    try {
      // 기존 루틴 존재 확인
      final existingRoutine = _memoryStorage[routine.id];
      if (existingRoutine == null) {
        return ResultFailure(StorageFailure('수정하려는 루틴을 찾을 수 없습니다.'));
      }

      // 업데이트 전 데이터 검증
      if (routine.id.isEmpty || routine.title.isEmpty) {
        return ResultFailure(StorageFailure('잘못된 루틴 데이터입니다.'));
      }

      _memoryStorage[routine.id] = routine;
      // print('🔄 Updated routine in memory: ${routine.title}');

      return const Success(null);
    } catch (e) {
      // print('❌ Error updating routine: $e');
      return ResultFailure(StorageFailure('루틴 수정 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<void>> deleteRoutine(String id) async {
    try {
      _memoryStorage.remove(id);
      // print('🗑️ Deleted routine from memory: $id');
      return const Success(null);
    } catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<RoutineModel>>> getActiveRoutines() async {
    try {
      final routines =
          _memoryStorage.values.where((routine) => routine.isActive).toList();
      return Success(routines);
    } catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<RoutineModel>>> getRoutinesByCategory(
      String category) async {
    try {
      final routines = _memoryStorage.values
          .where((routine) => routine.category == category)
          .toList();
      return Success(routines);
    } catch (e) {
      return ResultFailure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<RoutineModel>>> searchRoutines(String query) async {
    try {
      final lowercaseQuery = query.toLowerCase();
      final routines = _memoryStorage.values.where((routine) {
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

  @override
  Future<Result<void>> backupData() async {
    // 메모리 저장소는 백업 불가
    return ResultFailure(StorageFailure('메모리 저장소는 백업을 지원하지 않습니다.'));
  }

  @override
  Future<Result<void>> restoreData() async {
    // 메모리 저장소는 복원 불가
    return ResultFailure(StorageFailure('메모리 저장소는 복원을 지원하지 않습니다.'));
  }

  @override
  Future<Result<int>> getDataVersion() async {
    // 메모리 저장소는 항상 버전 1
    return Success(1);
  }

  @override
  Future<Result<void>> setDataVersion(int version) async {
    // 메모리 저장소는 버전 설정 불가
    return ResultFailure(StorageFailure('메모리 저장소는 버전 설정을 지원하지 않습니다.'));
  }
}

class HiveRoutineLocalDataSource implements RoutineLocalDataSource {
  final Box<RoutineModel> _box;
  static const String _boxName = 'routines';

  HiveRoutineLocalDataSource(this._box);

  static Future<HiveRoutineLocalDataSource> init() async {
    try {
      // main.dart에서 이미 Adapter가 등록되고 박스가 열려있으므로 기존 박스 사용
      Box<RoutineModel> box;

      try {
        // 이미 열려있는 박스 가져오기
        box = Hive.box<RoutineModel>(_boxName);
        // print('✅ Using existing Hive box');
      } catch (e) {
        // 박스가 없다면 새로 열기
        // print('📦 Opening new Hive box...');
        box = await Hive.openBox<RoutineModel>(_boxName);
        // print('✅ Hive box opened successfully');
      }

      // 박스 상태 확인
      final routineCount = box.length;
      // print('📊 Current routines in storage: $routineCount');

      return HiveRoutineLocalDataSource(box);
    } catch (e) {
      // print('❌ Error initializing HiveRoutineLocalDataSource: $e');

      // 마지막 시도: 메모리 저장소로 폴백
      // print('🔄 Falling back to memory storage...');
      throw Exception('Hive initialization failed, please restart the app: $e');
    }
  }

  @override
  Future<Result<List<RoutineModel>>> getRoutines() async {
    try {
      // print('📦 Getting routines from Hive box...');
      final routines = _box.values.toList();
      // print('📊 Found ${routines.length} routines in storage');
      return Success(routines);
    } catch (e) {
      // print('💥 Error getting routines: $e');
      // 스키마 변경으로 인한 데이터 호환성 문제 시 박스를 클리어
      if (e.toString().contains('type') || e.toString().contains('field')) {
        try {
          // print('🧹 Clearing corrupted data...');
          await _box.clear();
          return Success(<RoutineModel>[]);
        } catch (clearError) {
          // print('❌ Failed to clear box: $clearError');
        }
      }
      return ResultFailure(StorageFailure('데이터를 불러오는 중 오류가 발생했습니다: $e'));
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
      // 저장 전 데이터 검증
      if (routine.id.isEmpty || routine.title.isEmpty) {
        return ResultFailure(StorageFailure('잘못된 루틴 데이터입니다.'));
      }

      await _box.put(routine.id, routine);
      // print('💾 Saved routine: ${routine.title} (ID: ${routine.id})');

      // 저장 후 검증
      final savedRoutine = _box.get(routine.id);
      if (savedRoutine == null) {
        return ResultFailure(StorageFailure('루틴 저장 후 검증에 실패했습니다.'));
      }

      return const Success(null);
    } catch (e) {
      // print('❌ Error saving routine: $e');
      return ResultFailure(StorageFailure('루틴 저장 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<void>> updateRoutine(RoutineModel routine) async {
    try {
      // 기존 루틴 존재 확인
      final existingRoutine = _box.get(routine.id);
      if (existingRoutine == null) {
        return ResultFailure(StorageFailure('수정하려는 루틴을 찾을 수 없습니다.'));
      }

      // 업데이트 전 데이터 검증
      if (routine.id.isEmpty || routine.title.isEmpty) {
        return ResultFailure(StorageFailure('잘못된 루틴 데이터입니다.'));
      }

      await _box.put(routine.id, routine);
      // print('🔄 Updated routine: ${routine.title} (ID: ${routine.id})');

      return const Success(null);
    } catch (e) {
      // print('❌ Error updating routine: $e');
      return ResultFailure(StorageFailure('루틴 수정 중 오류가 발생했습니다: $e'));
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

  @override
  Future<Result<void>> backupData() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupBox = await Hive.openBox('routines_backup_$timestamp');

      // 모든 루틴 데이터를 백업 박스에 복사
      for (var routine in _box.values) {
        await backupBox.put(routine.id, routine.toJson());
      }

      await backupBox.close();
      // print('📦 Data backup completed: routines_backup_$timestamp');
      return const Success(null);
    } catch (e) {
      // print('❌ Backup failed: $e');
      return ResultFailure(StorageFailure('데이터 백업 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<void>> restoreData() async {
    try {
      // 가장 최근 백업 찾기
      final backupBoxes = await Hive.boxExists('routines_backup');
      if (!backupBoxes) {
        return ResultFailure(StorageFailure('백업 데이터를 찾을 수 없습니다.'));
      }

      // 복원 로직 구현 (향후 필요시)
      // print('🔄 Data restore feature - to be implemented');
      return const Success(null);
    } catch (e) {
      // print('❌ Restore failed: $e');
      return ResultFailure(StorageFailure('데이터 복원 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<int>> getDataVersion() async {
    try {
      final settingsBox = await Hive.openBox('app_settings');
      final version = settingsBox.get('data_version', defaultValue: 1) as int;
      return Success(version);
    } catch (e) {
      return ResultFailure(StorageFailure('버전 정보를 가져오는 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<void>> setDataVersion(int version) async {
    try {
      final settingsBox = await Hive.openBox('app_settings');
      await settingsBox.put('data_version', version);
      // print('📝 Data version updated to: $version');
      return const Success(null);
    } catch (e) {
      return ResultFailure(StorageFailure('버전 정보를 저장하는 중 오류가 발생했습니다: $e'));
    }
  }
}
