import 'dart:math' as math;

import '../../../application/ports/benchmark_runner.dart';

/// Benchmark runner implementation using Dart's built-in benchmark capabilities.
///
/// Provides accurate performance measurement with statistical analysis,
/// warmup periods, and platform-specific optimizations for reliable results.
class HarnessBenchmarkRunner implements BenchmarkRunner {
  const HarnessBenchmarkRunner({
    this.minIterations = 100,
    this.maxIterations = 100000,
    this.targetDurationMicros = 1000000, // 1 second
  });

  final int minIterations;
  final int maxIterations;
  final int targetDurationMicros;

  @override
  bool get isAvailable => true;

  @override
  BenchmarkResult run({
    required String name,
    required dynamic Function() function,
    int? iterations,
    int warmupIterations = 100,
  }) {
    // Warmup phase
    for (int i = 0; i < warmupIterations; i++) {
      function();
    }

    final actualIterations =
        iterations ?? _determineOptimalIterations(function);
    final timings = <int>[];
    final stopwatch = Stopwatch();

    // Measurement phase
    stopwatch.start();
    final startTime = stopwatch.elapsedMicroseconds;

    for (int i = 0; i < actualIterations; i++) {
      final iterationStart = stopwatch.elapsedMicroseconds;
      function();
      final iterationEnd = stopwatch.elapsedMicroseconds;
      timings.add(iterationEnd - iterationStart);
    }

    final endTime = stopwatch.elapsedMicroseconds;
    stopwatch.stop();

    // Calculate statistics
    final totalTimeMicros = endTime - startTime;
    final averageTimeMicros = totalTimeMicros / actualIterations;
    final minTimeMicros = timings.isNotEmpty ? timings.reduce(math.min) : 0;
    final maxTimeMicros = timings.isNotEmpty ? timings.reduce(math.max) : 0;

    // Standard deviation calculation
    double standardDeviation = 0.0;
    if (timings.length > 1) {
      final mean = timings.fold(0, (sum, time) => sum + time) / timings.length;
      final variance = timings
              .map((time) => math.pow(time - mean, 2))
              .fold(0.0, (sum, sq) => sum + sq) /
          timings.length;
      standardDeviation = math.sqrt(variance);
    }

    return BenchmarkResult(
      name: name,
      iterations: actualIterations,
      totalTimeMicros: totalTimeMicros,
      averageTimeMicros: averageTimeMicros,
      minTimeMicros: minTimeMicros,
      maxTimeMicros: maxTimeMicros,
      standardDeviationMicros: standardDeviation,
    );
  }

  @override
  ComparativeBenchmarkResult compare({
    required Map<String, dynamic Function()> functions,
    int? iterations,
    int warmupIterations = 100,
  }) {
    final results = <String, BenchmarkResult>{};

    // Run benchmarks for all functions
    for (final entry in functions.entries) {
      results[entry.key] = run(
        name: entry.key,
        function: entry.value,
        iterations: iterations,
        warmupIterations: warmupIterations,
      );
    }

    // Find fastest and slowest
    String fastest = '';
    String slowest = '';
    double fastestTime = double.infinity;
    double slowestTime = 0.0;

    for (final entry in results.entries) {
      final avgTime = entry.value.averageTimeMicros;
      if (avgTime < fastestTime) {
        fastestTime = avgTime;
        fastest = entry.key;
      }
      if (avgTime > slowestTime) {
        slowestTime = avgTime;
        slowest = entry.key;
      }
    }

    return ComparativeBenchmarkResult(
      results: results,
      fastest: fastest,
      slowest: slowest,
    );
  }

  /// Determine optimal number of iterations for reliable measurement.
  int _determineOptimalIterations(dynamic Function() function) {
    // Quick test to estimate function execution time
    final stopwatch = Stopwatch()..start();

    // Run a few iterations to get baseline timing
    const calibrationRuns = 10;
    for (int i = 0; i < calibrationRuns; i++) {
      function();
    }

    final elapsedMicros = stopwatch.elapsedMicroseconds;
    stopwatch.stop();

    if (elapsedMicros == 0) {
      return maxIterations; // Function is extremely fast
    }

    final averageTimePerRun = elapsedMicros / calibrationRuns;
    final targetIterations = targetDurationMicros ~/ averageTimePerRun;

    // Clamp to reasonable bounds
    return math.max(minIterations, math.min(maxIterations, targetIterations));
  }
}

