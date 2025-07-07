import 'package:auto_route/auto_route.dart';
import 'package:devroutine/features/routine/presentation/utils/priority_color_util.dart';
import 'package:devroutine/features/routine/presentation/widgets/flush_message.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/entities/routine.dart';
import '../providers/routine_provider.dart';
import '../widgets/routine_list_item.dart';

// 완료 히스토리 필터 enum
enum CompletionHistoryFilter {
  today, // 오늘
  yesterday, // 어제
  thisWeek, // 이번 주
  thisMonth, // 이번 달
}

// 상수 정의
class RoutineListScreenConstants {
  static const double listPadding = 12.0;
  static const double itemSpacing = 6.0;
  static const double emptyStateIconSize = 64.0;
  static const double loadingIconSize = 32.0;
  static const double filterChipHeight = 60.0;
  static const double tabBarHeight = 48.0;
}

// 스타일 클래스
class RoutineListScreenStyles {
  static TextStyle emptyTitleStyle(BuildContext context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle emptySubtitleStyle(BuildContext context) => TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        height: 1.4,
      );

  static TextStyle loadingTextStyle(BuildContext context) => TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      );

  static TextStyle errorTextStyle(BuildContext context) => TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.error,
        fontWeight: FontWeight.w500,
      );
}

@RoutePage()
class RoutineListScreen extends ConsumerStatefulWidget {
  const RoutineListScreen({super.key});

  @override
  ConsumerState<RoutineListScreen> createState() => _RoutineListScreenState();
}

