// Copyright (c) 2025 Kidpech-code. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';

import '../../../application/ports/isolate_executor.dart';

/// Web-compatible stub implementation of [IsolateExecutor].
///
/// This implementation runs code synchronously in the main isolate
/// since web platforms don't support dart:isolate. It's designed to
/// maintain API compatibility while providing degraded functionality.
///
/// **Web Limitations:**
/// - No true isolation - code runs on main thread
/// - No timeout support - operations run to completion
/// - Memory sharing with main isolate
/// - Potential UI blocking for CPU-intensive tasks
///
/// **Usage:**
/// ```dart
/// final executor = StubIsolateExecutor();
/// final result = await executor.execute(
///   function: (input) => someComputation(input),
///   input: data,
/// );
/// ```
class StubIsolateExecutor implements IsolateExecutor {
  /// Creates a new stub isolate executor for web compatibility.
  const StubIsolateExecutor();

  @override
  Future<R> execute<T, R>({
    required R Function(T) function,
    required T input,
    Duration? timeout,
  }) async {
    try {
      // Execute synchronously on main isolate (web compatibility)
      // Note: timeout is ignored as web doesn't support true isolation
      return function(input);
    } catch (error) {
      throw IsolateExecutionException(
        'Function execution failed on web platform',
        error,
      );
    }
  }

  @override
  Future<R> executeStatic<T, R>({
    required String functionName,
    required T input,
    Duration? timeout,
  }) {
    // Static function execution not supported in stub implementation
    throw IsolateExecutionException(
      'Static function execution not supported on web platform: $functionName',
    );
  }

  @override
  bool get isAvailable => true; // Always available but with limitations

  @override
  int get activeIsolates => 0; // No true isolates on web

  @override
  Future<void> killAll() async {
    // No isolates to kill in stub implementation
  }

  @override
  String toString() => 'StubIsolateExecutor(web-compatible)';
}
