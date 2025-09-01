import 'dart:math';
import 'package:algomate/algomate.dart';

/// Example demonstrating parallel/multi-core algorithms in AlgoMate
///
/// This example shows how to use divide-and-conquer algorithms that are
/// optimized for multi-core systems with automatic workload distribution.
void main() async {
  print('🚀 AlgoMate Parallel Algorithms Demo');
  print('=====================================\n');

  await demonstrateParallelSorting();
  await demonstrateParallelSearch();
  await demonstrateMatrixOperations();
  await demonstrateGraphAlgorithms();

  print('\n✅ All parallel algorithm demonstrations completed!');
}

/// Demonstrate parallel sorting algorithms
Future<void> demonstrateParallelSorting() async {
  print('📊 Parallel Sorting Algorithms');
  print('------------------------------');

  // Generate large random dataset
  final random = Random(42); // Fixed seed for reproducibility
  final smallData = List.generate(1000, (i) => random.nextInt(10000));
  final largeData = List.generate(50000, (i) => random.nextInt(100000));

  print('Dataset sizes: small=${smallData.length}, large=${largeData.length}');

  // Parallel Merge Sort
  print('\n1. Parallel Merge Sort:');
  final parallelMergeSort = ParallelMergeSort();

  if (parallelMergeSort.canApply(
      largeData, SelectorHint(n: largeData.length),)) {
    final stopwatch = Stopwatch()..start();
    final sorted1 = parallelMergeSort.execute(largeData);
    stopwatch.stop();

    print(
        '   ✓ Sorted ${largeData.length} elements in ${stopwatch.elapsedMilliseconds}ms',);
    print(
        '   ✓ Result validation: ${_isArraySorted(sorted1) ? "PASSED" : "FAILED"}',);
    print(
        '   ✓ Memory overhead: ${parallelMergeSort.meta.memoryOverheadBytes} bytes',);
  } else {
    print(
        '   ⚠️  Parallel merge sort not applicable (requires isolate support)',);
  }

  // Parallel Quick Sort
  print('\n2. Parallel Quick Sort:');
  final parallelQuickSort = ParallelQuickSort();

  if (parallelQuickSort.canApply(
      largeData, SelectorHint(n: largeData.length),)) {
    final stopwatch = Stopwatch()..start();
    final sorted2 = parallelQuickSort.execute(List.from(largeData));
    stopwatch.stop();

    print(
        '   ✓ Sorted ${largeData.length} elements in ${stopwatch.elapsedMilliseconds}ms',);
    print(
        '   ✓ Result validation: ${_isArraySorted(sorted2) ? "PASSED" : "FAILED"}',);
    print('   ✓ Algorithm: ${parallelQuickSort.meta.description}');
  } else {
    print('   ⚠️  Parallel quick sort not applicable');
  }

  // Performance comparison note
  print(
      '\n💡 Note: Parallel algorithms show performance benefits on multi-core systems',);
  print(
      '   with large datasets. Small datasets use sequential fallbacks for efficiency.',);
}

/// Demonstrate parallel search algorithms
Future<void> demonstrateParallelSearch() async {
  print('\n\n🔍 Parallel Search Algorithms');
  print('-----------------------------');

  // Create large sorted array
  final largeArray = List.generate(200000, (i) => i * 2); // Even numbers
  const searchTarget = 50000; // Target that exists
  const missingTarget = 50001; // Target that doesn't exist

  print('Array size: ${largeArray.length}');
  print('Search targets: $searchTarget (exists), $missingTarget (missing)');

  // Parallel Binary Search
  print('\n1. Parallel Binary Search:');
  final parallelBinarySearch = ParallelBinarySearch(searchTarget);

  if (parallelBinarySearch.canApply(
      largeArray, SelectorHint(n: largeArray.length),)) {
    final stopwatch = Stopwatch()..start();
    final index1 = parallelBinarySearch.execute(largeArray);
    stopwatch.stop();

    print(
        '   ✓ Found $searchTarget at index $index1 in ${stopwatch.elapsedMicroseconds}μs',);
    print(
        '   ✓ Verification: array[$index1] = ${index1 >= 0 ? largeArray[index1] : "not found"}',);

    // Search for missing element
    final missingSearch = ParallelBinarySearch(missingTarget);
    final index2 = missingSearch.execute(largeArray);
    print(
        '   ✓ Search for $missingTarget: ${index2 == -1 ? "not found (correct)" : "found at $index2"}',);
  } else {
    print(
        '   ⚠️  Parallel binary search not applicable (requires isolate support or larger array)',);

    // Fallback to regular binary search
    final regularBinarySearch = BinarySearchStrategy(searchTarget);
    final index = regularBinarySearch.execute(largeArray);
    print('   ✓ Regular binary search found $searchTarget at index $index');
  }
}

