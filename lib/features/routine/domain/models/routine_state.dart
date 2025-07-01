import 'package:freezed_annotation/freezed_annotation.dart';
import '../entities/routine.dart';

part 'routine_state.freezed.dart';

@freezed
class RoutineState with _$RoutineState {
  const factory RoutineState.initial() = _Initial;
  const factory RoutineState.loading() = _Loading;
  const factory RoutineState.loaded(List<Routine> routines) = _Loaded;
  const factory RoutineState.error(String message) = _Error;
}
