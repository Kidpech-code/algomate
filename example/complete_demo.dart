import 'dart:math';
import 'package:algomate/algomate.dart';
import 'package:algomate/src/infrastructure/adapters/execution/concrete_direct_executor.dart';
import 'package:algomate/src/interface/performance/direct_executor.dart';

/// Comprehensive AlgoMate Demo - Full Feature Showcase
///
/// This demo shows all AlgoMate capabilities:
/// 1. Standard algorithm selection
/// 2. Parallel/multi-core algorithms
/// 3. Direct execution API
/// 4. Performance benchmarking
/// 5. Matrix and graph operations
void main() async {
  print('🎯 AlgoMate Complete Demo');
  print('=========================\n');

  // 1. Standard Algorithm Selection
  await demonstrateStandardAlgorithms();

  // 2. Parallel Algorithms
  await demonstrateParallelAlgorithms();

  // 3. Direct Execution API
  await demonstrateDirectExecution();

  // 4. Performance Benchmarking
  await demonstratePerformanceBenchmarking();

  // 5. Advanced Data Structures
  await demonstrateAdvancedOperations();

  print('\n🏆 Complete AlgoMate demonstration finished!');
  print('📊 All algorithms, parallel processing, and benchmarking showcased.');
}

/// Demonstrate standard algorithm selection
Future<void> demonstrateStandardAlgorithms() async {
  print('📚 Standard Algorithm Selection');
  print('================================');

  final selector = AlgoSelectorFacade.development();

  // Small dataset - should select insertion sort
  final smallData = [64, 34, 25, 12, 22, 11, 90];
  print('\n1. Small Dataset Sorting (${smallData.length} elements):');

  final smallResult = selector.sort(
    input: smallData,
    hint: SelectorHint(n: smallData.length),
  );

  smallResult.fold(
    (success) {
      print('   ✓ Input:  $smallData');
      print('   ✓ Output: ${success.output}');
      print('   ✓ Algorithm: ${success.selectedStrategy.name}');
      print(
          '   ✓ Time: ${success.executionTimeMicros != null ? "${success.executionTimeMicros! / 1000}ms" : "not measured"}');
    },
    (failure) => print('   ❌ Error: $failure'),
  );

  // Medium dataset - should select merge sort or quick sort
  final mediumData = List.generate(1000, (i) => Random(42).nextInt(10000));
  print('\n2. Medium Dataset Sorting (${mediumData.length} elements):');

  final mediumResult = selector.sort(
    input: mediumData,
    hint: SelectorHint(n: mediumData.length),
  );

  mediumResult.fold(
    (success) {
      print('   ✓ Sorted ${mediumData.length} elements');
      print('   ✓ Algorithm: ${success.selectedStrategy.name}');
      print(
          '   ✓ Time: ${success.executionTimeMicros != null ? "${success.executionTimeMicros! / 1000}ms" : "not measured"}');
      print(
          '   ✓ Verification: ${_isArraySorted(success.output) ? "PASSED" : "FAILED"}');
    },
    (failure) => print('   ❌ Error: $failure'),
  );

  // Search demonstration
  final sortedData = List.generate(1000, (i) => i * 2);
  const searchTarget = 500;

  print('\n3. Search Operations:');
  final searchResult = selector.search(
    input: sortedData,
    target: searchTarget,
    hint: SelectorHint(n: sortedData.length),
  );

  searchResult.fold(
    (success) {
      print('   ✓ Found $searchTarget at index: ${success.output}');
      print('   ✓ Algorithm: ${success.selectedStrategy.name}');
      print(
          '   ✓ Time: ${success.executionTimeMicros != null ? "${success.executionTimeMicros! / 1000}ms" : "not measured"}');
    },
    (failure) => print('   ❌ Search failed: $failure'),
  );
}

