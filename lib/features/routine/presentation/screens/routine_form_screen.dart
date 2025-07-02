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
  late TextEditingController _tagController;
  late DateTime _startDate;
  DateTime? _endDate;
  late int _targetCompletionCount;
  String? _category;
  late Priority _priority;
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.routine?.title);
    _memoController = TextEditingController(text: widget.routine?.memo);
    _tagController = TextEditingController();
    _startDate = widget.routine?.startDate ?? DateTime.now();
    _endDate = widget.routine?.endDate;
    _targetCompletionCount = widget.routine?.targetCompletionCount ?? 1;
    _category = widget.routine?.category;
    _priority = widget.routine?.priority ?? Priority.medium;
    if (widget.routine != null) {
      _tags.addAll(widget.routine!.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine == null ? 'Create Routine' : 'Edit Routine'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: '메모 (선택사항)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
                switch (priority) {
                  case Priority.high:
                    label = '높음';
                    break;
                  case Priority.medium:
                    label = '중간';
                    break;
                  case Priority.low:
                    label = '낮음';
                    break;
                }
                return DropdownMenuItem(
                  value: priority,
                  child: Text(label),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: 'Add Tag',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTag,
                  child: const Text('Add'),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: _targetCompletionCount.toString(),
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Target Completion Count',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null ||
                          int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _targetCompletionCount =
                          int.tryParse(value) ?? _targetCompletionCount;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: _startDate.toString().split(' ')[0],
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: _endDate?.toString().split(' ')[0] ?? '',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'End Date (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveRoutine,
              child: Text(widget.routine == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : (_endDate ?? _startDate),
      firstDate: isStartDate ? DateTime.now() : _startDate,
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveRoutine() async {
    if (_formKey.currentState!.validate()) {
      final routine = widget.routine == null
          ? Routine.create(
              title: _titleController.text.trim(),
              memo: _memoController.text.trim(),
              tags: _tags,
              targetCompletionCount: _targetCompletionCount,
              startDate: _startDate,
              endDate: _endDate,
              category: _category,
              priority: _priority,
            )
          : widget.routine!.copyWith(
              title: _titleController.text.trim(),
              memo: _memoController.text.trim(),
              tags: _tags,
              targetCompletionCount: _targetCompletionCount,
              startDate: _startDate,
              endDate: _endDate,
              category: _category,
              priority: _priority,
            );

      if (widget.routine == null) {
        ref.read(routineNotifierProvider.notifier).createRoutine(routine);
        await showTopMessage(context, '✅ 루틴이 생성되었습니다!');
      } else {
        ref.read(routineNotifierProvider.notifier).updateRoutine(routine);
        await showTopMessage(context, '✅ 루틴이 업데이트되었습니다!');
      }

      context.router.pop();
    }
  }
}
