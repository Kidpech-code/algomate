/// Result type for handling success and failure cases without exceptions.
/// Provides a type-safe way to handle operations that may fail.
sealed class Result<T, F> {
  const Result();

  /// Creates a successful result.
  const factory Result.success(T value) = Success<T, F>;

  /// Creates a failure result.
  const factory Result.failure(F failure) = Failure<T, F>;

  /// Returns true if this result represents a success.
  bool get isSuccess => this is Success<T, F>;

  /// Returns true if this result represents a failure.
  bool get isFailure => this is Failure<T, F>;

  /// Returns the success value or null if this is a failure.
  T? get successOrNull => switch (this) {
    Success<T, F>(value: final value) => value,
    Failure<T, F>() => null,
  };

  /// Returns the failure value or null if this is a success.
  F? get failureOrNull => switch (this) {
    Success<T, F>() => null,
    Failure<T, F>(failure: final failure) => failure,
  };

  /// Transforms the success value using the provided function.
  Result<U, F> map<U>(U Function(T) transform) => switch (this) {
    Success<T, F>(value: final value) => Result.success(transform(value)),
    Failure<T, F>(failure: final failure) => Result.failure(failure),
  };

  /// Transforms the failure value using the provided function.
  Result<T, U> mapFailure<U>(U Function(F) transform) => switch (this) {
    Success<T, F>(value: final value) => Result.success(value),
    Failure<T, F>(failure: final failure) => Result.failure(transform(failure)),
  };

  /// Chains operations that return Results.
  Result<U, F> flatMap<U>(Result<U, F> Function(T) transform) => switch (this) {
    Success<T, F>(value: final value) => transform(value),
    Failure<T, F>(failure: final failure) => Result.failure(failure),
  };

  /// Executes one of two functions based on the result type.
  R fold<R>(R Function(T) onSuccess, R Function(F) onFailure) => switch (this) {
    Success<T, F>(value: final value) => onSuccess(value),
    Failure<T, F>(failure: final failure) => onFailure(failure),
  };
}

/// Represents a successful result containing a value.
final class Success<T, F> extends Result<T, F> {
  const Success(this.value);

  final T value;

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Success<T, F> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Represents a failed result containing a failure.
final class Failure<T, F> extends Result<T, F> {
  const Failure(this.failure);

  final F failure;

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Failure<T, F> && other.failure == failure);

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Failure($failure)';
}
