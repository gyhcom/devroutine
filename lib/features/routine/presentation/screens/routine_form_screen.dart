import 'package:auto_route/auto_route.dart';
import 'package:devroutine/features/routine/presentation/widgets/flush_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/routine.dart';
import '../providers/routine_provider.dart';

@RoutePage()
class RoutineFormScreen extends ConsumerStatefulWidget {
  final Routine? routine;

  const RoutineFormScreen({super.key, this.routine});

  @override
  ConsumerState<RoutineFormScreen> createState() => _RoutineFormScreenState();
}

class _RoutineFormScreenState extends ConsumerState<RoutineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _memoController;
  late Priority _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.routine?.title);
    _memoController = TextEditingController(text: widget.routine?.memo);
    _priority = widget.routine?.priority ?? Priority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine == null ? 'New Routine' : 'Edit Routine'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Today\'s Task',
                hintText: 'ex) Solve one algorithm problem',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: 'Memo (Optional)',
                hintText: 'Add additional notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Priority>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: Priority.values.map((priority) {
                String label;
                IconData icon;
                Color color;
                switch (priority) {
                  case Priority.high:
                    label = 'High';
                    icon = Icons.priority_high;
                    color = Colors.red;
                    break;
                  case Priority.medium:
                    label = 'Medium';
                    icon = Icons.remove;
                    color = Colors.orange;
                    break;
                  case Priority.low:
                    label = 'Low';
                    icon = Icons.arrow_downward;
                    color = Colors.green;
                    break;
                }
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(icon, color: color),
                      const SizedBox(width: 8),
                      Text(label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _priority = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveRoutine,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.routine == null ? 'Create Routine' : 'Update Routine',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveRoutine() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final routine = widget.routine == null
          ? Routine.create(
              title: _titleController.text.trim(),
              memo: _memoController.text.trim(),
              tags: [],
              targetCompletionCount: 1,
              startDate: now,
              endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
              priority: _priority,
            )
          : widget.routine!.copyWith(
              title: _titleController.text.trim(),
              memo: _memoController.text.trim(),
              priority: _priority,
              updatedAt: now,
            );

      if (widget.routine == null) {
        ref.read(routineNotifierProvider.notifier).createRoutine(routine);
        await showTopMessage(context, '✅ Routine created successfully!');
      } else {
        ref.read(routineNotifierProvider.notifier).updateRoutine(routine);
        await showTopMessage(context, '✅ Routine updated successfully!');
      }

      context.router.pop();
    }
  }
}
