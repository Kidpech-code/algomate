import 'dart:io';
import 'dart:math' as math;
import 'package:benchmark_harness/benchmark_harness.dart';

/// Comprehensive benchmark suite for AlgoMate algorithms
class AlgoMateBenchmark {
  late AlgoSelector _selector;
  final List<BenchmarkResult> _results = [];

  /// Initialize benchmark suite
  Future<void> initialize() async {
    _selector = AlgoSelectorBuilder()
        .useConsoleLogging()
        .enableExecutionTiming()
        .build();
  }

  /// Run all benchmarks
  Future<void> runAll() async {
    print('🚀 Starting AlgoMate Benchmark Suite');
    print(
        'Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',);
    print('Dart: ${Platform.version}');
    print('═' * 60);

    await _runSortingBenchmarks();
    await _runSearchingBenchmarks();
    await _runOverheadAnalysis();

    _generateReport();
  }

  /// Benchmarks for sorting algorithms
  Future<void> _runSortingBenchmarks() async {
    print('\n📊 Sorting Algorithm Benchmarks');

    final sizes = [100, 1000, 10000, 50000];
    final scenarios = {
      'random': _generateRandomData,
      'sorted': _generateSortedData,
      'reverse': _generateReverseData,
      'nearly_sorted': _generateNearlySortedData,
      'duplicates': _generateDuplicateData,
    };

    for (final size in sizes) {
      for (final scenario in scenarios.entries) {
        final data = scenario.value(size);
        await _benchmarkSort(size, scenario.key, data);
      }
    }
  }

  /// Benchmarks for searching algorithms
  Future<void> _runSearchingBenchmarks() async {
    print('\n🔍 Searching Algorithm Benchmarks');

    final sizes = [1000, 10000, 100000, 1000000];

    for (final size in sizes) {
      final sortedData = _generateSortedData(size);
      final target = sortedData[size ~/ 2]; // Middle element

      await _benchmarkSearch(size, sortedData, target);
    }
  }

  /// Analyze selector overhead vs direct execution
  Future<void> _runOverheadAnalysis() async {
    print('\n⚡ Selector Overhead Analysis');

    final sizes = [100, 1000, 10000];

    for (final size in sizes) {
      final data = _generateRandomData(size);
      await _analyzeOverhead(size, data);
    }
  }

  /// Benchmark sorting performance
  Future<void> _benchmarkSort(int size, String scenario, List<int> data) async {
    final benchmark = SortingBenchmark(_selector, data, scenario);
    final result =
        await _runBenchmarkWithStats(benchmark, 'sort_${size}_$scenario');
    _results.add(result);
  }

  /// Benchmark searching performance
  Future<void> _benchmarkSearch(int size, List<int> data, int target) async {
    final benchmark = SearchingBenchmark(_selector, data, target);
    final result = await _runBenchmarkWithStats(benchmark, 'search_$size');
    _results.add(result);
  }

  /// Analyze selector overhead
  Future<void> _analyzeOverhead(int size, List<int> data) async {
    const iterations = 1000;
    final directTimes = <int>[];
    final selectorTimes = <int>[];

    // Measure direct merge sort execution
    final mergeSort = _selector.getStrategies('sort').first;
    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();
      mergeSort.execute(List.from(data));
      stopwatch.stop();
      directTimes.add(stopwatch.elapsedMicroseconds);
    }

