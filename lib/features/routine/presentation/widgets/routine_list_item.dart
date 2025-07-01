import 'package:flutter/material.dart';
import '../../domain/entities/routine.dart';

class RoutineListItem extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const RoutineListItem({
    super.key,
    required this.routine,
    required this.onTap,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildPriorityIndicator(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      routine.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Switch(
                    value: routine.isActive,
                    onChanged: (_) => onToggleActive(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteConfirmation(context),
                  ),
                ],
              ),
              if (routine.memo != null && routine.memo!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  routine.memo!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 8),
              _buildProgressIndicator(context),
              const SizedBox(height: 8),
              _buildTags(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    Color color;
    IconData icon;
    switch (routine.priority) {
      case Priority.high:
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      case Priority.medium:
        color = Colors.orange;
        icon = Icons.remove;
        break;
      case Priority.low:
        color = Colors.green;
        icon = Icons.arrow_downward;
        break;
    }
    return Icon(icon, color: color, size: 20);
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress: ${routine.currentCompletionCount}/${routine.targetCompletionCount}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: routine.currentCompletionCount / routine.targetCompletionCount,
          backgroundColor: Colors.grey[200],
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      children: routine.tags.map((tag) {
        return Chip(
          label: Text(tag),
          padding: const EdgeInsets.all(4),
        );
      }).toList(),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Routine'),
        content: Text('Are you sure you want to delete "${routine.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete();
    }
  }
}
