import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:devroutine/core/routing/app_router.dart';
import 'package:devroutine/features/routine/domain/entities/routine.dart';
import 'package:devroutine/features/routine/presentation/providers/routine_provider.dart';
import 'package:devroutine/features/routine/presentation/utils/priority_color_util.dart';

// 상수 정의
class SummaryCardConstants {
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 16.0;
  static const double cardPadding = 12.0;
  static const double iconSize = 20.0;
  static const double progressBarHeight = 6.0;
  static const double spacing = 8.0;
  static const double largeSpacing = 16.0;
  static const double smallSpacing = 6.0;
  static const double mediumSpacing = 12.0;
  static const double sectionSpacing = 16.0;
  static const double itemBorderRadius = 8.0;
  static const double progressBarBorderRadius = 6.0;
}

// 스타일 클래스
class SummaryCardStyles {
  static TextStyle get titleStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      );

  static TextStyle get subtitleStyle => TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get valueStyle => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.2,
      );

  static TextStyle get labelStyle => TextStyle(
        color: Colors.grey.shade600,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );

  static TextStyle progressTextStyle(Color color) => TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get celebrationTextStyle => TextStyle(
        color: Colors.green.shade700,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  static BoxDecoration get celebrationDecoration => BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(SummaryCardConstants.itemBorderRadius),
        border: Border.all(color: Colors.green.shade300, width: 1.5),
      );
}

// 진행률 관련 유틸리티
class ProgressUtils {
  static Color getProgressColor(double progress, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (progress >= 100) {
      // 완료: 녹색 - 다크모드에서는 더 밝고 생동감 있는 녹색
      return isDark ? const Color(0xFF4ADE80) : Colors.green.shade600;
    }
    if (progress >= 80) {
      // 거의 완료: 연한 녹색 - 다크모드에서는 라임 그린
      return isDark ? const Color(0xFF84CC16) : Colors.lightGreen.shade600;
    }
    if (progress >= 60) {
      // 많이 진행: 파란색 - 다크모드에서는 스카이 블루
      return isDark ? const Color(0xFF3B82F6) : Colors.blue.shade600;
    }
    if (progress >= 40) {
      // 중간 진행: 청록색 - 다크모드에서는 에메랄드
      return isDark ? const Color(0xFF10B981) : Colors.cyan.shade600;
    }
    if (progress >= 20) {
      // 조금 진행: 다크모드에서는 황금색, 라이트에서는 보라색
      return isDark ? const Color(0xFFF59E0B) : Colors.purple.shade500;
    }
    // 시작: 다크모드에서는 코랄 오렌지, 라이트에서는 남색
    return isDark ? const Color(0xFFEF4444) : Colors.indigo.shade500;
  }

  static Color getProgressTextColor(double progress) {
    if (progress >= 100) return const Color(0xFF15803D); // 완료: 진한 녹색
    if (progress >= 80) return const Color(0xFF65A30D); // 거의 완료: 진한 라임
    if (progress >= 60) return const Color(0xFF1D4ED8); // 많이 진행: 진한 파란색
    if (progress >= 40) return const Color(0xFF047857); // 중간 진행: 진한 에메랄드
    if (progress >= 20) return const Color(0xFFD97706); // 조금 진행: 진한 황금색
    return const Color(0xFFDC2626); // 시작: 진한 빨간색
  }

  static String getProgressMessage(double progress, int remaining) {
    if (progress >= 100) return '모든 루틴 완료';
    if (remaining == 1) return '마지막 루틴 남음';
    if (remaining <= 3) return '${remaining}개 남음';
    if (progress >= 80) return '거의 완료';
    if (progress >= 60) return '순조롭게 진행 중';
    if (progress >= 40) return '절반 완료';
    if (progress >= 20) return '시작함';
    return '${remaining}개 남음';
  }
}

// 진행률 데이터 클래스
class ProgressData {
  final int totalTasks;
  final int completedTasks;
  final double progress;
  final Color color;
  final Color textColor;
  final String message;

  ProgressData({
    required this.totalTasks,
    required this.completedTasks,
    required this.progress,
    required BuildContext context,
  })  : color = ProgressUtils.getProgressColor(progress, context),
        textColor = ProgressUtils.getProgressTextColor(progress),
        message = ProgressUtils.getProgressMessage(
            progress, totalTasks - completedTasks);

  bool get isComplete => progress >= 100;
  bool get isEmpty => totalTasks == 0;
  int get remaining => totalTasks - completedTasks;
}

class TodaySummaryCard extends ConsumerStatefulWidget {
  const TodaySummaryCard({super.key});

  @override
  ConsumerState<TodaySummaryCard> createState() => _TodaySummaryCardState();
}

