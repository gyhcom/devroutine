// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoutineImpl _$$RoutineImplFromJson(Map<String, dynamic> json) =>
    _$RoutineImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      memo: json['memo'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      targetCompletionCount: (json['targetCompletionCount'] as num).toInt(),
      currentCompletionCount: (json['currentCompletionCount'] as num).toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      category: json['category'] as String?,
      priority: $enumDecodeNullable(_$PriorityEnumMap, json['priority']) ??
          Priority.medium,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      routineType:
          $enumDecodeNullable(_$RoutineTypeEnumMap, json['routineType']) ??
              RoutineType.daily,
    );

Map<String, dynamic> _$$RoutineImplToJson(_$RoutineImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'memo': instance.memo,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'tags': instance.tags,
      'targetCompletionCount': instance.targetCompletionCount,
      'currentCompletionCount': instance.currentCompletionCount,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'category': instance.category,
      'priority': _$PriorityEnumMap[instance.priority]!,
      'completedAt': instance.completedAt?.toIso8601String(),
      'routineType': _$RoutineTypeEnumMap[instance.routineType]!,
    };

const _$PriorityEnumMap = {
  Priority.low: 'LOW',
  Priority.medium: 'MEDIUM',
  Priority.high: 'HIGH',
};

const _$RoutineTypeEnumMap = {
  RoutineType.daily: 'DAILY',
  RoutineType.threeDay: 'THREE_DAY',
};