/// Demonstrate parallel matrix operations
Future<void> demonstrateMatrixOperations() async {
  print('\n\n🧮 Parallel Matrix Operations');
  print('-----------------------------');

  // Create test matrices
  const size = 100; // 100x100 matrices
  final matrixA = _createRandomMatrix(size, size);
  final matrixB = _createRandomMatrix(size, size);

  print('Matrix dimensions: ${size}x$size');

  // Parallel Matrix Multiplication
  print('\n1. Parallel Matrix Multiplication:');
  final parallelMatrixMult = ParallelMatrixMultiplication();
  final input = [matrixA, matrixB];

  if (parallelMatrixMult.canApply(input, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result1 = parallelMatrixMult.execute(input);
    stopwatch.stop();

    print(
        '   ✓ Multiplied ${size}x$size matrices in ${stopwatch.elapsedMilliseconds}ms',);
    print('   ✓ Result matrix: ${result1.rows}x${result1.cols}');
    print(
        '   ✓ Block-based approach with ${parallelMatrixMult.meta.memoryOverheadBytes} bytes overhead',);

    // Verify result (spot check)
    final expectedElement = _computeMatrixElement(matrixA, matrixB, 0, 0);
    final actualElement = result1.get(0, 0);
    print(
        '   ✓ Verification [0,0]: expected=$expectedElement, actual=$actualElement',);
  } else {
    print('   ⚠️  Parallel matrix multiplication not applicable');
  }

  // Strassen Algorithm (for larger matrices)
  if (size >= 128) {
    // Strassen is beneficial for larger matrices
    print('\n2. Parallel Strassen Multiplication:');
    final strassenMult = ParallelStrassenMultiplication();

    if (strassenMult.canApply(input, const SelectorHint())) {
      final stopwatch = Stopwatch()..start();
      strassenMult.execute(input);
      stopwatch.stop();

      print(
          '   ✓ Strassen multiplication completed in ${stopwatch.elapsedMilliseconds}ms',);
      print('   ✓ Algorithm: ${strassenMult.meta.description}');
    } else {
      print(
          '   ⚠️  Strassen algorithm not applicable (requires square matrices)',);
    }
  }
}

/// Demonstrate parallel graph algorithms
Future<void> demonstrateGraphAlgorithms() async {
  print('\n\n🕸️  Parallel Graph Algorithms');
  print('-----------------------------');

  // Create a sample graph (grid-like structure)
  const graphSize = 1000;
  final graph = _createSampleGraph(graphSize);

  print('Graph: $graphSize vertices, ${graph.edgeCount} edges');

  // Parallel BFS
  print('\n1. Parallel Breadth-First Search:');
  const startVertex = 0;
  final parallelBFS = ParallelBFS(startVertex);

  if (parallelBFS.canApply(graph, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final distances = parallelBFS.execute(graph);
    stopwatch.stop();

    print(
        '   ✓ BFS from vertex $startVertex completed in ${stopwatch.elapsedMilliseconds}ms',);
    print('   ✓ Reached ${distances.length} vertices');
    print(
        '   ✓ Max distance: ${distances.values.isEmpty ? 0 : distances.values.reduce(max)}',);

    // Show some sample distances
    final samples = [0, 1, 10, 100].where((v) => distances.containsKey(v));
    for (final vertex in samples) {
      print('   ✓ Distance to vertex $vertex: ${distances[vertex]}');
    }
  } else {
    print('   ⚠️  Parallel BFS not applicable');
  }

  // Parallel DFS
  print('\n2. Parallel Depth-First Search:');
  final parallelDFS = ParallelDFS(startVertex);

  if (parallelDFS.canApply(graph, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final visited = parallelDFS.execute(graph);
    stopwatch.stop();

    print(
        '   ✓ DFS from vertex $startVertex completed in ${stopwatch.elapsedMilliseconds}ms',);
    print('   ✓ Visited ${visited.length} vertices');
    print('   ✓ Work-stealing approach: ${parallelDFS.meta.description}');
  } else {
    print('   ⚠️  Parallel DFS not applicable');
  }

  // Connected Components
  print('\n3. Parallel Connected Components:');
  final parallelCC = ParallelConnectedComponents();

  if (parallelCC.canApply(graph, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result = parallelCC.execute(graph);
    stopwatch.stop();

    final componentCount = result['componentCount'] as int;
    final components = result['components'] as Map<int, List<int>>;

    print(
        '   ✓ Connected components analysis completed in ${stopwatch.elapsedMilliseconds}ms',);
    print('   ✓ Found $componentCount connected components');

    // Show component size distribution
    final sizes = components.values.map((c) => c.length).toList()
      ..sort((a, b) => b.compareTo(a));
    print(
        '   ✓ Component sizes: ${sizes.take(5).join(", ")}${sizes.length > 5 ? "..." : ""}',);
  } else {
    print('   ⚠️  Parallel connected components not applicable');
  }
}

/// Helper function to check if array is sorted
bool _isArraySorted(List<int> array) {
  for (int i = 1; i < array.length; i++) {
    if (array[i] < array[i - 1]) return false;
  }
  return true;
}

/// Create a random matrix for testing
Matrix _createRandomMatrix(int rows, int cols) {
  final random = Random(123); // Fixed seed
  final data = List.generate(rows * cols, (i) => random.nextInt(100));
  return Matrix(rows, cols, data);
}

/// Compute expected matrix multiplication element (for verification)
int _computeMatrixElement(Matrix a, Matrix b, int row, int col) {
  int sum = 0;
  for (int k = 0; k < a.cols; k++) {
    sum += a.get(row, k) * b.get(k, col);
  }
  return sum;
}

/// Create a sample graph with grid-like structure
Graph _createSampleGraph(int vertices) {
  final edges = <List<int>>[];
  final gridSize = sqrt(vertices).floor();

  // Create grid connections
  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      final vertex = i * gridSize + j;

      // Connect to right neighbor
      if (j < gridSize - 1) {
        edges.add([vertex, vertex + 1]);
      }

      // Connect to bottom neighbor
      if (i < gridSize - 1) {
        edges.add([vertex, vertex + gridSize]);
      }
    }
  }

  // Add some random long-distance edges
  final random = Random(456);
  final extraEdges = vertices ~/ 10;
  for (int i = 0; i < extraEdges; i++) {
    final v1 = random.nextInt(vertices);
    final v2 = random.nextInt(vertices);
    if (v1 != v2) {
      edges.add([v1, v2]);
    }
  }

  return Graph.fromEdgeList(vertices, edges);
}
