import 'package:auto_route/auto_route.dart';
import 'package:devroutine/core/routing/app_router.dart';
import 'package:devroutine/features/routine/presentation/providers/routine_provider.dart';
import 'package:devroutine/features/routine/presentation/utils/priority_color_util.dart';
import 'package:devroutine/features/routine/presentation/widgets/routine_card.dart';
import 'package:devroutine/features/routine/presentation/widgets/today_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

@RoutePage()
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyRoutines Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.router.push(RoutineFormRoute()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(routineNotifierProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildGreeting(),
            const SizedBox(height: 16),
            const TodaySummaryCard(),
            const SizedBox(height: 16),
            _buildGoToRoutineList(context),
            const SizedBox(height: 16),
            _buildTodayRoutines(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final now = DateTime.now();
    final formattedDate = DateFormat('MMMM d, yyyy (EEEE)').format(now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hello, Developer 👋',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(formattedDate, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildGoToRoutineList(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.router.push(const RoutineListRoute()),
      icon: const Icon(Icons.list),
      label: const Text('View All Routines'),
    );
  }

  Widget _buildTodayRoutines(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Routines',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, child) {
            return ref.watch(routineNotifierProvider).maybeWhen(
                  loaded: (routines) {
                    if (routines.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text('No routines for today'),
                        ),
                      );
                    }

                    // Calculate grid dimensions
                    const crossAxisCount = 3;
                    final itemCount = routines.length;

                    // Calculate grid height based on number of items
                    final rowCount = (itemCount / crossAxisCount).ceil();
                    final gridHeight = rowCount * 120.0; // 각 카드의 높이를 120으로 설정

                    return SizedBox(
                      height: gridHeight,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1, // Square aspect ratio
                        ),
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          final routine = routines[index];
                          return RoutineCard(
                            routine: routine,
                            borderColor:
                                getPriorityBorderColor(routine.priority),
                            onTap: () => context.router
                                .push(RoutineFormRoute(routine: routine)),
                          );
                        },
                      ),
                    );
                  },
                  orElse: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
          },
        ),
      ],
    );
  }
}
