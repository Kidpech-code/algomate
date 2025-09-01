/// AlgoMate - Algorithm selection co /// **Sorting Strategies:**
/// - `InsertionSort` - O(n²) - Best for small datasets
/// - `MergeSort` - O(n log n) - Stable, predictable performance
/// - `QuickSort` - O(n log n) avg - Fast general-purpose sorting
/// - `HeapSort` - O(n log n) - Guaranteed performance, in-place
///
/// **Search Strategies:**
/// - `LinearSearch` - O(n) - Works on unsorted data
/// - `BinarySearch` - O(log n) - Requires sorted dataor Dart and Flutter.
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
/// ## Built-in Algorithms
///
/// **Sorting Strategies:**
/// - `InsertionSort` - O(n²) - Best for small datasets
/// - `MergeSort` - O(n log n) - Stable, predictable performance
/// - `QuickSort` - O(n log n) avg - Fast general-purpose sorting
/// - `HeapSort` - O(n log n) - Guaranteed performance, in-place
///
/// **Search Strategies:**
/// - `LinearSearch` - O(n) - Works on unsorted data
/// - `BinarySearch` - O(log n) - Requires sorted data
///
/// ## Advanced Usage
///
/// ### Custom Strategy Registration
/// ```dart
/// class MyCustomSort extends Strategy<List<int>, List<int>> {
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
export 'src/infrastructure/adapters/concurrency/dart_isolate_executor.dart';

// Built-in strategies (for reference)
export 'src/infrastructure/strategies/search/linear_search.dart';
export 'src/infrastructure/strategies/search/binary_search.dart';
export 'src/infrastructure/strategies/sort/insertion_sort.dart';
export 'src/infrastructure/strategies/sort/merge_sort.dart';
export 'src/infrastructure/strategies/sort/quick_sort.dart';
export 'src/infrastructure/strategies/sort/heap_sort.dart';
