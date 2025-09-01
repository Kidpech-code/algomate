/// AlgoMate - Algorithm selection co /// **Sorting Strategies:**
/// - `InsertionSort` - O(n²) - Best for small datasets
/// - `MergeSort` - O(n log n) - Stable, predictable performance
/// - `QuickSort` - O(n log n) avg - Fast general-purpose sorting
/// - `HeapSort` - O(n log n) - Guaranteed performance, in-place
/// - `ParallelMergeSort` - O(n log n) - Multi-core merge sort for large datasets
/// - `ParallelQuickSort` - O(n log n) - Multi-core quick sort with work-stealing
///
/// **Search Strategies:**
/// - `LinearSearch` - O(n) - Works on unsorted data
/// - `BinarySearch` - O(log n) - Requires sorted data
/// - `ParallelBinarySearch` - O(log n) - Multi-core binary search for very large arrays
///
/// **Matrix Operations:**
/// - `ParallelMatrixMultiplication` - O(n³) - Multi-core block-based matrix multiplication
/// - `ParallelStrassenMultiplication` - O(n^2.807) - Divide-and-conquer matrix multiplication
///
/// **Graph Algorithms:**
/// - `ParallelBFS` - O(V + E) - Multi-core breadth-first search
/// - `ParallelDFS` - O(V + E) - Multi-core depth-first search with work-stealing
/// - `ParallelConnectedComponents` - O(V + E) - Multi-core Union-Find algorithmor Dart and Flutter.
///
/// AlgoMate provides intelligent algorithm selection with performance-focused
/// architecture and comprehensive support for sorting, searching, benchmarking,
/// and concurrent execution.
///
/// ## Key Features
///
/// - 🎯 **Intelligent Selection**: Context-aware algorithm selection
/// - ⚡ **Performance Focused**: Zero-allocation hot paths
/// - 🏗️ **Clean Architecture**: Domain-driven design with dependency inversion
/// - 📊 **Built-in Benchmarking**: Statistical performance measurement
/// - 🔄 **Concurrent Execution**: CPU-intensive operations in isolates
/// - 🧪 **Production Ready**: Comprehensive error handling and logging
/// - 🚀 **Multi-Core Support**: Parallel algorithms for divide-and-conquer operations
///
/// ## Quick Start
///
/// ```dart
/// import 'package:algomate/algomate.dart';
///
/// void main() {
///   final selector = AlgoSelectorFacade.development();
///
///   final result = selector.sort(
///     input: [64, 34, 25, 12, 22, 11, 90],
///     hint: SelectorHint(n: 7),
///   );
///
///   result.fold(
///     (success) => print('Sorted: ${success.output}'),
///     (failure) => print('Failed: $failure'),
///   );
/// }
/// ```
///
/// ## Parallel Algorithm Usage
///
/// ### Large Dataset Sorting
/// ```dart
/// final largeData = List.generate(100000, (i) => Random().nextInt(1000000));
///
/// // Automatically selects parallel algorithms for large datasets
/// final result = selector.sort(
///   input: largeData,
///   hint: SelectorHint(n: largeData.length, preferParallel: true),
/// );
/// ```
///
/// ### Matrix Operations
/// ```dart
/// final matrixA = Matrix.fromLists([[1, 2], [3, 4]]);
/// final matrixB = Matrix.fromLists([[5, 6], [7, 8]]);
///
/// final result = selector.execute(
///   strategy: ParallelMatrixMultiplication(),
///   input: [matrixA, matrixB],
/// );
/// ```
///
/// ### Graph Analysis
/// ```dart
/// final graph = Graph.fromEdgeList(1000, edges);
/// final bfs = ParallelBFS(startVertex: 0);
///
/// final distances = bfs.execute(graph);
/// print('BFS distances: \$distances');
/// ```
///
/// ## Built-in Algorithms
///
/// **Sorting Strategies:**
/// - `InsertionSort` - O(n²) - Best for small datasets
/// - `MergeSort` - O(n log n) - Stable, predictable performance
/// - `QuickSort` - O(n log n) avg - Fast general-purpose sorting
/// - `HeapSort` - O(n log n) - Guaranteed performance, in-place
/// - `ParallelMergeSort` - O(n log n) - Multi-core merge sort for large datasets
/// - `ParallelQuickSort` - O(n log n) - Multi-core quick sort with work-stealing
///
/// **Search Strategies:**
/// - `LinearSearch` - O(n) - Works on unsorted data
/// - `BinarySearch` - O(log n) - Requires sorted data
/// - `ParallelBinarySearch` - O(log n) - Multi-core binary search for very large arrays
///
/// **Matrix Operations:**
/// - `ParallelMatrixMultiplication` - O(n³) - Multi-core block-based matrix multiplication
/// - `ParallelStrassenMultiplication` - O(n^2.807) - Divide-and-conquer matrix multiplication
///
/// **Graph Algorithms:**
/// - `ParallelBFS` - O(V + E) - Multi-core breadth-first search
/// - `ParallelDFS` - O(V + E) - Multi-core depth-first search with work-stealing
/// - `ParallelConnectedComponents` - O(V + E) - Multi-core Union-Find algorithm
///
/// ## Advanced Usage
///
/// ### Custom Strategy Registration
/// ```dart
/// class MyCustomSort extends Strategy\<List\<int\>, List\<int\>\> {
///   // Implementation...
/// }
///
/// selector.registerStrategy(MyCustomSort());
/// ```
///
/// ### Performance Benchmarking
/// ```dart
/// final benchmarkRunner = HarnessBenchmarkRunner();
/// final comparison = benchmarkRunner.compare(
///   functions: {'algorithm_a': () => sortA(data)},
///   iterations: 1000,
/// );
/// ```
///
/// ### Concurrent Execution
/// ```dart
/// final isolateExecutor = DartIsolateExecutor();
/// final result = await isolateExecutor.execute(
///   function: (data) => expensiveSort(data),
///   input: largeDataset,
/// );
/// ```
///
/// See individual class documentation for detailed API reference.
library algomate;

