// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Routine _$RoutineFromJson(Map<String, dynamic> json) {
  return _Routine.fromJson(json);
}

/// @nodoc
mixin _$Routine {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  int get targetCompletionCount => throw _privateConstructorUsedError;
  int get currentCompletionCount => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  Priority get priority => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  List<DateTime> get completionHistory =>
      throw _privateConstructorUsedError; // 완료 이력 배열 추가
  RoutineType get routineType => throw _privateConstructorUsedError; // 루틴 타입 추가
  String? get groupId => throw _privateConstructorUsedError; // 3일 루틴 그룹 식별자
  int? get dayNumber => throw _privateConstructorUsedError;

  /// Serializes this Routine to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Routine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoutineCopyWith<Routine> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoutineCopyWith<$Res> {
  factory $RoutineCopyWith(Routine value, $Res Function(Routine) then) =
      _$RoutineCopyWithImpl<$Res, Routine>;
  @useResult
  $Res call(
      {String id,
      String title,
      String? memo,
      bool isActive,
      DateTime createdAt,
      DateTime updatedAt,
      List<String> tags,
      int targetCompletionCount,
      int currentCompletionCount,
      DateTime startDate,
      DateTime? endDate,
      String? category,
      Priority priority,
      DateTime? completedAt,
      List<DateTime> completionHistory,
      RoutineType routineType,
      String? groupId,
      int? dayNumber});
}

/// @nodoc
class _$RoutineCopyWithImpl<$Res, $Val extends Routine>
    implements $RoutineCopyWith<$Res> {
  _$RoutineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Routine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? memo = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? tags = null,
    Object? targetCompletionCount = null,
    Object? currentCompletionCount = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? category = freezed,
    Object? priority = null,
    Object? completedAt = freezed,
    Object? completionHistory = null,
    Object? routineType = null,
    Object? groupId = freezed,
    Object? dayNumber = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      targetCompletionCount: null == targetCompletionCount
          ? _value.targetCompletionCount
          : targetCompletionCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentCompletionCount: null == currentCompletionCount
          ? _value.currentCompletionCount
          : currentCompletionCount // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as Priority,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completionHistory: null == completionHistory
          ? _value.completionHistory
          : completionHistory // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
      routineType: null == routineType
          ? _value.routineType
          : routineType // ignore: cast_nullable_to_non_nullable
              as RoutineType,
      groupId: freezed == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
      dayNumber: freezed == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoutineImplCopyWith<$Res> implements $RoutineCopyWith<$Res> {
  factory _$$RoutineImplCopyWith(
          _$RoutineImpl value, $Res Function(_$RoutineImpl) then) =
      __$$RoutineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? memo,
      bool isActive,
      DateTime createdAt,
      DateTime updatedAt,
      List<String> tags,
      int targetCompletionCount,
      int currentCompletionCount,
      DateTime startDate,
      DateTime? endDate,
      String? category,
      Priority priority,
      DateTime? completedAt,
      List<DateTime> completionHistory,
      RoutineType routineType,
      String? groupId,
      int? dayNumber});
}