class _RoutineListScreenState extends ConsumerState<RoutineListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Priority? selectedPriority; // 진행중 탭의 우선순위 필터
  CompletionHistoryFilter selectedHistoryFilter =
      CompletionHistoryFilter.today; // 완료됨 탭의 히스토리 필터

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routineState = ref.watch(routineNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '나의 루틴',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(routineNotifierProvider.notifier).refreshRoutines(),
            tooltip: '새로고침',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.schedule_rounded),
              text: '진행중',
            ),
            Tab(
              icon: Icon(Icons.check_circle_rounded),
              text: '완료됨',
            ),
          ],
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 진행중 탭
          Column(
            children: [
              _buildPriorityFilterChips(),
              Expanded(
                child: routineState.when(
                  initial: () => _buildInitialState(context),
                  loading: () => _buildLoadingState(context),
                  loaded: (routines) =>
                      _buildActiveRoutineList(context, ref, routines),
                  error: (message) => _buildErrorState(context, message, ref),
                ),
              ),
            ],
          ),
          // 완료됨 탭
          Column(
            children: [
              _buildHistoryFilterChips(),
              Expanded(
                child: routineState.when(
                  initial: () => _buildInitialState(context),
                  loading: () => _buildLoadingState(context),
                  loaded: (routines) =>
                      _buildCompletedRoutineList(context, ref, routines),
                  error: (message) => _buildErrorState(context, message, ref),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.router.push(RoutineFormRoute());
          ref.read(routineNotifierProvider.notifier).refreshRoutines();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('루틴 추가'),
        tooltip: '새 루틴 추가',
      ),
    );
  }

  Widget _buildPriorityFilterChips() {
    return Container(
      height: RoutineListScreenConstants.filterChipHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
      ),
    );
  }

  Widget _buildHistoryFilterChips() {
    return Container(
      height: RoutineListScreenConstants.filterChipHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // 오늘
            _buildHistoryFilterChip(
              label: '오늘',
              filter: CompletionHistoryFilter.today,
              icon: Icons.today,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            // 어제
            _buildHistoryFilterChip(
              label: '어제',
              filter: CompletionHistoryFilter.yesterday,
              icon: Icons.history,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            // 이번 주
            _buildHistoryFilterChip(
              label: '이번 주',
              filter: CompletionHistoryFilter.thisWeek,
              icon: Icons.view_week,
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            // 이번 달
            _buildHistoryFilterChip(
              label: '이번 달',
              filter: CompletionHistoryFilter.thisMonth,
              icon: Icons.calendar_month,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryFilterChip({
    required String label,
    required CompletionHistoryFilter filter,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = selectedHistoryFilter == filter;

    return GestureDetector(
      onTap: () => setState(() => selectedHistoryFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // 루틴이 현재 활성 상태인지 확인
  bool _isRoutineActive(Routine routine) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(
        routine.startDate.year, routine.startDate.month, routine.startDate.day);

    if (routine.endDate != null) {
      final endDate = DateTime(
          routine.endDate!.year, routine.endDate!.month, routine.endDate!.day);
      return routine.isActive &&
          !today.isBefore(startDate) &&
          !today.isAfter(endDate);
    }

    return routine.isActive && !today.isBefore(startDate);
  }

  // 특정 날짜에 완료된 루틴인지 확인
  bool _isCompletedOnDate(Routine routine, DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return routine.completionHistory.any((completionDate) {
      final completion = DateTime(
          completionDate.year, completionDate.month, completionDate.day);
      return completion.isAtSameMomentAs(targetDate);
    });
  }

  // 히스토리 필터에 따른 완료된 루틴 필터링
  List<Routine> _getCompletedRoutinesByFilter(List<Routine> routines) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (selectedHistoryFilter) {
      case CompletionHistoryFilter.today:
        return routines
            .where((routine) => _isCompletedOnDate(routine, today))
            .toList();

      case CompletionHistoryFilter.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        return routines
            .where((routine) => _isCompletedOnDate(routine, yesterday))
            .toList();

      case CompletionHistoryFilter.thisWeek:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        return routines.where((routine) {
          return routine.completionHistory.any((completionDate) {
            final completion = DateTime(
                completionDate.year, completionDate.month, completionDate.day);
            return completion
                    .isAfter(weekStart.subtract(const Duration(days: 1))) &&
                completion.isBefore(today.add(const Duration(days: 1)));
          });
        }).toList();

      case CompletionHistoryFilter.thisMonth:
        final monthStart = DateTime(today.year, today.month, 1);
        return routines.where((routine) {
          return routine.completionHistory.any((completionDate) {
            final completion = DateTime(
                completionDate.year, completionDate.month, completionDate.day);
            return completion
                    .isAfter(monthStart.subtract(const Duration(days: 1))) &&
                completion.isBefore(today.add(const Duration(days: 1)));
          });
        }).toList();
    }
  }

  Widget _buildInitialState(BuildContext context) {
    return _buildEmptyStateContent(
      context,
      icon: Icons.today_outlined,
      title: '루틴을 시작해보세요!',
      subtitle: '일상을 더 체계적으로 관리할 수 있도록\n첫 번째 루틴을 추가해보세요.',
      actionText: '루틴 추가하기',
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: RoutineListScreenConstants.loadingIconSize,
            height: RoutineListScreenConstants.loadingIconSize,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '루틴 데이터를 불러오는 중...',
            style: RoutineListScreenStyles.loadingTextStyle(context),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: RoutineListScreenConstants.emptyStateIconSize,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: RoutineListScreenStyles.emptyTitleStyle(context).copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: RoutineListScreenStyles.emptySubtitleStyle(context),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.refresh(routineNotifierProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateContent(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionText,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(48),
              ),
              child: Icon(
                icon,
                size: RoutineListScreenConstants.emptyStateIconSize,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: RoutineListScreenStyles.emptyTitleStyle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: RoutineListScreenStyles.emptySubtitleStyle(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRoutineList(
      BuildContext context, WidgetRef ref, List<Routine> routines) {
    // 진행중인 루틴만 필터링 (완료되지 않은 활성 루틴)
    var activeRoutines = routines
        .where(
            (routine) => _isRoutineActive(routine) && !routine.isCompletedToday)
        .toList();

    // 우선순위로 추가 필터링
    if (selectedPriority != null) {
      activeRoutines = activeRoutines
          .where((routine) => routine.priority == selectedPriority)
          .toList();
    }

    // 우선순위 순으로 정렬
    activeRoutines.sort((a, b) => a.priority.index.compareTo(b.priority.index));

    if (activeRoutines.isEmpty) {
      return _buildEmptyStateContent(
        context,
        icon: selectedPriority == null
            ? Icons.task_alt_rounded
            : Icons.filter_list_off,
        title: selectedPriority == null
            ? '진행중인 루틴이 없습니다'
            : '${getPriorityLabel(selectedPriority!)} 루틴이 없습니다',
        subtitle: selectedPriority == null
            ? '모든 루틴이 완료되었거나\n새로운 루틴을 추가해보세요!'
            : '다른 우선순위를 확인해보거나\n새로운 루틴을 추가해보세요!',
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(routineNotifierProvider.notifier).refreshRoutines(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding:
                const EdgeInsets.all(RoutineListScreenConstants.listPadding),
            sliver: SliverList.separated(
              itemCount: activeRoutines.length,
              separatorBuilder: (context, index) => const SizedBox(
                height: RoutineListScreenConstants.itemSpacing,
              ),
              itemBuilder: (context, index) {
                final routine = activeRoutines[index];
                return RoutineListItem(
                  routine: routine,
                  borderColor: getPriorityBorderColor(routine.priority),
                  onTap: () async {
                    await context.router
                        .push(RoutineDetailRoute(routine: routine));
                    ref
                        .read(routineNotifierProvider.notifier)
                        .refreshRoutines();
                  },
                  onToggleCompletion: () {
                    ref
                        .read(routineNotifierProvider.notifier)
                        .toggleRoutineCompletion(routine.id);

                    final message = routine.isCompletedToday
                        ? '↩️ 완료 상태가 취소되었습니다!'
                        : '🎉 루틴이 완료되었습니다!';
                    showTopMessage(context, message);
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
                            : '⏸️ 루틴이 비활성화되었습니다!');
                  },
                  onDelete: () async {
                    if (routine.isThreeDayRoutine && routine.groupId != null) {
                      await _showThreeDayRoutineDeleteDialog(
                          context, ref, routine, routines);
                    } else {
                      ref
                          .read(routineNotifierProvider.notifier)
                          .deleteRoutine(routine.id);
                      showTopMessage(context, '🗑️ 루틴이 삭제되었습니다!');
                    }
                  },
                );
              },
            ),
          ),
          // 하단 여백 (FAB와 겹치지 않도록)
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedRoutineList(
      BuildContext context, WidgetRef ref, List<Routine> routines) {
    // 완료된 루틴들을 히스토리 필터에 따라 필터링
    final completedRoutines = _getCompletedRoutinesByFilter(routines);

    if (completedRoutines.isEmpty) {
      String title;
      String subtitle;

      switch (selectedHistoryFilter) {
        case CompletionHistoryFilter.today:
          title = '오늘 완료된 루틴이 없습니다';
          subtitle = '루틴을 완료하면 여기에 표시됩니다!';
          break;
        case CompletionHistoryFilter.yesterday:
          title = '어제 완료된 루틴이 없습니다';
          subtitle = '어제는 루틴을 완료하지 않았습니다.';
          break;
        case CompletionHistoryFilter.thisWeek:
          title = '이번 주 완료된 루틴이 없습니다';
          subtitle = '이번 주에 완료된 루틴이 없습니다.';
          break;
        case CompletionHistoryFilter.thisMonth:
          title = '이번 달 완료된 루틴이 없습니다';
          subtitle = '이번 달에 완료된 루틴이 없습니다.';
          break;
      }

      return _buildEmptyStateContent(
        context,
        icon: Icons.history_rounded,
        title: title,
        subtitle: subtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(routineNotifierProvider.notifier).refreshRoutines(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding:
                const EdgeInsets.all(RoutineListScreenConstants.listPadding),
            sliver: SliverList.separated(
              itemCount: completedRoutines.length,
              separatorBuilder: (context, index) => const SizedBox(
                height: RoutineListScreenConstants.itemSpacing,
              ),
              itemBuilder: (context, index) {
                final routine = completedRoutines[index];
                return Opacity(
                  opacity: 0.7, // 완료된 루틴은 투명도를 조정하여 시각적 구분
                  child: RoutineListItem(
                    routine: routine,
                    borderColor: getPriorityBorderColor(routine.priority),
                    onTap: () async {
                      await context.router
                          .push(RoutineDetailRoute(routine: routine));
                      ref
                          .read(routineNotifierProvider.notifier)
                          .refreshRoutines();
                    },
                    onToggleCompletion: () {
                      ref
                          .read(routineNotifierProvider.notifier)
                          .toggleRoutineCompletion(routine.id);

                      final message = routine.isCompletedToday
                          ? '↩️ 완료 상태가 취소되었습니다!'
                          : '🎉 루틴이 완료되었습니다!';
                      showTopMessage(context, message);
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
                              : '⏸️ 루틴이 비활성화되었습니다!');
                    },
                    onDelete: () async {
                      if (routine.isThreeDayRoutine &&
                          routine.groupId != null) {
                        await _showThreeDayRoutineDeleteDialog(
                            context, ref, routine, routines);
                      } else {
                        ref
                            .read(routineNotifierProvider.notifier)
                            .deleteRoutine(routine.id);
                        showTopMessage(context, '🗑️ 루틴이 삭제되었습니다!');
                      }
                    },
                  ),
                );
              },
            ),
          ),
          // 하단 여백 (FAB와 겹치지 않도록)
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
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
      ref.read(routineNotifierProvider.notifier).deleteRoutine(routine.id);
      showTopMessage(context, '🗑️ 루틴이 삭제되었습니다!');
      return;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange.shade600,
          size: 36,
        ),
        title: const Text(
          '3일 루틴 삭제',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${routine.title}" 루틴을 삭제하시겠습니까?',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '3일 루틴 그룹 정보',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '현재 그룹에 ${groupRoutines.length}개의 루틴이 있습니다.\n개별 삭제 또는 전체 그룹 삭제를 선택하세요.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.3,
                    ),
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange.shade600,
            ),
            child: const Text('이 루틴만 삭제'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'group'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('전체 그룹 삭제'),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );

    if (result == 'single') {
      ref.read(routineNotifierProvider.notifier).deleteRoutine(routine.id);
      showTopMessage(context, '🗑️ 루틴이 삭제되었습니다!');
    } else if (result == 'group') {
      await notifier.deleteThreeDayGroup(routine.groupId!);
      showTopMessage(context, '🗑️ 3일 루틴 그룹이 삭제되었습니다!');
    }
  }
}
