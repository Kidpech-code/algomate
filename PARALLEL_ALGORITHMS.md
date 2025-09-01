# AlgoMate Parallel Algorithms Documentation

## Overview

AlgoMate now includes comprehensive support for **parallel/divide-and-conquer algorithms** optimized for multi-core systems. These algorithms automatically distribute work across available CPU cores to improve performance on large datasets.

## 🚀 New Parallel Algorithm Collections

### 1. Parallel Sorting Algorithms (`parallel_sort_algorithms.dart`)

#### ParallelMergeSort

- **Algorithm**: Level-synchronous merge sort with work distribution
- **Time Complexity**: O(n log n)
- **Best For**: Large datasets (>10K elements), stable sorting requirements
- **Features**:
  - Automatic core detection and chunk distribution
  - Falls back to sequential for small datasets
  - Cache-friendly memory access patterns
  - Configurable parallelism thresholds

```dart
final parallelMergeSort = ParallelMergeSort();
final sorted = parallelMergeSort.execute(largeDataset);
```

#### ParallelQuickSort

- **Algorithm**: Work-stealing parallel quick sort with hybrid optimization
- **Time Complexity**: O(n log n) average case
- **Best For**: Large unsorted datasets, good cache locality
- **Features**:
  - Fork-join pattern with depth limiting
  - Randomized pivot selection
  - Automatic switch to insertion sort for small subarrays
  - Load balancing across cores

```dart
final parallelQuickSort = ParallelQuickSort();
final sorted = parallelQuickSort.execute(unsortedData);
```

#### ParallelBinarySearch

- **Algorithm**: Multi-core binary search with chunk processing
- **Time Complexity**: O(log n)
- **Best For**: Very large sorted arrays (>100K elements)
- **Features**:
  - Splits search space across multiple cores
  - Cache-friendly memory access
  - Automatic sampling for sorted array validation

### 2. Parallel Matrix Operations (`parallel_matrix_algorithms.dart`)

#### Matrix Class

New `Matrix` class for efficient matrix operations:

```dart
final matrixA = Matrix.fromLists([[1, 2], [3, 4]]);
final matrixB = Matrix.identity(2);
```

#### ParallelMatrixMultiplication

- **Algorithm**: Block decomposition with parallel processing
- **Time Complexity**: O(n³) with improved wall-clock time
- **Best For**: Large dense matrices (>500×500)
- **Features**:
  - Cache-efficient block operations
  - Automatic block size optimization
  - Work distribution across isolates
  - Handles rectangular matrices

```dart
final matrixMult = ParallelMatrixMultiplication();
final result = matrixMult.execute([matrixA, matrixB]);
```

#### ParallelStrassenMultiplication

- **Algorithm**: Divide-and-conquer Strassen's algorithm
- **Time Complexity**: O(n^2.807)
- **Best For**: Very large square matrices (>1000×1000)
- **Features**:
  - Parallel recursive calls
  - Automatic fallback to standard multiplication
  - Memory-efficient with minimal matrix copies
  - Depth-limited recursion

### 3. Parallel Graph Algorithms (`parallel_graph_algorithms.dart`)

#### Graph Class

New `Graph` class for graph operations:

```dart
final edges = [[0, 1], [1, 2], [2, 3]];
final graph = Graph.fromEdgeList(4, edges);
```

#### ParallelBFS

- **Algorithm**: Level-synchronous breadth-first search
- **Time Complexity**: O(V + E)
- **Best For**: Large graphs with high branching factor
- **Features**:
  - Processes each BFS level in parallel
  - Efficient frontier management
  - Automatic load balancing
  - Memory-efficient visited tracking

```dart
final parallelBFS = ParallelBFS(startVertex: 0);
final distances = parallelBFS.execute(graph);
```

#### ParallelDFS

- **Algorithm**: Work-stealing depth-first search
- **Time Complexity**: O(V + E)
- **Best For**: Large sparse graphs, tree-like structures
- **Features**:
  - Dynamic load balancing
  - Stack-based exploration with parallel branching
  - Supports connected component detection

#### ParallelConnectedComponents

- **Algorithm**: Parallel Union-Find with path compression
- **Time Complexity**: O((V + E) × α(V))
- **Best For**: Large graphs with many components
- **Features**:
  - Parallel edge processing
  - Union by rank optimization
  - Efficient component merging and counting

