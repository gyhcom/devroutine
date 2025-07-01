import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'routine.freezed.dart';
part 'routine.g.dart';

enum Priority {
  @JsonValue('LOW')
  low,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('HIGH')
  high
}

@freezed
class Routine with _$Routine {
  const factory Routine({
    required String id,
    required String title,
    String? memo,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<String> tags,
    required int targetCompletionCount,
    required int currentCompletionCount,
    required DateTime startDate,
    DateTime? endDate,
    String? category,
    @Default(Priority.medium) Priority priority,
  }) = _Routine;

  factory Routine.create({
    required String title,
    String? memo,
    required List<String> tags,
    required int targetCompletionCount,
    required DateTime startDate,
    DateTime? endDate,
    String? category,
    Priority priority = Priority.medium,
  }) {
    // Validation
    if (title.trim().isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }
    if (targetCompletionCount <= 0) {
      throw ArgumentError('Target completion count must be greater than 0');
    }
    if (startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      throw ArgumentError('Start date cannot be in the past');
    }
    if (endDate != null && endDate.isBefore(startDate)) {
      throw ArgumentError('End date must be after start date');
    }

    final now = DateTime.now();
    return Routine(
      id: const Uuid().v4(),
      title: title.trim(),
      memo: memo?.trim(),
      isActive: true,
      createdAt: now,
      updatedAt: now,
      tags: tags,
      targetCompletionCount: targetCompletionCount,
      currentCompletionCount: 0,
      startDate: startDate,
      endDate: endDate,
      category: category?.trim(),
      priority: priority,
    );
  }

  const Routine._();

  Routine incrementCompletion() {
    if (currentCompletionCount >= targetCompletionCount) {
      throw StateError('Cannot increment beyond target completion count');
    }
    return copyWith(
      currentCompletionCount: currentCompletionCount + 1,
      updatedAt: DateTime.now(),
    );
  }

  Routine decrementCompletion() {
    if (currentCompletionCount <= 0) {
      throw StateError('Cannot decrement below 0');
    }
    return copyWith(
      currentCompletionCount: currentCompletionCount - 1,
      updatedAt: DateTime.now(),
    );
  }

  Routine toggleActive() {
    return copyWith(
      isActive: !isActive,
      updatedAt: DateTime.now(),
    );
  }

  bool get isCompleted => currentCompletionCount >= targetCompletionCount;

  factory Routine.fromJson(Map<String, dynamic> json) =>
      _$RoutineFromJson(json);
}
