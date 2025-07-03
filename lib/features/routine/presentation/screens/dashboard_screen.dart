import 'package:auto_route/auto_route.dart';
import 'package:devroutine/core/routing/app_router.dart';
import 'package:devroutine/features/routine/presentation/providers/routine_provider.dart';
import 'package:devroutine/features/routine/presentation/widgets/routine_list_item.dart';
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
        title: const Text('DevRoutine 대시보드'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.router.push(RoutineFormRoute()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(routineNotifierProvider);
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
            _buildTodayRoutines(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('안녕하세요, 개발자님 👋',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(formattedDate, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildGoToRoutineList(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.router.push(const RoutineListRoute()),
      icon: const Icon(Icons.list),
      label: const Text('루틴 전체 보기'),
    );
  }

  Widget _buildTodayRoutines() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '오늘의 루틴',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, child) {
            return ref.watch(routineNotifierProvider).maybeWhen(
                  loaded: (routines) {
                    if (routines.isEmpty) {
                      return const Center(
                        child: Text('오늘의 루틴이 없습니다.'),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: routines.length,
                      itemBuilder: (context, index) {
                        final routine = routines[index];
                        return RoutineListItem(
                          routine: routine,
                          onTap: () => context.router
                              .push(RoutineFormRoute(routine: routine)),
                          onToggleActive: () => ref
                              .read(routineNotifierProvider.notifier)
                              .toggleRoutineActive(routine.id),
                          onDelete: () => ref
                              .read(routineNotifierProvider.notifier)
                              .deleteRoutine(routine.id),
                          borderColor: Theme.of(context).primaryColor,
                        );
                      },
                    );
                  },
                  orElse: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
          },
        ),
      ],
    );
  }
}
