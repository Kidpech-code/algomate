import 'dart:io';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:benchmark_harness/benchmark_harness.dart';

// Simple strategy interface and a placeholder merge sort strategy
abstract class Strategy {
  void execute(List<int> data);
}

class MergeSortStrategy implements Strategy {
  @override
  void execute(List<int> data) {
    // For now just use built-in sort as a stand-in for merge sort
    data.sort();
  }
}

// Algo selector provides sorting/searching and a way to list strategies
class AlgoSelector {
  AlgoSelector({this.consoleLogging = false, this.timingEnabled = false});
  final bool consoleLogging;
  final bool timingEnabled;

  List<Strategy> getStrategies(String type) {
    if (type == 'sort') return [MergeSortStrategy()];
    return <Strategy>[];
  }

  Future<void> sort(List<int> data) async {
    data.sort();
    if (timingEnabled) {
      // Yield to event loop to emulate async overhead if timing enabled
      await Future<void>.delayed(Duration.zero);
    }
  }

  int search(List<int> data, int target) {
    // Binary search (expects sorted data)
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
      consoleLogging: _consoleLogging,
      timingEnabled: _timing,
    );
  }
}

// Results containers
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

class MicrobenchResult {
  MicrobenchResult({
    required this.name,
    required this.allocations,
    required this.peakMemory,
    required this.gcCycles,
    required this.iterations,
  });
  final String name;
  final int allocations;
  final int peakMemory;
  final int gcCycles;
  final int iterations;

  Map<String, dynamic> toJson() => {
        'name': name,
        'allocations_bytes': allocations,
        'peak_memory_bytes': peakMemory,
        'gc_cycles': gcCycles,
        'iterations': iterations,
      };
}

// Benchmarks built on benchmark_harness
class SortingBenchmark extends BenchmarkBase {
  SortingBenchmark(this.selector, this.originalData, this.scenario)
      : super('Sort_${originalData.length}_$scenario');
  final AlgoSelector selector;
  final List<int> originalData;
  final String scenario;
  late List<int> data;

  @override
  void setup() {
    data = List<int>.from(originalData);
  }

  @override
  void run() {
    selector.sort(data);
  }

  @override
  void teardown() {
    data = const [];
  }
}

class SearchingBenchmark extends BenchmarkBase {
  SearchingBenchmark(this.selector, this.data, this.target)
      : super('Search_${data.length}');
  final AlgoSelector selector;
  final List<int> data;
  final int target;

  @override
  void run() {
    selector.search(data, target);
  }
}

class AlgoMateBenchmark {
  late AlgoSelector _selector;
  final List<BenchmarkResult> _results = [];
  final List<MicrobenchResult> _micro = [];
  late int _seed;
  int _measureRuns = 80;
  String? _jsonPath;
  String? _csvPath;

  void configure({
    required int seed,
    required int measureRuns,
    String? jsonPath,
    String? csvPath,
  }) {
    _seed = seed;
    _measureRuns = measureRuns;
    _jsonPath = jsonPath;
    _csvPath = csvPath;
  }

  Future<void> initialize() async {
    _selector = AlgoSelectorBuilder()
        .useConsoleLogging()
        // Keep timing disabled to reduce overhead skew
        .build();
  }

  Future<void> runAll() async {
    print('🚀 Starting AlgoMate Benchmark Suite');
    print(
      'Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
    );
    print('Dart: ${Platform.version}');
    print('═' * 60);

    await _runSortingBenchmarks();
    await _runSearchingBenchmarks();
    await _runOverheadAnalysis();

    _generateReport();
  }

  // Sorting benchmarks
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

  // Searching benchmarks
  Future<void> _runSearchingBenchmarks() async {
    print('\n🔍 Searching Algorithm Benchmarks');

    final sizes = [1000, 10000, 100000, 1000000];

    for (final size in sizes) {
      final sortedData = _generateSortedData(size);
      final target = sortedData[size ~/ 2]; // Middle element
      await _benchmarkSearch(size, sortedData, target);
    }
  }

  // Overhead analysis
  Future<void> _runOverheadAnalysis() async {
    print('\n⚡ Selector Overhead Analysis');

    final sizes = [100, 1000, 10000];

    for (final size in sizes) {
      final data = _generateRandomData(size);
      await _analyzeOverhead(size, data);
    }
  }

  Future<void> _benchmarkSort(int size, String scenario, List<int> data) async {
    final benchmark = SortingBenchmark(_selector, data, scenario);
    final result =
        await _runBenchmarkWithStats(benchmark, 'sort_${size}_$scenario');
    _results.add(result);
  }

  Future<void> _benchmarkSearch(int size, List<int> data, int target) async {
    final benchmark = SearchingBenchmark(_selector, data, target);
    final result = await _runBenchmarkWithStats(benchmark, 'search_$size');
    _results.add(result);
  }

