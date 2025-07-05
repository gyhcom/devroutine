import 'package:devroutine/features/routine/presentation/providers/routine_provider.dart';
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
            // 오늘의 루틴만 필터링
            final todayRoutines = ref
                .read(routineNotifierProvider.notifier)
                .getTodayRoutines(routines);
            final todayCount = todayRoutines.length;
            final completedCount = ref
                .read(routineNotifierProvider.notifier)
                .getCompletedRoutinesCount(todayRoutines);

            // 진행률 계산
            final progress =
                todayCount > 0 ? (completedCount / todayCount) * 100 : 0.0;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildItem('📌 오늘의 할 일', '$todayCount개'),
                    _buildItem('✅ 완료', '$completedCount개'),
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
                    color: progressColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (progress == 100) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '🎉 모든 할 일을 완료했습니다! 수고하셨습니다!',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
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
}