/// @nodoc
class __$$RoutineImplCopyWithImpl<$Res>
    extends _$RoutineCopyWithImpl<$Res, _$RoutineImpl>
    implements _$$RoutineImplCopyWith<$Res> {
  __$$RoutineImplCopyWithImpl(
      _$RoutineImpl _value, $Res Function(_$RoutineImpl) _then)
      : super(_value, _then);

  /// Create a copy of Routine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? memo = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? tags = null,
    Object? targetCompletionCount = null,
    Object? currentCompletionCount = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? category = freezed,
    Object? priority = null,
    Object? completedAt = freezed,
    Object? completionHistory = null,
    Object? routineType = null,
    Object? groupId = freezed,
    Object? dayNumber = freezed,
  }) {
    return _then(_$RoutineImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      targetCompletionCount: null == targetCompletionCount
          ? _value.targetCompletionCount
          : targetCompletionCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentCompletionCount: null == currentCompletionCount
          ? _value.currentCompletionCount
          : currentCompletionCount // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as Priority,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completionHistory: null == completionHistory
          ? _value._completionHistory
          : completionHistory // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
      routineType: null == routineType
          ? _value.routineType
          : routineType // ignore: cast_nullable_to_non_nullable
              as RoutineType,
      groupId: freezed == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
      dayNumber: freezed == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoutineImpl extends _Routine {
  const _$RoutineImpl(
      {required this.id,
      required this.title,
      this.memo,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt,
      required final List<String> tags,
      required this.targetCompletionCount,
      required this.currentCompletionCount,
      required this.startDate,
      this.endDate,
      this.category,
      this.priority = Priority.medium,
      this.completedAt,
      final List<DateTime> completionHistory = const [],
      this.routineType = RoutineType.daily,
      this.groupId,
      this.dayNumber})
      : _tags = tags,
        _completionHistory = completionHistory,
        super._();

  factory _$RoutineImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoutineImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? memo;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final int targetCompletionCount;
  @override
  final int currentCompletionCount;
  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;
  @override
  final String? category;
  @override
  @JsonKey()
  final Priority priority;
  @override
  final DateTime? completedAt;
  final List<DateTime> _completionHistory;
  @override
  @JsonKey()
  List<DateTime> get completionHistory {
    if (_completionHistory is EqualUnmodifiableListView)
      return _completionHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completionHistory);
  }

// 완료 이력 배열 추가
  @override
  @JsonKey()
  final RoutineType routineType;
// 루틴 타입 추가
  @override
  final String? groupId;
// 3일 루틴 그룹 식별자
  @override
  final int? dayNumber;

  @override
  String toString() {
    return 'Routine(id: $id, title: $title, memo: $memo, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, tags: $tags, targetCompletionCount: $targetCompletionCount, currentCompletionCount: $currentCompletionCount, startDate: $startDate, endDate: $endDate, category: $category, priority: $priority, completedAt: $completedAt, completionHistory: $completionHistory, routineType: $routineType, groupId: $groupId, dayNumber: $dayNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoutineImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.targetCompletionCount, targetCompletionCount) ||
                other.targetCompletionCount == targetCompletionCount) &&
            (identical(other.currentCompletionCount, currentCompletionCount) ||
                other.currentCompletionCount == currentCompletionCount) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            const DeepCollectionEquality()
                .equals(other._completionHistory, _completionHistory) &&
            (identical(other.routineType, routineType) ||
                other.routineType == routineType) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.dayNumber, dayNumber) ||
                other.dayNumber == dayNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      memo,
      isActive,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_tags),
      targetCompletionCount,
      currentCompletionCount,
      startDate,
      endDate,
      category,
      priority,
      completedAt,
      const DeepCollectionEquality().hash(_completionHistory),
      routineType,
      groupId,
      dayNumber);

  /// Create a copy of Routine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoutineImplCopyWith<_$RoutineImpl> get copyWith =>
      __$$RoutineImplCopyWithImpl<_$RoutineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoutineImplToJson(
      this,
    );
  }
}

abstract class _Routine extends Routine {
  const factory _Routine(
      {required final String id,
      required final String title,
      final String? memo,
      required final bool isActive,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final List<String> tags,
      required final int targetCompletionCount,
      required final int currentCompletionCount,
      required final DateTime startDate,
      final DateTime? endDate,
      final String? category,
      final Priority priority,
      final DateTime? completedAt,
      final List<DateTime> completionHistory,
      final RoutineType routineType,
      final String? groupId,
      final int? dayNumber}) = _$RoutineImpl;
  const _Routine._() : super._();

  factory _Routine.fromJson(Map<String, dynamic> json) = _$RoutineImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get memo;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  List<String> get tags;
  @override
  int get targetCompletionCount;
  @override
  int get currentCompletionCount;
  @override
  DateTime get startDate;
  @override
  DateTime? get endDate;
  @override
  String? get category;
  @override
  Priority get priority;
  @override
  DateTime? get completedAt;
  @override
  List<DateTime> get completionHistory; // 완료 이력 배열 추가
  @override
  RoutineType get routineType; // 루틴 타입 추가
  @override
  String? get groupId; // 3일 루틴 그룹 식별자
  @override
  int? get dayNumber;

  /// Create a copy of Routine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoutineImplCopyWith<_$RoutineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
