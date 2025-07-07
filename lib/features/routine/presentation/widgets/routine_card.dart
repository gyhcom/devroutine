import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/routine.dart';
import '../providers/routine_provider.dart';
import '../utils/priority_color_util.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/routing/app_router.dart';

// 상수 정의
class RoutineCardConstants {
  static const double cardBorderRadius = 16.0;
  static const double cardMarginBottom = 8.0;
  static const double cardPadding = 12.0;
  static const double iconSize = 16.0;
  static const double buttonSize = 44.0;
  static const double priorityIndicatorWidth = 4.0;
  static const double priorityIndicatorHeight = 32.0;
  static const Duration animationDuration = Duration(milliseconds: 600);
  static const Duration feedbackDuration = Duration(seconds: 2);
}

// 스타일 클래스
class RoutineCardStyles {
  static BoxDecoration cardDecoration(Color borderColor,
      {bool isFiltered = false, Priority? priority}) {
    if (isFiltered && priority != null) {
      return BoxDecoration(
        color: getPriorityBackgroundColor(priority),
        borderRadius:
            BorderRadius.circular(RoutineCardConstants.cardBorderRadius),
        border: Border.all(
          color: getPriorityBorderColor(priority),
          width: 2, // 필터링 시 더 굵은 테두리
        ),
        boxShadow: [
          BoxShadow(
            color: getPriorityBorderColor(priority).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(RoutineCardConstants.cardBorderRadius),
      border: Border.all(
        color: borderColor.withValues(alpha: 0.3),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static TextStyle titleStyle(bool isCompleted) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        decoration: isCompleted ? TextDecoration.lineThrough : null,
        color: isCompleted ? Colors.grey.shade600 : Colors.black87,
      );

  static TextStyle subtitleStyle() => TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
      );

  static TextStyle priorityLabelStyle(Color color) => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color,
      );
}

// 루틴 상태 정보를 담는 클래스
class RoutineStatus {
  final bool isCompleted;
  final bool isToday;
  final bool isPast;
  final bool isFuture;
  final Color color;
  final IconData icon;
  final String statusText;

  RoutineStatus({
    required this.isCompleted,
    required this.isToday,
    required this.isPast,
    required this.isFuture,
    required this.color,
    required this.icon,
    required this.statusText,
  });
}

class RoutineCard extends ConsumerStatefulWidget {
  final Routine routine;
  final VoidCallback onTap;
  final Color borderColor;
  final List<Routine>? groupRoutines; // 3일 루틴 그룹 (선택적)
  final bool isFiltered; // 필터링된 상태인지
  final Priority? filterPriority; // 현재 필터링된 우선순위

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onTap,
    required this.borderColor,
    this.groupRoutines,
    this.isFiltered = false,
    this.filterPriority,
  });

  @override
  ConsumerState<RoutineCard> createState() => _RoutineCardState();
}

class _RoutineCardState extends ConsumerState<RoutineCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  // 완료 애니메이션 컨트롤러
  late AnimationController _completionAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  // 캐시된 오늘 날짜 (성능 최적화)
  late final DateTime _today;
  late final DateTime _todayDate;

  // 완료 상태 추적
  bool _isCompleting = false;
  bool _shouldHide = false;
  String? _completedRoutineId; // 완료된 루틴 ID 추적