class _TodaySummaryCardState extends ConsumerState<TodaySummaryCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _celebrationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _celebrationScaleAnimation;
  late Animation<double> _celebrationFadeAnimation;
  late Animation<double> _celebrationBounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // 축하 메시지용 애니메이션들
    _celebrationScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _celebrationFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
    ));

    _celebrationBounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: const Interval(0.3, 1.0, curve: Curves.bounceOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routineState = ref.watch(routineNotifierProvider);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Card(
              elevation: SummaryCardConstants.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    SummaryCardConstants.cardBorderRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(SummaryCardConstants.cardPadding),
                child: routineState.maybeWhen(
                  loaded: (routines) => _buildLoadedContent(context, routines),
                  loading: () => _buildLoadingState(),
                  orElse: () => _buildEmptyState(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 80,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation(Theme.of(context).primaryColor),
            ),
            const SizedBox(height: SummaryCardConstants.smallSpacing),
            Text(
              '현황 확인 중...',
              style: SummaryCardStyles.subtitleStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: () {
        context.router.push(RoutineFormRoute());
      },
      child: SizedBox(
        height: 80,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.today_outlined,
                size: 32,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: SummaryCardConstants.smallSpacing),
              Text(
                '오늘 할 루틴을 추가해보세요',
                style: SummaryCardStyles.subtitleStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, List<Routine> routines) {
    final todayAnalysis = _analyzeTodayRoutines(routines);
    final progressData = _calculateProgress(context, todayAnalysis);

    if (progressData.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildQuickStats(progressData),
        const SizedBox(height: SummaryCardConstants.smallSpacing),
        _buildPriorityBreakdown(todayAnalysis),
        const SizedBox(height: SummaryCardConstants.mediumSpacing),
        _buildProgressSection(progressData),
      ],
    );
  }

  Widget _buildQuickStats(ProgressData progressData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 다크 모드에서는 밝은 슬레이트 블루, 라이트 모드에서는 인디고
    final todayTaskColor =
        isDark ? const Color(0xFF6366F1) : Colors.indigo.shade600;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.assignment_outlined,
            label: '오늘의 할 일',
            value: progressData.totalTasks.toString(),
            color: todayTaskColor, // WCAG 준수 다크 모드 색상
          ),
        ),
        Container(
          width: 1,
          height: 50,
          color: Colors.grey.shade300,
          margin: const EdgeInsets.symmetric(
              horizontal: SummaryCardConstants.mediumSpacing),
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.check_circle_outline,
            label: '완료',
            value: progressData.completedTasks.toString(),
            color: progressData.color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: SummaryCardConstants.iconSize),
        const SizedBox(height: SummaryCardConstants.smallSpacing),
        Text(
          value,
          style: SummaryCardStyles.valueStyle.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: SummaryCardStyles.labelStyle.copyWith(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(ProgressData progressData) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${progressData.progress.toStringAsFixed(0)}% 완료',
              style:
                  SummaryCardStyles.progressTextStyle(progressData.textColor),
            ),
            Text(
              progressData.message,
              style: SummaryCardStyles.subtitleStyle.copyWith(
                color: progressData.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: SummaryCardConstants.mediumSpacing),
        ClipRRect(
          borderRadius: BorderRadius.circular(
              SummaryCardConstants.progressBarBorderRadius),
          child: LinearProgressIndicator(
            value: progressData.progress / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(progressData.color),
            minHeight: SummaryCardConstants.progressBarHeight,
          ),
        ),
      ],
    );
  }

  Widget _buildCelebrationMessage() {
    // 축하 메시지가 처음 나타날 때 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_celebrationController.status == AnimationStatus.dismissed) {
        _celebrationController.forward();
      }
    });

    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _celebrationFadeAnimation,
          child: Transform.scale(
            scale: _celebrationScaleAnimation.value,
            child: Transform.translate(
              offset: Offset(0, (1 - _celebrationBounceAnimation.value) * 10),
              child: Container(
                padding:
                    const EdgeInsets.all(SummaryCardConstants.mediumSpacing),
                decoration: SummaryCardStyles.celebrationDecoration.copyWith(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(
                          alpha: 0.2 * _celebrationFadeAnimation.value),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.rotate(
                      angle: _celebrationBounceAnimation.value * 0.2,
                      child: Icon(
                        Icons.celebration,
                        color: Colors.green.shade600,
                        size: SummaryCardConstants.iconSize,
                      ),
                    ),
                    const SizedBox(width: SummaryCardConstants.spacing),
                    Flexible(
                      child: Text(
                        '오늘 할 일 완료!',
                        style: SummaryCardStyles.celebrationTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ProgressData _calculateProgress(
      BuildContext context, TodayAnalysis analysis) {
    final totalTasks =
        analysis.dailyRoutines.length + analysis.threeDayGroups.length;
    final completedTasks =
        analysis.completedDailyRoutines + analysis.completedThreeDayGroups;
    final progress = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

    return ProgressData(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      progress: progress,
      context: context,
    );
  }

  TodayAnalysis _analyzeTodayRoutines(List<Routine> allRoutines) {
    // 오늘 날짜 캐싱 (성능 최적화)
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final dailyRoutines = <Routine>[];
    final allThreeDayGroups = <String, List<Routine>>{};
    final todayThreeDayGroups = <String, List<Routine>>{};

    // 일일 루틴과 3일 루틴 분류
    for (final routine in allRoutines) {
      if (routine.isThreeDayRoutine && routine.groupId != null) {
        // 전체 3일 루틴 그룹화
        allThreeDayGroups.putIfAbsent(routine.groupId!, () => []).add(routine);
      } else if (!routine.isThreeDayRoutine) {
        // 활성화된 일일 루틴만 포함
        if (routine.isActive) {
          dailyRoutines.add(routine);
        }
      }
    }

    // 완료된 일일 루틴 수 계산 (오늘 완료된 것만)
    final completedDailyRoutines =
        dailyRoutines.where((r) => r.isCompletedToday == true).length;

    // 3일 루틴 그룹별 완성도 계산 및 오늘 해야 할 그룹 필터링
    int completedThreeDayGroups = 0;
    for (final entry in allThreeDayGroups.entries) {
      final groupId = entry.key;
      final groupRoutines = entry.value;

      // 그룹이 완전한지 확인 (3개 루틴이 모두 있는지)
      if (groupRoutines.length < 3) {
        continue;
      }

      // 오늘 해야 할 일차 확인 (캐시된 날짜 사용)
      final todayRoutines = groupRoutines.where((r) {
        final routineDate = DateTime(
          r.startDate.year,
          r.startDate.month,
          r.startDate.day,
        );
        return routineDate.isAtSameMomentAs(todayDate);
      }).toList();

      // 오늘 해야 할 일이 있는 그룹만 포함
      if (todayRoutines.isNotEmpty) {
        todayThreeDayGroups[groupId] = groupRoutines;

        // 오늘 할 일이 완료되었으면 그룹 완료로 카운트
        if (todayRoutines.every((r) => r.isCompletedToday == true)) {
          completedThreeDayGroups++;
        }
      }
    }

    return TodayAnalysis(
      dailyRoutines: dailyRoutines,
      threeDayGroups: todayThreeDayGroups, // 오늘 해야 할 그룹만 포함
      completedDailyRoutines: completedDailyRoutines,
      completedThreeDayGroups: completedThreeDayGroups,
    );
  }

  Widget _buildPriorityBreakdown(TodayAnalysis analysis) {
    // 오늘의 모든 루틴을 가져오기
    final allTodayRoutines = <Routine>[];

    // 일일 루틴 추가
    allTodayRoutines.addAll(analysis.dailyRoutines);

    // 3일 루틴 중 오늘 해야 할 것들 추가
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (final groupRoutines in analysis.threeDayGroups.values) {
      final todayRoutines = groupRoutines.where((r) {
        final routineDate = DateTime(
          r.startDate.year,
          r.startDate.month,
          r.startDate.day,
        );
        return routineDate.isAtSameMomentAs(todayDate);
      }).toList();
      allTodayRoutines.addAll(todayRoutines);
    }

    // 우선순위별 개수 계산
    final priorityCounts = <Priority, int>{};
    for (final routine in allTodayRoutines) {
      priorityCounts[routine.priority] =
          (priorityCounts[routine.priority] ?? 0) + 1;
    }

    // 우선순위별 완료 개수 계산
    final priorityCompletedCounts = <Priority, int>{};
    for (final routine in allTodayRoutines) {
      if (routine.isCompletedToday == true) {
        priorityCompletedCounts[routine.priority] =
            (priorityCompletedCounts[routine.priority] ?? 0) + 1;
      }
    }

    if (priorityCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final priorityOrder = [Priority.high, Priority.medium, Priority.low];
    final priorityItems = <Widget>[];

    for (final priority in priorityOrder) {
      final count = priorityCounts[priority] ?? 0;
      final completed = priorityCompletedCounts[priority] ?? 0;

      if (count > 0) {
        priorityItems.add(
          _buildPriorityItem(priority, completed, count),
        );
      }
    }

    if (priorityItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SummaryCardConstants.mediumSpacing,
        vertical: SummaryCardConstants.smallSpacing,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
            BorderRadius.circular(SummaryCardConstants.itemBorderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: priorityItems,
      ),
    );
  }

  Widget _buildPriorityItem(Priority priority, int completed, int total) {
    final color = getPriorityTextColor(priority);
    final label = getPriorityLabel(priority);
    final icon = getPriorityIcon(priority);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            children: [
              TextSpan(text: label),
              const TextSpan(text: ' '),
              TextSpan(
                text: '$completed/$total',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: completed == total ? Colors.green.shade600 : color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TodayAnalysis {
  final List<Routine> dailyRoutines;
  final Map<String, List<Routine>> threeDayGroups;
  final int completedDailyRoutines;
  final int completedThreeDayGroups;

  TodayAnalysis({
    required this.dailyRoutines,
    required this.threeDayGroups,
    required this.completedDailyRoutines,
    required this.completedThreeDayGroups,
  });
}
