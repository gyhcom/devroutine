import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
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
RoutineRepository routineRepository(Ref ref) {
  try {
    // main.dart에서 이미 열린 박스를 사용
    final box = Hive.box<RoutineModel>('routines');
    final localDataSource = HiveRoutineLocalDataSource(box);
    return RoutineRepositoryImpl(localDataSource);
  } catch (e) {
    // print('❌ Error accessing Hive box: $e');
    // Hive 접근 실패 시 임시로 메모리 저장소 사용
    // print('⚠️ Falling back to memory storage');
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

    final todayRoutines = routines.where((routine) {
      if (!routine.isActive) return false;

      if (routine.isThreeDayRoutine) {
        // 3일 루틴의 경우: 각 루틴의 startDate가 오늘과 같은지 확인
        final routineDate = DateTime(
          routine.startDate.year,
          routine.startDate.month,
          routine.startDate.day,
        );
        final isToday = routineDate.isAtSameMomentAs(today);

        return isToday;
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

    return todayRoutines;
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
            // print('🚨 Critical error in build: $e');
            state = RoutineState.error('앱을 초기화하는 중 오류가 발생했습니다. 앱을 재시작해주세요.');
          }
        });
      }

      return const RoutineState.initial();
    } catch (e) {
      // print('💥 Error in build method: $e');
      return RoutineState.error('데이터베이스 연결에 실패했습니다: $e');
    }
  }

  Future<void> _loadRoutines() async {
    try {
      // print('🔄 Loading routines...');
      state = const RoutineState.loading();
      final result = await _getRoutinesUseCase.execute();
      if (result case Success(data: final routines)) {
        // print('✅ Loaded ${routines.length} routines successfully');
        state = RoutineState.loaded(_sortRoutinesByPriority(routines));
      } else if (result case ResultFailure(failure: final failure)) {
        // print('❌ Failed to load routines: ${failure.message}');
        state = RoutineState.error(failure.message);
      }
    } catch (e, stackTrace) {
      // print('💥 Exception while loading routines: $e');
      // print('Stack trace: $stackTrace');
      state = RoutineState.error('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  // 3일 루틴 완료 체크 메서드
  bool isThreeDayRoutineCompleted(String groupId, List<Routine> routines) {
    final groupRoutines = routines.where((r) => r.groupId == groupId).toList();
    if (groupRoutines.length != 3) return false;

    return groupRoutines.every((routine) => routine.isCompletedToday);
  }

  // 3일 루틴 그룹 정보 가져오기
  List<Routine> getThreeDayGroupRoutines(
      String groupId, List<Routine> routines) {
    final groupRoutines = routines.where((r) => r.groupId == groupId).toList();

    // dayNumber 순서로 정렬 (1일차, 2일차, 3일차)
    groupRoutines
        .sort((a, b) => (a.dayNumber ?? 0).compareTo(b.dayNumber ?? 0));

    return groupRoutines;
  }

  // 3일 루틴 그룹 삭제 (모든 관련 루틴 삭제)
  Future<void> deleteThreeDayGroup(String groupId) async {
    state.whenOrNull(
      loaded: (routines) async {
        try {
          final groupRoutines = getThreeDayGroupRoutines(groupId, routines);
          if (groupRoutines.isEmpty) return;

          // 모든 그룹 루틴 삭제
          for (final routine in groupRoutines) {
            final result = await _deleteRoutineUseCase.execute(routine.id);
            if (result case ResultFailure(failure: final failure)) {
              state =
                  RoutineState.error('그룹 삭제 중 오류가 발생했습니다: ${failure.message}');
              return;
            }
          }

          // 성공 시 데이터 새로고침
          await refreshRoutines();
        } catch (e) {
          state = RoutineState.error('그룹 삭제 중 오류가 발생했습니다: $e');
        }
      },
    );
  }

  // 3일 루틴 개별 삭제 시 그룹 상태 확인 및 처리
  Future<void> deleteRoutineWithGroupCheck(String id) async {
    state.whenOrNull(
      loaded: (routines) async {
        try {
          final routineToDelete = routines.firstWhere((r) => r.id == id);

          if (routineToDelete.isThreeDayRoutine &&
              routineToDelete.groupId != null) {
            // 3일 루틴의 경우 그룹 전체 삭제 여부 확인
            final groupRoutines =
                getThreeDayGroupRoutines(routineToDelete.groupId!, routines);

            if (groupRoutines.length > 1) {
              // 그룹에 다른 루틴이 있으면 경고 표시
              state =
                  RoutineState.error('3일 루틴은 그룹 단위로 관리됩니다. 전체 그룹을 삭제하시겠습니까?');
              return;
            }
          }

          // 단일 루틴 삭제 또는 마지막 그룹 루틴 삭제
          await deleteRoutine(id);
        } catch (e) {
          state = RoutineState.error('루틴 삭제 중 오류가 발생했습니다: $e');
        }
      },
    );
  }

  // 3일 루틴 그룹의 완성도 계산 (전체 그룹 기준)
  double getThreeDayGroupCompletionRate(
      String groupId, List<Routine> routines) {
    final groupRoutines = getThreeDayGroupRoutines(groupId, routines);
    if (groupRoutines.isEmpty) return 0.0;

    final completedCount =
        groupRoutines.where((r) => r.isCompletedToday).length;
    return completedCount / groupRoutines.length;
  }

  // 3일 루틴 그룹의 오늘 할 일 확인
  List<Routine> getTodayThreeDayRoutines(
      String groupId, List<Routine> routines) {
    final groupRoutines = getThreeDayGroupRoutines(groupId, routines);
    final today = DateTime.now();

    return groupRoutines.where((routine) {
      final routineDate = DateTime(
        routine.startDate.year,
        routine.startDate.month,
        routine.startDate.day,
      );
      final todayDate = DateTime(today.year, today.month, today.day);
      return routineDate.isAtSameMomentAs(todayDate);
    }).toList();
  }

  // markRoutineAsCompleted 메서드에 3일 루틴 완료 체크 추가
  Future<void> markRoutineAsCompleted(String id) async {
    // print('🔄 markRoutineAsCompleted 시작 - ID: $id');
    state.whenOrNull(
      loaded: (routines) async {
        try {
          final index = routines.indexWhere((r) => r.id == id);
          if (index == -1) {
            // print('❌ 루틴을 찾을 수 없음 - ID: $id');
            return;
          }

          final routine = routines[index];
          if (routine.isCompletedToday) {
            // print('⚠️ 이미 완료된 루틴 - ${routine.title}');
            return;
          }

          // print('📝 루틴 완료 처리 중 - ${routine.title}');
          final updatedRoutine = routine.markAsCompleted();
          final updatedRoutines = List<Routine>.from(routines);
          updatedRoutines[index] = updatedRoutine;
          state = RoutineState.loaded(updatedRoutines);

          // print('✅ UI 상태 업데이트 완료 - ${routine.title}');

          // 백엔드 업데이트
          // print('💾 데이터베이스 업데이트 시작 - ${routine.title}');
          final result = await _updateRoutineUseCase.execute(updatedRoutine);

          if (result case Success()) {
            // print('✅ 데이터베이스 업데이트 성공 - ${routine.title}');

            // 알림 스케줄링 (루틴 완료 시)
            _scheduleRoutineReminder(routine);

            // 3일 루틴 완료 체크 (데이터베이스 업데이트 성공 후에만)
            if (routine.groupId != null) {
              final isGroupCompleted =
                  isThreeDayRoutineCompleted(routine.groupId!, updatedRoutines);
              if (isGroupCompleted) {
                // 🎉 3일 루틴 완료 축하 메시지 (안전하게 지연 실행)
                Future.delayed(const Duration(milliseconds: 500), () {
                  _showThreeDayCompletionCelebration(routine.groupId!);
                });
              } else {
                // 3일 루틴 진행 중 - 격려 메시지 스케줄링
                _scheduleThreeDayEncouragement(routine, updatedRoutines);
              }
            }
          } else if (result case ResultFailure(failure: final failure)) {
            // print('❌ 데이터베이스 업데이트 실패 - ${routine.title}: ${failure.message}');
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
          // print('💥 markRoutineAsCompleted 예외 - $e');
          state = RoutineState.error(e.toString());
        }
      },
    );
  }

  void _showThreeDayCompletionCelebration(String groupId) {
    // 3일 루틴 완료 시 특별한 효과
    // 상태를 통해 축하 메시지 표시 (UI에서 감지하여 처리)
    state.whenOrNull(
      loaded: (routines) {
        // 완료된 그룹의 첫 번째 루틴 제목 가져오기
        final groupRoutines =
            routines.where((r) => r.groupId == groupId).toList();
        if (groupRoutines.isNotEmpty) {
          final baseTitle =
              groupRoutines.first.title.replaceAll(RegExp(r'\s*\(\d+일차\)'), '');

          // 임시로 축하 메시지를 에러 상태로 표시 (UI에서 감지)
          // 실제로는 별도의 상태나 이벤트 시스템을 사용하는 것이 좋음
          final celebrationMessage = '🎉 "$baseTitle" 3일 챌린지 완료! 정말 대단해요! 🏆';

          // 축하 메시지를 임시 에러 상태로 표시하고 곧바로 복원
          Future.microtask(() {
            state = RoutineState.error(celebrationMessage);
            Future.delayed(const Duration(seconds: 3), () {
              state = RoutineState.loaded(routines);
            });
          });
        }
      },
    );
  }

  /// 루틴 완료 시 다음 날 리마인더 알림 스케줄링
  void _scheduleRoutineReminder(Routine routine) {
    try {
      // 루틴이 일일 루틴이고 활성 상태일 때만 알림 스케줄링
      if (!routine.isThreeDayRoutine && routine.isActive) {
        // 내일 같은 시간에 리마인더 설정 (기본 오전 9시)
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final reminderTime = DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          9, // 오전 9시
        );

        NotificationService().scheduleRoutineReminder(
          routineId: routine.id,
          routineTitle: routine.title,
          scheduledTime: reminderTime,
        );
      }
    } catch (e) {
      // 알림 스케줄링 실패 시 로그만 출력 (앱 동작에는 영향 없음)
      // print('⚠️ 알림 스케줄링 실패: $e');
    }
  }

  /// 3일 챌린지 격려 메시지 스케줄링
  void _scheduleThreeDayEncouragement(Routine routine, List<Routine> routines) {
    try {
      if (!routine.isThreeDayRoutine || routine.groupId == null) return;

      // 같은 그룹의 모든 루틴 가져오기
      final groupRoutines =
          routines.where((r) => r.groupId == routine.groupId).toList();
      if (groupRoutines.isEmpty) return;

      // 완료된 일차 수 계산
      final completedDays =
          groupRoutines.where((r) => r.isCompletedToday).length;
      final totalDays = groupRoutines.length;

      // 기본 제목 추출 (일차 정보 제거)
      final baseTitle = routine.title.replaceAll(RegExp(r'\s*\(\d+일차\)'), '');

      // 진행 상황에 따른 격려 메시지 스케줄링
      if (completedDays == 1 && totalDays == 3) {
        // 1일차 완료 시 - 2일차 격려 메시지
        NotificationService().scheduleThreeDayChallenge(
          routineTitle: baseTitle,
          dayNumber: 2,
        );
      } else if (completedDays == 2 && totalDays == 3) {
        // 2일차 완료 시 - 3일차 격려 메시지
        NotificationService().scheduleThreeDayChallenge(
          routineTitle: baseTitle,
          dayNumber: 3,
        );
      }
    } catch (e) {
      // 알림 스케줄링 실패 시 로그만 출력 (앱 동작에는 영향 없음)
      // print('⚠️ 3일 챌린지 격려 메시지 스케줄링 실패: $e');
    }
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

  Future<bool> createRoutine(Routine routine) async {
    // print('🔄 createRoutine 시작 - 루틴 제목: ${routine.title}');
    bool success = false;

    try {
      success = await state.when(
        initial: () async {
          // print('✅ 상태가 initial임 - 초기 루틴 생성');
          return await _createRoutineInInitialState(routine);
        },
        loading: () async {
          // print('⏳ 로딩 중... 잠시 대기 후 재시도');
          await Future.delayed(const Duration(milliseconds: 500));
          return false; // 재귀 호출
        },
        loaded: (routines) async {
          // print('✅ 상태가 loaded임 - 루틴 개수: ${routines.length}');
          return await _createRoutineInLoadedState(routine, routines);
        },
        error: (message) async {
          // print('❌ 오류 상태에서 루틴 생성 시도: $message');
          // 오류 상태에서는 먼저 데이터를 다시 로드
          await _loadRoutines();
          return false; // 재귀 호출
        },
      );
    } catch (e) {
      // print('💥 createRoutine 예외: $e');
      state = RoutineState.error('루틴 생성 중 오류가 발생했습니다: $e');
      success = false;
    }

    // print('✅ createRoutine 완료 - 성공: $success');
    return success;
  }

  Future<bool> _createRoutineInLoadedState(
      Routine routine, List<Routine> routines) async {
    try {
      // print('🔄 loaded 상태에서 루틴 생성 시작');
      final result = await _saveRoutineUseCase.execute(routine);

      if (result case Success()) {
        // print('✅ 루틴 저장 성공 - 데이터 새로고침 시작');
        await refreshRoutines();
        // print('✅ 데이터 새로고침 완료');
        return true;
      } else if (result case ResultFailure(failure: final failure)) {
        // print('❌ 루틴 저장 실패: ${failure.message}');
        state = RoutineState.error(failure.message);
        Future.delayed(const Duration(seconds: 2), () {
          state = RoutineState.loaded(routines);
        });
        return false;
      }
    } catch (e) {
      // print('💥 _createRoutineInLoadedState 예외: $e');
      state = RoutineState.error(e.toString());
      Future.delayed(const Duration(seconds: 2), () {
        state = RoutineState.loaded(routines);
      });
      return false;
    }
    return false;
  }

  Future<bool> _createRoutineInInitialState(Routine routine) async {
    try {
      // print('🔄 initial 상태에서 루틴 생성 시작');
      final result = await _saveRoutineUseCase.execute(routine);

      if (result case Success()) {
        // print('✅ 루틴 저장 성공 - 데이터 새로고침 시작');
        await refreshRoutines();
        // print('✅ 데이터 새로고침 완료');
        return true;
      } else if (result case ResultFailure(failure: final failure)) {
        // print('❌ 루틴 저장 실패: ${failure.message}');
        state = RoutineState.error(failure.message);
        Future.delayed(const Duration(seconds: 2), () {
          state = const RoutineState.initial();
        });
        return false;
      }
    } catch (e) {
      // print('💥 _createRoutineInInitialState 예외: $e');
      state = RoutineState.error(e.toString());
      Future.delayed(const Duration(seconds: 2), () {
        state = const RoutineState.initial();
      });
      return false;
    }
    return false;
  }

  // 3일 루틴 다중 생성 메서드
  Future<bool> createThreeDayRoutines(List<Routine> routines) async {
    // print('🔄 createThreeDayRoutines 시작 - 루틴 개수: ${routines.length}');
    bool success = false;

    try {
      success = await state.when(
        initial: () async {
          // print('✅ 상태가 initial임 - 초기 3일 루틴 생성');
          return await _createThreeDayRoutinesInInitialState(routines);
        },
        loading: () async {
          // print('⏳ 로딩 중... 잠시 대기 후 재시도');
          await Future.delayed(const Duration(milliseconds: 500));
          return false; // 재귀 호출
        },
        loaded: (existingRoutines) async {
          // print('✅ 상태가 loaded임 - 기존 루틴 개수: ${existingRoutines.length}');
          return await _createThreeDayRoutinesInLoadedState(
              routines, existingRoutines);
        },
        error: (message) async {
          // print('❌ 오류 상태에서 3일 루틴 생성 시도: $message');
          // 오류 상태에서는 먼저 데이터를 다시 로드
          await _loadRoutines();
          return false; // 재귀 호출
        },
      );
    } catch (e) {
      // print('💥 createThreeDayRoutines 예외: $e');
      state = RoutineState.error('3일 루틴 생성 중 오류가 발생했습니다: $e');
      success = false;
    }

    // print('✅ createThreeDayRoutines 완료 - 성공: $success');
    return success;
  }

  Future<bool> _createThreeDayRoutinesInLoadedState(
      List<Routine> routines, List<Routine> existingRoutines) async {
    try {
      // print('🔄 loaded 상태에서 3일 루틴 생성 시작');
      // 모든 루틴을 순차적으로 저장합니다
      for (final routine in routines) {
        final result = await _saveRoutineUseCase.execute(routine);
        if (result case ResultFailure(failure: final failure)) {
          // print('❌ 3일 루틴 저장 실패: ${failure.message}');
          state = RoutineState.error(failure.message);
          Future.delayed(const Duration(seconds: 2), () {
            state = RoutineState.loaded(existingRoutines);
          });
          return false;
        }
      }

      // 모든 루틴 저장 성공 시 데이터를 새로고침합니다
      // print('✅ 모든 3일 루틴 저장 성공 - 데이터 새로고침 시작');
      await refreshRoutines();
      // print('✅ 데이터 새로고침 완료');
      return true;
    } catch (e) {
      // print('💥 _createThreeDayRoutinesInLoadedState 예외: $e');
      state = RoutineState.error(e.toString());
      Future.delayed(const Duration(seconds: 2), () {
        state = RoutineState.loaded(existingRoutines);
      });
      return false;
    }
  }

  Future<bool> _createThreeDayRoutinesInInitialState(
      List<Routine> routines) async {
    try {
      // print('🔄 initial 상태에서 3일 루틴 생성 시작');
      // 모든 루틴을 순차적으로 저장합니다
      for (final routine in routines) {
        final result = await _saveRoutineUseCase.execute(routine);
        if (result case ResultFailure(failure: final failure)) {
          // print('❌ 3일 루틴 저장 실패: ${failure.message}');
          state = RoutineState.error(failure.message);
          Future.delayed(const Duration(seconds: 2), () {
            state = const RoutineState.initial();
          });
          return false;
        }
      }

      // 모든 루틴 저장 성공 시 데이터를 새로고침합니다
      // print('✅ 모든 3일 루틴 저장 성공 - 데이터 새로고침 시작');
      await refreshRoutines();
      // print('✅ 데이터 새로고침 완료');
      return true;
    } catch (e) {
      // print('💥 _createThreeDayRoutinesInInitialState 예외: $e');
      state = RoutineState.error(e.toString());
      Future.delayed(const Duration(seconds: 2), () {
        state = const RoutineState.initial();
      });
      return false;
    }
  }

  Future<bool> updateRoutine(Routine routine) async {
    bool success = false;
    await state.whenOrNull(
      loaded: (routines) async {
        try {
          // 현재 루틴 목록에서 업데이트할 루틴의 인덱스를 찾습니다
          final routineIndex = routines.indexWhere((r) => r.id == routine.id);
          if (routineIndex == -1) return;

          // final originalRoutine = routines[routineIndex]; // 현재 사용하지 않음

          // 3일 루틴의 경우 그룹 일관성 검증
          if (routine.isThreeDayRoutine && routine.groupId != null) {
            final groupRoutines =
                getThreeDayGroupRoutines(routine.groupId!, routines);

            // 그룹 내 다른 루틴들과 일관성 확인
            if (groupRoutines.length > 1) {
              final firstInGroup = groupRoutines.first;

              // 제목 패턴 검증 (기본 제목이 같아야 함)
              if (!_isValidThreeDayTitleUpdate(
                  routine.title, firstInGroup.title, routine.dayNumber ?? 1)) {
                state = RoutineState.error('3일 루틴 그룹의 제목은 일관성을 유지해야 합니다.');
                return;
              }

              // 우선순위 일관성 검증
              if (routine.priority != firstInGroup.priority) {
                state = RoutineState.error('3일 루틴 그룹의 우선순위는 모두 같아야 합니다.');
                return;
              }
            }
          }

          // 백엔드 업데이트를 시도합니다
          final result = await _updateRoutineUseCase.execute(routine);

          if (result case Success()) {
            // 성공 시 데이터를 새로고침합니다
            await refreshRoutines();
            success = true;
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
    );
    return success;
  }

  // 3일 루틴 제목 업데이트 유효성 검증
  bool _isValidThreeDayTitleUpdate(
      String newTitle, String groupBaseTitle, int dayNumber) {
    // 기본 제목에서 "(X일차)" 부분 제거
    final baseTitle = groupBaseTitle.replaceAll(RegExp(r'\s*\(\d+일차\)'), '');
    final expectedTitle = '$baseTitle (${dayNumber}일차)';

    return newTitle == expectedTitle || newTitle == baseTitle;
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

  // 3일 루틴 그룹 상태 요약 정보
  Map<String, dynamic> getThreeDayGroupSummary(
      String groupId, List<Routine> routines) {
    final groupRoutines = getThreeDayGroupRoutines(groupId, routines);

    if (groupRoutines.isEmpty) {
      return {
        'isValid': false,
        'totalCount': 0,
        'completedCount': 0,
        'completionRate': 0.0,
        'missingDays': <int>[],
        'status': 'empty',
      };
    }

    final totalCount = groupRoutines.length;
    final completedCount =
        groupRoutines.where((r) => r.isCompletedToday).length;
    final completionRate = completedCount / totalCount;

    // 누락된 일차 확인
    final existingDays = groupRoutines.map((r) => r.dayNumber ?? 1).toSet();
    final missingDays = <int>[];
    for (int day = 1; day <= 3; day++) {
      if (!existingDays.contains(day)) {
        missingDays.add(day);
      }
    }

    String status;
    if (missingDays.isNotEmpty) {
      status = 'incomplete_group'; // 그룹이 불완전함
    } else if (completionRate == 1.0) {
      status = 'completed'; // 모든 일차 완료
    } else if (completionRate > 0) {
      status = 'in_progress'; // 진행 중
    } else {
      status = 'not_started'; // 시작 안함
    }

    return {
      'isValid': missingDays.isEmpty,
      'totalCount': totalCount,
      'completedCount': completedCount,
      'completionRate': completionRate,
      'missingDays': missingDays,
      'status': status,
      'groupRoutines': groupRoutines,
    };
  }

  // 전체 루틴 상태 요약
  Map<String, dynamic> getAllRoutinesSummary(List<Routine> routines) {
    final dailyRoutines = routines.where((r) => !r.isThreeDayRoutine).toList();
    final threeDayGroups = <String, List<Routine>>{};

    // 3일 루틴 그룹화
    for (final routine in routines.where((r) => r.isThreeDayRoutine)) {
      if (routine.groupId != null) {
        threeDayGroups.putIfAbsent(routine.groupId!, () => []).add(routine);
      }
    }

    // 일일 루틴 통계
    final dailyCompleted =
        dailyRoutines.where((r) => r.isCompletedToday).length;
    final dailyTotal = dailyRoutines.length;

    // 3일 루틴 그룹 통계
    int threeDayGroupsCompleted = 0;
    int threeDayGroupsValid = 0;

    for (final groupId in threeDayGroups.keys) {
      final summary = getThreeDayGroupSummary(groupId, routines);
      if (summary['isValid'] as bool) {
        threeDayGroupsValid++;
        if (summary['status'] == 'completed') {
          threeDayGroupsCompleted++;
        }
      }
    }

    final totalTasks = dailyTotal + threeDayGroupsValid;
    final totalCompleted = dailyCompleted + threeDayGroupsCompleted;
    final overallProgress =
        totalTasks > 0 ? (totalCompleted / totalTasks) * 100 : 0.0;

    return {
      'daily': {
        'total': dailyTotal,
        'completed': dailyCompleted,
        'rate': dailyTotal > 0 ? dailyCompleted / dailyTotal : 0.0,
      },
      'threeDay': {
        'totalGroups': threeDayGroups.length,
        'validGroups': threeDayGroupsValid,
        'completedGroups': threeDayGroupsCompleted,
        'rate': threeDayGroupsValid > 0
            ? threeDayGroupsCompleted / threeDayGroupsValid
            : 0.0,
      },
      'overall': {
        'totalTasks': totalTasks,
        'completedTasks': totalCompleted,
        'progress': overallProgress,
      },
    };
  }
}
