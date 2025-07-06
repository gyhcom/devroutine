import 'package:auto_route/auto_route.dart';
import 'package:devroutine/features/routine/presentation/utils/priority_color_util.dart';
import 'package:devroutine/features/routine/presentation/widgets/flush_message.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/entities/routine.dart';
import '../providers/routine_provider.dart';
import '../widgets/routine_list_item.dart';

@RoutePage()
class RoutineListScreen extends ConsumerWidget {
  const RoutineListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routineState = ref.watch(routineNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 루틴'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(routineNotifierProvider.notifier).refreshRoutines(),
          ),
        ],
      ),
      body: routineState.when(
        initial: () => const Center(child: Text('루틴 추가를 시작해보세요!')),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (routines) => _buildRoutineList(context, ref, routines),
        error: (message) => Center(child: Text('오류: $message')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.router.push(RoutineFormRoute());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRoutineList(
      BuildContext context, WidgetRef ref, List<Routine> routines) {
    if (routines.isEmpty) {
      return const Center(child: Text('아직 루틴이 없습니다. 하나 추가해보세요!'));
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(routineNotifierProvider.notifier).refreshRoutines(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: routines.length,
        itemBuilder: (context, index) {
          final routine = routines[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RoutineListItem(
              routine: routine,
              borderColor: getPriorityBorderColor(routine.priority),
              onTap: () {
                context.router.push(RoutineFormRoute(routine: routine));
              },
              onToggleActive: () {
                final updatedRoutine = routine.toggleActive();
                ref
                    .read(routineNotifierProvider.notifier)
                    .updateRoutine(updatedRoutine);
                showTopMessage(
                    context,
                    updatedRoutine.isActive
                        ? '✅ 루틴이 활성화되었습니다!'
                        : '✅ 루틴이 비활성화되었습니다!');
              },
              onDelete: () async {
                if (routine.isThreeDayRoutine && routine.groupId != null) {
                  // 3일 루틴의 경우 그룹 삭제 확인
                  await _showThreeDayRoutineDeleteDialog(
                      context, ref, routine, routines);
                } else {
                  // 일일 루틴의 경우 바로 삭제
                  ref
                      .read(routineNotifierProvider.notifier)
                      .deleteRoutine(routine.id);
                  showTopMessage(context, '✅ 루틴이 삭제되었습니다!');
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showThreeDayRoutineDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Routine routine,
    List<Routine> allRoutines,
  ) async {
    final notifier = ref.read(routineNotifierProvider.notifier);
    final groupRoutines =
        notifier.getThreeDayGroupRoutines(routine.groupId!, allRoutines);

    if (groupRoutines.length <= 1) {
      // 마지막 루틴이면 바로 삭제
      ref.read(routineNotifierProvider.notifier).deleteRoutine(routine.id);
      showTopMessage(context, '✅ 루틴이 삭제되었습니다!');
      return;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('3일 루틴 삭제'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${routine.title}" 루틴을 삭제하시겠습니까?',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ 3일 루틴은 그룹으로 관리됩니다',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '현재 그룹에 ${groupRoutines.length}개의 루틴이 있습니다.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'single'),
            child: Text(
              '이 루틴만 삭제',
              style: TextStyle(color: Colors.orange.shade600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'group'),
            child: Text(
              '전체 그룹 삭제',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );

    if (result == 'single') {
      // 개별 루틴 삭제
      ref.read(routineNotifierProvider.notifier).deleteRoutine(routine.id);
      showTopMessage(context, '✅ 루틴이 삭제되었습니다!');
    } else if (result == 'group') {
      // 전체 그룹 삭제
      await notifier.deleteThreeDayGroup(routine.groupId!);
      showTopMessage(context, '✅ 3일 루틴 그룹이 삭제되었습니다!');
    }
  }
}
