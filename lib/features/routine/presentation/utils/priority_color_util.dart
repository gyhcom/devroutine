import 'package:devroutine/features/routine/domain/entities/routine.dart';
import 'package:flutter/material.dart';

Color getPriorityBorderColor(Priority priority) {
  switch (priority) {
    case Priority.high:
      return Colors.redAccent;
    case Priority.medium:
      return Colors.amber;
    case Priority.low:
      return Colors.greenAccent;
    default:
      return Colors.grey;
  }
}
