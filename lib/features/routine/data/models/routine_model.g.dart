// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoutineModelAdapter extends TypeAdapter<RoutineModel> {
  @override
  final int typeId = 0;

  @override
  RoutineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutineModel(
      id: fields[1] as String,
      title: fields[2] as String,
      memo: fields[3] as String?,
      isActive: fields[4] as bool,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      tags: (fields[7] as List).cast<String>(),
      targetCompletionCount: fields[8] as int,
      currentCompletionCount: fields[9] as int,
      startDate: fields[10] as DateTime,
      endDate: fields[11] as DateTime?,
      category: fields[12] as String?,
      priority: fields[13] as Priority,
    );
  }

  @override
  void write(BinaryWriter writer, RoutineModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.memo)
      ..writeByte(4)
      ..write(obj.isActive)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.targetCompletionCount)
      ..writeByte(9)
      ..write(obj.currentCompletionCount)
      ..writeByte(10)
      ..write(obj.startDate)
      ..writeByte(11)
      ..write(obj.endDate)
      ..writeByte(12)
      ..write(obj.category)
      ..writeByte(13)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoutineModelImpl _$$RoutineModelImplFromJson(Map<String, dynamic> json) =>
    _$RoutineModelImpl(
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
    );

Map<String, dynamic> _$$RoutineModelImplToJson(_$RoutineModelImpl instance) =>
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
    };

const _$PriorityEnumMap = {
  Priority.low: 'LOW',
  Priority.medium: 'MEDIUM',
  Priority.high: 'HIGH',
};
