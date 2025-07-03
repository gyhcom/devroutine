import 'package:flutter/material.dart';
import '../../domain/entities/routine.dart';

class RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;
  final Color borderColor;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onTap,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        routine.currentCompletionCount >= routine.targetCompletionCount;

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1, // 정사각형 비율 유지
        child: Container(
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Priority Icon
                _buildPriorityIndicator(),
                const SizedBox(height: 8),

                // Title
                Expanded(
                  child: Center(
                    child: Text(
                      routine.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Completion status
                SizedBox(
                  height: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: isCompleted ? Colors.green : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCompleted ? 'Done' : 'To Do',
                        style: TextStyle(
                          fontSize: 12,
                          color: isCompleted ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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

    return Icon(icon, color: color, size: 24);
  }
}
