import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/routine.dart';

part 'routine_model.freezed.dart';
part 'routine_model.g.dart';

@freezed
@HiveType(typeId: 0)
class RoutineModel with _$RoutineModel {
  @HiveField(0)
  factory RoutineModel({
    @HiveField(1) required String id,
    @HiveField(2) required String title,
    @HiveField(3) String? memo,
    @HiveField(4) required bool isActive,
    @HiveField(5) required DateTime createdAt,
    @HiveField(6) required DateTime updatedAt,
    @HiveField(7) required List<String> tags,
    @HiveField(8) required int targetCompletionCount,
    @HiveField(9) required int currentCompletionCount,
    @HiveField(10) required DateTime startDate,
    @HiveField(11) DateTime? endDate,
    @HiveField(12) String? category,
    @HiveField(13) @Default(Priority.medium) Priority priority,
    @HiveField(14) DateTime? completedAt,
    @HiveField(15) @Default(RoutineType.daily) RoutineType routineType,
    @HiveField(16) String? groupId,
    @HiveField(17) int? dayNumber,
  }) = _RoutineModel;

  factory RoutineModel.fromJson(Map<String, dynamic> json) =>
      _$RoutineModelFromJson(json);

  factory RoutineModel.fromEntity(Routine routine) {
    return RoutineModel(
      id: routine.id,
      title: routine.title,
      memo: routine.memo,
      isActive: routine.isActive,
      createdAt: routine.createdAt,
      updatedAt: routine.updatedAt,
      tags: routine.tags,
      targetCompletionCount: routine.targetCompletionCount,
      currentCompletionCount: routine.currentCompletionCount,
      startDate: routine.startDate,
      endDate: routine.endDate,
      category: routine.category,
      priority: routine.priority,
      completedAt: routine.completedAt,
      routineType: routine.routineType,
      groupId: routine.groupId,
      dayNumber: routine.dayNumber,
    );
  }
}

extension RoutineModelX on RoutineModel {
  Routine toEntity() {
    return Routine(
      id: id,
      title: title,
      memo: memo,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tags: tags,
      targetCompletionCount: targetCompletionCount,
      currentCompletionCount: currentCompletionCount,
      startDate: startDate,
      endDate: endDate,
      category: category,
      priority: priority,
      completedAt: completedAt,
      routineType: routineType,
      groupId: groupId,
      dayNumber: dayNumber,
    );
  }
}
