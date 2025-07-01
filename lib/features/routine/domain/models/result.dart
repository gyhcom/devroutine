import 'failure.dart';

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class ResultFailure<T> extends Result<T> {
  final Failure failure;
  const ResultFailure(this.failure);
}

extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultFailure<T>;

  void when({
    required void Function(T data) success,
    required void Function(Failure failure) failure,
  }) {
    if (this is Success<T>) {
      success((this as Success<T>).data);
    } else if (this is ResultFailure<T>) {
      failure((this as ResultFailure<T>).failure);
    }
  }

  R map<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    } else if (this is ResultFailure<T>) {
      return failure((this as ResultFailure<T>).failure);
    }
    throw StateError('Invalid Result type');
  }
}