  @override
  void initState() {
    super.initState();

    // 오늘 날짜 캐싱
    _today = DateTime.now();
    _todayDate = DateTime(_today.year, _today.month, _today.day);

    // 기본 애니메이션 컨트롤러
    _animationController = AnimationController(
      duration: RoutineCardConstants.animationDuration,
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // 완료 애니메이션 컨트롤러
    _completionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 크기 축소 애니메이션
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _completionAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInBack),
    ));

    // 투명도 애니메이션
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _completionAnimationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    // 슬라이드 애니메이션
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _completionAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _completionAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isThreeDayRoutine = widget.routine.isThreeDayRoutine;

    // 🔥 수정: 루틴 완료 상태와 애니메이션 상태를 함께 확인
    final isCompletedForToday = widget.routine.isThreeDayRoutine
        ? widget.routine.isCompletedOnDate(DateTime.now())
        : widget.routine.isCompletedToday;

    // 완료된 루틴이고 애니메이션이 끝났다면 카드를 숨김
    if (_shouldHide &&
        isCompletedForToday &&
        _completedRoutineId == widget.routine.id) {
      // Card hidden for routine: ${widget.routine.title} (completed: $isCompletedForToday, shouldHide: $_shouldHide, completedId: $_completedRoutineId)
      return const SizedBox.shrink();
    }

    return Semantics(
      label: '${widget.routine.title} 루틴 카드',
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _completionAnimationController,
        ]),
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: Transform.scale(
              scale: _pulseAnimation.value * _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  margin: const EdgeInsets.only(
                      bottom: RoutineCardConstants.cardMarginBottom),
                  decoration: RoutineCardStyles.cardDecoration(
                    widget.borderColor,
                    isFiltered: widget.isFiltered,
                    priority: widget.filterPriority,
                  ),
                  child: isThreeDayRoutine
                      ? _buildThreeDayRoutineCard(widget.groupRoutines ?? [])
                      : _buildDailyCard(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyCard() {
    final isCompleted = widget.routine.isCompletedToday;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(RoutineCardConstants.cardPadding),
        child: Row(
          children: [
            // 완료 상태 아이콘
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.radio_button_unchecked,
                color: Colors.white,
                size: 16,
              ),
            ),

            const SizedBox(width: 12),

            // 제목과 설명
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.routine.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                      color:
                          isCompleted ? Colors.grey.shade600 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.today,
                        color: Colors.blue.shade400,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '일일 루틴',
                        style: TextStyle(
                          fontSize: 11,
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
                width: RoutineCardConstants.buttonSize,
                height: RoutineCardConstants.buttonSize,
                decoration: BoxDecoration(
                  color:
                      isCompleted ? Colors.green.shade50 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
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
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreeDayRoutineCard(List<Routine> groupRoutines) {
    final completedCount =
        groupRoutines.where((r) => r.isCompletedToday == true).length;
    final totalCount = groupRoutines.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final isFullyCompleted = completedCount == totalCount;
    final currentDay = widget.routine.dayNumber ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
              horizontal: RoutineCardConstants.cardPadding, vertical: 6),
          childrenPadding: const EdgeInsets.only(
              left: RoutineCardConstants.cardPadding,
              right: RoutineCardConstants.cardPadding,
              bottom: RoutineCardConstants.cardPadding),
          leading: _buildCircularProgress(progress, currentDay, totalCount),
          // 확장/축소 상태 제어
          controlAffinity: ListTileControlAffinity.trailing,
          // 기본 화살표 아이콘 숨기기
          trailing: const SizedBox.shrink(),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.routine.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: isFullyCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: isFullyCompleted
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 간략한 진행 상황 표시
                  _buildCompactProgressIndicator(groupRoutines),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange.shade600,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '3일 챌린지 - Day $currentDay/$totalCount',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  // 완료 체크 버튼을 여기로 이동
                  GestureDetector(
                    onTap: () => _toggleCompletion(showFeedback: true),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.routine.isCompletedToday
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
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
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // 전체 진행 상황 미리보기 - 간소화
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.expand_more,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '세부 진행 상황 보기',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
      ),
    );
  }

  Widget _buildCircularProgress(
      double progress, int currentDay, int totalCount) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(
              progress == 1.0 ? Colors.green.shade400 : Colors.orange.shade400,
            ),
          ),
          Text(
            '$currentDay/$totalCount',
            style: TextStyle(
              fontSize: 11,
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
          final status = _getRoutineStatus(routine);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: status.isToday ? Colors.blue.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: status.isToday
                    ? Colors.blue.shade200
                    : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: status.isCompleted
                        ? Colors.green.shade400
                        : status.isToday
                            ? Colors.blue.shade400
                            : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: status.isCompleted
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
                          color: status.isToday
                              ? Colors.blue.shade700
                              : Colors.black87,
                        ),
                      ),
                      Text(
                        status.statusText == '오늘'
                            ? '오늘 할 일'
                            : status.statusText,
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

  // 날짜 라벨 생성 (오늘, 내일, 모레)
  String _getDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(today).inDays;

    switch (difference) {
      case 0:
        return '오늘';
      case 1:
        return '내일';
      case 2:
        return '모레';
      case -1:
        return '어제';
      case -2:
        return '2일전';
      default:
        return '${date.month}/${date.day}';
    }
  }

  // 루틴 상세 페이지로 이동
  void _navigateToRoutineDetail(Routine routine) async {
    // AutoRoute를 사용하여 루틴 상세 페이지로 이동 후 돌아올 때 자동 새로고침
    await context.router.push(RoutineDetailRoute(routine: routine));
    // 상세화면에서 돌아온 후 새로고침
    ref.read(routineNotifierProvider.notifier).refreshRoutines();
  }

  void _toggleCompletion({bool showFeedback = false}) {
    final wasCompleted = widget.routine.isCompletedToday;

    // _toggleCompletion called for routine: ${widget.routine.title} (ID: ${widget.routine.id})
    // print('📊 wasCompleted: $wasCompleted, _isCompleting: $_isCompleting');

    // 완료 중이면 중복 실행 방지
    if (_isCompleting) {
      // print('⚠️ Already completing, skipping...');
      return;
    }

    if (!wasCompleted) {
      // 완료 처리
      // print('✅ Starting completion process for: ${widget.routine.title}');
      _isCompleting = true;

      // 즉시 완료 상태로 변경
      ref
          .read(routineNotifierProvider.notifier)
          .toggleRoutineCompletion(widget.routine.id);

      // 완료 애니메이션 실행
      // print('🎬 Starting completion animation for: ${widget.routine.title}');
      _completedRoutineId = widget.routine.id; // 완료된 루틴 ID 저장
      _completionAnimationController.forward().then((_) {
        // 애니메이션 완료 후 카드 숨김
        if (mounted && _completedRoutineId == widget.routine.id) {
          // print('🙈 Hiding card after animation: ${widget.routine.title}');
          setState(() {
            _shouldHide = true;
          });
        }
      });

      // 완료 메시지 표시
      if (showFeedback) {
        _showCompletionFeedback();
      }
    } else {
      // 완료 취소 (일반적인 토글)
      // print('🔄 Toggling completion for: ${widget.routine.title}');
      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      ref
          .read(routineNotifierProvider.notifier)
          .toggleRoutineCompletion(widget.routine.id);
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
      // 3일 루틴 완료 피드백 (Provider에서 처리하므로 여기서는 간단한 일차 완료 메시지만)
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

  Widget _buildCompactProgressIndicator(List<Routine> groupRoutines) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: groupRoutines.asMap().entries.map((entry) {
        final index = entry.key;
        final routine = entry.value;
        final status = _getRoutineStatus(routine);

        return Container(
          margin:
              EdgeInsets.only(right: index < groupRoutines.length - 1 ? 4 : 0),
          child: Tooltip(
            message: '${index + 1}일차 ${status.statusText}',
            child: Icon(
              status.icon,
              size: 16,
              color: status.color,
            ),
          ),
        );
      }).toList(),
    );
  }

  // 루틴 상태 계산 (중복 제거)
  RoutineStatus _getRoutineStatus(Routine routine) {
    final routineDate = DateTime(
      routine.startDate.year,
      routine.startDate.month,
      routine.startDate.day,
    );

    final isCompleted = routine.isCompletedToday == true;
    final isToday = routineDate.isAtSameMomentAs(_todayDate);
    final isPast = routineDate.isBefore(_todayDate);
    final isFuture = routineDate.isAfter(_todayDate);

    Color color;
    IconData icon;
    String statusText;

    if (isCompleted) {
      color = Colors.green.shade600;
      icon = Icons.check_circle;
      statusText = '완료';
    } else if (isToday) {
      color = Colors.blue.shade600;
      icon = Icons.radio_button_unchecked;
      statusText = '오늘';
    } else if (isPast) {
      color = Colors.red.shade400;
      icon = Icons.cancel;
      statusText = '미완료';
    } else {
      color = Colors.grey.shade400;
      icon = Icons.radio_button_unchecked;
      statusText = '예정';
    }

    return RoutineStatus(
      isCompleted: isCompleted,
      isToday: isToday,
      isPast: isPast,
      isFuture: isFuture,
      color: color,
      icon: icon,
      statusText: statusText,
    );
  }
}

// 우선순위 표시 위젯
class PriorityIndicator extends StatelessWidget {
  final Priority priority;

  const PriorityIndicator({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(priority);
    final priorityLabel = _getPriorityLabel(priority);

    return Column(
      children: [
        Container(
          width: RoutineCardConstants.priorityIndicatorWidth,
          height: RoutineCardConstants.priorityIndicatorHeight,
          decoration: BoxDecoration(
            color: priorityColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          priorityLabel,
          style: RoutineCardStyles.priorityLabelStyle(priorityColor),
        ),
      ],
    );
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
}

// 완료 버튼 위젯
class CompletionButton extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onTap;
  final double size;

  const CompletionButton({
    super.key,
    required this.isCompleted,
    required this.onTap,
    this.size = RoutineCardConstants.buttonSize,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isCompleted ? '완료됨' : '완료하기',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted ? Colors.green.shade200 : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green.shade600 : Colors.grey.shade400,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