    // Measure selector-based execution
    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();
      await _selector.sort(List.from(data));
      stopwatch.stop();
      selectorTimes.add(stopwatch.elapsedMicroseconds);
    }

    final stats = _calculateStatistics(directTimes, selectorTimes);

    print('Size: $size');
    print('  Direct median: ${stats['direct_median']}μs');
    print('  Selector median: ${stats['selector_median']}μs');
    print('  Overhead: ${stats['overhead']}μs (${stats['overhead_percent']}%)');
    print('  P95 overhead: ${stats['p95_overhead']}μs');
  }

  /// Run benchmark with statistical analysis
  Future<BenchmarkResult> _runBenchmarkWithStats(
      BenchmarkBase benchmark, String name,) async {
    const warmupRuns = 10;
    const measureRuns = 100;

    // Warm up
    for (int i = 0; i < warmupRuns; i++) {
      benchmark.run();
    }

    // Measure
    final times = <double>[];
    for (int i = 0; i < measureRuns; i++) {
      final stopwatch = Stopwatch()..start();
      benchmark.run();
      stopwatch.stop();
      times.add(stopwatch.elapsedMicroseconds.toDouble());
    }

    times.sort();
    final median = _percentile(times, 0.5);
    final p95 = _percentile(times, 0.95);
    final p99 = _percentile(times, 0.99);
    final stdDev = _standardDeviation(times);
    final mean = times.reduce((a, b) => a + b) / times.length;

    final result = BenchmarkResult(
      name: name,
      median: median,
      mean: mean,
      p95: p95,
      p99: p99,
      standardDeviation: stdDev,
      iterations: measureRuns,
    );

    print(
        '${result.name}: ${result.median.toStringAsFixed(2)}μs (±${result.standardDeviation.toStringAsFixed(2)})',);

    return result;
  }

  /// Generate test data
  List<int> _generateRandomData(int size) {
    final random = math.Random(42); // Fixed seed for reproducibility
    return List.generate(size, (_) => random.nextInt(size * 10));
  }

  List<int> _generateSortedData(int size) {
    return List.generate(size, (i) => i);
  }

  List<int> _generateReverseData(int size) {
    return List.generate(size, (i) => size - i);
  }

  List<int> _generateNearlySortedData(int size) {
    final data = _generateSortedData(size);
    final random = math.Random(42);

    // Shuffle 5% of elements
    final shuffleCount = (size * 0.05).round();
    for (int i = 0; i < shuffleCount; i++) {
      final idx1 = random.nextInt(size);
      final idx2 = random.nextInt(size);
      final temp = data[idx1];
      data[idx1] = data[idx2];
      data[idx2] = temp;
    }

    return data;
  }

  List<int> _generateDuplicateData(int size) {
    final random = math.Random(42);
    final uniqueValues = size ~/ 10; // 90% duplicates
    return List.generate(size, (_) => random.nextInt(uniqueValues));
  }

  /// Statistical helper functions
  double _percentile(List<double> sortedData, double percentile) {
    final index = (sortedData.length * percentile).round() - 1;
    return sortedData[math.max(0, math.min(index, sortedData.length - 1))];
  }

  double _standardDeviation(List<double> data) {
    final mean = data.reduce((a, b) => a + b) / data.length;
    final variance =
        data.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
            data.length;
    return math.sqrt(variance);
  }

  Map<String, dynamic> _calculateStatistics(
      List<int> directTimes, List<int> selectorTimes,) {
    directTimes.sort();
    selectorTimes.sort();

    final directMedian = directTimes[directTimes.length ~/ 2];
    final selectorMedian = selectorTimes[selectorTimes.length ~/ 2];
    final overhead = selectorMedian - directMedian;
    final overheadPercent = (overhead / directMedian * 100);

    final directP95 = directTimes[(directTimes.length * 0.95).round() - 1];
    final selectorP95 =
        selectorTimes[(selectorTimes.length * 0.95).round() - 1];
    final p95Overhead = selectorP95 - directP95;

    return {
      'direct_median': directMedian,
      'selector_median': selectorMedian,
      'overhead': overhead,
      'overhead_percent': overheadPercent.toStringAsFixed(2),
      'p95_overhead': p95Overhead,
    };
  }

  /// Generate comprehensive benchmark report
  void _generateReport() {
    print('\n📈 Benchmark Report Summary');
    print('═' * 60);

    // Group results by algorithm type
    final sortResults =
        _results.where((r) => r.name.startsWith('sort_')).toList();
    final searchResults =
        _results.where((r) => r.name.startsWith('search_')).toList();

    if (sortResults.isNotEmpty) {
      print('\n🔄 Sorting Performance:');
      for (final result in sortResults) {
        print(
            '  ${result.name}: ${result.median.toStringAsFixed(2)}μs (P95: ${result.p95.toStringAsFixed(2)}μs)',);
      }
    }

    if (searchResults.isNotEmpty) {
      print('\n🔍 Searching Performance:');
      for (final result in searchResults) {
        print(
            '  ${result.name}: ${result.median.toStringAsFixed(2)}μs (P95: ${result.p95.toStringAsFixed(2)}μs)',);
      }
    }

    // Generate JSON report for CI/CD
    _generateJSONReport();

    print('\n✅ Benchmark completed successfully!');
    print('📊 Detailed results saved to benchmark_results.json');
  }

  /// Generate JSON report for CI integration
  void _generateJSONReport() {
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'platform': {
        'os': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'dart': Platform.version,
      },
      'results': _results.map((r) => r.toJson()).toList(),
    };

    final file = File('benchmark_results.json');
    file.writeAsStringSync(_jsonEncode(report));
  }

  /// Simple JSON encoder (to avoid external dependencies)
  String _jsonEncode(Map<String, dynamic> data) {
    // Simplified JSON encoding - in production, use dart:convert
    final buffer = StringBuffer('{');

    final entries = data.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('"${entry.key}":');

      if (entry.value is String) {
        buffer.write('"${entry.value}"');
      } else if (entry.value is Map) {
        buffer.write(_jsonEncode(entry.value as Map<String, dynamic>));
      } else if (entry.value is List) {
        buffer.write('[');
        final list = entry.value as List;
        for (int j = 0; j < list.length; j++) {
          if (list[j] is Map) {
            buffer.write(_jsonEncode(list[j] as Map<String, dynamic>));
          } else {
            buffer.write('"${list[j]}"');
          }
          if (j < list.length - 1) buffer.write(',');
        }
        buffer.write(']');
      } else {
        buffer.write('${entry.value}');
      }

      if (i < entries.length - 1) buffer.write(',');
    }

    buffer.write('}');
    return buffer.toString();
  }
}

