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
    @Default([]) List<DateTime> completionHistory, // 완료 이력 배열 추가
    @Default(RoutineType.daily) RoutineType routineType, // 루틴 타입 추가
    String? groupId, // 3일 루틴 그룹 식별자
    int? dayNumber, // 3일 루틴의 일차 (1, 2, 3)
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
    String? groupId, // 그룹 ID 추가
    int? dayNumber, // 일차 추가
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
      groupId: groupId,
      dayNumber: dayNumber,
    );
  }

  // 3일 루틴 3개 생성 팩토리 메서드
  static List<Routine> createThreeDayRoutines({
    required String title,
    String? memo,
    required List<String> tags,
    required int targetCompletionCount,
    required DateTime startDate,
    String? category,
    Priority priority = Priority.medium,
  }) {
    final groupId = const Uuid().v4(); // 그룹 ID 생성
    final baseTitle = title.trim();

    return [
      Routine.create(
        title: '$baseTitle (1일차)',
        memo: memo,
        tags: tags,
        targetCompletionCount: targetCompletionCount,
        startDate: startDate,
        endDate: DateTime(
            startDate.year, startDate.month, startDate.day, 23, 59, 59),
        category: category,
        priority: priority,
        routineType: RoutineType.threeDay,
        groupId: groupId,
        dayNumber: 1,
      ),
      Routine.create(
        title: '$baseTitle (2일차)',
        memo: memo,
        tags: tags,
        targetCompletionCount: targetCompletionCount,
        startDate: startDate.add(const Duration(days: 1)),
        endDate: DateTime(
            startDate.add(const Duration(days: 1)).year,
            startDate.add(const Duration(days: 1)).month,
            startDate.add(const Duration(days: 1)).day,
            23,
            59,
            59),
        category: category,
        priority: priority,
        routineType: RoutineType.threeDay,
        groupId: groupId,
        dayNumber: 2,
      ),
      Routine.create(
        title: '$baseTitle (3일차)',
        memo: memo,
        tags: tags,
        targetCompletionCount: targetCompletionCount,
        startDate: startDate.add(const Duration(days: 2)),
        endDate: DateTime(
            startDate.add(const Duration(days: 2)).year,
            startDate.add(const Duration(days: 2)).month,
            startDate.add(const Duration(days: 2)).day,
            23,
            59,
            59),
        category: category,
        priority: priority,
        routineType: RoutineType.threeDay,
        groupId: groupId,
        dayNumber: 3,
      ),
    ];
  }

  // 기존 3일 루틴 생성 팩토리 메서드 (단일 루틴) - 호환성을 위해 유지
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
    final today = DateTime.now();
    return completionHistory.any((date) => isSameDay(date, today));
  }

  // 특정 날짜에 완료되었는지 확인
  bool isCompletedOnDate(DateTime date) {
    return completionHistory
        .any((completedDate) => isSameDay(completedDate, date));
  }

  // 완료된 총 일수
  int get totalCompletedDays => completionHistory.length;

  // 연속 완료 일수 (현재 날짜부터 역순으로)
  int get currentStreak {
    if (completionHistory.isEmpty) return 0;

    final sortedDates = List<DateTime>.from(completionHistory)
      ..sort((a, b) => b.compareTo(a)); // 최신 날짜부터 정렬

    int streak = 0;
    final today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    for (int i = 0; i < sortedDates.length; i++) {
      final completedDate = DateTime(
        sortedDates[i].year,
        sortedDates[i].month,
        sortedDates[i].day,
      );

      if (isSameDay(completedDate, checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  // 최근 7일간 완료 횟수
  int get weeklyCompletionCount {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return completionHistory
        .where((date) =>
            date.isAfter(weekAgo) &&
            date.isBefore(now.add(const Duration(days: 1))))
        .length;
  }

  // 이번 달 완료 횟수
  int get monthlyCompletionCount {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return completionHistory
        .where((date) =>
            date.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
            date.isBefore(lastDayOfMonth.add(const Duration(days: 1))))
        .length;
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
  Routine markAsCompleted([DateTime? date]) {
    final completionDate = date ?? DateTime.now();
    final dateOnly =
        DateTime(completionDate.year, completionDate.month, completionDate.day);

    // 이미 해당 날짜에 완료되어 있으면 그대로 반환
    if (isCompletedOnDate(dateOnly)) return this;

    final updatedHistory = List<DateTime>.from(completionHistory)
      ..add(dateOnly);

    return copyWith(
      completedAt: completionDate,
      completionHistory: updatedHistory,
      updatedAt: DateTime.now(),
    );
  }

  // 루틴 미완료 메서드
  Routine markAsIncomplete([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    final dateOnly =
        DateTime(targetDate.year, targetDate.month, targetDate.day);

    // 해당 날짜의 완료 기록 제거
    final updatedHistory = completionHistory
        .where((completedDate) => !isSameDay(completedDate, dateOnly))
        .toList();

    return copyWith(
      completedAt: updatedHistory.isEmpty ? null : completionHistory.last,
      completionHistory: updatedHistory,
      updatedAt: DateTime.now(),
    );
  }

  // 오늘 완료 상태 토글
  Routine toggleTodayCompletion() {
    return isCompletedToday ? markAsIncomplete() : markAsCompleted();
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
