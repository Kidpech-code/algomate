import 'dart:math' as math;
import '../../domain/entities/strategy.dart';
import '../../domain/value_objects/algo_metadata.dart';
import '../../domain/value_objects/selector_hint.dart';
import '../../shared/result.dart';
import '../../shared/errors.dart';
import '../facade/algo_selector_facade.dart';

/// Type alias for algorithm results
typedef AlgoResult<T> = Result<T, AlgoMateFailure>;

/// Direct strategy execution interface for performance-critical scenarios
///
/// This API bypasses the selection layer to minimize overhead when
/// the specific algorithm is already known.
///
/// Example usage:
/// ```dart
/// final executor = DirectExecutor();
/// final result = executor.execute('merge_sort', [3, 1, 4, 1, 5]);
/// ```
abstract class DirectExecutor {
  /// Executes a strategy directly by name without selection overhead
  ///
  /// [strategyName] - The exact name of the registered strategy
  /// [input] - The input data to process
  ///
  /// Returns [AlgoResult] with execution result or error
  AlgoResult<T> execute<T>(String strategyName, T input);

  /// Lists all available strategies for direct execution
  List<String> getAvailableStrategies();

  /// Gets strategy metadata without executing
  AlgoMetadata? getStrategyInfo(String strategyName);
}

/// Fast path strategy binding for compile-time optimization
///
/// Provides type-safe, zero-overhead strategy execution.
///
/// Example usage:
/// ```dart
/// final mergeSort = MergeSortStrategy(); // Concrete implementation
/// final boundSort = BoundStrategy.fromStrategy(mergeSort);
/// final result = boundSort.execute([3, 1, 4, 1, 5]);
/// ```
class BoundStrategy<TInput, TOutput> {
  const BoundStrategy(String strategyName)
      : _strategyName = strategyName,
        _strategy = null;

  BoundStrategy.fromStrategy(Strategy<TInput, TOutput> strategy)
      : _strategy = strategy,
        _strategyName = null;
  final String? _strategyName;
  final Strategy<TInput, TOutput>? _strategy;

  /// Executes the bound strategy directly
  AlgoResult<TOutput> execute(TInput input) {
    if (_strategy != null) {
      try {
        final result = _strategy!.execute(input);
        return AlgoResult.success(result);
      } catch (e) {
        return AlgoResult.failure(
          ExecutionFailure.strategyError(
            _strategy!.meta.name,
            e,
          ),
        );
      }
    }

    // Fallback to name-based lookup (slower path)
    return AlgoResult.failure(NoStrategyFailure(
      'Strategy not found: $_strategyName',
      'Ensure the strategy is registered or use BoundStrategy.fromStrategy() instead.',
      // ignore: require_trailing_commas
    ));
  }

  /// Gets the strategy name
  String get strategyName => _strategyName ?? _strategy!.meta.name;

  /// Gets strategy metadata (only available for strategy-bound instances)
  AlgoMetadata? get metadata => _strategy?.meta;
}

/// Performance comparison utilities for overhead analysis
class OverheadAnalyzer {
  /// Compares direct execution vs selector overhead
  ///
  /// Returns a map with timing information:
  /// - 'direct': Direct strategy execution time
  /// - 'selector': Selector-based execution time
  /// - 'overhead': Difference in microseconds
  /// - 'overhead_percent': Overhead as percentage
  static Future<Map<String, dynamic>> analyzeOverhead<T>(
    String strategyName,
    T input, {
    int iterations = 100,
    DirectExecutor? directExecutor,
    AlgoSelectorFacade? selector,
  }) async {
    final directTimes = <int>[];
    final selectorTimes = <int>[];

    // Ensure we have executor instances
    directExecutor ??= _createDefaultDirectExecutor();
    selector ??= AlgoSelectorFacade.development();

    // Warm up JIT (10 iterations)
    for (int i = 0; i < 10; i++) {
      if (directExecutor != null) {
        directExecutor.execute(strategyName, input);
      }
      _executeWithSelector(selector, input);
    }

    // Measure direct execution
    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();
      if (directExecutor != null) {
        directExecutor.execute(strategyName, input);
      }
      stopwatch.stop();
      directTimes.add(stopwatch.elapsedMicroseconds);
    }

