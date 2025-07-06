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
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3Days - 나의 루틴'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.router.push(RoutineFormRoute()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(routineNotifierProvider.notifier).refreshRoutines();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildGreeting(),
            const SizedBox(height: 16),
            const TodaySummaryCard(),
            const SizedBox(height: 16),
            _buildGoToRoutineList(context),
            const SizedBox(height: 16),
            _buildTodayRoutines(context, ref),
          ],
        ),
      ),
      bottomNavigationBar: const SafeArea(
        child: BannerAdWidget(),
      ),
    );
  }

  Widget _buildGreeting() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy년 M월 d일 (EEEE)', 'ko_KR').format(now);

    // 시간대별 인사말
    String greeting;
    final hour = now.hour;
    if (hour < 12) {
      greeting = '좋은 아침이에요! ☀️';
    } else if (hour < 18) {
      greeting = '좋은 오후예요! 🌤️';
    } else {
      greeting = '좋은 저녁이에요! 🌙';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(formattedDate, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildGoToRoutineList(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.router.push(const RoutineListRoute()),
      icon: const Icon(Icons.list),
      label: const Text('전체 루틴 보기'),
    );
  }

  Widget _buildTodayRoutines(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📋 오늘의 루틴',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Consumer(
          builder: (context, ref, child) {
            return ref.watch(routineNotifierProvider).when(
                  initial: () => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('루틴 데이터를 불러오는 중...'),
                      ],
                    ),
                  ),
                  loading: () => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('루틴 데이터를 불러오는 중...'),
                      ],
                    ),
                  ),
                  error: (error) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          '오류가 발생했습니다',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.refresh(routineNotifierProvider),
                          child: Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                  loaded: (routines) {
                    // 오늘의 루틴만 필터링
                    final notifier = ref.read(routineNotifierProvider.notifier);
                    final todayRoutines = notifier.getTodayRoutines(routines);

                    if (todayRoutines.isEmpty) {
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_task,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                '오늘 할 루틴이 없습니다\n새로운 루틴을 추가해보세요!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // 3일 루틴 그룹 정보 생성 및 전체 그룹 찾기
                    final groupedRoutines = <String, List<Routine>>{};
                    final threeDayGroups = <String, List<Routine>>{};

                    // 전체 루틴에서 3일 루틴 그룹 찾기
                    for (final routine in routines) {
                      if (routine.isThreeDayRoutine &&
                          routine.groupId != null) {
                        threeDayGroups
                            .putIfAbsent(routine.groupId!, () => [])
                            .add(routine);
                      }
                    }

                    // 3일 루틴 그룹들을 dayNumber 순서로 정렬
                    for (final groupId in threeDayGroups.keys) {
                      threeDayGroups[groupId]!.sort((a, b) =>
                          (a.dayNumber ?? 0).compareTo(b.dayNumber ?? 0));
                    }

                    // 오늘의 루틴에서 그룹 정보 생성
                    for (final routine in todayRoutines) {
                      if (routine.groupId != null) {
                        // 3일 루틴의 경우 전체 그룹을 가져오기
                        if (routine.isThreeDayRoutine &&
                            threeDayGroups.containsKey(routine.groupId!)) {
                          groupedRoutines[routine.groupId!] =
                              threeDayGroups[routine.groupId!]!;
                        } else {
                          // 일일 루틴의 경우 개별 루틴만
                          groupedRoutines
                              .putIfAbsent(routine.groupId!, () => [])
                              .add(routine);
                        }
                      }
                    }

                    // 우선순위별로 정렬
                    final sortedRoutines = [...todayRoutines];
                    sortedRoutines.sort((a, b) {
                      // 우선순위 순서: High -> Medium -> Low
                      final priorityOrder = {
                        Priority.high: 0,
                        Priority.medium: 1,
                        Priority.low: 2,
                      };
                      return priorityOrder[a.priority]!
                          .compareTo(priorityOrder[b.priority]!);
                    });

                    return Column(
                      children: sortedRoutines.map((routine) {
                        List<Routine>? groupRoutines;
                        if (routine.groupId != null) {
                          groupRoutines = groupedRoutines[routine.groupId!];
                        }

                        return RoutineCard(
                          routine: routine,
                          borderColor: getPriorityBorderColor(routine.priority),
                          groupRoutines: groupRoutines,
                          onTap: () => context.router
                              .push(RoutineFormRoute(routine: routine)),
                        );
                      }).toList(),
                    );
                  },
                );
          },
        ),
      ],
    );
  }
}
