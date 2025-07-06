import 'package:devroutine/features/routine/domain/entities/routine.dart';
import 'package:flutter/material.dart';

// 우선순위별 부드러운 색상 (Material Design 3 기준)
Color getPriorityBorderColor(Priority priority) {
  switch (priority) {
    case Priority.high:
      return const Color(0xFFFF6B6B); // 부드러운 빨간색
    case Priority.medium:
      return const Color(0xFFFFB347); // 부드러운 주황색
    case Priority.low:
      return const Color(0xFF4ECDC4); // 부드러운 청록색
    default:
      return Colors.grey.shade400;
  }
}

// 우선순위별 배경 색상 (더 연한 톤)
Color getPriorityBackgroundColor(Priority priority) {
  switch (priority) {
    case Priority.high:
      return const Color(0xFFFFF5F5); // 연한 빨간색 배경
    case Priority.medium:
      return const Color(0xFFFFF9F0); // 연한 주황색 배경
    case Priority.low:
      return const Color(0xFFF0FDFC); // 연한 청록색 배경
    default:
      return Colors.grey.shade50;
  }
}

// 우선순위별 아이콘
IconData getPriorityIcon(Priority priority) {
  switch (priority) {
    case Priority.high:
      return Icons.priority_high_rounded;
    case Priority.medium:
      return Icons.schedule_rounded;
    case Priority.low:
      return Icons.low_priority_rounded;
    default:
      return Icons.radio_button_unchecked;
  }
}

// 우선순위별 그라데이션
LinearGradient getPriorityGradient(Priority priority) {
  switch (priority) {
    case Priority.high:
      return const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case Priority.medium:
      return const LinearGradient(
        colors: [Color(0xFFFFB347), Color(0xFFFFC66D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case Priority.low:
      return const LinearGradient(
        colors: [Color(0xFF4ECDC4), Color(0xFF6DD5DB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    default:
      return LinearGradient(
        colors: [Colors.grey.shade300, Colors.grey.shade400],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  }
}

// 우선순위별 텍스트 색상
Color getPriorityTextColor(Priority priority) {
  switch (priority) {
    case Priority.high:
      return const Color(0xFFE53E3E);
    case Priority.medium:
      return const Color(0xFFD69E2E);
    case Priority.low:
      return const Color(0xFF319795);
    default:
      return Colors.grey.shade700;
  }
}

// 우선순위별 라벨
String getPriorityLabel(Priority priority) {
  switch (priority) {
    case Priority.high:
      return '긴급';
    case Priority.medium:
      return '중요';
    case Priority.low:
      return '여유';
    default:
      return '일반';
  }
}
