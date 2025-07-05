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

enum RoutineType {
  @JsonValue('DAILY')
  daily, // 일일 루틴 (기존 리셋 루틴)
  @JsonValue('THREE_DAY')
  threeDay // 3일 루틴
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
    DateTime? completedAt,
    @Default(RoutineType.daily) RoutineType routineType, // 루틴 타입 추가
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
    RoutineType routineType = RoutineType.daily, // 루틴 타입 파라미터 추가
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

    // 3일 루틴일 경우 자동으로 종료일 설정
    if (routineType == RoutineType.threeDay && endDate == null) {
      endDate = startDate.add(const Duration(days: 2));
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
      completedAt: null,
      routineType: routineType,
    );
  }

  // 3일 루틴 생성 팩토리 메서드
  factory Routine.createThreeDayRoutine({
    required String title,
    String? memo,
    required List<String> tags,
    required int targetCompletionCount,
    required DateTime startDate,
    String? category,
    Priority priority = Priority.medium,
  }) {
    return Routine.create(
      title: title,
      memo: memo,
      tags: tags,
      targetCompletionCount: targetCompletionCount,
      startDate: startDate,
      endDate: startDate.add(const Duration(days: 2)), // 시작일 + 2일
      category: category,
      priority: priority,
      routineType: RoutineType.threeDay,
    );
  }

  const Routine._();

  // 날짜가 같은지 확인하는 유틸리티 메서드
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // 오늘 완료되었는지 확인하는 getter
  bool get isCompletedToday {
    if (completedAt == null) return false;
    return isSameDay(completedAt!, DateTime.now());
  }

  // 3일 루틴인지 확인하는 getter
  bool get isThreeDayRoutine => routineType == RoutineType.threeDay;

  // 3일 루틴의 남은 일수 계산 (D-2, D-1, D-DAY)
  int get remainingDays {
    if (!isThreeDayRoutine || endDate == null) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate!.year, endDate!.month, endDate!.day);

    return end.difference(today).inDays;
  }

  // 3일 루틴의 상태 텍스트 (D-2, D-1, D-DAY, 완료됨)
  String get threeDayStatusText {
    if (!isThreeDayRoutine) return '';
    if (isCompletedToday) return '완료됨';

    final days = remainingDays;
    if (days < 0) return '만료됨';
    if (days == 0) return 'D-DAY';
    return 'D-$days';
  }

  // 루틴 완료 메서드
  Routine markAsCompleted() {
    return copyWith(
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // 루틴 미완료 메서드
  Routine markAsIncomplete() {
    return copyWith(
      completedAt: null,
      updatedAt: DateTime.now(),
    );
  }

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
