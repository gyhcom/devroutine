import 'package:auto_route/auto_route.dart';
import 'package:devroutine/features/routine/presentation/widgets/flush_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/routine.dart';
import '../providers/routine_provider.dart';
import '../../../../core/widgets/banner_ad_widget.dart';

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
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.routine == null ? '새 루틴' : '루틴 수정',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2188FF),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: orientation == Orientation.landscape
                    ? _buildLandscapeLayout()
                    : _buildPortraitLayout(),
              ),
            ),
          ),
          // 광고 배너 추가
          Container(
            color: Colors.grey.shade100,
            child: const BannerAdWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return ListView(
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
        _buildRoutineTypeSection(),
        const SizedBox(height: 16),
        _buildPriorityDropdown(),
        const SizedBox(height: 24),
        _buildSubmitButton(),
        if (widget.routine != null) ...[
          const SizedBox(height: 16),
          _buildDeleteButton(),
        ],
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 상단: 텍스트 필드들
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
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
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _memoController,
                  decoration: const InputDecoration(
                    labelText: '메모 (선택사항)',
                    hintText: '추가 메모를 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 중간: 루틴 타입과 우선순위
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildRoutineTypeSection(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _buildPriorityDropdown(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 하단: 버튼들
          Row(
            children: [
              Expanded(
                child: _buildSubmitButton(),
              ),
              if (widget.routine != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDeleteButton(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineTypeSection() {
    return Card(
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
                    description: '3개 루틴 생성',
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
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<Priority>(
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
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _saveRoutine,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.routine == null ? Icons.add : Icons.edit,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            widget.routine == null ? '루틴 생성' : '루틴 수정',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return OutlinedButton(
      onPressed: _showDeleteConfirmation,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: Colors.red.shade400),
        foregroundColor: Colors.red.shade600,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, size: 20),
          const SizedBox(width: 8),
          const Text(
            '루틴 삭제',
            style: TextStyle(fontSize: 16),
          ),
        ],
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
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
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
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
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

  // 삭제 확인 다이얼로그 표시
  Future<void> _showDeleteConfirmation() async {
    if (widget.routine == null) return;

    final routine = widget.routine!;

    // 3일 루틴의 경우 그룹 삭제 확인
    if (routine.isThreeDayRoutine && routine.groupId != null) {
      await _showThreeDayRoutineDeleteDialog();
    } else {
      // 일일 루틴 삭제 확인
      await _showSingleRoutineDeleteDialog();
    }
  }

  // 일일 루틴 삭제 확인 다이얼로그
  Future<void> _showSingleRoutineDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text('루틴 삭제'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${widget.routine!.title}" 루틴을 삭제하시겠습니까?',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '이 작업은 되돌릴 수 없습니다.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade600,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteRoutine();
    }
  }

  // 3일 루틴 삭제 확인 다이얼로그
  Future<void> _showThreeDayRoutineDeleteDialog() async {
    final routine = widget.routine!;
    final notifier = ref.read(routineNotifierProvider.notifier);

    // 현재 루틴 상태에서 그룹 정보 가져오기
    final routineState = ref.read(routineNotifierProvider);
    List<Routine> allRoutines = [];

    routineState.whenOrNull(
      loaded: (routines) => allRoutines = routines,
    );

    final groupRoutines =
        notifier.getThreeDayGroupRoutines(routine.groupId!, allRoutines);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('3일 루틴 삭제'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${routine.title}" 루틴을 삭제하시겠습니까?',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ 3일 루틴은 그룹으로 관리됩니다',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '현재 그룹에 ${groupRoutines.length}개의 루틴이 있습니다.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'single'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange.shade600,
            ),
            child: const Text('이 루틴만 삭제'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'group'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade600,
            ),
            child: const Text('전체 그룹 삭제'),
          ),
        ],
      ),
    );

    if (result == 'single') {
      // 개별 루틴 삭제
      await _deleteRoutine();
    } else if (result == 'group') {
      // 전체 그룹 삭제
      await _deleteThreeDayGroup();
    }
  }

  // 루틴 삭제 실행
  Future<void> _deleteRoutine() async {
    try {
      await ref
          .read(routineNotifierProvider.notifier)
          .deleteRoutine(widget.routine!.id);
      await showTopMessage(context, '✅ 루틴이 삭제되었습니다!');
      context.router.pop();
    } catch (e) {
      await showTopMessage(context, '❌ 루틴 삭제 중 오류가 발생했습니다.');
    }
  }

  // 3일 루틴 그룹 삭제 실행
  Future<void> _deleteThreeDayGroup() async {
    try {
      await ref
          .read(routineNotifierProvider.notifier)
          .deleteThreeDayGroup(widget.routine!.groupId!);
      await showTopMessage(context, '✅ 3일 루틴 그룹이 삭제되었습니다!');
      context.router.pop();
    } catch (e) {
      await showTopMessage(context, '❌ 그룹 삭제 중 오류가 발생했습니다.');
    }
  }

  Future<void> _saveRoutine() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      bool success = false;

      try {
        if (widget.routine == null) {
          // 새 루틴 생성
          if (_routineType == RoutineType.threeDay) {
            // 3일 루틴: 3개의 루틴 생성
            // print('🚀 3일 루틴 생성 시작...');
            final today = DateTime(now.year, now.month, now.day);

            final threeDayRoutines = Routine.createThreeDayRoutines(
              title: _titleController.text.trim(),
              memo: _memoController.text.trim(),
              tags: [],
              targetCompletionCount: 1,
              startDate: today,
              priority: _priority,
            );

            // print('📝 생성할 3일 루틴 개수: ${threeDayRoutines.length}');
            success = await ref
                .read(routineNotifierProvider.notifier)
                .createThreeDayRoutines(threeDayRoutines);
            // print('✅ 3일 루틴 생성 결과: $success');

            if (success) {
              await showTopMessage(context, '🚀 3일 챌린지가 시작되었습니다! 함께 완주해봐요!');
            } else {
              await showTopMessage(context, '❌ 3일 루틴 생성에 실패했습니다.');
            }
          } else {
            // 일일 루틴: 1개의 루틴 생성
            // print('📅 일일 루틴 생성 시작...');
            final routine = Routine.create(
              title: _titleController.text.trim(),
              memo: _memoController.text.trim(),
              tags: [],
              targetCompletionCount: 1,
              startDate: now,
              endDate: null, // 일일 루틴은 종료일 없이 계속 반복
              priority: _priority,
              routineType: RoutineType.daily,
            );

            success = await ref
                .read(routineNotifierProvider.notifier)
                .createRoutine(routine);
            // print('✅ 일일 루틴 생성 결과: $success');

            if (success) {
              await showTopMessage(context, '✅ 루틴이 생성되었습니다!');
            } else {
              await showTopMessage(context, '❌ 루틴 생성에 실패했습니다.');
            }
          }
        } else {
          // 기존 루틴 수정
          // print('✏️ 루틴 수정 시작...');
          final updatedRoutine = widget.routine!.copyWith(
            title: _titleController.text.trim(),
            memo: _memoController.text.trim(),
            priority: _priority,
            updatedAt: now,
          );

          success = await ref
              .read(routineNotifierProvider.notifier)
              .updateRoutine(updatedRoutine);
          // print('✅ 루틴 수정 결과: $success');

          if (success) {
            await showTopMessage(context, '✅ 루틴이 수정되었습니다!');
          } else {
            await showTopMessage(context, '❌ 루틴 수정에 실패했습니다.');
          }
        }

        // 성공한 경우에만 화면 닫기
        if (success) {
          // print('🔄 화면 닫기 시작...');
          context.router.pop();
          // print('✅ 화면 닫기 완료');
        } else {
          // print('❌ 작업이 실패하여 화면을 닫지 않습니다.');
        }
      } catch (e) {
        // print('💥 _saveRoutine 예외 발생: $e');
        await showTopMessage(context, '❌ 예상치 못한 오류가 발생했습니다: $e');
      }
    }
  }
}
