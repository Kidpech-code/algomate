import '../value_objects/algo_metadata.dart';
import '../value_objects/selector_hint.dart';

/// Abstract base class for all algorithm strategies.
///
/// Strategies are stateless, type-safe implementations of algorithms
/// with fast applicability checking and zero-allocation execution paths.
///
/// Type parameters:
/// - [I]: Input type (e.g., List<int>, String)
/// - [O]: Output type (e.g., int, bool, List<int>)
abstract class Strategy<I, O> {
  /// Metadata describing this strategy's characteristics and requirements
  AlgoMetadata get meta;

  /// Fast check if this strategy can be applied to the given input and hint.
  ///
  /// This method should be:
  /// - Fast: avoid expensive computations or validations
  /// - Pure: no side effects or state modifications
  /// - Conservative: return false if uncertain
  ///
  /// Example implementations:
  /// ```dart
  /// // Binary search requires sorted input
  /// bool canApply(List<int> input, SelectorHint hint) => hint.sorted == true;
  ///
  /// // Insertion sort works well for small datasets
  /// bool canApply(List<int> input, SelectorHint hint) => (hint.n ?? input.length) <= 50;
  /// ```
  bool canApply(I input, SelectorHint hint);

  /// Execute the algorithm on the given input.
  ///
  /// This method should be:
  /// - Fast: optimized for the hot path with minimal allocations
  /// - Pure: no side effects (unless documented otherwise)
  /// - Predictable: consistent behavior for the same input
  ///
  /// Preconditions:
  /// - canApply(input, hint) must return true
  /// - Input must meet the strategy's requirements (e.g., sorted if requiresSorted)
  ///
  /// The caller is responsible for ensuring preconditions are met.
  O execute(I input);

  @override
  String toString() => 'Strategy(${meta.name})';

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Strategy<I, O> && other.meta.name == meta.name);

  @override
  int get hashCode => meta.name.hashCode;
}

/// Base class for strategies that can be configured with parameters.
///
/// Useful for strategies that need tuning (e.g., threshold values, comparison functions).
abstract class ConfigurableStrategy<I, O, TConfig> extends Strategy<I, O> {
  ConfigurableStrategy(this.config);

  /// Configuration object for this strategy instance
  final TConfig config;

  /// Creates a new instance with updated configuration
  ConfigurableStrategy<I, O, TConfig> withConfig(TConfig newConfig);
}

/// Mixin for strategies that can provide execution statistics.
///
/// Useful for benchmarking and performance analysis during development.
mixin ExecutionStats<I, O> on Strategy<I, O> {
  int _executionCount = 0;
  int _totalExecutionTimeMicros = 0;

  /// Number of times this strategy has been executed
  int get executionCount => _executionCount;

  /// Average execution time in microseconds
  double get averageExecutionTimeMicros => _executionCount > 0 ? _totalExecutionTimeMicros / _executionCount : 0;

  /// Execute with timing measurement (dev/debug only)
  O executeWithTiming(I input) {
    final stopwatch = Stopwatch()..start();
    final result = execute(input);
    stopwatch.stop();

    _executionCount++;
    _totalExecutionTimeMicros += stopwatch.elapsedMicroseconds;

    return result;
  }

  /// Reset execution statistics
  void resetStats() {
    _executionCount = 0;
    _totalExecutionTimeMicros = 0;
  }
}