/// Demonstrate parallel algorithms with performance comparison
Future<void> demonstrateParallelAlgorithms() async {
  print('\n\n🚀 Parallel Algorithm Performance');
  print('==================================');

  // Large dataset for parallel processing
  final largeData = List.generate(100000, (i) => Random(42).nextInt(1000000));
  print('Dataset size: ${largeData.length} elements');

  // Compare sequential vs parallel sorting
  print('\n1. Sequential vs Parallel Sorting Comparison:');

  // Sequential merge sort
  final sequentialMergeSort = MergeSortStrategy();
  final stopwatch1 = Stopwatch()..start();
  final sequentialResult = sequentialMergeSort.execute(List.from(largeData));
  stopwatch1.stop();

  print('   📊 Sequential Merge Sort:');
  print('      ✓ Time: ${stopwatch1.elapsedMilliseconds}ms');
  print(
      '      ✓ Verification: ${_isArraySorted(sequentialResult) ? "PASSED" : "FAILED"}');

  // Parallel merge sort
  final parallelMergeSort = ParallelMergeSort();
  if (parallelMergeSort.canApply(
      largeData, SelectorHint(n: largeData.length))) {
    final stopwatch2 = Stopwatch()..start();
    final parallelResult = parallelMergeSort.execute(List.from(largeData));
    stopwatch2.stop();

    print('   🚀 Parallel Merge Sort:');
    print('      ✓ Time: ${stopwatch2.elapsedMilliseconds}ms');
    print(
        '      ✓ Verification: ${_isArraySorted(parallelResult) ? "PASSED" : "FAILED"}');

    final speedup =
        stopwatch1.elapsedMilliseconds / stopwatch2.elapsedMilliseconds;
    print('      📈 Speedup: ${speedup.toStringAsFixed(2)}x');
    print(
        '      💾 Memory overhead: ${parallelMergeSort.meta.memoryOverheadBytes} bytes');
  } else {
    print('   ⚠️  Parallel merge sort not available on this platform');
  }

  // Parallel search demonstration
  print('\n2. Parallel Binary Search:');
  final hugeSortedArray = List.generate(1000000, (i) => i * 3);
  const searchTarget = 1500000;

  final parallelSearch = ParallelBinarySearch(searchTarget);
  if (parallelSearch.canApply(
      hugeSortedArray, SelectorHint(n: hugeSortedArray.length))) {
    final stopwatch3 = Stopwatch()..start();
    final searchIndex = parallelSearch.execute(hugeSortedArray);
    stopwatch3.stop();

    print('   🔍 Parallel Binary Search:');
    print('      ✓ Found $searchTarget at index: $searchIndex');
    print('      ✓ Time: ${stopwatch3.elapsedMicroseconds}μs');
    print('      ✓ Array size: ${hugeSortedArray.length} elements');
  } else {
    print('   ⚠️  Parallel binary search not available');
  }
}

/// Demonstrate direct execution API for performance-critical scenarios
Future<void> demonstrateDirectExecution() async {
  print('\n\n⚡ Direct Execution API');
  print('=======================');

  try {
    print('\n1. Direct Strategy Execution (Simplified):');

    // Direct execution using strategy instances
    final testData = [5, 2, 8, 1, 9, 3, 7, 4, 6];
    print('   Input: $testData');

    // Direct merge sort execution
    final mergeSort = MergeSortStrategy();
    final directResult = mergeSort.execute(testData);
    print('   ✓ Direct merge sort result: $directResult');
    print('   ✓ Bypassed selection overhead');
    print('   ✓ Algorithm: ${mergeSort.meta.name}');

    // Direct quick sort execution
    final quickSort = QuickSortStrategy();
    final quickResult = quickSort.execute(List.from(testData));
    print('   ✓ Direct quick sort result: $quickResult');
    print('   ✓ Algorithm: ${quickSort.meta.name}');

    // Strategy metadata
    print('\n2. Strategy Information:');
    print('   📊 Merge Sort Metadata:');
    print('      • Time Complexity: ${mergeSort.meta.timeComplexity}');
    print('      • Space Complexity: ${mergeSort.meta.spaceComplexity}');
    print(
        '      • Memory Overhead: ${mergeSort.meta.memoryOverheadBytes} bytes');
    print('      • Description: ${mergeSort.meta.description}');

    print('   📊 Quick Sort Metadata:');
    print('      • Time Complexity: ${quickSort.meta.timeComplexity}');
    print('      • Space Complexity: ${quickSort.meta.spaceComplexity}');
    print(
        '      • Memory Overhead: ${quickSort.meta.memoryOverheadBytes} bytes');

    // Performance comparison
    print('\n3. Performance Comparison (Direct vs Facade):');
    final selector = AlgoSelectorFacade.development();

    // Measure direct execution
    final stopwatch1 = Stopwatch()..start();
    for (int i = 0; i < 1000; i++) {
      mergeSort.execute(List.from(testData));
    }
    stopwatch1.stop();

    // Measure facade execution
    final stopwatch2 = Stopwatch()..start();
    for (int i = 0; i < 1000; i++) {
      selector.sort(
          input: List.from(testData), hint: SelectorHint(n: testData.length));
    }
    stopwatch2.stop();

    final directTime = stopwatch1.elapsedMicroseconds / 1000;
    final facadeTime = stopwatch2.elapsedMicroseconds / 1000;
    final overhead = ((facadeTime - directTime) / directTime * 100);

    print('   📊 Performance Results (1000 iterations):');
    print('      • Direct execution: ${directTime.toStringAsFixed(2)}μs avg');
    print('      • Facade execution: ${facadeTime.toStringAsFixed(2)}μs avg');
    print('      • Selection overhead: ${overhead.toStringAsFixed(1)}%');
  } catch (e) {
    print('   ⚠️  Direct execution demo failed: $e');
  }
}