/// Individual benchmark for sorting algorithms
class SortingBenchmark extends BenchmarkBase {
  SortingBenchmark(this._selector, this._originalData, String scenario)
      : super('Sort_${_originalData.length}_$scenario');
  final AlgoSelector _selector;
  final List<int> _originalData;
  late List<int> _data;

  @override
  void setup() {
    _data = List.from(_originalData);
  }

  @override
  void run() {
    _selector.sort(_data);
  }
}

/// Individual benchmark for searching algorithms
class SearchingBenchmark extends BenchmarkBase {
  SearchingBenchmark(this._selector, this._data, this._target)
      : super('Search_${_data.length}');
  final AlgoSelector _selector;
  final List<int> _data;
  final int _target;

  @override
  void run() {
    _selector.search(_data, _target);
  }
}

/// Benchmark result with statistical information
class BenchmarkResult {
  BenchmarkResult({
    required this.name,
    required this.median,
    required this.mean,
    required this.p95,
    required this.p99,
    required this.standardDeviation,
    required this.iterations,
  });
  final String name;
  final double median;
  final double mean;
  final double p95;
  final double p99;
  final double standardDeviation;
  final int iterations;

  Map<String, dynamic> toJson() => {
        'name': name,
        'median_us': median,
        'mean_us': mean,
        'p95_us': p95,
        'p99_us': p99,
        'std_dev': standardDeviation,
        'iterations': iterations,
      };
}

/// Entry point for running benchmarks
// Minimal implementations to satisfy references to AlgoSelector and related APIs
// These are lightweight placeholders — replace with real implementations as needed.
class AlgoSelector {
  AlgoSelector({this.consoleLogging = false, this.timingEnabled = false});
  final bool consoleLogging;
  final bool timingEnabled;

  List<Strategy> getStrategies(String type) {
    if (type == 'sort') return [MergeSortStrategy()];
    return [];
  }

  Future<void> sort(List<int> data) async {
    // Simple in-place sort; async to match usage where awaited.
    data.sort();
    if (timingEnabled) {
      // Yield to the event loop to emulate async timing overhead
      await Future<void>.delayed(Duration.zero);
    }
  }

  int search(List<int> data, int target) {
    // Simple binary search (expects sorted data)
    int low = 0;
    int high = data.length - 1;
    while (low <= high) {
      final mid = (low + high) >> 1;
      if (data[mid] == target) return mid;
      if (data[mid] < target) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    return -1;
  }
}

abstract class Strategy {
  void execute(List<int> data);
}

class MergeSortStrategy implements Strategy {
  @override
  void execute(List<int> data) {
    // Placeholder: use Dart's built-in sort for simplicity
    data.sort();
  }
}

class AlgoSelectorBuilder {
  bool _consoleLogging = false;
  bool _timing = false;

  AlgoSelectorBuilder useConsoleLogging() {
    _consoleLogging = true;
    return this;
  }

  AlgoSelectorBuilder enableExecutionTiming() {
    _timing = true;
    return this;
  }

  AlgoSelector build() {
    return AlgoSelector(
        consoleLogging: _consoleLogging, timingEnabled: _timing,);
  }
}

/// Entry point for running benchmarks
Future<void> main(List<String> arguments) async {
  final benchmark = AlgoMateBenchmark();
  await benchmark.initialize();
  await benchmark.runAll();
}
