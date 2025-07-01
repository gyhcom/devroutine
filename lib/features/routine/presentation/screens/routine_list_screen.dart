import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/entities/routine.dart';
import '../providers/routine_provider.dart';
import '../widgets/routine_list_item.dart';

@RoutePage()
class RoutineListScreen extends ConsumerWidget {
  const RoutineListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routineState = ref.watch(routineNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Routines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(routineNotifierProvider.notifier).refreshRoutines(),
          ),
        ],
      ),
      body: routineState.when(
        initial: () => const Center(child: Text('Start adding your routines!')),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (routines) => _buildRoutineList(context, ref, routines),
        error: (message) => Center(child: Text('Error: $message')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.router.push(RoutineFormRoute());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRoutineList(
      BuildContext context, WidgetRef ref, List<Routine> routines) {
    if (routines.isEmpty) {
      return const Center(child: Text('No routines yet. Start by adding one!'));
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(routineNotifierProvider.notifier).refreshRoutines(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: routines.length,
        itemBuilder: (context, index) {
          final routine = routines[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RoutineListItem(
              routine: routine,
              onTap: () {
                context.router.push(RoutineFormRoute(routine: routine));
              },
              onToggleActive: () {
                final updatedRoutine = routine.toggleActive();
                ref
                    .read(routineNotifierProvider.notifier)
                    .updateRoutine(updatedRoutine);
              },
              onDelete: () {
                ref
                    .read(routineNotifierProvider.notifier)
                    .deleteRoutine(routine.id);
              },
            ),
          );
        },
      ),
    );
  }
}
