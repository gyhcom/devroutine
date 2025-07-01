// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoutineModel _$RoutineModelFromJson(Map<String, dynamic> json) {
  return _RoutineModel.fromJson(json);
}

/// @nodoc
mixin _$RoutineModel {
  @HiveField(1)
  String get id => throw _privateConstructorUsedError;
  @HiveField(2)
  String get title => throw _privateConstructorUsedError;
  @HiveField(3)
  String? get memo => throw _privateConstructorUsedError;
  @HiveField(4)
  bool get isActive => throw _privateConstructorUsedError;
  @HiveField(5)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @HiveField(6)
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @HiveField(7)
  List<String> get tags => throw _privateConstructorUsedError;
  @HiveField(8)
  int get targetCompletionCount => throw _privateConstructorUsedError;
  @HiveField(9)
  int get currentCompletionCount => throw _privateConstructorUsedError;
  @HiveField(10)
  DateTime get startDate => throw _privateConstructorUsedError;
  @HiveField(11)
  DateTime? get endDate => throw _privateConstructorUsedError;
  @HiveField(12)
  String? get category => throw _privateConstructorUsedError;
  @HiveField(13)
  Priority get priority => throw _privateConstructorUsedError;

  /// Serializes this RoutineModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoutineModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoutineModelCopyWith<RoutineModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoutineModelCopyWith<$Res> {
  factory $RoutineModelCopyWith(
          RoutineModel value, $Res Function(RoutineModel) then) =
      _$RoutineModelCopyWithImpl<$Res, RoutineModel>;
  @useResult
  $Res call(
      {@HiveField(1) String id,
      @HiveField(2) String title,
      @HiveField(3) String? memo,
      @HiveField(4) bool isActive,
      @HiveField(5) DateTime createdAt,
      @HiveField(6) DateTime updatedAt,
      @HiveField(7) List<String> tags,
      @HiveField(8) int targetCompletionCount,
      @HiveField(9) int currentCompletionCount,
      @HiveField(10) DateTime startDate,
      @HiveField(11) DateTime? endDate,
      @HiveField(12) String? category,
      @HiveField(13) Priority priority});
}

/// @nodoc
class _$RoutineModelCopyWithImpl<$Res, $Val extends RoutineModel>
    implements $RoutineModelCopyWith<$Res> {
  _$RoutineModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoutineModel
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoutineModelImplCopyWith<$Res>
    implements $RoutineModelCopyWith<$Res> {
  factory _$$RoutineModelImplCopyWith(
          _$RoutineModelImpl value, $Res Function(_$RoutineModelImpl) then) =
      __$$RoutineModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(1) String id,
      @HiveField(2) String title,
      @HiveField(3) String? memo,
      @HiveField(4) bool isActive,
      @HiveField(5) DateTime createdAt,
      @HiveField(6) DateTime updatedAt,
      @HiveField(7) List<String> tags,
      @HiveField(8) int targetCompletionCount,
      @HiveField(9) int currentCompletionCount,
      @HiveField(10) DateTime startDate,
      @HiveField(11) DateTime? endDate,
      @HiveField(12) String? category,
      @HiveField(13) Priority priority});
}

/// @nodoc
class __$$RoutineModelImplCopyWithImpl<$Res>
    extends _$RoutineModelCopyWithImpl<$Res, _$RoutineModelImpl>
    implements _$$RoutineModelImplCopyWith<$Res> {
  __$$RoutineModelImplCopyWithImpl(
      _$RoutineModelImpl _value, $Res Function(_$RoutineModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of RoutineModel
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
  }) {
    return _then(_$RoutineModelImpl(
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveField(0)
class _$RoutineModelImpl implements _RoutineModel {
  _$RoutineModelImpl(
      {@HiveField(1) required this.id,
      @HiveField(2) required this.title,
      @HiveField(3) this.memo,
      @HiveField(4) required this.isActive,
      @HiveField(5) required this.createdAt,
      @HiveField(6) required this.updatedAt,
      @HiveField(7) required final List<String> tags,
      @HiveField(8) required this.targetCompletionCount,
      @HiveField(9) required this.currentCompletionCount,
      @HiveField(10) required this.startDate,
      @HiveField(11) this.endDate,
      @HiveField(12) this.category,
      @HiveField(13) this.priority = Priority.medium})
      : _tags = tags;

  factory _$RoutineModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoutineModelImplFromJson(json);

  @override
  @HiveField(1)
  final String id;
  @override
  @HiveField(2)
  final String title;
  @override
  @HiveField(3)
  final String? memo;
  @override
  @HiveField(4)
  final bool isActive;
  @override
  @HiveField(5)
  final DateTime createdAt;
  @override
  @HiveField(6)
  final DateTime updatedAt;
  final List<String> _tags;
  @override
  @HiveField(7)
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @HiveField(8)
  final int targetCompletionCount;
  @override
  @HiveField(9)
  final int currentCompletionCount;
  @override
  @HiveField(10)
  final DateTime startDate;
  @override
  @HiveField(11)
  final DateTime? endDate;
  @override
  @HiveField(12)
  final String? category;
  @override
  @JsonKey()
  @HiveField(13)
  final Priority priority;

  @override
  String toString() {
    return 'RoutineModel(id: $id, title: $title, memo: $memo, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, tags: $tags, targetCompletionCount: $targetCompletionCount, currentCompletionCount: $currentCompletionCount, startDate: $startDate, endDate: $endDate, category: $category, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoutineModelImpl &&
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
                other.priority == priority));
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
      priority);

  /// Create a copy of RoutineModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoutineModelImplCopyWith<_$RoutineModelImpl> get copyWith =>
      __$$RoutineModelImplCopyWithImpl<_$RoutineModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoutineModelImplToJson(
      this,
    );
  }
}

abstract class _RoutineModel implements RoutineModel {
  factory _RoutineModel(
      {@HiveField(1) required final String id,
      @HiveField(2) required final String title,
      @HiveField(3) final String? memo,
      @HiveField(4) required final bool isActive,
      @HiveField(5) required final DateTime createdAt,
      @HiveField(6) required final DateTime updatedAt,
      @HiveField(7) required final List<String> tags,
      @HiveField(8) required final int targetCompletionCount,
      @HiveField(9) required final int currentCompletionCount,
      @HiveField(10) required final DateTime startDate,
      @HiveField(11) final DateTime? endDate,
      @HiveField(12) final String? category,
      @HiveField(13) final Priority priority}) = _$RoutineModelImpl;

  factory _RoutineModel.fromJson(Map<String, dynamic> json) =
      _$RoutineModelImpl.fromJson;

  @override
  @HiveField(1)
  String get id;
  @override
  @HiveField(2)
  String get title;
  @override
  @HiveField(3)
  String? get memo;
  @override
  @HiveField(4)
  bool get isActive;
  @override
  @HiveField(5)
  DateTime get createdAt;
  @override
  @HiveField(6)
  DateTime get updatedAt;
  @override
  @HiveField(7)
  List<String> get tags;
  @override
  @HiveField(8)
  int get targetCompletionCount;
  @override
  @HiveField(9)
  int get currentCompletionCount;
  @override
  @HiveField(10)
  DateTime get startDate;
  @override
  @HiveField(11)
  DateTime? get endDate;
  @override
  @HiveField(12)
  String? get category;
  @override
  @HiveField(13)
  Priority get priority;

  /// Create a copy of RoutineModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoutineModelImplCopyWith<_$RoutineModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
