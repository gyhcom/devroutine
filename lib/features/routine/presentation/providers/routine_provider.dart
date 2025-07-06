import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/routine_local_datasource.dart';
import '../../data/models/routine_model.dart';
import '../../data/repositories/routine_repository_impl.dart';
import '../../domain/entities/routine.dart';
import '../../domain/models/result.dart';
import '../../domain/models/routine_state.dart';
import '../../domain/repositories/routine_repository.dart';
import '../../domain/usecases/get_routines_usecase.dart';
import '../../domain/usecases/save_routine_usecase.dart';
import '../../domain/usecases/update_routine_usecase.dart';
import '../../domain/usecases/delete_routine_usecase.dart';

part 'routine_provider.g.dart';

@riverpod
RoutineRepository routineRepository(RoutineRepositoryRef ref) {
  try {
    // main.dart에서 이미 열린 박스를 사용
    final box = Hive.box<RoutineModel>('routines');
    final localDataSource = HiveRoutineLocalDataSource(box);
    return RoutineRepositoryImpl(localDataSource);
  } catch (e) {
    print('❌ Error accessing Hive box: $e');
    // Hive 접근 실패 시 임시로 메모리 저장소 사용
    print('⚠️ Falling back to memory storage');
    final memoryDataSource = MemoryRoutineLocalDataSource();
    return RoutineRepositoryImpl(memoryDataSource);
  }
}

@riverpod
class RoutineNotifier extends _$RoutineNotifier {
  late final GetRoutinesUseCase _getRoutinesUseCase;
  late final SaveRoutineUseCase _saveRoutineUseCase;
  late final UpdateRoutineUseCase _updateRoutineUseCase;
  late final DeleteRoutineUseCase _deleteRoutineUseCase;

  bool _isInitialized = false;

