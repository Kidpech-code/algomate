import 'dart:async';
import 'dart:isolate';

import '../../../application/ports/isolate_executor.dart';

/// Dart isolate executor implementation for CPU-intensive tasks.
///
/// Executes functions in separate isolates to prevent UI blocking,
/// with proper error handling, timeouts, and resource management.
class DartIsolateExecutor implements IsolateExecutor {
  DartIsolateExecutor({this.maxConcurrentIsolates = 4, this.defaultTimeout = const Duration(seconds: 30)});

  final int maxConcurrentIsolates;
  final Duration defaultTimeout;
  final Set<Isolate> _activeIsolates = <Isolate>{};

  @override
  bool get isAvailable => true;

  @override
  int get activeIsolates => _activeIsolates.length;

  @override
  Future<R> execute<T, R>({required R Function(T) function, required T input, Duration? timeout}) async {
    if (_activeIsolates.length >= maxConcurrentIsolates) {
      throw IsolateExecutionException('Maximum concurrent isolates reached: $maxConcurrentIsolates');
    }

    final effectiveTimeout = timeout ?? defaultTimeout;
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();

    try {
      final isolate = await Isolate.spawn(
        _isolateEntryPoint<T, R>,
        _IsolateMessage(function: function, input: input, sendPort: receivePort.sendPort),
        onError: errorPort.sendPort,
        debugName: 'AlgoMate-Isolate-${DateTime.now().millisecondsSinceEpoch}',
      );

      _activeIsolates.add(isolate);

      // Set up timeout
      Timer? timeoutTimer;
      if (effectiveTimeout.inMicroseconds > 0) {
        timeoutTimer = Timer(effectiveTimeout, () {
          isolate.kill(priority: Isolate.immediate);
          _activeIsolates.remove(isolate);
          receivePort.close();
          errorPort.close();
        });
      }

      // Wait for result or error
      final completer = Completer<R>();

      receivePort.listen((message) {
        timeoutTimer?.cancel();
        _activeIsolates.remove(isolate);
        receivePort.close();
        errorPort.close();

        if (message is _IsolateResult<R>) {
          if (message.isSuccess) {
            completer.complete(message.result as R);
          } else {
            completer.completeError(IsolateExecutionException(message.error ?? 'Unknown error in isolate'));
          }
        } else {
          completer.completeError(IsolateExecutionException('Invalid response from isolate: $message'));
        }

        isolate.kill();
      });

      errorPort.listen((error) {
        timeoutTimer?.cancel();
        _activeIsolates.remove(isolate);
        receivePort.close();
        errorPort.close();

        completer.completeError(IsolateExecutionException('Isolate error: ${error.toString()}'));

        isolate.kill();
      });

      return await completer.future.timeout(
        effectiveTimeout,
        onTimeout: () {
          _activeIsolates.remove(isolate);
          isolate.kill(priority: Isolate.immediate);
          throw IsolateTimeoutException('Isolate execution timed out after ${effectiveTimeout.inSeconds}s');
        },
      );
    } catch (e) {
      receivePort.close();
      errorPort.close();
      rethrow;
    }
  }

  @override
  Future<R> executeStatic<T, R>({required String functionName, required T input, Duration? timeout}) async {
    // For static function execution, we need to maintain a registry
    // of static functions. This is a simplified implementation.
    throw UnsupportedError('Static function execution not yet implemented');
  }

  /// Kill all active isolates (cleanup method).
  @override
  Future<void> killAll() async {
    for (final isolate in _activeIsolates) {
      isolate.kill(priority: Isolate.immediate);
    }
    _activeIsolates.clear();
  }

  /// Dispose of the executor and clean up resources.
  void dispose() {
    killAll();
  }

  /// Entry point for isolate execution.
  static void _isolateEntryPoint<T, R>(_IsolateMessage<T, R> message) {
    try {
      final result = message.function(message.input);
      message.sendPort.send(_IsolateResult<R>.success(result));
    } catch (e) {
      message.sendPort.send(_IsolateResult<R>.error(e.toString()));
    }
  }
}

/// Stub isolate executor for platforms where isolates are not available.
///
/// Falls back to synchronous execution in the main thread.
/// Useful for testing and platforms with limited isolate support.
class StubIsolateExecutor implements IsolateExecutor {
  const StubIsolateExecutor();

  @override
  bool get isAvailable => false;

  @override
  int get activeIsolates => 0;

  @override
  Future<void> killAll() async {
    // No isolates to kill in stub implementation
  }

  @override
  Future<R> execute<T, R>({required R Function(T) function, required T input, Duration? timeout}) async {
    // Execute synchronously as a fallback
    return function(input);
  }

  @override
  Future<R> executeStatic<T, R>({required String functionName, required T input, Duration? timeout}) async {
    throw UnsupportedError('Static function execution not available in stub executor');
  }
}

/// Mock isolate executor for testing purposes.
///
/// Returns predictable results without actual isolate execution,
/// useful for unit testing isolate-dependent code.
class MockIsolateExecutor implements IsolateExecutor {
  MockIsolateExecutor({this.mockResults = const {}, this.shouldThrow = false, this.throwAfterDelay});

  final Map<Type, dynamic> mockResults;
  final bool shouldThrow;
  final Duration? throwAfterDelay;

  @override
  bool get isAvailable => true;

  @override
  int get activeIsolates => 0;

  @override
  Future<void> killAll() async {
    // No isolates to kill in mock implementation
  }

  @override
  Future<R> execute<T, R>({required R Function(T) function, required T input, Duration? timeout}) async {
    if (throwAfterDelay != null) {
      await Future<void>.delayed(throwAfterDelay!);
    }

    if (shouldThrow) {
      throw const IsolateExecutionException('Mock isolate execution failed');
    }

    // Return mock result if available
    if (mockResults.containsKey(R)) {
      return mockResults[R] as R;
    }

    // Fallback to actual execution
    return function(input);
  }

  @override
  Future<R> executeStatic<T, R>({required String functionName, required T input, Duration? timeout}) async {
    return execute<T, R>(function: (_) => mockResults[R] as R, input: input, timeout: timeout);
  }
}

/// Message structure for isolate communication.
class _IsolateMessage<T, R> {
  const _IsolateMessage({required this.function, required this.input, required this.sendPort});

  final R Function(T) function;
  final T input;
  final SendPort sendPort;
}

/// Result structure for isolate communication.
class _IsolateResult<R> {
  const _IsolateResult._({required this.isSuccess, this.result, this.error});

  factory _IsolateResult.success(R result) {
    return _IsolateResult._(isSuccess: true, result: result);
  }

  factory _IsolateResult.error(String error) {
    return _IsolateResult._(isSuccess: false, error: error);
  }

  final bool isSuccess;
  final R? result;
  final String? error;
}

/// Exception thrown when isolate execution fails.
class IsolateExecutionException implements Exception {
  const IsolateExecutionException(this.message);

  final String message;

  @override
  String toString() => 'IsolateExecutionException: $message';
}

/// Exception thrown when isolate execution times out.
class IsolateTimeoutException implements Exception {
  const IsolateTimeoutException(this.message);

  final String message;

  @override
  String toString() => 'IsolateTimeoutException: $message';
}
