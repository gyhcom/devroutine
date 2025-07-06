import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_router.dart';
import '../../domain/entities/routine.dart';
import '../providers/routine_provider.dart';
import '../utils/priority_color_util.dart';
import '../widgets/flush_message.dart';

// 상수 클래스
class RoutineDetailConstants {
  static const double headerHeight = 120.0;
  static const double cardPadding = 16.0;
  static const double sectionSpacing = 24.0;
  static const double iconSize = 24.0;
  static const double buttonHeight = 48.0;
  static const double borderRadius = 12.0;
}

// 스타일 클래스
class RoutineDetailStyles {
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.white70,
  );

  static TextStyle sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade800,
  );

  static TextStyle infoTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey.shade700,
  );

  static TextStyle labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.grey.shade600,
  );
}

@RoutePage()
class RoutineDetailScreen extends ConsumerStatefulWidget {
  final Routine routine;

  const RoutineDetailScreen({
    super.key,
    required this.routine,
  });

  @override
  ConsumerState<RoutineDetailScreen> createState() =>
      _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends ConsumerState<RoutineDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routineState = ref.watch(routineNotifierProvider);

    return routineState.when(
      initial: () => _buildLoadingScaffold(),
      loading: () => _buildLoadingScaffold(),
      loaded: (routines) {
        // 현재 루틴의 최신 상태 찾기
        final currentRoutine = routines.firstWhere(
          (r) => r.id == widget.routine.id,
          orElse: () => widget.routine,
        );

        return _buildDetailScaffold(currentRoutine, routines);
      },
      error: (message) => _buildErrorScaffold(message),
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('루틴 상세'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScaffold(String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('루틴 상세'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.router.pop(),
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailScaffold(Routine routine, List<Routine> allRoutines) {
    final priorityColor = getPriorityBorderColor(routine.priority);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(routine, priorityColor),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(RoutineDetailConstants.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompletionSection(routine),
                  const SizedBox(height: RoutineDetailConstants.sectionSpacing),
                  _buildInfoSection(routine, allRoutines),
                  const SizedBox(height: RoutineDetailConstants.sectionSpacing),
                  _buildActionButtons(routine),
                  const SizedBox(height: 80), // 하단 여백
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Routine routine, Color priorityColor) {
    return SliverAppBar(
      expandedHeight: RoutineDetailConstants.headerHeight,
      floating: false,
      pinned: true,
      backgroundColor: priorityColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          routine.title,
          style: RoutineDetailStyles.titleStyle.copyWith(fontSize: 20),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                priorityColor,
                priorityColor.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildCompactPriorityBadge(routine.priority),
                      const SizedBox(width: 8),
                      _buildCompactRoutineTypeBadge(routine),
                    ],
                  ),
                  if (routine.memo?.isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    Text(
                      routine.memo!,
                      style: RoutineDetailStyles.subtitleStyle
                          .copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white, size: 20),
          onPressed: () => _navigateToEdit(routine),
          tooltip: '수정',
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.white, size: 20),
          onPressed: () => _showDeleteDialog(routine),
          tooltip: '삭제',
        ),
      ],
    );
  }

  Widget _buildCompactPriorityBadge(Priority priority) {
    final label = getPriorityLabel(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getPriorityIcon(priority),
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactRoutineTypeBadge(Routine routine) {
    final isThreeDay = routine.isThreeDayRoutine;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isThreeDay ? Icons.local_fire_department : Icons.today,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            isThreeDay ? '3일' : '일일',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionSection(Routine routine) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(RoutineDetailConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(RoutineDetailConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '완료 상태',
              style: RoutineDetailStyles.sectionTitleStyle,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: GestureDetector(
                        onTap: () => _toggleCompletion(routine),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: routine.isCompletedToday
                                ? Colors.green.shade50
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: routine.isCompletedToday
                                  ? Colors.green.shade200
                                  : Colors.grey.shade200,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            routine.isCompletedToday
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: routine.isCompletedToday
                                ? Colors.green.shade600
                                : Colors.grey.shade400,
                            size: 30,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routine.isCompletedToday ? '완료됨' : '미완료',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: routine.isCompletedToday
                              ? Colors.green.shade600
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        routine.isCompletedToday
                            ? '오늘 할 일을 완료했어요! 🎉'
                            : '아직 완료하지 않았어요',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (routine.isCompletedToday &&
                          routine.completedAt != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '완료 시간: ${DateFormat('HH:mm').format(routine.completedAt!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(Routine routine, List<Routine> allRoutines) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(RoutineDetailConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(RoutineDetailConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '상세 정보',
              style: RoutineDetailStyles.sectionTitleStyle,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: '시작일',
              value: DateFormat('yyyy년 M월 d일').format(routine.startDate),
            ),
            if (routine.endDate != null)
              _buildInfoRow(
                icon: Icons.event,
                label: '종료일',
                value: DateFormat('yyyy년 M월 d일').format(routine.endDate!),
              ),
            _buildInfoRow(
              icon: Icons.flag,
              label: '우선순위',
              value: _getPriorityText(routine.priority),
            ),
            _buildInfoRow(
              icon: Icons.category,
              label: '루틴 유형',
              value: routine.isThreeDayRoutine ? '3일 챌린지' : '일일 루틴',
            ),
            if (routine.memo?.isNotEmpty == true)
              _buildInfoRow(
                icon: Icons.note,
                label: '메모',
                value: routine.memo!,
                isMultiline: true,
              ),
            if (routine.isThreeDayRoutine)
              _buildThreeDayInfo(routine, allRoutines),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: RoutineDetailStyles.labelStyle,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: RoutineDetailStyles.infoTextStyle,
                  maxLines: isMultiline ? null : 1,
                  overflow: isMultiline ? null : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreeDayInfo(Routine routine, List<Routine> allRoutines) {
    if (routine.groupId == null) return const SizedBox.shrink();

    final groupRoutines = allRoutines
        .where((r) => r.groupId == routine.groupId)
        .toList()
      ..sort((a, b) => (a.dayNumber ?? 0).compareTo(b.dayNumber ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.local_fire_department,
              size: 20,
              color: Colors.orange.shade600,
            ),
            const SizedBox(width: 12),
            Text(
              '3일 챌린지 진행 상황',
              style: RoutineDetailStyles.labelStyle,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...groupRoutines.map((r) => _buildThreeDayProgressItem(r)),
      ],
    );
  }

  Widget _buildThreeDayProgressItem(Routine routine) {
    final today = DateTime.now();
    final routineDate = DateTime(
      routine.startDate.year,
      routine.startDate.month,
      routine.startDate.day,
    );
    final todayDate = DateTime(today.year, today.month, today.day);

    final isToday = routineDate.isAtSameMomentAs(todayDate);
    final isPast = routineDate.isBefore(todayDate);
    final isCompleted = routine.isCompletedToday;

    IconData icon;
    Color color;
    String status;

    if (isCompleted) {
      icon = Icons.check_circle;
      color = Colors.green.shade600;
      status = '완료';
    } else if (isToday) {
      icon = Icons.radio_button_unchecked;
      color = Colors.blue.shade600;
      status = '오늘';
    } else if (isPast) {
      icon = Icons.cancel;
      color = Colors.red.shade400;
      status = '미완료';
    } else {
      icon = Icons.schedule;
      color = Colors.grey.shade400;
      status = '예정';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${routine.dayNumber}일차',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Routine routine) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: RoutineDetailConstants.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: () => _navigateToEdit(routine),
            icon: const Icon(Icons.edit),
            label: const Text('루틴 수정'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(RoutineDetailConstants.borderRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: RoutineDetailConstants.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: () => _showDeleteDialog(routine),
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text(
              '루틴 삭제',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(RoutineDetailConstants.borderRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.high:
        return '높음';
      case Priority.medium:
        return '보통';
      case Priority.low:
        return '낮음';
    }
  }

  void _toggleCompletion(Routine routine) {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    final wasCompleted = routine.isCompletedToday;

    ref
        .read(routineNotifierProvider.notifier)
        .toggleRoutineCompletion(routine.id);

    if (!wasCompleted) {
      _showCompletionFeedback(routine);
    }
  }

  void _showCompletionFeedback(Routine routine) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('잘했어요! "${routine.title}" 완료! 🎉'),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _navigateToEdit(Routine routine) async {
    await context.router.push(RoutineFormRoute(routine: routine));
    // 수정 후 돌아올 때 데이터 새로고침
    ref.read(routineNotifierProvider.notifier).refreshRoutines();
  }

  Future<void> _showDeleteDialog(Routine routine) async {
    if (routine.isThreeDayRoutine && routine.groupId != null) {
      await _showThreeDayDeleteDialog(routine);
    } else {
      await _showSingleDeleteDialog(routine);
    }
  }

  Future<void> _showSingleDeleteDialog(Routine routine) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('루틴 삭제'),
        content: Text('정말로 "${routine.title}" 루틴을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (result == true) {
      await ref
          .read(routineNotifierProvider.notifier)
          .deleteRoutine(routine.id);
      await showTopMessage(context, '✅ 루틴이 삭제되었습니다!');
      context.router.maybePop();
    }
  }

  Future<void> _showThreeDayDeleteDialog(Routine routine) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('3일 루틴 삭제'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('정말로 "${routine.title}" 루틴을 삭제하시겠습니까?'),
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
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '3일 루틴 정보',
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
                    '이 루틴만 삭제하거나 전체 3일 챌린지를 삭제할 수 있습니다.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('single'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange.shade600,
            ),
            child: const Text('이 루틴만 삭제'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop('group'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('전체 그룹 삭제'),
          ),
        ],
      ),
    );

    if (result == 'single') {
      await ref
          .read(routineNotifierProvider.notifier)
          .deleteRoutine(routine.id);
      await showTopMessage(context, '✅ 루틴이 삭제되었습니다!');
      context.router.maybePop();
    } else if (result == 'group') {
      await ref
          .read(routineNotifierProvider.notifier)
          .deleteThreeDayGroup(routine.groupId!);
      await showTopMessage(context, '✅ 3일 루틴 그룹이 삭제되었습니다!');
      context.router.maybePop();
    }
  }
}