/// Demonstrate performance benchmarking
Future<void> demonstratePerformanceBenchmarking() async {
  print('\n\n📈 Performance Benchmarking');
  print('============================');

  final benchmarkData =
      List.generate(10000, (i) => Random(123).nextInt(100000));

  try {
    // Overhead analysis
    print('\n1. Overhead Analysis (Direct vs Selector):');
    final overheadResults = await OverheadAnalyzer.analyzeOverhead(
      'merge_sort',
      benchmarkData,
      iterations: 50,
    );

    print('   📊 Performance Comparison:');
    print(
        '      • Direct execution median: ${overheadResults['direct_median_us']}μs');
    print(
        '      • Selector execution median: ${overheadResults['selector_median_us']}μs');
    print('      • Overhead: ${overheadResults['overhead_us']}μs');
    print(
        '      • Overhead percentage: ${overheadResults['overhead_percent']}%');
    print('      • Test iterations: ${overheadResults['iterations']}');

    // Strategy benchmarking
    print('\n2. Strategy Benchmarking:');
    final selector = AlgoSelectorFacade.development();
    final directExecutor = ConcreteDirectExecutor(selector.catalog);
    final benchmarkResults = await OverheadAnalyzer.benchmarkStrategy(
      'quick_sort',
      benchmarkData,
      iterations: 100,
      directExecutor: directExecutor,
    );

    print('   📊 Quick Sort Performance:');
    print('      • Median time: ${benchmarkResults['median_us']}μs');
    print('      • Mean time: ${benchmarkResults['mean_us']}μs');
    print('      • P95 time: ${benchmarkResults['p95_us']}μs');
    print('      • P99 time: ${benchmarkResults['p99_us']}μs');
    print('      • Min time: ${benchmarkResults['min_us']}μs');
    print('      • Max time: ${benchmarkResults['max_us']}μs');
    print(
        '      • Success rate: ${benchmarkResults['success_count']}/${benchmarkResults['iterations']}');
  } catch (e) {
    print('   ⚠️  Benchmarking failed: $e');
  }
}

