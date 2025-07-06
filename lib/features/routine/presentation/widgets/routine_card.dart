import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/routine.dart';
import '../providers/routine_provider.dart';

class RoutineCard extends ConsumerStatefulWidget {
  final Routine routine;
  final VoidCallback onTap;
  final Color borderColor;
  final List<Routine>? groupRoutines; // 3일 루틴 그룹 (선택적)

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onTap,
    required this.borderColor,
    this.groupRoutines,
  });

  @override
  ConsumerState<RoutineCard> createState() => _RoutineCardState();
}

class _RoutineCardState extends ConsumerState<RoutineCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
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
    final isThreeDayRoutine = widget.routine.isThreeDayRoutine;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.borderColor.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isThreeDayRoutine
                ? _buildThreeDayExpandableCard()
                : _buildDailyCard(),
          ),
        );
      },
    );
  }

  Widget _buildDailyCard() {
    final isCompleted = widget.routine.isCompletedToday;
    final priorityColor = _getPriorityColor(widget.routine.priority);
    final priorityLabel = _getPriorityLabel(widget.routine.priority);

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 우선순위 표시 (색상 + 라벨)
            Column(
              children: [
                Container(
                  width: 6,
                  height: 40,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  priorityLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: priorityColor,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // 제목과 설명
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.routine.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                      color:
                          isCompleted ? Colors.grey.shade600 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.today,
                        color: Colors.blue.shade400,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '일일 루틴',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 완료 버튼 (터치 영역 분리)
            GestureDetector(
              onTap: () => _toggleCompletion(showFeedback: true),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      isCompleted ? Colors.green.shade50 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCompleted
                        ? Colors.green.shade200
                        : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isCompleted
                      ? Colors.green.shade600
                      : Colors.grey.shade400,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreeDayExpandableCard() {
    final groupRoutines = widget.groupRoutines ?? [];
    final completedCount =
        groupRoutines.where((r) => r.isCompletedToday == true).length;
    final totalCount = groupRoutines.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final isFullyCompleted = completedCount == totalCount;
    final currentDay = widget.routine.dayNumber ?? 1;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        leading: _buildCircularProgress(progress, currentDay, totalCount),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.routine.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                decoration:
                    isFullyCompleted ? TextDecoration.lineThrough : null,
                color: isFullyCompleted ? Colors.grey.shade600 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange.shade600,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '3일 챌린지 - Day $currentDay/$totalCount',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: GestureDetector(
          onTap: () => _toggleCompletion(showFeedback: true),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.routine.isCompletedToday
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.routine.isCompletedToday
                    ? Colors.green.shade200
                    : Colors.orange.shade200,
                width: 1,
              ),
            ),
            child: Icon(
              widget.routine.isCompletedToday
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: widget.routine.isCompletedToday
                  ? Colors.green.shade600
                  : Colors.orange.shade400,
              size: 24,
            ),
          ),
        ),
        children: [
          // 전체 진행률 표시
          _buildDetailedProgress(groupRoutines),

          // 완료 축하 메시지
          if (isFullyCompleted) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Colors.amber.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🎉 3일 챌린지 완료! 정말 대단해요!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCircularProgress(
      double progress, int currentDay, int totalCount) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(
              progress == 1.0 ? Colors.green.shade400 : Colors.orange.shade400,
            ),
          ),
          Text(
            '$currentDay/$totalCount',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: progress == 1.0
                  ? Colors.green.shade600
                  : Colors.orange.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedProgress(List<Routine> groupRoutines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '세부 진행 상황',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...groupRoutines.asMap().entries.map((entry) {
          final index = entry.key;
          final routine = entry.value;
          final isCompleted = routine.isCompletedToday == true;
          final isToday = routine.id == widget.routine.id;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isToday ? Colors.blue.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isToday ? Colors.blue.shade200 : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.shade400
                        : isToday
                            ? Colors.blue.shade400
                            : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}일차',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isToday ? Colors.blue.shade700 : Colors.black87,
                        ),
                      ),
                      Text(
                        isCompleted
                            ? '완료됨'
                            : isToday
                                ? '오늘 할 일'
                                : '예정',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String _getPriorityLabel(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'HIGH';
      case Priority.medium:
        return 'MID';
      case Priority.low:
        return 'LOW';
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red.shade400;
      case Priority.medium:
        return Colors.orange.shade400;
      case Priority.low:
        return Colors.green.shade400;
    }
  }

  void _toggleCompletion({bool showFeedback = false}) {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    final wasCompleted = widget.routine.isCompletedToday;

    ref
        .read(routineNotifierProvider.notifier)
        .toggleRoutineCompletion(widget.routine.id);

    if (showFeedback && !wasCompleted) {
      _showCompletionFeedback();
    }
  }

  void _showCompletionFeedback() {
    // 일일 루틴 완료 피드백
    if (!widget.routine.isThreeDayRoutine) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.celebration, color: Colors.white),
              const SizedBox(width: 8),
              Text('잘했어요! "${widget.routine.title}" 완료! 🎉'),
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
    } else {
      // 3일 루틴 완료 피드백
      final groupRoutines = widget.groupRoutines ?? [];
      final completedCount =
          groupRoutines.where((r) => r.isCompletedToday == true).length +
              1; // +1 for current completion
      final totalCount = groupRoutines.length;

      if (completedCount == totalCount) {
        // 3일 챌린지 완료!
        _showChallengeCompletionDialog();
      } else {
        // 일차 완료
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.white),
                const SizedBox(width: 8),
                Text('Day ${widget.routine.dayNumber} 완료! 🔥 계속 화이팅!'),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showChallengeCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.amber.shade600,
              size: 48,
            ),
            const SizedBox(height: 8),
            const Text(
              '🎉 미션 성공!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '"${widget.routine.title}"',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '3일 챌린지를 완주하셨습니다!\n정말 대단해요! 🏆',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('계속하기'),
          ),
        ],
      ),
    );
  }
}