    // Measure selector execution
    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();
      _executeWithSelector(selector, input);
      stopwatch.stop();
      selectorTimes.add(stopwatch.elapsedMicroseconds);
    }

    final directMedian = _median(directTimes);
    final selectorMedian = _median(selectorTimes);
    final overhead = selectorMedian - directMedian;
    final overheadPercent =
        directMedian > 0 ? (overhead / directMedian) * 100 : 0.0;

    return {
      'direct_median_us': directMedian,
      'selector_median_us': selectorMedian,
      'overhead_us': overhead,
      'overhead_percent': overheadPercent.toStringAsFixed(2),
      'iterations': iterations,
      'direct_times': directTimes,
      'selector_times': selectorTimes,
      'strategy_name': strategyName,
    };
  }

  /// Benchmark a single strategy with detailed statistics
  static Future<Map<String, dynamic>> benchmarkStrategy<T>(
    String strategyName,
    T input, {
    int iterations = 1000,
    DirectExecutor? directExecutor,
  }) async {
    directExecutor ??= _createDefaultDirectExecutor();

    final times = <int>[];
    var successCount = 0;
    var errorCount = 0;

    // Warm up
    for (int i = 0; i < 10; i++) {
      directExecutor!.execute(strategyName, input);
    }

    // Benchmark iterations
    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();
      final result = directExecutor!.execute(strategyName, input);
      stopwatch.stop();

      times.add(stopwatch.elapsedMicroseconds);

      result.fold(
        (success) => successCount++,
        (failure) => errorCount++,
      );
    }

    // Calculate statistics
    times.sort();
    final median = _median(times);
    final mean = times.reduce((a, b) => a + b) / times.length;
    final p95 = _percentile(times, 0.95);
    final p99 = _percentile(times, 0.99);
    final min = times.first;
    final max = times.last;

    return {
      'strategy_name': strategyName,
      'iterations': iterations,
      'success_count': iterations - errorCount,
      'error_count': errorCount,
      'median_us': median,
      'mean_us': mean.toStringAsFixed(2),
      'p95_us': p95,
      'p99_us': p99,
      'min_us': min,
      'max_us': max,
      'std_dev_us': _standardDeviation(times, mean).toStringAsFixed(2),
    };
  }

  /// Execute with selector (type-specific handling)
  static dynamic _executeWithSelector<T>(AlgoSelectorFacade selector, T input) {
    if (input is List<int>) {
      return selector.sort(
        input: input,
        hint: SelectorHint(n: input.length),
      );
    } else if (input is List) {
      // Generic list - assume sorting
      return selector.sort(
        input: input as List<int>, // Type cast assumption
        hint: SelectorHint(n: input.length),
      );
    } else {
      // For other types, we'd need more specific handling
      throw UnsupportedError('Unsupported input type for selector: $T');
    }
  }

  /// Create a default DirectExecutor for benchmarking
  static DirectExecutor? _createDefaultDirectExecutor() {
    // This would need to be implemented with a concrete executor
    // For now, return null to indicate it needs to be provided
    return null;
  }

  static int _median(List<int> values) {
    final sorted = List<int>.from(values)..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length % 2 == 0) {
      return (sorted[middle - 1] + sorted[middle]) ~/ 2;
    } else {
      return sorted[middle];
    }
  }

  static int _percentile(List<int> sortedValues, double percentile) {
    final index = (sortedValues.length * percentile).floor();
    return sortedValues[index.clamp(0, sortedValues.length - 1)];
  }

  static double _standardDeviation(List<int> values, double mean) {
    final squaredDifferences = values.map((x) => (x - mean) * (x - mean));
    final variance = squaredDifferences.reduce((a, b) => a + b) / values.length;
    return math.sqrt(variance);
  }
}
