/// Port for running benchmarks on algorithm strategies.
///
/// Provides controlled performance measurement with proper warmup,
/// statistical analysis, and platform-specific optimizations.
abstract class BenchmarkRunner {
  /// Run a benchmark for the given function.
  ///
  /// Parameters:
  /// - [name]: Human-readable name for the benchmark
  /// - [function]: Function to benchmark (should return a consistent result)
  /// - [iterations]: Number of iterations to run (null for auto-determination)
  /// - [warmupIterations]: Number of warmup iterations before measurement
  ///
  /// Returns benchmark results with timing statistics.
  BenchmarkResult run(
      {required String name,
      required dynamic Function() function,
      int? iterations,
      int warmupIterations = 100,});

  /// Run a comparative benchmark between multiple functions.
  ///
  /// All functions should produce equivalent results for the comparison to be valid.
  ComparativeBenchmarkResult compare(
      {required Map<String, dynamic Function()> functions,
      int? iterations,
      int warmupIterations = 100,});

  /// Check if benchmark runner is available and properly configured.
  bool get isAvailable;
}

/// Results from a single benchmark run.
class BenchmarkResult {
  const BenchmarkResult({
    required this.name,
    required this.iterations,
    required this.totalTimeMicros,
    required this.averageTimeMicros,
    this.minTimeMicros,
    this.maxTimeMicros,
    this.standardDeviationMicros,
  });

  final String name;
  final int iterations;
  final int totalTimeMicros;
  final double averageTimeMicros;
  final int? minTimeMicros;
  final int? maxTimeMicros;
  final double? standardDeviationMicros;

  /// Average time per iteration in milliseconds
  double get averageTimeMillis => averageTimeMicros / 1000.0;

  /// Operations per second
  double get operationsPerSecond => 1000000.0 / averageTimeMicros;

  @override
  String toString() => 'BenchmarkResult('
      'name: $name, '
      'avg: ${averageTimeMillis.toStringAsFixed(3)}ms, '
      'ops/sec: ${operationsPerSecond.toStringAsFixed(0)}'
      ')';
}

/// Results from comparing multiple benchmarks.
class ComparativeBenchmarkResult {
  const ComparativeBenchmarkResult(
      {required this.results, required this.fastest, required this.slowest,});

  final Map<String, BenchmarkResult> results;
  final String fastest;
  final String slowest;

  /// Get relative performance compared to the fastest
  double getRelativePerformance(String name) {
    final result = results[name];
    final fastestResult = results[fastest];

    if (result == null || fastestResult == null) return 0.0;

    return result.averageTimeMicros / fastestResult.averageTimeMicros;
  }

  @override
  String toString() {
    final buffer = StringBuffer('ComparativeBenchmarkResult:\n');

    // Sort by performance (fastest first)
    final sortedEntries = results.entries.toList()
      ..sort((a, b) =>
          a.value.averageTimeMicros.compareTo(b.value.averageTimeMicros),);

    for (var i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final relative = getRelativePerformance(entry.key);

      buffer.write('  ${i + 1}. ${entry.key}: ');
      buffer.write('${entry.value.averageTimeMillis.toStringAsFixed(3)}ms ');
      buffer.write('(${relative.toStringAsFixed(2)}x)');

      if (i < sortedEntries.length - 1) buffer.write('\n');
    }

    return buffer.toString();
  }
}
