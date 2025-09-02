/// AlgoMate - Algorithm selection co /// **Sorting Strategies:**
/// - `InsertionSort` - O(n²) - Best for small datasets
/// - `MergeSort` - O(n log n) - Stable, predictable performance
/// - `QuickSort` - O(n log n) avg - Fast general-purpose sorting
/// - `HeapSort` - O(n log n) - Guaranteed performance, in-place
/// - `ParallelMergeSort` - O(n log n) - Multi-core merge sort for large datasets
/// - `ParallelQuickSort` - O(n log n) - Multi-core quick sort with work-stealing
///
/// **Generic Algorithms (for Custom Types):**
/// - `GenericMergeSort<T>` - O(n log n) - Stable sort for any Comparable&lt;T&gt;
/// - `GenericQuickSort<T>` - O(n log n) - Fast sort for any Comparable&lt;T&gt;
/// - `GenericInsertionSort<T>` - O(n²) - Simple sort for any Comparable&lt;T&gt;
/// - `GenericHeapSort<T>` - O(n log n) - In-place sort for any Comparable&lt;T&gt;
///
/// **Search Strategies:**
/// - `LinearSearch` - O(n) - Works on unsorted data
/// - `BinarySearch` - O(log n) - Requires sorted data
/// - `ParallelBinarySearch` - O(log n) - Multi-core binary search for very large arrays
/// - `GenericBinarySearch<T>` - O(log n) - Binary search for any Comparable&lt;T&gt;
/// - `GenericLinearSearch<T>` - O(n) - Linear search with custom equality
///
/// **Custom Data Structures:**
/// - `PriorityQueue<T>` - Min-heap priority queue for any Comparable&lt;T&gt;
/// - `BinarySearchTree<T>` - BST for any Comparable&lt;T&gt;
/// - `CircularBuffer<T>` - Fixed-size ring buffer for any type T
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
/// **Dynamic Programming:**
/// - `KnapsackDP` - O(nW) - 0/1 Knapsack problem optimization
/// - `LongestCommonSubsequenceDP` - O(nm) - Text comparison and alignment
/// - `LongestIncreasingSubsequenceDP` - O(n²) - Finding increasing patterns
/// - `CoinChangeDP` - O(nW) - Optimal coin combination problem
/// - `EditDistanceDP` - O(nm) - String transformation operations
/// - `MatrixChainMultiplicationDP` - O(n³) - Optimal matrix multiplication order
/// - `SubsetSumDP` - O(nW) - Finding subsets with target sum
/// - `FibonacciDP` - O(n) - Top-down, bottom-up, and space-optimized approaches
///
/// **String Processing:**
/// - `KnuthMorrisPrattAlgorithm` - O(n+m) - Efficient pattern matching
/// - `RabinKarpAlgorithm` - O(n+m) - Rolling hash pattern matching
/// - `ZAlgorithm` - O(n) - String analysis and pattern finding
/// - `LongestPalindromicSubstringAlgorithm` - O(n²) - Find longest palindromes
/// - `ManacherAlgorithm` - O(n) - Linear time palindrome detection
/// - `SuffixArrayAlgorithm` - O(n log n) - String indexing and search
/// - `TrieAlgorithm` - O(total length) - Prefix tree construction
/// - `AhoCorasickAlgorithm` - O(n+m+z) - Multiple pattern matching
/// - `StringCompressionAlgorithm` - O(n) - Run Length, LZ77, Huffman compression
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
/// ## Custom Objects Usage
///
/// ### Define Custom Comparable Objects
/// ```dart
/// class Person implements Comparable<Person> {
///   final String name;
///   final int age;
///
///   Person(this.name, this.age);
///
///   @override
///   int compareTo(Person other) => age.compareTo(other.age);
///
///   @override
///   String toString() => 'Person(name: $name, age: $age)';
/// }
/// ```
///
/// ### Sort Custom Objects
/// ```dart
/// final people = [
///   Person('Alice', 30),
///   Person('Bob', 25),
///   Person('Carol', 35),
/// ];
///
/// final sorter = GenericMergeSort<Person>();
/// final sorted = sorter.execute(people);
/// // Result: [Person(name: Bob, age: 25), Person(name: Alice, age: 30), Person(name: Carol, age: 35)]
/// ```
///
/// ### Search Custom Objects
/// ```dart
/// final searcher = GenericBinarySearch<Person>(Person('Alice', 30));
/// final index = searcher.execute(sorted);
/// print('Found Alice at index: $index');
/// ```
///
/// ## Custom Data Structures
///
/// ### Priority Queue Usage
/// ```dart
/// final pq = PriorityQueue<int>();
/// pq.add(5);
/// pq.add(2);
/// pq.add(8);
/// print(pq.removeMin()); // 2 (minimum)
/// ```
///
/// ### Binary Search Tree Usage
/// ```dart
/// final bst = BinarySearchTree<String>();
/// bst.insert('banana');
/// bst.insert('apple');
/// bst.insert('cherry');
/// print(bst.toSortedList()); // [apple, banana, cherry]
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
/// ### Dynamic Programming Examples
/// ```dart
/// // Knapsack problem
/// final knapsack = KnapsackDP();
/// final result = knapsack.execute(KnapsackInput([2, 3, 4], [3, 4, 5], 5));
/// print('Maximum value: ${result.maxValue}');
///
/// // Longest Common Subsequence
/// final lcs = LongestCommonSubsequenceDP();
/// final lcsResult = lcs.execute(LCSInput('ABCDGH', 'AEDFHR'));
/// print('LCS: ${lcsResult.subsequence}');
///
/// // Coin Change
/// final coinChange = CoinChangeDP();
/// final coinResult = coinChange.execute(CoinChangeInput([1, 3, 4], 6));
/// print('Min coins: ${coinResult.minCoins}');
/// ```
///
/// ### String Processing Examples
/// ```dart
/// // Pattern matching with KMP
/// final kmp = KnuthMorrisPrattAlgorithm();
/// final result = kmp.execute(KMPInput('ABABCABABA', 'ABABCAB'));
/// print('Pattern found at: ${result.occurrences}');
///
/// // Multiple pattern search with Aho-Corasick
/// final ahoCorasick = AhoCorasickAlgorithm();
/// final multiResult = ahoCorasick.execute(
///   AhoCorasickInput('She sells seashells by the seashore', ['she', 'sea', 'sells'])
/// );
/// print('Found patterns: ${multiResult.foundPatterns}');
///
/// // Find palindromes with Manacher's Algorithm
/// final manacher = ManacherAlgorithm();
/// final palindrome = manacher.execute(ManacherInput('ABACABAD'));
/// print('Longest palindrome: "${palindrome.longestPalindrome}"');
///
/// // Build Trie for word suggestions
/// final trie = TrieAlgorithm();
/// final trieResult = trie.execute(TrieInput(['cat', 'car', 'card', 'care', 'dog']));
/// print('Words starting with "car": ${trieResult.getWordsWithPrefix("car")}');
///
/// // String compression
/// final compression = StringCompressionAlgorithm();
/// final compressed = compression.execute(
///   StringCompressionInput('AAAABBBBCCCC', type: CompressionType.runLength)
/// );
/// print('Compression ratio: ${compressed.compressionRatio}');
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

// Generic algorithms (for custom types)
export 'src/infrastructure/strategies/sort/generic_sort_algorithms.dart';
export 'src/infrastructure/strategies/search/generic_search_algorithms.dart';

// Custom data structures
export 'src/infrastructure/strategies/data_structures/custom_data_structures.dart';

// Graph algorithms (comprehensive graph processing)
export 'src/infrastructure/strategies/graph/graph_data_structures.dart';
export 'src/infrastructure/strategies/graph/graph_traversal_algorithms.dart';
export 'src/infrastructure/strategies/graph/shortest_path_algorithms.dart';
export 'src/infrastructure/strategies/graph/minimum_spanning_tree_algorithms.dart';
export 'src/infrastructure/strategies/graph/advanced_graph_algorithms.dart';

// Parallel algorithms (multi-core support with web compatibility)
export 'src/infrastructure/strategies/parallel_algorithms.dart';

// Dynamic programming algorithms (optimization problems)
export 'src/infrastructure/strategies/dynamic_programming/dp_algorithms.dart';

// String processing algorithms (text analysis and manipulation)
export 'src/infrastructure/strategies/string/string_algorithms.dart';