// Core public API
export 'src/interface/facade/algo_selector_facade.dart';
export 'src/interface/config/selector_builder.dart';

// Value Objects (for public API)
export 'src/domain/value_objects/algo_metadata.dart';
export 'src/domain/value_objects/time_complexity.dart';
export 'src/domain/value_objects/selector_hint.dart';

// Domain Entities (for custom strategies)
export 'src/domain/entities/strategy.dart';
export 'src/domain/entities/strategy_signature.dart';

// Result and Error Types
export 'src/shared/result.dart';
export 'src/shared/errors.dart';

// Application Ports (for advanced usage)
export 'src/application/ports/logger.dart';

// Repository interface (for custom implementations)
export 'src/domain/repositories/strategy_catalog.dart';

// Domain Services (for custom policies)
export 'src/domain/services/selector_policy.dart';
export 'src/domain/services/complexity_ranker.dart';

// Infrastructure implementations (for advanced configuration)
export 'src/infrastructure/adapters/logging/console_logger.dart';
export 'src/infrastructure/adapters/registry/registry_in_memory.dart';
export 'src/infrastructure/adapters/benchmark/harness_benchmark_runner.dart';
export 'src/infrastructure/adapters/concurrency/isolate_executor.dart';

// Built-in strategies (for reference)
export 'src/infrastructure/strategies/search/linear_search.dart';
export 'src/infrastructure/strategies/search/binary_search.dart';
export 'src/infrastructure/strategies/sort/insertion_sort.dart';
export 'src/infrastructure/strategies/sort/merge_sort.dart';
export 'src/infrastructure/strategies/sort/quick_sort.dart';
export 'src/infrastructure/strategies/sort/heap_sort.dart';

// Parallel algorithms (multi-core support)
export 'src/infrastructure/strategies/sort/parallel_sort_algorithms.dart';
export 'src/infrastructure/strategies/matrix/parallel_matrix_algorithms.dart';
export 'src/infrastructure/strategies/graph/parallel_graph_algorithms.dart';
