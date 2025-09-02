import 'package:flutter/material.dart';
import 'package:algomate/algomate.dart';
import 'dart:math' as math;

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  final AlgoSelectorFacade _selector = AlgoSelectorFacade.development();
  final List<BenchmarkResult> _results = [];
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '⚡ Performance Benchmarks',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _isRunning ? null : _runBenchmarks,
                icon: _isRunning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.speed),
                label: Text(_isRunning ? 'Running...' : 'Run Benchmarks'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_results.isNotEmpty) ...[
            const Text(
              'Benchmark Results:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: _results.isEmpty
                ? const Center(
                    child: Text(
                      'Click "Run Benchmarks" to start performance testing',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      return BenchmarkCard(result: _results[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _runBenchmarks() async {
    setState(() {
      _isRunning = true;
      _results.clear();
    });

    final benchmarks = [
      () => _benchmarkSorting(),
      () => _benchmarkSearch(),
      () => _benchmarkMatrixOperations(),
      () => _benchmarkGraphAlgorithms(),
    ];

    for (final benchmark in benchmarks) {
      try {
        final result = await benchmark();
        setState(() => _results.add(result));
      } catch (e) {
        setState(
          () => _results.add(
            BenchmarkResult(
              category: 'Error',
              algorithm: 'Unknown',
              dataSize: 0,
              executionTime: Duration.zero,
              memoryUsed: 0,
              error: e.toString(),
            ),
          ),
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }

    setState(() => _isRunning = false);
  }

  Future<BenchmarkResult> _benchmarkSorting() async {
    final sizes = [1000, 5000, 10000];
    final results = <String, Duration>{};

    for (final size in sizes) {
      final data = List.generate(size, (i) => math.Random().nextInt(size));
      final stopwatch = Stopwatch()..start();

      _selector.sort(
        input: data,
        hint: SelectorHint(n: data.length),
      );

      stopwatch.stop();
      results['Size $size'] = stopwatch.elapsed;
    }

    final avgTime = Duration(
      microseconds:
          results.values.map((d) => d.inMicroseconds).reduce((a, b) => a + b) ~/
              results.length,
    );

    return BenchmarkResult(
      category: 'Sorting',
      algorithm: 'MergeSort (Web-Optimized)',
      dataSize: sizes.last,
      executionTime: avgTime,
      memoryUsed: sizes.last * 4, // Approximate bytes
      details: results.entries
          .map((e) => '${e.key}: ${e.value.inMicroseconds}μs')
          .join('\n'),
    );
  }

  Future<BenchmarkResult> _benchmarkSearch() async {
    const size = 100000;
    final data = List.generate(size, (i) => i);
    const target = size ~/ 2;

    final stopwatch = Stopwatch()..start();

    _selector.search(
      input: data,
      target: target,
      hint: SelectorHint(n: data.length, sorted: true),
    );

    stopwatch.stop();

    return BenchmarkResult(
      category: 'Searching',
      algorithm: 'Binary Search',
      dataSize: size,
      executionTime: stopwatch.elapsed,
      memoryUsed: size * 4,
      details:
          'O(log n) complexity\nTarget: $target\nFound in ${stopwatch.elapsedMicroseconds}μs',
    );
  }

  Future<BenchmarkResult> _benchmarkMatrixOperations() async {
    const size = 50; // Reduce size for web performance
    final random = math.Random();

    // Create matrix data using integer lists (compatible with Matrix.fromLists)
    final data1 = List.generate(
        size, (_) => List.generate(size, (_) => random.nextInt(100)),);
    final data2 = List.generate(
        size, (_) => List.generate(size, (_) => random.nextInt(100)),);

    final matrix1 = Matrix.fromLists(data1);
    final matrix2 = Matrix.fromLists(data2);
    final stopwatch = Stopwatch()..start();
    // Use matrix multiplication strategy instead of direct method
    final matrixMult = ParallelMatrixMultiplication();
    matrixMult.execute([matrix1, matrix2]);
    stopwatch.stop();
    return BenchmarkResult(
      category: 'Matrix',
      algorithm: 'Matrix Multiplication',
      dataSize: size * size,
      executionTime: stopwatch.elapsed,
      memoryUsed: size * size * 8 * 3, // 3 matrices, 8 bytes per double
      details: '${size}x$size matrix multiplication\nO(n³) complexity',
    );
  }

  Future<BenchmarkResult> _benchmarkGraphAlgorithms() async {
    final graph = Graph<int>(isDirected: false);
    const vertices = 1000;

    // Add vertices
    for (int i = 0; i < vertices; i++) {
      graph.addVertex(i);
    }

    // Add random edges
    final random = math.Random();
    for (int i = 0; i < vertices * 2; i++) {
      final v1 = random.nextInt(vertices);
      final v2 = random.nextInt(vertices);
      if (v1 != v2) {
        graph.addEdge(v1, v2);
      }
    }

    final stopwatch = Stopwatch()..start();

    final bfs = BreadthFirstSearchStrategy<int>();
    bfs.execute(BfsInput(graph, 0));

    stopwatch.stop();

    return BenchmarkResult(
      category: 'Graph',
      algorithm: 'Breadth-First Search',
      dataSize: vertices,
      executionTime: stopwatch.elapsed,
      memoryUsed: vertices * 32, // Approximate memory for graph structure
      details:
          '$vertices vertices\n~${vertices * 2} edges\nO(V + E) complexity',
    );
  }
}

class BenchmarkResult {
  BenchmarkResult({
    required this.category,
    required this.algorithm,
    required this.dataSize,
    required this.executionTime,
    required this.memoryUsed,
    this.details,
    this.error,
  });
  final String category;
  final String algorithm;
  final int dataSize;
  final Duration executionTime;
  final int memoryUsed;
  final String? details;
  final String? error;

  String get performanceRating {
    final microseconds = executionTime.inMicroseconds;
    if (microseconds < 1000) return 'Excellent';
    if (microseconds < 10000) return 'Good';
    if (microseconds < 100000) return 'Fair';
    return 'Slow';
  }

  Color get performanceColor {
    switch (performanceRating) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.lightGreen;
      case 'Fair':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}

class BenchmarkCard extends StatelessWidget {
  const BenchmarkCard({super.key, required this.result});

  final BenchmarkResult result;

  @override
  Widget build(BuildContext context) {
    if (result.error != null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    'Error in ${result.category}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                result.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${result.category}: ${result.algorithm}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: result.performanceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result.performanceRating,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    'Execution Time',
                    '${result.executionTime.inMicroseconds}μs',
                    Icons.timer,
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    'Data Size',
                    '${result.dataSize}',
                    Icons.data_usage,
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    'Memory',
                    '${(result.memoryUsed / 1024).toStringAsFixed(1)}KB',
                    Icons.memory,
                  ),
                ),
              ],
            ),
            if (result.details != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.details!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