/// Simple benchmark runner for basic performance testing.
///
/// Uses a fixed number of iterations without statistical analysis.
/// Suitable for quick performance checks and testing scenarios.
class SimpleBenchmarkRunner implements BenchmarkRunner {
  const SimpleBenchmarkRunner({this.defaultIterations = 1000});

  final int defaultIterations;

  @override
  bool get isAvailable => true;

  @override
  BenchmarkResult run({
    required String name,
    required dynamic Function() function,
    int? iterations,
    int warmupIterations = 10,
  }) {
    final actualIterations = iterations ?? defaultIterations;

    // Minimal warmup
    for (int i = 0; i < warmupIterations; i++) {
      function();
    }

    // Measurement
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < actualIterations; i++) {
      function();
    }

    final totalTimeMicros = stopwatch.elapsedMicroseconds;
    stopwatch.stop();

    final averageTimeMicros = totalTimeMicros / actualIterations;

    return BenchmarkResult(
      name: name,
      iterations: actualIterations,
      totalTimeMicros: totalTimeMicros,
      averageTimeMicros: averageTimeMicros,
    );
  }

  @override
  ComparativeBenchmarkResult compare({
    required Map<String, dynamic Function()> functions,
    int? iterations,
    int warmupIterations = 10,
  }) {
    final results = <String, BenchmarkResult>{};

    for (final entry in functions.entries) {
      results[entry.key] = run(
        name: entry.key,
        function: entry.value,
        iterations: iterations,
        warmupIterations: warmupIterations,
      );
    }

    // Find fastest and slowest
    String fastest = functions.keys.first;
    String slowest = functions.keys.first;

    for (final entry in results.entries) {
      if (entry.value.averageTimeMicros < results[fastest]!.averageTimeMicros) {
        fastest = entry.key;
      }
      if (entry.value.averageTimeMicros > results[slowest]!.averageTimeMicros) {
        slowest = entry.key;
      }
    }

    return ComparativeBenchmarkResult(
      results: results,
      fastest: fastest,
      slowest: slowest,
    );
  }
}

/// Mock benchmark runner for testing scenarios.
///
/// Returns predictable results without actual execution,
/// useful for unit testing and development.
class MockBenchmarkRunner implements BenchmarkRunner {
  MockBenchmarkRunner({
    this.mockResults = const {},
    this.defaultTimeMicros = 1000.0,
  });

  final Map<String, BenchmarkResult> mockResults;
  final double defaultTimeMicros;

  @override
  bool get isAvailable => true;

  @override
  BenchmarkResult run({
    required String name,
    required dynamic Function() function,
    int? iterations,
    int warmupIterations = 0,
  }) {
    if (mockResults.containsKey(name)) {
      return mockResults[name]!;
    }

    final actualIterations = iterations ?? 1000;
    return BenchmarkResult(
      name: name,
      iterations: actualIterations,
      totalTimeMicros: (defaultTimeMicros * actualIterations).round(),
      averageTimeMicros: defaultTimeMicros,
    );
  }

  @override
  ComparativeBenchmarkResult compare({
    required Map<String, dynamic Function()> functions,
    int? iterations,
    int warmupIterations = 0,
  }) {
    final results = <String, BenchmarkResult>{};

    for (final entry in functions.entries) {
      results[entry.key] = run(
        name: entry.key,
        function: entry.value,
        iterations: iterations,
        warmupIterations: warmupIterations,
      );
    }

    final fastest = results.keys.first;
    final slowest = results.keys.last;

    return ComparativeBenchmarkResult(
      results: results,
      fastest: fastest,
      slowest: slowest,
    );
  }
}