  Future<void> _analyzeOverhead(int size, List<int> data) async {
    const iterations = 500; // keep tight but not too long
    final directTimes = <int>[];
    final selectorTimes = <int>[];

    final mergeSort = _selector.getStrategies('sort').first;
    for (int i = 0; i < iterations; i++) {
      final sw = Stopwatch()..start();
      mergeSort.execute(List<int>.from(data));
      sw.stop();
      directTimes.add(sw.elapsedMicroseconds);
    }

    for (int i = 0; i < iterations; i++) {
      final sw = Stopwatch()..start();
      await _selector.sort(List<int>.from(data));
      sw.stop();
      selectorTimes.add(sw.elapsedMicroseconds);
    }

    final stats = _calculateStatistics(directTimes, selectorTimes);

    print('Size: $size');
    print('  Direct median: ${stats['direct_median']}μs');
    print('  Selector median: ${stats['selector_median']}μs');
    print('  Overhead: ${stats['overhead']}μs (${stats['overhead_percent']}%)');
    print('  P95 overhead: ${stats['p95_overhead']}μs');
  }

  Future<BenchmarkResult> _runBenchmarkWithStats(
    BenchmarkBase benchmark,
    String name,
  ) async {
    const warmupRuns = 8;
    final measureRuns = _measureRuns;

    // Warm up
    for (int i = 0; i < warmupRuns; i++) {
      benchmark.setup();
      benchmark.run();
      benchmark.teardown();
    }

    // Optional VM service metrics collector
    final microCollector = await _VmMicroCollector.create();

    // Measure
    final times = <double>[];
    for (int i = 0; i < measureRuns; i++) {
      benchmark.setup();
      final sw = Stopwatch()..start();
      benchmark.run();
      sw.stop();
      benchmark.teardown();
      times.add(sw.elapsedMicroseconds.toDouble());
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
      '${result.name}: ${result.median.toStringAsFixed(2)}μs (±${result.standardDeviation.toStringAsFixed(2)})',
    );

    // Gather optional micro metrics
    MicrobenchResult? micro;
    if (microCollector != null) {
      final m = await microCollector.snapshot(name);
      if (m != null) {
        _micro.add(m);
        micro = m;
      }
    }

    // Append CSV row if requested
    if (_csvPath != null) {
      final file = File(_csvPath!);
      if (!file.existsSync()) {
        file.createSync(recursive: true);
        file.writeAsStringSync(
          'name,median_us,mean_us,p95_us,p99_us,std_dev_us,iterations,allocations_bytes,peak_memory_bytes,gc_cycles\n',
        );
      }
      final row = [
        result.name,
        result.median.toStringAsFixed(2),
        result.mean.toStringAsFixed(2),
        result.p95.toStringAsFixed(2),
        result.p99.toStringAsFixed(2),
        result.standardDeviation.toStringAsFixed(2),
        result.iterations,
        micro?.allocations ?? '',
        micro?.peakMemory ?? '',
        micro?.gcCycles ?? '',
      ].join(',');
      file.writeAsStringSync('$row\n', mode: FileMode.append);
    }

    return result;
  }

  // Data generators
  List<int> _generateRandomData(int size) {
    final rnd = math.Random(_seed);
    return List<int>.generate(size, (_) => rnd.nextInt(size * 10));
  }

  List<int> _generateSortedData(int size) {
    return List<int>.generate(size, (i) => i);
  }

  List<int> _generateReverseData(int size) {
    return List<int>.generate(size, (i) => size - i);
  }

  List<int> _generateNearlySortedData(int size) {
    final data = _generateSortedData(size);
    final rnd = math.Random(_seed);
    final shuffleCount = (size * 0.05).round();
    for (int i = 0; i < shuffleCount; i++) {
      final a = rnd.nextInt(size);
      final b = rnd.nextInt(size);
      final t = data[a];
      data[a] = data[b];
      data[b] = t;
    }
    return data;
  }

  List<int> _generateDuplicateData(int size) {
    final rnd = math.Random(_seed);
    final uniq = math.max(1, size ~/ 10);
    return List<int>.generate(size, (_) => rnd.nextInt(uniq));
  }

  // Stats helpers
  double _percentile(List<double> sortedData, double percentile) {
    final index = (sortedData.length * percentile).round() - 1;
    final i = index.clamp(0, sortedData.length - 1);
    return sortedData[i];
  }

  double _standardDeviation(List<double> data) {
    final mean = data.reduce((a, b) => a + b) / data.length;
    var sumSq = 0.0;
    for (final x in data) {
      final d = x - mean;
      sumSq += d * d;
    }
    final variance = sumSq / data.length;
    return math.sqrt(variance);
  }

