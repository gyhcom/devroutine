import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/routine.dart';
import '../providers/routine_provider.dart';

class RoutineCard extends ConsumerWidget {
  final Routine routine;
  final VoidCallback onTap;
  final Color borderColor;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onTap,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = routine.isCompletedToday;

    // 3일 루틴 관련 변수
    final isThreeDayRoutine = routine.isThreeDayRoutine;
    final threeDayStatus = isThreeDayRoutine ? routine.threeDayStatusText : '';

    // 3일 루틴의 테두리 색상 계산
    Color cardBorderColor = borderColor;
    if (isThreeDayRoutine) {
      if (isCompleted) {
        cardBorderColor = Colors.grey;
      } else {
        final days = routine.remainingDays;
        if (days < 0) {
          cardBorderColor = Colors.grey; // 만료됨
        } else if (days == 0) {
          cardBorderColor = Colors.red; // D-Day
        } else if (days == 1) {
          cardBorderColor = Colors.orange; // D-1
        } else {
          cardBorderColor = Colors.blue; // D-2 이상
        }
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1, // 정사각형 비율 유지
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: cardBorderColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // 메인 콘텐츠
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Priority Icon
                    _buildPriorityIndicator(),
                    const SizedBox(height: 8),

                    // Title
                    Expanded(
                      child: Center(
                        child: Text(
                          routine.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 완료 상태 토글 버튼
                    SizedBox(
                      height: 24,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref
                              .read(routineNotifierProvider.notifier)
                              .toggleRoutineCompletion(routine.id);
                        },
                        icon: Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isCompleted ? Colors.white : Colors.white,
                          size: 16,
                        ),
                        label: Text(
                          isCompleted ? 'Done' : 'To Do',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isCompleted ? Colors.green : Colors.grey,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(80, 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 완료 표시 뱃지 (완료된 경우에만)
              if (isCompleted)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),

              // 3일 루틴 뱃지
              if (isThreeDayRoutine && !isCompleted)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getThreeDayBadgeColor(routine.remainingDays),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      threeDayStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    Color color;
    IconData icon;

    switch (routine.priority) {
      case Priority.high:
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      case Priority.medium:
        color = Colors.orange;
        icon = Icons.remove;
        break;
      case Priority.low:
        color = Colors.green;
        icon = Icons.arrow_downward;
        break;
    }

    return Icon(icon, color: color, size: 24);
  }

  // 3일 루틴 뱃지 색상 계산
  Color _getThreeDayBadgeColor(int remainingDays) {
    if (remainingDays < 0) return Colors.grey; // 만료됨
    if (remainingDays == 0) return Colors.red; // D-Day
    if (remainingDays == 1) return Colors.orange; // D-1
    return Colors.blue; // D-2 이상
  }
}
