import 'package:auto_route/auto_route.dart';
import 'package:devroutine/core/routing/app_router.dart';
import 'package:devroutine/core/widgets/banner_ad_widget.dart';
import 'package:devroutine/features/routine/domain/entities/routine.dart';
import 'package:devroutine/features/routine/presentation/providers/routine_provider.dart';
import 'package:devroutine/features/routine/presentation/utils/priority_color_util.dart';
import 'package:devroutine/features/routine/presentation/widgets/routine_card.dart';
import 'package:devroutine/features/routine/presentation/widgets/today_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

@RoutePage()
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Priority? selectedPriority; // null이면 전체 보기

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3Days - 나의 루틴'),
        actions: [
          // 전체 루틴 보기 버튼
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () async {
              await context.router.push(const RoutineListRoute());
              // 전체 루틴 화면에서 돌아온 후 새로고침
              ref.read(routineNotifierProvider.notifier).refreshRoutines();
            },
            tooltip: '전체 루틴 보기',
          ),
          // 루틴 추가 버튼
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // 루틴 폼으로 이동 후 돌아올 때 자동 새로고침
              await context.router.push(RoutineFormRoute());
              // 루틴 폼에서 돌아온 후 새로고침
              ref.read(routineNotifierProvider.notifier).refreshRoutines();
            },
            tooltip: '루틴 추가',
          ),
        ],
      ),
      body: Column(
        children: [
          // 상단 정보
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 날짜 정보
                Text(
                  DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR')
                      .format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                // 썸머리 카드
                const TodaySummaryCard(),
              ],
            ),
          ),
          // 오늘의 루틴 섹션
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 섹션 헤더
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Text(
                    '오늘의 루틴',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 필터 칩들
                _buildFilterChips(),
                const SizedBox(height: 12),
                // 루틴 리스트
                Expanded(
                  child: _buildRoutineList(),
                ),
              ],
            ),
          ),
          // 배너 광고
          const SafeArea(
            child: BannerAdWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 전체 필터
          _buildFilterChip(
            label: '전체',
            isSelected: selectedPriority == null,
            onTap: () => setState(() => selectedPriority = null),
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          // 긴급 필터
          _buildFilterChip(
            label: '긴급',
            isSelected: selectedPriority == Priority.high,
            onTap: () => setState(() => selectedPriority = Priority.high),
            color: getPriorityBorderColor(Priority.high),
          ),
          const SizedBox(width: 8),
          // 중요 필터
          _buildFilterChip(
            label: '중요',
            isSelected: selectedPriority == Priority.medium,
            onTap: () => setState(() => selectedPriority = Priority.medium),
            color: getPriorityBorderColor(Priority.medium),
          ),
          const SizedBox(width: 8),
          // 여유 필터
          _buildFilterChip(
            label: '여유',
            isSelected: selectedPriority == Priority.low,
            onTap: () => setState(() => selectedPriority = Priority.low),
            color: getPriorityBorderColor(Priority.low),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineList() {
    return Consumer(
      builder: (context, ref, child) {
        final routineState = ref.watch(routineNotifierProvider);

        return routineState.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  '오류가 발생했습니다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          loaded: (routines) {
            // 오늘의 루틴 필터링
            final notifier = ref.read(routineNotifierProvider.notifier);
            final todayRoutines = notifier.getTodayRoutines(routines);

            // 선택된 우선순위로 필터링
            final filteredRoutines = selectedPriority == null
                ? todayRoutines
                : todayRoutines
                    .where((routine) => routine.priority == selectedPriority)
                    .toList();

            if (filteredRoutines.isEmpty) {
              // 모든 루틴이 완료되었는지 확인
              final originalFilteredRoutines = selectedPriority == null
                  ? todayRoutines
                  : todayRoutines
                      .where((routine) => routine.priority == selectedPriority)
                      .toList();

              final hasCompletedRoutines =
                  originalFilteredRoutines.isNotEmpty &&
                      originalFilteredRoutines
                          .every((routine) => routine.isCompletedToday);

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 완료 상태에 따른 아이콘 선택
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: hasCompletedRoutines
                              ? Colors.green.shade50
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: hasCompletedRoutines
                                ? Colors.green.shade200
                                : Colors.grey.shade200,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          hasCompletedRoutines
                              ? Icons.celebration
                              : (selectedPriority == null
                                  ? Icons.add_task
                                  : Icons.filter_list_off),
                          size: 40,
                          color: hasCompletedRoutines
                              ? Colors.green.shade600
                              : Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        hasCompletedRoutines
                            ? (selectedPriority == null
                                ? '🎉 오늘의 모든 루틴 완료!'
                                : '🎉 ${getPriorityLabel(selectedPriority!)} 루틴 완료!')
                            : (selectedPriority == null
                                ? '오늘 할 루틴이 없습니다'
                                : '${getPriorityLabel(selectedPriority!)} 루틴이 없습니다'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: hasCompletedRoutines
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        hasCompletedRoutines
                            ? (selectedPriority == null
                                ? '모든 할 일을 완료했어요!\n정말 대단해요! 🌟'
                                : '해당 우선순위의 모든 할 일을 완료했어요!\n훌륭해요! ✨')
                            : (selectedPriority == null
                                ? '새로운 루틴을 추가해보세요!'
                                : '다른 우선순위를 확인해보세요!'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: hasCompletedRoutines
                              ? Colors.green.shade600
                              : Colors.grey.shade600,
                        ),
                      ),
                      if (hasCompletedRoutines) ...[
                        const SizedBox(height: 24),
                        // 완료 축하 애니메이션 효과
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1500),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: Opacity(
                                opacity: value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.shade400,
                                        Colors.green.shade600,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.shade200,
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    '🏆 완벽해요!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }

            // 3일 루틴 그룹 정보 생성
            final groupedRoutines = <String, List<Routine>>{};
            final threeDayGroups = <String, List<Routine>>{};

            // 전체 루틴에서 3일 루틴 그룹 찾기
            for (final routine in routines) {
              if (routine.isThreeDayRoutine && routine.groupId != null) {
                threeDayGroups
                    .putIfAbsent(routine.groupId!, () => [])
                    .add(routine);
              }
            }

            // 3일 루틴 그룹들을 dayNumber 순서로 정렬
            for (final groupId in threeDayGroups.keys) {
              threeDayGroups[groupId]!.sort(
                  (a, b) => (a.dayNumber ?? 0).compareTo(b.dayNumber ?? 0));
            }

            // 오늘의 루틴에서 그룹 정보 생성
            for (final routine in todayRoutines) {
              if (routine.groupId != null) {
                if (routine.isThreeDayRoutine &&
                    threeDayGroups.containsKey(routine.groupId!)) {
                  groupedRoutines[routine.groupId!] =
                      threeDayGroups[routine.groupId!]!;
                } else {
                  groupedRoutines
                      .putIfAbsent(routine.groupId!, () => [])
                      .add(routine);
                }
              }
            }

            // 스마트 정렬: 우선순위 순서로 정렬
            filteredRoutines.sort((a, b) {
              // 우선순위 순서: high > medium > low
              final priorityOrder = {
                Priority.high: 0,
                Priority.medium: 1,
                Priority.low: 2,
              };

              final aPriority = priorityOrder[a.priority] ?? 999;
              final bPriority = priorityOrder[b.priority] ?? 999;

              if (aPriority != bPriority) {
                return aPriority.compareTo(bPriority);
              }

              // 같은 우선순위면 제목순
              return a.title.compareTo(b.title);
            });

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: filteredRoutines.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final routine = filteredRoutines[index];
                List<Routine>? groupRoutines;
                if (routine.groupId != null) {
                  groupRoutines = groupedRoutines[routine.groupId!];
                }

                return RoutineCard(
                  routine: routine,
                  borderColor: getPriorityBorderColor(routine.priority),
                  groupRoutines: groupRoutines,
                  isFiltered: selectedPriority != null,
                  filterPriority: selectedPriority,
                  onTap: () async {
                    await context.router
                        .push(RoutineDetailRoute(routine: routine));
                    ref
                        .read(routineNotifierProvider.notifier)
                        .refreshRoutines();
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
