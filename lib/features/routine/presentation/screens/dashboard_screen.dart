import 'package:devroutine/core/routing/app_router.dart';
import 'package:devroutine/core/widgets/banner_ad_widget.dart';
import 'package:devroutine/core/services/notification_service.dart';
import 'package:devroutine/features/routine/domain/entities/routine.dart';
import 'package:devroutine/features/routine/presentation/providers/routine_provider.dart';
import 'package:devroutine/features/routine/presentation/utils/priority_color_util.dart';
import 'package:devroutine/features/routine/presentation/widgets/routine_card.dart';
import 'package:devroutine/features/routine/presentation/widgets/today_summary_card.dart';
import 'package:devroutine/features/routine/presentation/screens/routine_list_screen.dart';
import 'package:devroutine/features/routine/presentation/screens/routine_form_screen.dart';
import 'package:devroutine/features/routine/presentation/screens/routine_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';

// 대시보드 필터 타입 정의
enum DashboardFilter {
  all, // 전체 (완료되지 않은 것만)
  high, // 긴급 (완료되지 않은 것만)
  medium, // 중요 (완료되지 않은 것만)
  low, // 여유 (완료되지 않은 것만)
  completed, // 완료됨 (완료된 것만)
}

@RoutePage()
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DashboardFilter selectedFilter = DashboardFilter.all; // 기본값: 전체

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('3Days - 나의 루틴'),
        actions: [
          // 디버그 모드에서만 보이는 알림 테스트 버튼
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.notifications_active),
              onPressed: () => _showNotificationTestMenu(context),
              tooltip: '알림 테스트',
            ),
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
      body: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        // 상단 정보
        _buildHeaderSection(),
        // 오늘의 루틴 섹션
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 섹션 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  selectedFilter == DashboardFilter.completed
                      ? '완료된 루틴'
                      : '오늘의 루틴',
                  style: const TextStyle(
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
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // 좌측 패널 (정보 섹션)
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          child: Column(
            children: [
              _buildHeaderSection(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedFilter == DashboardFilter.completed
                            ? '완료된 루틴'
                            : '오늘의 루틴',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFilterChips(),
                    ],
                  ),
                ),
              ),
              const SafeArea(
                child: BannerAdWidget(),
              ),
            ],
          ),
        ),
        // 우측 패널 (루틴 리스트)
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 1),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: _buildRoutineList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenHeight = MediaQuery.of(context).size.height;

    // 가로 모드에서는 높이를 줄이고, 세로 모드에서는 기본 높이 유지
    final headerPadding = isLandscape
        ? const EdgeInsets.fromLTRB(20, 12, 20, 12)
        : const EdgeInsets.fromLTRB(20, 20, 20, 20);

    return Container(
      padding: headerPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 정보
          Text(
            DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(DateTime.now()),
            style: TextStyle(
              color: Colors.white,
              fontSize: isLandscape ? 12 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isLandscape ? 8 : 16),
          // 썸머리 카드
          const TodaySummaryCard(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      height: isLandscape ? 45 : 50,
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 8 : 16,
        vertical: isLandscape ? 4 : 8,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // 전체 필터
            _buildFilterChip(
              label: '전체',
              isSelected: selectedFilter == DashboardFilter.all,
              onTap: () => setState(() => selectedFilter = DashboardFilter.all),
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            // 긴급 필터
            _buildFilterChip(
              label: '긴급',
              isSelected: selectedFilter == DashboardFilter.high,
              onTap: () =>
                  setState(() => selectedFilter = DashboardFilter.high),
              color: getPriorityBorderColor(Priority.high),
            ),
            const SizedBox(width: 8),
            // 중요 필터
            _buildFilterChip(
              label: '중요',
              isSelected: selectedFilter == DashboardFilter.medium,
              onTap: () =>
                  setState(() => selectedFilter = DashboardFilter.medium),
              color: getPriorityBorderColor(Priority.medium),
            ),
            const SizedBox(width: 8),
            // 여유 필터
            _buildFilterChip(
              label: '여유',
              isSelected: selectedFilter == DashboardFilter.low,
              onTap: () => setState(() => selectedFilter = DashboardFilter.low),
              color: getPriorityBorderColor(Priority.low),
            ),
            const SizedBox(width: 8),
            // 완료 필터
            _buildFilterChip(
              label: '완료',
              isSelected: selectedFilter == DashboardFilter.completed,
              onTap: () =>
                  setState(() => selectedFilter = DashboardFilter.completed),
              color: Colors.green,
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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isLandscape ? 10 : 12,
          vertical: isLandscape ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: isLandscape ? 12 : 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineList() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Consumer(
      builder: (context, ref, child) {
        final routineState = ref.watch(routineNotifierProvider);

        return routineState.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (message) {
            // 축하 메시지인지 확인
            final isCelebrationMessage =
                message.startsWith('🎉') && message.contains('3일 챌린지 완료');

            if (isCelebrationMessage) {
              // 축하 메시지를 스낵바로 안전하게 표시
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text(message)),
                        ],
                      ),
                      backgroundColor: Colors.amber.shade600,
                      duration: const Duration(seconds: 4),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              });

              // 로딩 상태로 표시하여 곧바로 정상 상태로 복원되도록 함
              return const Center(child: CircularProgressIndicator());
            }

            // 일반 에러 메시지 표시
            return Center(
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
            );
          },
          loaded: (routines) {
            // 오늘의 루틴 필터링
            final notifier = ref.read(routineNotifierProvider.notifier);
            final todayRoutines = notifier.getTodayRoutines(routines);

            // 🔥 핵심 수정: 완료되지 않은 루틴만 필터링
            // 3일 루틴의 경우 해당 날짜에 완료되었는지 확인
            final incompleteRoutines = todayRoutines
                .where((routine) => !_isRoutineCompletedForToday(routine))
                .toList();

            // Debug logs (removed for production)
            // Total routines: ${routines.length}
            // Today routines: ${todayRoutines.length}
            // Incomplete routines: ${incompleteRoutines.length}
            // Completed routines: ${todayRoutines.where((r) => r.isCompletedToday).length}

            // 선택된 필터로 루틴 필터링
            List<Routine> filteredRoutines;
            switch (selectedFilter) {
              case DashboardFilter.all:
                filteredRoutines = incompleteRoutines;
                break;
              case DashboardFilter.high:
                filteredRoutines = incompleteRoutines
                    .where((routine) => routine.priority == Priority.high)
                    .toList();
                break;
              case DashboardFilter.medium:
                filteredRoutines = incompleteRoutines
                    .where((routine) => routine.priority == Priority.medium)
                    .toList();
                break;
              case DashboardFilter.low:
                filteredRoutines = incompleteRoutines
                    .where((routine) => routine.priority == Priority.low)
                    .toList();
                break;
              case DashboardFilter.completed:
                filteredRoutines = todayRoutines
                    .where((routine) => _isRoutineCompletedForToday(routine))
                    .toList();
                break;
            }

            if (filteredRoutines.isEmpty) {
              // 빈 상태 처리
              final isCompletedFilter =
                  selectedFilter == DashboardFilter.completed;
              final hasCompletedRoutines = isCompletedFilter
                  ? false // 완료 필터에서 빈 상태는 축하가 아님
                  : todayRoutines.isNotEmpty &&
                      todayRoutines.every(
                          (routine) => _isRoutineCompletedForToday(routine));

              return GestureDetector(
                onTap: () {
                  // 완료 필터에서는 클릭 비활성화
                  if (!isCompletedFilter) {
                    context.router.push(RoutineFormRoute());
                  }
                },
                child: _buildEmptyState(
                  hasCompletedRoutines: hasCompletedRoutines,
                  isCompletedFilter: isCompletedFilter,
                  isLandscape: isLandscape,
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

            // 🔥 수정: 필터된 루틴에서 그룹 정보 생성
            for (final routine in filteredRoutines) {
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
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 12 : 20,
                vertical: 8,
              ),
              itemCount: filteredRoutines.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final routine = filteredRoutines[index];
                List<Routine>? groupRoutines;
                if (routine.groupId != null) {
                  groupRoutines = groupedRoutines[routine.groupId!];
                }

                // 완료된 루틴은 투명도를 낮춰서 시각적 구분
                final isCompletedRoutine =
                    selectedFilter == DashboardFilter.completed;

                return Opacity(
                  opacity: isCompletedRoutine ? 0.7 : 1.0,
                  child: RoutineCard(
                    key: ValueKey(routine.id), // 🔥 고유 키 추가
                    routine: routine,
                    borderColor: getPriorityBorderColor(routine.priority),
                    groupRoutines: groupRoutines,
                    isFiltered: selectedFilter != DashboardFilter.all,
                    filterPriority: _getFilterPriority(),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RoutineDetailScreen(routine: routine),
                        ),
                      );
                      ref
                          .read(routineNotifierProvider.notifier)
                          .refreshRoutines();
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required bool hasCompletedRoutines,
    required bool isCompletedFilter,
    required bool isLandscape,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isLandscape ? 16 : 24),
        child: isLandscape
            ? _buildLandscapeEmptyState(hasCompletedRoutines, isCompletedFilter)
            : _buildPortraitEmptyState(hasCompletedRoutines, isCompletedFilter),
      ),
    );
  }

  Widget _buildPortraitEmptyState(
      bool hasCompletedRoutines, bool isCompletedFilter) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 완료 상태에 따른 아이콘 선택
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: hasCompletedRoutines
                ? Colors.green.shade50
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(32),
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
                : (isCompletedFilter ? Icons.task_alt : Icons.add_task),
            size: 32,
            color: hasCompletedRoutines
                ? Colors.green.shade600
                : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _getEmptyStateTitle(hasCompletedRoutines, isCompletedFilter),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: hasCompletedRoutines
                ? Colors.green.shade700
                : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getEmptyStateSubtitle(hasCompletedRoutines, isCompletedFilter),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: hasCompletedRoutines
                ? Colors.green.shade600
                : Colors.grey.shade600,
          ),
        ),
        if (hasCompletedRoutines) ...[
          const SizedBox(height: 16),
          // 완료 축하 애니메이션 효과 (크기 축소)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1200),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.9 + (0.1 * value),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade400,
                          Colors.green.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      '🏆 완벽해요!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
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
    );
  }

  Widget _buildLandscapeEmptyState(
      bool hasCompletedRoutines, bool isCompletedFilter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 좌측 아이콘
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: hasCompletedRoutines
                ? Colors.green.shade50
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(24),
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
                : (isCompletedFilter ? Icons.task_alt : Icons.add_task),
            size: 24,
            color: hasCompletedRoutines
                ? Colors.green.shade600
                : Colors.grey.shade400,
          ),
        ),
        const SizedBox(width: 16),
        // 우측 텍스트
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getEmptyStateTitle(hasCompletedRoutines, isCompletedFilter),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: hasCompletedRoutines
                      ? Colors.green.shade700
                      : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getEmptyStateSubtitle(hasCompletedRoutines, isCompletedFilter),
                style: TextStyle(
                  fontSize: 13,
                  color: hasCompletedRoutines
                      ? Colors.green.shade600
                      : Colors.grey.shade600,
                ),
              ),
              if (hasCompletedRoutines) ...[
                const SizedBox(height: 12),
                // 완료 축하 메시지
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '🏆 완벽해요!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getEmptyStateTitle(
      bool hasCompletedRoutines, bool isCompletedFilter) {
    if (hasCompletedRoutines) {
      return '🎉 오늘의 모든 루틴 완료!';
    }

    if (isCompletedFilter) {
      return '완료된 루틴이 없습니다';
    }

    switch (selectedFilter) {
      case DashboardFilter.all:
        return '오늘 할 루틴이 없습니다';
      case DashboardFilter.high:
        return '긴급 루틴이 없습니다';
      case DashboardFilter.medium:
        return '중요 루틴이 없습니다';
      case DashboardFilter.low:
        return '여유 루틴이 없습니다';
      case DashboardFilter.completed:
        return '완료된 루틴이 없습니다';
    }
  }

  String _getEmptyStateSubtitle(
      bool hasCompletedRoutines, bool isCompletedFilter) {
    if (hasCompletedRoutines) {
      return '모든 할 일을 완료했어요!\n정말 대단해요! 🌟';
    }

    if (isCompletedFilter) {
      return '루틴을 완료하면 여기에 표시됩니다!';
    }

    return '새로운 루틴을 추가해보세요!';
  }

  Priority? _getFilterPriority() {
    switch (selectedFilter) {
      case DashboardFilter.high:
        return Priority.high;
      case DashboardFilter.medium:
        return Priority.medium;
      case DashboardFilter.low:
        return Priority.low;
      default:
        return null;
    }
  }

  /// 루틴이 오늘 완료되었는지 확인하는 메서드
  /// 3일 루틴의 경우 해당 날짜에 완료되었는지 확인
  bool _isRoutineCompletedForToday(Routine routine) {
    final today = DateTime.now();

    if (routine.isThreeDayRoutine) {
      // 3일 루틴의 경우 해당 날짜에 완료되었는지 확인
      final routineDate = routine.startDate;

      // 루틴의 날짜가 오늘과 같은지 확인
      final isRoutineForToday = Routine.isSameDay(routineDate, today);

      if (isRoutineForToday) {
        // 오늘 날짜에 완료되었는지 확인
        return routine.isCompletedOnDate(today);
      } else {
        // 오늘이 아닌 3일 루틴은 표시하지 않음
        return false;
      }
    } else {
      // 일반 루틴의 경우 오늘 완료 여부 확인
      return routine.isCompletedToday;
    }
  }

  /// 알림 테스트 메뉴 표시 (디버그 모드 전용)
  void _showNotificationTestMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🔔 알림 테스트 메뉴',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTestButton(
              context,
              '즉시 알림 테스트',
              Icons.notifications,
              Colors.blue,
              () => _sendInstantNotification(),
            ),
            _buildTestButton(
              context,
              '5초 후 알림 테스트',
              Icons.schedule,
              Colors.orange,
              () => _sendDelayedNotification(5),
            ),
            _buildTestButton(
              context,
              '30초 후 알림 테스트',
              Icons.timer,
              Colors.green,
              () => _sendDelayedNotification(30),
            ),
            _buildTestButton(
              context,
              '3일 챌린지 격려 메시지',
              Icons.local_fire_department,
              Colors.red,
              () => _sendChallengeNotification(),
            ),
            _buildTestButton(
              context,
              '모든 알림 취소',
              Icons.cancel,
              Colors.grey,
              () => _cancelAllNotifications(),
            ),
          ],
        ),
      ),
    );
  }

  /// 테스트 버튼 위젯
  Widget _buildTestButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          onPressed();
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  /// 즉시 알림 전송
  void _sendInstantNotification() {
    NotificationService().showInstantNotification(
      title: '🎯 즉시 알림 테스트',
      body: '알림이 정상적으로 작동하고 있습니다!',
      payload: 'test:instant',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('즉시 알림이 전송되었습니다!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 지연 알림 전송
  void _sendDelayedNotification(int seconds) {
    NotificationService().scheduleTestNotification(
      delay: Duration(seconds: seconds),
      title: '⏰ 지연 알림 테스트',
      body: '${seconds}초 후 알림이 도착했습니다!',
      payload: 'test:delayed:$seconds',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${seconds}초 후 알림이 예약되었습니다!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 3일 챌린지 격려 메시지
  void _sendChallengeNotification() {
    NotificationService().scheduleThreeDayChallenge(
      routineTitle: '테스트 루틴',
      dayNumber: 2,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('3일 챌린지 격려 메시지가 내일 오전 9시에 예약되었습니다!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 모든 알림 취소
  void _cancelAllNotifications() {
    NotificationService().cancelAllNotifications();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('모든 알림이 취소되었습니다!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
