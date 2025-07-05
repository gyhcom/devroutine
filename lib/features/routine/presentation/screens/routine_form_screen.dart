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
  late RoutineType _routineType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.routine?.title);
    _memoController = TextEditingController(text: widget.routine?.memo);
    _priority = widget.routine?.priority ?? Priority.medium;
    _routineType = widget.routine?.routineType ?? RoutineType.daily;
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
        title: Text(widget.routine == null ? '새 루틴' : '루틴 수정'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '오늘의 할 일',
                hintText: '예) 알고리즘 문제 1개 풀기',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '할 일을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: '메모 (선택사항)',
                hintText: '추가 메모를 입력하세요',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // 루틴 타입 선택
            Card(
              elevation: 0,
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '루틴 타입',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRoutineTypeOption(
                            title: '일일 루틴',
                            description: '매일 리셋',
                            icon: Icons.refresh,
                            color: Colors.teal,
                            isSelected: _routineType == RoutineType.daily,
                            onTap: () => setState(() {
                              _routineType = RoutineType.daily;
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildRoutineTypeOption(
                            title: '3일 루틴',
                            description: '3일간 지속',
                            icon: Icons.calendar_today,
                            color: Colors.blue,
                            isSelected: _routineType == RoutineType.threeDay,
                            onTap: () => setState(() {
                              _routineType = RoutineType.threeDay;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            DropdownButtonFormField<Priority>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: '우선순위',
                border: OutlineInputBorder(),
              ),
              items: Priority.values.map((priority) {
                String label;
                IconData icon;
                Color color;
                switch (priority) {
                  case Priority.high:
                    label = '높음';
                    icon = Icons.priority_high;
                    color = Colors.red;
                    break;
                  case Priority.medium:
                    label = '보통';
                    icon = Icons.remove;
                    color = Colors.orange;
                    break;
                  case Priority.low:
                    label = '낮음';
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
                widget.routine == null ? '루틴 생성' : '루틴 수정',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineTypeOption({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
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
          ? (_routineType == RoutineType.threeDay
              ? Routine.createThreeDayRoutine(
                  title: _titleController.text.trim(),
                  memo: _memoController.text.trim(),
                  tags: [],
                  targetCompletionCount: 1,
                  startDate: now,
                  priority: _priority,
                )
              : Routine.create(
                  title: _titleController.text.trim(),
                  memo: _memoController.text.trim(),
                  tags: [],
                  targetCompletionCount: 1,
                  startDate: now,
                  endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
                  priority: _priority,
                  routineType: RoutineType.daily,
                ))
          : widget.routine!.copyWith(
              title: _titleController.text.trim(),
              memo: _memoController.text.trim(),
              priority: _priority,
              updatedAt: now,
            );

      if (widget.routine == null) {
        ref.read(routineNotifierProvider.notifier).createRoutine(routine);
        await showTopMessage(context, '✅ 루틴이 생성되었습니다!');
      } else {
        ref.read(routineNotifierProvider.notifier).updateRoutine(routine);
        await showTopMessage(context, '✅ 루틴이 수정되었습니다!');
      }

      context.router.pop();
    }
  }
}