  Map<String, dynamic> _calculateStatistics(
    List<int> directTimes,
    List<int> selectorTimes,
  ) {
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

  // Reporting
  void _generateReport() {
    print('\n📈 Benchmark Report Summary');
    print('═' * 60);

    final sortResults =
        _results.where((r) => r.name.startsWith('sort_')).toList();
    final searchResults =
        _results.where((r) => r.name.startsWith('search_')).toList();

    if (sortResults.isNotEmpty) {
      print('\n🔄 Sorting Performance:');
      for (final r in sortResults) {
        print(
          '  ${r.name}: ${r.median.toStringAsFixed(2)}μs (P95: ${r.p95.toStringAsFixed(2)}μs)',
        );
      }
    }

    if (searchResults.isNotEmpty) {
      print('\n🔍 Searching Performance:');
      for (final r in searchResults) {
        print(
          '  ${r.name}: ${r.median.toStringAsFixed(2)}μs (P95: ${r.p95.toStringAsFixed(2)}μs)',
        );
      }
    }

    _generateJSONReport();

    print('\n✅ Benchmark completed successfully!');
    print('📊 Detailed results saved to benchmark_results.json');
  }

  void _generateJSONReport() {
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'platform': {
        'os': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'dart': Platform.version,
      },
      'seed': _seed,
      'results': _results.map((r) => r.toJson()).toList(),
      'micro': _micro.map((m) => m.toJson()).toList(),
    };

    final path = _jsonPath ?? 'benchmark_results.json';
    final file = File(path);
    file.writeAsStringSync(_jsonEncode(report));
  }

  String _jsonEncode(Map<String, dynamic> data) {
    final buffer = StringBuffer('{');

    final entries = data.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('"${entry.key}":');

      final v = entry.value;
      if (v is String) {
        buffer.write('"$v"');
      } else if (v is Map<String, dynamic>) {
        buffer.write(_jsonEncode(v));
      } else if (v is List) {
        buffer.write('[');
        for (int j = 0; j < v.length; j++) {
          final item = v[j];
          if (item is Map<String, dynamic>) {
            buffer.write(_jsonEncode(item));
          } else if (item is String) {
            buffer.write('"$item"');
          } else {
            buffer.write('$item');
          }
          if (j < v.length - 1) buffer.write(',');
        }
        buffer.write(']');
      } else {
        buffer.write('$v');
      }

      if (i < entries.length - 1) buffer.write(',');
    }

    buffer.write('}');
    return buffer.toString();
  }
}

Future<void> main(List<String> arguments) async {
  // Simple arg parsing
  int iterations = 80;
  int seed = 42;
  String? jsonPath;
  String? csvPath;
  // dataset filter could be used to limit scenarios in future

  for (int i = 0; i < arguments.length; i++) {
    final arg = arguments[i];
    if (arg == '--iterations' && i + 1 < arguments.length) {
      iterations = int.tryParse(arguments[++i]) ?? iterations;
    } else if (arg == '--seed' && i + 1 < arguments.length) {
      seed = int.tryParse(arguments[++i]) ?? seed;
    } else if (arg == '--json' && i + 1 < arguments.length) {
      jsonPath = arguments[++i];
    } else if (arg == '--csv' && i + 1 < arguments.length) {
      csvPath = arguments[++i];
    }
  }

  final benchmark = AlgoMateBenchmark();
  benchmark.configure(
    seed: seed,
    measureRuns: iterations,
    jsonPath: jsonPath,
    csvPath: csvPath,
  );
  await benchmark.initialize();
  await benchmark.runAll();
}

/// Optional VM-service backed micro-metrics collector (allocations, GC, memory).
class _VmMicroCollector {
  _VmMicroCollector();

  static Future<_VmMicroCollector?> create() async {
    try {
      // Try to connect to VM service via vm_service package
      // Only works if running with --enable-vm-service
      final info = await developer.Service.getInfo();
      if (info.serverUri == null) return null;
      return _VmMicroCollector();
    } catch (_) {
      return null;
    }
  }

  Future<MicrobenchResult?> snapshot(String name) async {
    try {
      // Use vm_service to get allocations and GC cycles
      // This requires running with --enable-vm-service and vm_service dependency
      // If not available, fallback to ProcessInfo
      const int allocations = -1;
      const int gcCycles = -1;
      int peakMemory = -1;
      try {
        // If available, use vm_service API (pseudo-code)
        // For now, fallback to ProcessInfo
        peakMemory = ProcessInfo.currentRss;
      } catch (_) {
        peakMemory = ProcessInfo.currentRss;
      }
      return MicrobenchResult(
        name: name,
        allocations: allocations,
        peakMemory: peakMemory,
        gcCycles: gcCycles,
        iterations: 1,
      );
    } catch (_) {
      return null;
    }
  }
}
