/// Base class for all AlgoMate failures.
sealed class AlgoMateFailure {
  const AlgoMateFailure(this.message, [this.details]);

  final String message;
  final String? details;

  @override
  String toString() => details != null ? '$message: $details' : message;
}

/// Failure when no suitable strategy is found for the given criteria.
final class NoStrategyFailure extends AlgoMateFailure {
  const NoStrategyFailure(super.message, [super.details]);

  factory NoStrategyFailure.forSignature(String signature) => NoStrategyFailure(
      'No strategy found for signature: $signature',
      'Consider registering built-in strategies or adjusting your selector hint.',);
}

/// Failure when input data doesn't meet strategy requirements.
final class InapplicableInputFailure extends AlgoMateFailure {
  const InapplicableInputFailure(super.message, [super.details]);

  factory InapplicableInputFailure.requiresSorted(String strategyName) =>
      InapplicableInputFailure(
        'Strategy "$strategyName" requires sorted input',
        'Set hint.sorted = true or use a strategy that works with unsorted data.',
      );

  factory InapplicableInputFailure.sizeLimit(String strategyName, int limit) =>
      InapplicableInputFailure(
          'Strategy "$strategyName" has size limit of $limit',
          'Use a different strategy or reduce input size.',);
}

/// Failure when resource limits are exceeded.
final class ResourceLimitFailure extends AlgoMateFailure {
  const ResourceLimitFailure(super.message, [super.details]);

  factory ResourceLimitFailure.memoryBudget(int required, int budget) =>
      ResourceLimitFailure(
        'Strategy requires ${required}MB but budget is ${budget}MB',
        'Increase memory budget in hint or choose a more memory-efficient strategy.',
      );

  factory ResourceLimitFailure.timeout(Duration timeout) =>
      ResourceLimitFailure(
          'Operation timed out after ${timeout.inMilliseconds}ms',
          'Consider using async execution or increasing timeout.',);
}

/// Failure during strategy execution.
final class ExecutionFailure extends AlgoMateFailure {
  const ExecutionFailure(super.message, [super.details]);

  factory ExecutionFailure.strategyError(String strategyName, Object error) =>
      ExecutionFailure(
          'Strategy "$strategyName" failed during execution', error.toString(),);

  factory ExecutionFailure.fallbackExhausted(
          List<String> attemptedStrategies,) =>
      ExecutionFailure(
        'All fallback strategies failed',
        'Attempted strategies: ${attemptedStrategies.join(", ")}. Consider using different input or registering more robust strategies.',
      );
}

/// Failure during async execution in isolate.
final class IsolateFailure extends AlgoMateFailure {
  const IsolateFailure(super.message, [super.details]);

  factory IsolateFailure.spawnError(Object error) => IsolateFailure(
      'Failed to spawn isolate for async execution', error.toString(),);

  factory IsolateFailure.communicationError(Object error) =>
      IsolateFailure('Communication error with isolate', error.toString());

  factory IsolateFailure.timeout(Duration timeout) => IsolateFailure(
      'Isolate execution timed out after ${timeout.inMilliseconds}ms',
      'Consider increasing timeout or reducing workload size.',);
}

/// Failure during benchmarking operations.
final class BenchmarkFailure extends AlgoMateFailure {
  const BenchmarkFailure(super.message, [super.details]);

  factory BenchmarkFailure.invalidConfiguration(String reason) =>
      BenchmarkFailure('Invalid benchmark configuration', reason);

  factory BenchmarkFailure.executionError(String benchmarkName, Object error) =>
      BenchmarkFailure(
          'Benchmark "$benchmarkName" execution failed', error.toString(),);

  factory BenchmarkFailure.insufficientData(int required, int actual) =>
      BenchmarkFailure('Insufficient benchmark iterations',
          'Required at least $required iterations but only $actual completed successfully.',);
}

/// Failure in memory management operations.
final class MemoryLimitFailure extends AlgoMateFailure {
  const MemoryLimitFailure(super.message, [super.details]);

  factory MemoryLimitFailure.exceeded(int usedBytes, int limitBytes) =>
      MemoryLimitFailure(
        'Memory limit exceeded',
        'Used ${(usedBytes / 1024 / 1024).toStringAsFixed(2)}MB but limit is ${(limitBytes / 1024 / 1024).toStringAsFixed(2)}MB',
      );

  factory MemoryLimitFailure.allocationFailed(int requestedBytes) =>
      MemoryLimitFailure(
        'Memory allocation failed',
        'Could not allocate ${(requestedBytes / 1024 / 1024).toStringAsFixed(2)}MB. Consider using smaller datasets or more memory-efficient algorithms.',
      );
}

/// Failure when a timeout occurs.
final class TimeoutFailure extends AlgoMateFailure {
  const TimeoutFailure(super.message, [super.details]);

  factory TimeoutFailure.operationTimeout(String operation, Duration timeout) =>
      TimeoutFailure(
        'Operation "$operation" timed out',
        'Exceeded ${timeout.inMilliseconds}ms limit. Consider using async execution or optimizing the algorithm.',
      );

  factory TimeoutFailure.strategyTimeout(
          String strategyName, Duration timeout,) =>
      TimeoutFailure(
        'Strategy "$strategyName" execution timed out',
        'Exceeded ${timeout.inMilliseconds}ms limit. The strategy may be inefficient for this input size.',
      );
}

/// Failure in strategy registration or configuration.
final class StrategyRegistrationFailure extends AlgoMateFailure {
  const StrategyRegistrationFailure(super.message, [super.details]);

  factory StrategyRegistrationFailure.duplicateName(String strategyName) =>
      StrategyRegistrationFailure(
        'Strategy with name "$strategyName" already registered',
        'Use a different name or explicitly replace the existing strategy.',
      );

  factory StrategyRegistrationFailure.invalidMetadata(String reason) =>
      StrategyRegistrationFailure('Invalid strategy metadata', reason);

  factory StrategyRegistrationFailure.incompatibleInterface(
          String expected, String actual,) =>
      StrategyRegistrationFailure(
        'Strategy interface mismatch',
        'Expected $expected but got $actual. Ensure strategy implements correct generic types.',
      );
}