```dart
final parallelCC = ParallelConnectedComponents();
final result = parallelCC.execute(graph);
print('Found ${result['componentCount']} components');
```

## 🎯 Intelligent Algorithm Selection

### Automatic Multi-Core Detection

- Algorithms automatically detect available CPU cores
- Configurable maximum isolate limits for resource management
- Platform-specific optimizations (falls back gracefully on web)

### Performance Thresholds

- **Sequential Thresholds**: Algorithms automatically switch to sequential versions for small inputs
- **Parallel Thresholds**: Minimum data sizes required to benefit from parallelization
- **Memory Overhead**: Explicit memory overhead tracking for each algorithm

### Context-Aware Selection

```dart
// Automatic selection based on data size and system capabilities
final selector = AlgoSelectorFacade.development();
final result = selector.sort(
  input: largeDataset,
  hint: SelectorHint(
    n: largeDataset.length,
    preferParallel: true,  // Hint for parallel preference
  ),
);
```

## 🛠️ Architecture & Design

### Clean Architecture Compliance

- All parallel algorithms implement the same `Strategy` interface
- Domain-driven design with proper separation of concerns
- Infrastructure layer handles isolate management and platform specifics

### Error Handling & Resilience

- Graceful fallback to sequential algorithms on isolate failures
- Comprehensive timeout handling for isolate operations
- Platform-specific error recovery (web vs native)

### Memory Management

- Explicit memory overhead tracking
- Efficient data serialization between isolates
- Automatic garbage collection optimization

## 📊 Performance Characteristics

### Scalability

- **Linear Speedup**: Achievable on data-parallel algorithms (sorting, matrix operations)
- **Sub-linear Speedup**: Expected on graph algorithms due to synchronization overhead
- **Amdahl's Law**: Performance limited by sequential portions of algorithms

### Benchmarking Integration

- All parallel algorithms work with existing benchmark suite
- Statistical analysis includes parallel vs sequential comparisons
- CI/CD integration with performance regression detection

### Platform Support

- **Native**: Full isolate support with true parallelism
- **Web**: Graceful degradation to sequential algorithms
- **Flutter**: Maintains UI responsiveness during computation

## 📝 Usage Examples

### Complete Parallel Algorithm Demo

```bash
dart run example/parallel_algorithms_example.dart
```

### Integration with AlgoMate Facade

```dart
import 'package:algomate/algomate.dart';

void main() {
  final selector = AlgoSelectorFacade.production();

  // Large dataset sorting (automatically selects parallel algorithm)
  final largeData = List.generate(100000, (i) => Random().nextInt(1000000));
  final sortResult = selector.sort(
    input: largeData,
    hint: SelectorHint(n: largeData.length),
  );

  // Matrix multiplication
  final matrixA = Matrix.fromLists([[1, 2], [3, 4]]);
  final matrixB = Matrix.fromLists([[5, 6], [7, 8]]);
  final matrixResult = ParallelMatrixMultiplication().execute([matrixA, matrixB]);

  // Graph analysis
  final graph = Graph.fromEdgeList(1000, edges);
  final bfsDistances = ParallelBFS(0).execute(graph);
  final components = ParallelConnectedComponents().execute(graph);
}
```

## 🔄 Integration with Existing AlgoMate Features

### Selector Hints Enhancement

- New `preferParallel` hint for algorithm selection
- System capability detection in selection logic
- Performance-based algorithm ranking includes parallel considerations

### Benchmark Suite Integration

- Parallel algorithms included in comprehensive benchmarking
- Statistical analysis compares sequential vs parallel performance
- CI/CD pipeline tests parallel algorithm correctness and performance

### Direct Execution API

- Fast Path API supports parallel algorithms
- Zero-overhead execution for performance-critical scenarios
- Bound strategy pattern works with parallel implementations

## 📈 Future Enhancements

### Roadmap Integration

- **Version 0.2.0**: Basic parallel algorithm collection (✅ Complete)
- **Version 0.3.0**: Advanced work-stealing patterns
- **Version 0.4.0**: GPU acceleration support consideration
- **Version 1.0.0**: Production-ready parallel algorithm suite

### Performance Optimization Opportunities

- SIMD instruction utilization
- Cache-aware algorithm variants
- Platform-specific optimizations (ARM vs x86)
- Memory pool management for reduced GC pressure

This implementation significantly enhances AlgoMate's capabilities for large-scale data processing while maintaining the library's clean architecture and ease of use.