  List<Routine> _sortRoutinesByPriority(List<Routine> routines) {
    return List<Routine>.from(routines)
      ..sort((a, b) {
        // 우선순위로 정렬 (high -> medium -> low)
        final priorityComparison = a.priority.index.compareTo(b.priority.index);
        if (priorityComparison != 0) return -priorityComparison;

        // 우선순위가 같으면 생성일 기준 내림차순
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  // 오늘 루틴만 필터링하는 메서드
  List<Routine> getTodayRoutines(List<Routine> routines) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return routines.where((routine) {
      if (!routine.isActive) return false;

      if (routine.isThreeDayRoutine) {
        // 3일 루틴의 경우: 오늘이 해당 루틴의 수행 날짜인지 확인
        final routineDate = DateTime(
          routine.startDate.year,
          routine.startDate.month,
          routine.startDate.day,
        );
        return routineDate.isAtSameMomentAs(today);
      } else {
        // 일일 루틴의 경우: 시작일이 오늘이거나 과거이고, 종료일이 없거나 미래인 경우
        final routineStartDate = DateTime(
          routine.startDate.year,
          routine.startDate.month,
          routine.startDate.day,
        );

        // 시작일이 오늘이거나 과거여야 함
        if (routineStartDate.isAfter(today)) return false;

        // 종료일이 있다면 오늘이거나 미래여야 함
        if (routine.endDate != null) {
          final routineEndDate = DateTime(
            routine.endDate!.year,
            routine.endDate!.month,
            routine.endDate!.day,
          );
          if (routineEndDate.isBefore(today)) return false;
        }

        return true;
      }
    }).toList();
  }

  // 오늘 완료된 루틴 수를 계산하는 메서드
  int getCompletedRoutinesCount(List<Routine> routines) {
    return routines.where((routine) => routine.isCompletedToday).length;
  }

  @override
  RoutineState build() {
    try {
      final repository = ref.read(routineRepositoryProvider);

      // 한 번만 초기화 (중복 초기화 방지)
      if (!_isInitialized) {
        _getRoutinesUseCase = GetRoutinesUseCase(repository);
        _saveRoutineUseCase = SaveRoutineUseCase(repository);
        _updateRoutineUseCase = UpdateRoutineUseCase(repository);
        _deleteRoutineUseCase = DeleteRoutineUseCase(repository);
        _isInitialized = true;

        // 안전한 비동기 데이터 로드 (Hive 박스가 준비된 후)
        Future.microtask(() async {
          try {
            // 잠시 대기하여 Hive 박스가 완전히 준비되도록 함
            await Future.delayed(const Duration(milliseconds: 100));
            await _loadRoutines();
          } catch (e) {
            print('🚨 Critical error in build: $e');
            state = RoutineState.error('앱을 초기화하는 중 오류가 발생했습니다. 앱을 재시작해주세요.');
          }
        });
      }

      return const RoutineState.initial();
    } catch (e) {
      print('💥 Error in build method: $e');
      return RoutineState.error('데이터베이스 연결에 실패했습니다: $e');
    }
  }

  Future<void> _loadRoutines() async {
    try {
      print('🔄 Loading routines...');
      state = const RoutineState.loading();
      final result = await _getRoutinesUseCase.execute();
      if (result case Success(data: final routines)) {
        print('✅ Loaded ${routines.length} routines successfully');
        state = RoutineState.loaded(_sortRoutinesByPriority(routines));
      } else if (result case ResultFailure(failure: final failure)) {
        print('❌ Failed to load routines: ${failure.message}');
        state = RoutineState.error(failure.message);
      }
    } catch (e, stackTrace) {
      print('💥 Exception while loading routines: $e');
      print('Stack trace: $stackTrace');
      state = RoutineState.error('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  // 3일 루틴 완료 체크 메서드
  bool isThreeDayRoutineCompleted(String groupId, List<Routine> routines) {
    final groupRoutines = routines.where((r) => r.groupId == groupId).toList();
    if (groupRoutines.length != 3) return false;

    return groupRoutines.every((routine) => routine.isCompletedToday);
  }

  // markRoutineAsCompleted 메서드에 3일 루틴 완료 체크 추가
  Future<void> markRoutineAsCompleted(String id) async {
    state.whenOrNull(
      loaded: (routines) async {
        try {
          final index = routines.indexWhere((r) => r.id == id);
          if (index == -1) return;

          final routine = routines[index];
          if (routine.isCompletedToday) return;

          final updatedRoutine = routine.markAsCompleted();
          final updatedRoutines = List<Routine>.from(routines);
          updatedRoutines[index] = updatedRoutine;
          state = RoutineState.loaded(updatedRoutines);

          // 3일 루틴 완료 체크
          if (routine.groupId != null) {
            final isGroupCompleted =
                isThreeDayRoutineCompleted(routine.groupId!, updatedRoutines);
            if (isGroupCompleted) {
              // 🎉 3일 루틴 완료 축하 메시지
              Future.microtask(() {
                // 여기서 특별한 축하 효과 실행
                _showThreeDayCompletionCelebration();
              });
            }
          }

          // 백엔드 업데이트
          final result = await _updateRoutineUseCase.execute(updatedRoutine);

          if (result case ResultFailure(failure: final failure)) {
            // 실패 시 이전 상태로 복원
            final revertedRoutines = List<Routine>.from(routines);
            revertedRoutines[index] = routine;
            state = RoutineState.loaded(revertedRoutines);

            // 에러 메시지 표시
            Future.microtask(() {
              state = RoutineState.error(failure.message);
              Future.delayed(const Duration(seconds: 2), () {
                state = RoutineState.loaded(revertedRoutines);
              });
            });
          }
        } catch (e) {
          state = RoutineState.error(e.toString());
        }
      },
    );
  }

  void _showThreeDayCompletionCelebration() {
    // 3일 루틴 완료 시 특별한 효과
    // 예: 애니메이션, 사운드, 특별 메시지 등
  }

  // 루틴 미완료 메서드
  Future<void> markRoutineAsIncomplete(String id) async {
    state.whenOrNull(
      loaded: (routines) async {
        try {
          final index = routines.indexWhere((r) => r.id == id);
          if (index == -1) return;

          final routine = routines[index];
          if (!routine.isCompletedToday) return; // 이미 미완료 상태면 아무 동작 안함

          final updatedRoutine = routine.markAsIncomplete();

          // UI 즉시 업데이트
          final updatedRoutines = List<Routine>.from(routines);
          updatedRoutines[index] = updatedRoutine;
          state = RoutineState.loaded(updatedRoutines);

          // 백엔드 업데이트
          final result = await _updateRoutineUseCase.execute(updatedRoutine);

          if (result case ResultFailure(failure: final failure)) {
            // 실패 시 이전 상태로 복원
            final revertedRoutines = List<Routine>.from(routines);
            revertedRoutines[index] = routine;
            state = RoutineState.loaded(revertedRoutines);

            // 에러 메시지 표시
            Future.microtask(() {
              state = RoutineState.error(failure.message);
              Future.delayed(const Duration(seconds: 2), () {
                state = RoutineState.loaded(revertedRoutines);
              });
            });
          }
        } catch (e) {
          state = RoutineState.error(e.toString());
        }
      },
    );
  }

  // 루틴 완료 토글 메서드
  Future<void> toggleRoutineCompletion(String id) async {
    state.whenOrNull(
      loaded: (routines) async {
        final index = routines.indexWhere((r) => r.id == id);
        if (index == -1) return;

        final routine = routines[index];
        if (routine.isCompletedToday) {
          await markRoutineAsIncomplete(id);
        } else {
          await markRoutineAsCompleted(id);
        }
      },
    );
  }

  Future<void> createRoutine(Routine routine) async {
    state.whenOrNull(
      loaded: (routines) async {
        try {
          // 백엔드 업데이트를 먼저 시도합니다
          final result = await _saveRoutineUseCase.execute(routine);

          if (result case Success()) {
            // 성공 시 데이터를 새로고침합니다
            await refreshRoutines();
          } else if (result case ResultFailure(failure: final failure)) {
            // 실패 시 에러를 표시합니다
            state = RoutineState.error(failure.message);
            Future.delayed(const Duration(seconds: 2), () {
              state = RoutineState.loaded(routines);
            });
          }
        } catch (e) {
          // 예외 발생 시 에러를 표시합니다
          state = RoutineState.error(e.toString());
          Future.delayed(const Duration(seconds: 2), () {
            state = RoutineState.loaded(routines);
          });
        }
      },
      initial: () async {
        try {
          // 초기 상태일 경우 바로 새 루틴으로 시작합니다
          final result = await _saveRoutineUseCase.execute(routine);

          if (result case Success()) {
            // 성공 시 데이터를 새로고침합니다
            await refreshRoutines();
          } else if (result case ResultFailure(failure: final failure)) {
            state = RoutineState.error(failure.message);
            Future.delayed(const Duration(seconds: 2), () {
              state = const RoutineState.initial();
            });
          }
        } catch (e) {
          state = RoutineState.error(e.toString());
          Future.delayed(const Duration(seconds: 2), () {
            state = const RoutineState.initial();
          });
        }
      },
    );
  }

  // 3일 루틴 다중 생성 메서드
  Future<void> createThreeDayRoutines(List<Routine> routines) async {
    state.whenOrNull(
      loaded: (existingRoutines) async {
        try {
          // 모든 루틴을 순차적으로 저장합니다
          for (final routine in routines) {
            final result = await _saveRoutineUseCase.execute(routine);
            if (result case ResultFailure(failure: final failure)) {
              // 실패 시 에러를 표시합니다
              state = RoutineState.error(failure.message);
              Future.delayed(const Duration(seconds: 2), () {
                state = RoutineState.loaded(existingRoutines);
              });
              return;
            }
          }

          // 모든 루틴 저장 성공 시 데이터를 새로고침합니다
          await refreshRoutines();
        } catch (e) {
          // 예외 발생 시 에러를 표시합니다
          state = RoutineState.error(e.toString());
          Future.delayed(const Duration(seconds: 2), () {
            state = RoutineState.loaded(existingRoutines);
          });
        }
      },
      initial: () async {
        try {
          // 모든 루틴을 순차적으로 저장합니다
          for (final routine in routines) {
            final result = await _saveRoutineUseCase.execute(routine);
            if (result case ResultFailure(failure: final failure)) {
              state = RoutineState.error(failure.message);
              Future.delayed(const Duration(seconds: 2), () {
                state = const RoutineState.initial();
              });
              return;
            }
          }

          // 모든 루틴 저장 성공 시 데이터를 새로고침합니다
          await refreshRoutines();
        } catch (e) {
          state = RoutineState.error(e.toString());
          Future.delayed(const Duration(seconds: 2), () {
            state = const RoutineState.initial();
          });
        }
      },
    );
  }

  Future<void> updateRoutine(Routine routine) async {
    state.whenOrNull(
      loaded: (routines) async {
        try {
          // 현재 루틴 목록에서 업데이트할 루틴의 인덱스를 찾습니다
          final routineIndex = routines.indexWhere((r) => r.id == routine.id);
          if (routineIndex == -1) return;

          // 이전 상태를 저장하고 UI를 즉시 업데이트합니다
          final previousRoutines = List<Routine>.from(routines);
          final updatedRoutines = List<Routine>.from(routines);
          updatedRoutines[routineIndex] = routine;
          state = RoutineState.loaded(_sortRoutinesByPriority(updatedRoutines));

          // 백엔드 업데이트를 시도합니다
          final result = await _updateRoutineUseCase.execute(routine);

          if (result case ResultFailure(failure: final failure)) {
            // 실패 시 이전 상태로 복원하고 에러를 표시합니다
            state = RoutineState.loaded(previousRoutines);
            Future.microtask(() {
              state = RoutineState.error(failure.message);
              Future.delayed(const Duration(seconds: 2), () {
                state = RoutineState.loaded(previousRoutines);
              });
            });
          }
        } catch (e) {
          // 예외 발생 시 에러를 표시하고 이전 상태로 복원합니다
          state = RoutineState.error(e.toString());
          Future.delayed(const Duration(seconds: 2), () {
            state = RoutineState.loaded(routines);
          });
        }
      },
    );
  }

  Future<void> deleteRoutine(String id) async {
    state.whenOrNull(
      loaded: (routines) async {
        try {
          // 현재 루틴 목록에서 삭제할 루틴의 인덱스를 찾습니다
          final routineIndex = routines.indexWhere((r) => r.id == id);
          if (routineIndex == -1) return;

          // 이전 상태를 저장하고 UI를 즉시 업데이트합니다
          final previousRoutines = List<Routine>.from(routines);
          final updatedRoutines = List<Routine>.from(routines)
            ..removeAt(routineIndex);
          state = RoutineState.loaded(_sortRoutinesByPriority(updatedRoutines));

          // 백엔드 업데이트를 시도합니다
          final result = await _deleteRoutineUseCase.execute(id);

          if (result case ResultFailure(failure: final failure)) {
            // 실패 시 이전 상태로 복원하고 에러를 표시합니다
            state = RoutineState.loaded(previousRoutines);
            Future.microtask(() {
              state = RoutineState.error(failure.message);
              Future.delayed(const Duration(seconds: 2), () {
                state = RoutineState.loaded(previousRoutines);
              });
            });
          }
        } catch (e) {
          // 예외 발생 시 에러를 표시하고 이전 상태로 복원합니다
          state = RoutineState.error(e.toString());
          Future.delayed(const Duration(seconds: 2), () {
            state = RoutineState.loaded(routines);
          });
        }
      },
    );
  }

  Future<void> refreshRoutines() async {
    await _loadRoutines();
  }

  Future<void> toggleRoutineActive(String id) async {
    state.whenOrNull(loaded: (routines) {
      final index = routines.indexWhere((r) => r.id == id);
      if (index != -1) {
        final routine = routines[index];
        final updatedRoutine = routine.copyWith(isActive: !routine.isActive);
        final updatedRoutines = [...routines];
        updatedRoutines[index] = updatedRoutine;
        state = RoutineState.loaded(updatedRoutines);
      }
    });
  }
}