/// Demonstrate advanced operations (Matrix and Graph)
Future<void> demonstrateAdvancedOperations() async {
  print('\n\n🧮 Advanced Data Structures');
  print('============================');

  // Matrix operations
  print('\n1. Matrix Multiplication:');
  final matrixA = Matrix.fromLists([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
  ]);

  final matrixB = Matrix.fromLists([
    [9, 8, 7],
    [6, 5, 4],
    [3, 2, 1],
  ]);

  print('   Matrix A (3x3): ${matrixA.toLists()}');
  print('   Matrix B (3x3): ${matrixB.toLists()}');

  // For small matrices, use standard multiplication
  final result = _multiplyMatricesSequential(matrixA, matrixB);
  print('   Result A×B: ${result.toLists()}');

  // Large matrix parallel multiplication demo
  print('\n2. Large Matrix Parallel Multiplication:');
  final largeA = _createRandomMatrix(200, 200);
  final largeB = _createRandomMatrix(200, 200);

  final parallelMatrixMult = ParallelMatrixMultiplication();
  if (parallelMatrixMult.canApply([largeA, largeB], const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final largeResult = parallelMatrixMult.execute([largeA, largeB]);
    stopwatch.stop();

    print(
        '   ✓ Multiplied 200×200 matrices in ${stopwatch.elapsedMilliseconds}ms');
    print('   ✓ Result dimensions: ${largeResult.rows}×${largeResult.cols}');
    print('   ✓ Parallel block-based algorithm');
  } else {
    print('   ⚠️  Parallel matrix multiplication not available');
  }

  // Graph operations
  print('\n3. Graph Analysis:');
  final graph = _createComplexGraph();
  print('   Graph: ${graph.vertices} vertices, ${graph.edgeCount} edges');

  // BFS
  final bfs = ParallelBFS(0);
  if (bfs.canApply(graph, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final distances = bfs.execute(graph);
    stopwatch.stop();

    print('   🔍 Parallel BFS Results:');
    print('      ✓ Execution time: ${stopwatch.elapsedMilliseconds}ms');
    print('      ✓ Reachable vertices: ${distances.length}');
    print(
        '      ✓ Max distance: ${distances.values.isEmpty ? 0 : distances.values.reduce(max)}');

    // Show sample distances
    final samples = [0, 1, 5, 10, 50].where((v) => distances.containsKey(v));
    for (final vertex in samples.take(3)) {
      print('      ✓ Distance to vertex $vertex: ${distances[vertex]}');
    }
  } else {
    print('   ⚠️  Parallel BFS not available');
  }

  // Connected Components
  final cc = ParallelConnectedComponents();
  if (cc.canApply(graph, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final ccResult = cc.execute(graph);
    stopwatch.stop();

    final componentCount = ccResult['componentCount'] as int;
    print('   🕸️  Connected Components:');
    print('      ✓ Execution time: ${stopwatch.elapsedMilliseconds}ms');
    print('      ✓ Number of components: $componentCount');

    final components = ccResult['components'] as Map<int, List<int>>;
    final sizes = components.values.map((c) => c.length).toList()
      ..sort((a, b) => b.compareTo(a));
    print(
        '      ✓ Largest component: ${sizes.isNotEmpty ? sizes.first : 0} vertices');
  } else {
    print('   ⚠️  Parallel connected components not available');
  }

  // Performance summary
  print('\n4. Performance Summary:');
  print('   📊 Algorithm Performance Characteristics:');
  print('      • Small data (< 1K): Sequential algorithms optimal');
  print('      • Medium data (1K-10K): Mixed approach, context-dependent');
  print('      • Large data (> 10K): Parallel algorithms show benefits');
  print('      • Very large data (> 100K): Significant speedup on multi-core');
  print('   🎯 AlgoMate automatically selects optimal approach based on:');
  print('      • Data size and characteristics');
  print('      • Available system resources');
  print('      • Algorithm complexity profiles');
}

// Helper functions
bool _isArraySorted(List<int> array) {
  for (int i = 1; i < array.length; i++) {
    if (array[i] < array[i - 1]) return false;
  }
  return true;
}

Matrix _createRandomMatrix(int rows, int cols) {
  final random = Random(456);
  final data = List.generate(rows * cols, (i) => random.nextInt(100));
  return Matrix(rows, cols, data);
}

Matrix _multiplyMatricesSequential(Matrix a, Matrix b) {
  final result = Matrix.zero(a.rows, b.cols);
  for (int i = 0; i < a.rows; i++) {
    for (int j = 0; j < b.cols; j++) {
      int sum = 0;
      for (int k = 0; k < a.cols; k++) {
        sum += a.get(i, k) * b.get(k, j);
      }
      result.set(i, j, sum);
    }
  }
  return result;
}

Graph _createComplexGraph() {
  final edges = <List<int>>[];
  const vertices = 500;
  final random = Random(789);

  // Create a connected graph with clusters
  for (int i = 0; i < vertices - 1; i++) {
    // Connect to next vertex (ensures connectivity)
    edges.add([i, i + 1]);

    // Add random edges for complexity
    for (int j = 0; j < 3; j++) {
      final target = random.nextInt(vertices);
      if (target != i) {
        edges.add([i, target]);
      }
    }
  }

  return Graph.fromEdgeList(vertices, edges);
}

/// A minimal local stub for QuickSortStrategy to satisfy compilation and demo usage.
/// This uses Dart's List.sort() under the hood and provides a small meta object
/// so code that reads quickSort.meta.* continues to work.
class QuickSortStrategy {
  final meta = _QuickSortMeta();

  List<int> execute(List<int> input) {
    final out = List<int>.from(input);
    out.sort();
    return out;
  }

  bool canApply(dynamic input, [dynamic hint]) {
    // Simple heuristic stub: always available
    return true;
  }
}

class _QuickSortMeta {
  final String name = 'QuickSort (stub)';
  final String timeComplexity = 'O(n log n)';
  final String spaceComplexity = 'O(log n)';
  final int memoryOverheadBytes = 0;
  final String description =
      'Stub QuickSortStrategy using List.sort() for demonstration only';
}
