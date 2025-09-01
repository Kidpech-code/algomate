/// Port for executing functions in isolates to avoid UI blocking.
///
/// Provides type-safe isolate execution with proper error handling,
/// timeout support, and efficient data serialization.
abstract class IsolateExecutor {
  /// Execute a function in an isolate with the given input.
  ///
  /// The function and input must be sendable between isolates
  /// (primitives, lists, maps, or custom serializable objects).
  ///
  /// Returns a Future that completes with the result or throws
  /// an exception if execution fails or times out.
  Future<R> execute<T, R>({required R Function(T) function, required T input, Duration? timeout});

  /// Execute a static function by name in an isolate.
  ///
  /// This is more efficient for simple functions as it avoids
  /// serializing function closures.
  Future<R> executeStatic<T, R>({required String functionName, required T input, Duration? timeout});

  /// Check if isolate execution is available on this platform.
  bool get isAvailable;

  /// Get the number of currently active isolates.
  int get activeIsolates;

  /// Kill all active isolates (emergency cleanup).
  Future<void> killAll();
}

/// Configuration for isolate execution.
class IsolateConfig {
  const IsolateConfig({this.debugName, this.paused = false, this.errorsAreFatal = false});

  /// Debug name for the isolate (useful for debugging)
  final String? debugName;

  /// Whether to start the isolate in paused state
  final bool paused;

  /// Whether errors should terminate the isolate
  final bool errorsAreFatal;
}

/// Message types for isolate communication.
enum IsolateMessageType { execute, result, error, timeout }

/// Base class for isolate messages.
abstract class IsolateMessage {
  const IsolateMessage(this.type, this.id);

  final IsolateMessageType type;
  final int id;
}

/// Message to execute a function in an isolate.
class ExecuteMessage<T> extends IsolateMessage {
  const ExecuteMessage({required int id, required this.functionName, required this.input}) : super(IsolateMessageType.execute, id);

  final String functionName;
  final T input;
}

/// Message containing execution result.
class ResultMessage<R> extends IsolateMessage {
  const ResultMessage({required int id, required this.result}) : super(IsolateMessageType.result, id);

  final R result;
}

/// Message containing execution error.
class ErrorMessage extends IsolateMessage {
  const ErrorMessage({required int id, required this.error, this.stackTrace}) : super(IsolateMessageType.error, id);

  final String error;
  final String? stackTrace;
}

/// Exception thrown when isolate execution fails.
class IsolateExecutionException implements Exception {
  const IsolateExecutionException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'IsolateExecutionException: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

/// Exception thrown when isolate execution times out.
class IsolateTimeoutException extends IsolateExecutionException {
  IsolateTimeoutException(Duration timeout) : super('Isolate execution timed out after ${timeout.inMilliseconds}ms');
}
