import 'package:flutter/material.dart';
import '../../domain/entities/routine.dart';

// 상수 정의
class RoutineListItemConstants {
  static const double cardBorderRadius = 12.0;
  static const double cardElevation = 1.0; // 2.0에서 1.0으로 줄임
  static const double cardPadding = 12.0; // 16.0에서 12.0으로 줄임
  static const double iconSize = 20.0;
  static const double priorityIconSize = 18.0; // 20.0에서 18.0으로 줄임
  static const double spacing = 8.0;
  static const double smallSpacing = 4.0;
  static const double borderWidth = 1.5; // 2.0에서 1.5로 줄임
  static const double minTouchTarget = 44.0; // Material Design 권장 최소 터치 타겟
}

// 스타일 클래스
class RoutineListItemStyles {
  static TextStyle titleStyle(BuildContext context) => TextStyle(
        fontSize: 16, // titleLarge보다 작게
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle memoStyle(BuildContext context) => TextStyle(
        fontSize: 13, // bodyMedium보다 작게
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        height: 1.3,
      );

  static TextStyle progressStyle(BuildContext context) => TextStyle(
        fontSize: 12, // bodySmall보다 작게
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        fontWeight: FontWeight.w500,
      );

  static TextStyle chipTextStyle(BuildContext context) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      );
}

class RoutineListItem extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;
  final VoidCallback? onToggleCompletion;
  final Color borderColor;

  const RoutineListItem({
    super.key,
    required this.routine,
    required this.onTap,
    required this.onToggleActive,
    required this.onDelete,
    this.onToggleCompletion,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '루틴: ${routine.title}',
      hint: '탭하여 수정, 스위치로 활성화/비활성화, 삭제 버튼 사용 가능',
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor.withOpacity(0.6), // 투명도 추가로 부드럽게
            width: RoutineListItemConstants.borderWidth,
          ),
          borderRadius:
              BorderRadius.circular(RoutineListItemConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.08), // 미세한 그림자
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          elevation: RoutineListItemConstants.cardElevation,
          borderRadius:
              BorderRadius.circular(RoutineListItemConstants.cardBorderRadius),
          color: theme.colorScheme.surface,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
                RoutineListItemConstants.cardBorderRadius),
            child: Padding(
              padding:
                  const EdgeInsets.all(RoutineListItemConstants.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  if (routine.memo != null && routine.memo!.isNotEmpty) ...[
                    const SizedBox(
                        height: RoutineListItemConstants.smallSpacing),
                    _buildMemo(context),
                  ],
                  const SizedBox(height: RoutineListItemConstants.spacing),
                  _buildProgressIndicator(context),
                  if (routine.tags.isNotEmpty) ...[
                    const SizedBox(height: RoutineListItemConstants.spacing),
                    _buildTags(context),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildPriorityIndicator(context),
        const SizedBox(width: RoutineListItemConstants.spacing),
        Expanded(
          child: Text(
            routine.title,
            style: RoutineListItemStyles.titleStyle(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: RoutineListItemConstants.spacing),
        if (onToggleCompletion != null) ...[
          _buildCompletionButton(context),
          const SizedBox(width: RoutineListItemConstants.smallSpacing),
        ],
        _buildActiveSwitch(context),
        _buildDeleteButton(context),
      ],
    );
  }

  Widget _buildPriorityIndicator(BuildContext context) {
    final (color, icon, label) = _getPriorityInfo();

    return Semantics(
      label: '$label 우선순위',
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Icon(
          icon,
          color: color,
          size: RoutineListItemConstants.priorityIconSize,
        ),
      ),
    );
  }

  (Color, IconData, String) _getPriorityInfo() {
    switch (routine.priority) {
      case Priority.high:
        return (Colors.red.shade600, Icons.keyboard_arrow_up, '높음');
      case Priority.medium:
        return (Colors.orange.shade600, Icons.remove, '보통');
      case Priority.low:
        return (Colors.green.shade600, Icons.keyboard_arrow_down, '낮음');
    }
  }

  Widget _buildCompletionButton(BuildContext context) {
    return Semantics(
      label: routine.isCompletedToday ? '완료됨' : '완료하기',
      hint: '탭하여 완료 상태 변경',
      child: SizedBox(
        width: RoutineListItemConstants.minTouchTarget,
        height: RoutineListItemConstants.minTouchTarget,
        child: IconButton(
          icon: Icon(
            routine.isCompletedToday
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: routine.isCompletedToday
                ? Colors.green.shade600
                : Colors.grey.shade400,
            size: RoutineListItemConstants.iconSize,
          ),
          onPressed: onToggleCompletion,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: RoutineListItemConstants.minTouchTarget,
            minHeight: RoutineListItemConstants.minTouchTarget,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSwitch(BuildContext context) {
    return Semantics(
      label: routine.isActive ? '루틴 활성화됨' : '루틴 비활성화됨',
      hint: '탭하여 활성화 상태 변경',
      child: SizedBox(
        height: RoutineListItemConstants.minTouchTarget,
        child: Switch(
          value: routine.isActive,
          onChanged: (_) => onToggleActive(),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Semantics(
      label: '루틴 삭제',
      hint: '탭하여 루틴 삭제',
      child: SizedBox(
        width: RoutineListItemConstants.minTouchTarget,
        height: RoutineListItemConstants.minTouchTarget,
        child: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).colorScheme.error,
            size: RoutineListItemConstants.iconSize,
          ),
          onPressed: () => _showDeleteConfirmation(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: RoutineListItemConstants.minTouchTarget,
            minHeight: RoutineListItemConstants.minTouchTarget,
          ),
        ),
      ),
    );
  }

  Widget _buildMemo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        routine.memo!,
        style: RoutineListItemStyles.memoStyle(context),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final progress =
        routine.currentCompletionCount / routine.targetCompletionCount;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '진행률',
              style: RoutineListItemStyles.progressStyle(context),
            ),
            Text(
              '${routine.currentCompletionCount}/${routine.targetCompletionCount}',
              style: RoutineListItemStyles.progressStyle(context).copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: RoutineListItemConstants.smallSpacing),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0
                  ? Colors.green.shade600
                  : theme.colorScheme.primary,
            ),
            minHeight: 4, // 높이 줄임
          ),
        ),
      ],
    );
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: 6, // 8에서 6으로 줄임
      runSpacing: 4,
      children: routine.tags.take(3).map((tag) {
        // 최대 3개만 표시
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tag,
            style: RoutineListItemStyles.chipTextStyle(context),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        title: const Text('루틴 삭제'),
        content: Text(
          '정말로 "${routine.title}" 루틴을 삭제하시겠습니까?\n\n이 작업은 되돌릴 수 없습니다.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );

    if (confirmed == true) {
      onDelete();
    }
  }
}
