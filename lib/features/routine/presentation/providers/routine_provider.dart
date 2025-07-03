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
  final box = Hive.box<RoutineModel>('routines');
  final localDataSource = HiveRoutineLocalDataSource(box);
  return RoutineRepositoryImpl(localDataSource);
}

@riverpod
class RoutineNotifier extends _$RoutineNotifier {
  late final GetRoutinesUseCase _getRoutinesUseCase;
  late final SaveRoutineUseCase _saveRoutineUseCase;
  late final UpdateRoutineUseCase _updateRoutineUseCase;
  late final DeleteRoutineUseCase _deleteRoutineUseCase;

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

  @override
  RoutineState build() {
    final repository = ref.read(routineRepositoryProvider);
    _getRoutinesUseCase = GetRoutinesUseCase(repository);
    _saveRoutineUseCase = SaveRoutineUseCase(repository);
    _updateRoutineUseCase = UpdateRoutineUseCase(repository);
    _deleteRoutineUseCase = DeleteRoutineUseCase(repository);

    // 초기 상태 반환 후 비동기로 데이터 로드
    Future.microtask(() => _loadRoutines());
    return const RoutineState.initial();
  }

  Future<void> _loadRoutines() async {
    try {
      state = const RoutineState.loading();
      final result = await _getRoutinesUseCase.execute();
      if (result case Success(data: final routines)) {
        state = RoutineState.loaded(_sortRoutinesByPriority(routines));
      } else if (result case ResultFailure(failure: final failure)) {
        state = RoutineState.error(failure.message);
      }
    } catch (e) {
      state = RoutineState.error(e.toString());
    }
  }

  Future<void> createRoutine(Routine routine) async {
    state.whenOrNull(
      loaded: (routines) async {
        try {
          // 이전 상태를 저장하고 UI를 즉시 업데이트합니다
          final previousRoutines = List<Routine>.from(routines);
          final updatedRoutines =
              _sortRoutinesByPriority([...routines, routine]);
          state = RoutineState.loaded(updatedRoutines);

          // 백엔드 업데이트를 시도합니다
          final result = await _saveRoutineUseCase.execute(routine);

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
      initial: () async {
        try {
          // 초기 상태일 경우 바로 새 루틴으로 시작합니다
          state = RoutineState.loaded([routine]);
          final result = await _saveRoutineUseCase.execute(routine);

          if (result case ResultFailure(failure: final failure)) {
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
