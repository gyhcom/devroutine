import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.validation(String message) = ValidationFailure;
  const factory Failure.server(String message) = ServerFailure;
  const factory Failure.storage(String message) = StorageFailure;
  const factory Failure.network(String message) = NetworkFailure;
  const factory Failure.unexpected(String message) = UnexpectedFailure;
}
