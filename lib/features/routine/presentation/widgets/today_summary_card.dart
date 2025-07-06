import 'package:devroutine/features/routine/presentation/providers/routine_provider.dart';
import 'package:devroutine/features/routine/domain/entities/routine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodaySummaryCard extends ConsumerWidget {
  const TodaySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routineState = ref.watch(routineNotifierProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: routineState.maybeWhen(
          loaded: (routines) {
            // 오늘의 루틴 분석
            final todayAnalysis = _analyzeTodayRoutines(routines);

            // 전체 진행률 계산
            final totalTasks = todayAnalysis.dailyRoutines.length +
                todayAnalysis.threeDayGroups.length;
            final completedTasks = todayAnalysis.completedDailyRoutines +
                todayAnalysis.completedThreeDayGroups;
            final progress =
                totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

            // 진행률에 따른 색상 설정
            Color progressColor;
            if (progress >= 100) {
              progressColor = Colors.green;
            } else if (progress >= 50) {
              progressColor = Colors.orange;
            } else {
              progressColor = Theme.of(context).primaryColor;
            }

            return Column(
              children: [
                // 전체 요약
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildItem('📌 오늘의 할 일', '$totalTasks개'),
                    _buildItem('✅ 완료', '$completedTasks개'),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
                const SizedBox(height: 4),

                Text(
                  '${progress.toStringAsFixed(1)}% 완료',
                  style: TextStyle(
                    color: progress >= 100
                        ? Colors.green.shade700
                        : progress >= 50
                            ? Colors.orange.shade700
                            : Colors.blue.shade700, // 진행률에 따른 동적 색상
                    fontSize: 14, // 크기 증가
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 세부 분석
                if (totalTasks > 0) ...[
                  const SizedBox(height: 16),
                  _buildDetailedAnalysis(todayAnalysis),
                ],

                if (progress == 100) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.celebration, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '🎉 모든 할 일을 완료했습니다! 수고하셨습니다!',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
          orElse: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDetailedAnalysis(TodayAnalysis analysis) {
    return Column(
      children: [
        // 일일 루틴 요약
        if (analysis.dailyRoutines.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.today, color: Colors.blue.shade600, size: 16),
              const SizedBox(width: 4),
              Text(
                '일일 루틴: ${analysis.completedDailyRoutines}/${analysis.dailyRoutines.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: analysis.dailyRoutines.isNotEmpty
                      ? analysis.completedDailyRoutines /
                          analysis.dailyRoutines.length
                      : 0.0,
                  backgroundColor: Colors.blue.shade100,
                  valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ],

        // 3일 루틴 요약
        if (analysis.threeDayGroups.isNotEmpty) ...[
          if (analysis.dailyRoutines.isNotEmpty) const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.local_fire_department,
                  color: Colors.orange.shade600, size: 16),
              const SizedBox(width: 4),
              Text(
                '3일 챌린지: ${analysis.completedThreeDayGroups}/${analysis.threeDayGroups.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: analysis.threeDayGroups.isNotEmpty
                      ? analysis.completedThreeDayGroups /
                          analysis.threeDayGroups.length
                      : 0.0,
                  backgroundColor: Colors.orange.shade100,
                  valueColor: AlwaysStoppedAnimation(Colors.orange.shade400),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ],

        // 3일 루틴 개별 진행률 (선택적으로 표시)
        if (analysis.threeDayGroups.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...analysis.threeDayGroups.entries.map((entry) {
            final groupId = entry.key;
            final groupRoutines = entry.value;
            final groupName =
                groupRoutines.isNotEmpty ? groupRoutines.first.title : groupId;

            // 오늘 해야 할 일차만 확인
            final todayRoutine = groupRoutines.where((r) {
              final today = DateTime.now();
              final routineDate = r.createdAt;
              final dayNumber = r.dayNumber ?? 1;
              final targetDate = DateTime(
                routineDate.year,
                routineDate.month,
                routineDate.day + (dayNumber - 1),
              );
              return targetDate.year == today.year &&
                  targetDate.month == today.month &&
                  targetDate.day == today.day;
            }).toList();

            final isFullyCompleted = todayRoutine.isNotEmpty &&
                todayRoutine.every((r) => r.isCompletedToday == true);
            final completedCount =
                groupRoutines.where((r) => r.isCompletedToday == true).length;
            final totalCount = groupRoutines.length;
            final completionRate =
                analysis.threeDayGroupCompletionRates[groupId] ?? 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isFullyCompleted
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isFullyCompleted
                      ? Colors.green.shade200
                      : Colors.orange.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isFullyCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isFullyCompleted
                        ? Colors.green.shade600
                        : Colors.orange.shade400,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      groupName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$completedCount/$totalCount',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  TodayAnalysis _analyzeTodayRoutines(List<Routine> allRoutines) {
    final dailyRoutines = <Routine>[];
    final threeDayGroups = <String, List<Routine>>{};
    final threeDayGroupCompletionRates = <String, double>{};

    // 일일 루틴과 3일 루틴 분류
    for (final routine in allRoutines) {
      if (routine.isThreeDayRoutine && routine.groupId != null) {
        // groupId를 키로 사용하여 그룹화
        threeDayGroups.putIfAbsent(routine.groupId!, () => []).add(routine);
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

    // 3일 루틴 그룹별 완성도 계산
    int completedThreeDayGroups = 0;
    for (final entry in threeDayGroups.entries) {
      final groupId = entry.key;
      final groupRoutines = entry.value;

      // 그룹이 완전한지 확인 (3개 루틴이 모두 있는지)
      if (groupRoutines.length < 3) {
        // 불완전한 그룹은 제외하고 완성도 0%로 설정
        threeDayGroupCompletionRates[groupId] = 0.0;
        continue;
      }

      // 오늘 해야 할 일차 확인
      final today = DateTime.now();
      final todayRoutines = groupRoutines.where((r) {
        final routineDate = DateTime(
          r.startDate.year,
          r.startDate.month,
          r.startDate.day,
        );
        final todayDate = DateTime(today.year, today.month, today.day);
        return routineDate.isAtSameMomentAs(todayDate);
      }).toList();

      // 오늘 할 일이 있고 완료되었으면 그룹 완료로 카운트
      if (todayRoutines.isNotEmpty &&
          todayRoutines.every((r) => r.isCompletedToday == true)) {
        completedThreeDayGroups++;
      }

      // 전체 그룹 완성도 계산 (삭제된 루틴 고려)
      final completedInGroup =
          groupRoutines.where((r) => r.isCompletedToday == true).length;
      threeDayGroupCompletionRates[groupId] =
          completedInGroup / groupRoutines.length;
    }

    return TodayAnalysis(
      dailyRoutines: dailyRoutines,
      threeDayGroups: threeDayGroups,
      completedDailyRoutines: completedDailyRoutines,
      completedThreeDayGroups: completedThreeDayGroups,
      threeDayGroupCompletionRates: threeDayGroupCompletionRates,
    );
  }
}

class TodayAnalysis {
  final List<Routine> dailyRoutines;
  final Map<String, List<Routine>> threeDayGroups;
  final int completedDailyRoutines;
  final int completedThreeDayGroups;
  final Map<String, double> threeDayGroupCompletionRates;

  TodayAnalysis({
    required this.dailyRoutines,
    required this.threeDayGroups,
    required this.completedDailyRoutines,
    required this.completedThreeDayGroups,
    required this.threeDayGroupCompletionRates,
  });
}
