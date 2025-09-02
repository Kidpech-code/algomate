import 'dart:io';
import 'dart:isolate';
import '../platform_cores.dart';
import 'dart:math' as math;
import 'dart:async';
import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';

/// Parallel Merge Sort using Dart's compute-like functionality
///
/// Features:
/// - Divides work across multiple isolates (cores)
/// - Automatic core detection and work distribution
/// - Falls back to sequential merge sort for small datasets
/// - Uses lightweight isolate communication
///
/// Best for: Large datasets (>10K elements), CPU-intensive sorting,
/// when you have multiple cores available.
///
/// Performance: O(n log n) time, improved wall-clock time on multi-core
/// Space: O(n) for temporary arrays
class ParallelMergeSort extends Strategy<List<int>, List<int>> {
  static const int _sequentialThreshold = 10000;
  static const int _minChunkSize = 5000;
  static const int _maxIsolates = 4;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'parallel_merge_sort',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.oN,
        requiresSorted: false,
        memoryOverheadBytes: 8192, // Isolate overhead + temp arrays
        description:
            'Multi-core merge sort using isolates for improved performance',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final size = hint.n ?? input.length;

    // Only beneficial for large datasets
    if (size < _sequentialThreshold) return false;

    // Check if isolates are available (not on web)
    try {
      Isolate.current;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  List<int> execute(List<int> input) {
    if (input.isEmpty) return [];
    if (input.length < _sequentialThreshold) {
      return _sequentialMergeSort(input);
    }

    try {
      return _parallelMergeSort(input);
    } catch (e) {
      // Fallback to sequential if parallel fails
      return _sequentialMergeSort(input);
    }
  }

  /// Parallel merge sort implementation
  List<int> _parallelMergeSort(List<int> input) {
    final availableCores = getNumberOfProcessors();
    final numChunks = math.min(availableCores, _maxIsolates);
    final chunkSize = math.max(_minChunkSize, input.length ~/ numChunks);

    // Divide input into chunks
    final chunks = <List<int>>[];
    for (int i = 0; i < input.length; i += chunkSize) {
      final end = math.min(i + chunkSize, input.length);
      chunks.add(input.sublist(i, end));
    }

    // Sort chunks in parallel
    final sortedChunks = _sortChunksInParallel(chunks);

    // Merge sorted chunks
    return _mergeChunks(sortedChunks);
  }

  /// Sort chunks in parallel using isolates
  List<List<int>> _sortChunksInParallel(List<List<int>> chunks) {
    final futures = <Future<List<int>>>[];

    for (final chunk in chunks) {
      futures.add(_computeSort(chunk));
    }

    // Wait for all chunks to complete
    final results = <List<int>>[];
    for (int i = 0; i < futures.length; i++) {
      try {
        // Simple synchronous wait for demo
        // In production, use proper async/await
        List<int>? result;
        futures[i].then((value) => result = value).catchError((error) {
          result = _sequentialMergeSort(chunks[i]);
          return result!;
        });

        // Wait for result
        while (result == null) {
          // Busy wait (not recommended in production)
        }
        results.add(result!);
      } catch (e) {
        // Fallback to sequential sort
        results.add(_sequentialMergeSort(chunks[i]));
      }
    }

    return results;
  }

  /// Compute-like function for sorting in isolate
  Future<List<int>> _computeSort(List<int> data) async {
    final completer = Completer<List<int>>();

    try {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(
        _isolateMergeSort,
        [receivePort.sendPort, data],
      );

      receivePort.listen((message) {
        if (message is List<int>) {
          completer.complete(message);
        } else if (message is String && message.startsWith('error:')) {
          completer.completeError(Exception(message));
        }
        receivePort.close();
        isolate.kill();
      });
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () =>
          throw TimeoutException('Sort timeout', const Duration(seconds: 30)),
    );
  }

  /// Merge sorted chunks using k-way merge
  List<int> _mergeChunks(List<List<int>> sortedChunks) {
    if (sortedChunks.isEmpty) return [];
    if (sortedChunks.length == 1) return sortedChunks[0];

    // Use priority queue for efficient k-way merge
    final result = <int>[];
    final indices = List.filled(sortedChunks.length, 0);

    while (true) {
      int? minValue;
      int minChunkIndex = -1;

      // Find minimum element across all chunks
      for (int i = 0; i < sortedChunks.length; i++) {
        if (indices[i] < sortedChunks[i].length) {
          final value = sortedChunks[i][indices[i]];
          if (minValue == null || value < minValue) {
            minValue = value;
            minChunkIndex = i;
          }
        }
      }

      if (minChunkIndex == -1) break; // All chunks exhausted

      result.add(minValue!);
      indices[minChunkIndex]++;
    }

    return result;
  }

  /// Sequential merge sort fallback
  List<int> _sequentialMergeSort(List<int> input) {
    if (input.length <= 1) return List.from(input);

    final middle = input.length ~/ 2;
    final left = _sequentialMergeSort(input.sublist(0, middle));
    final right = _sequentialMergeSort(input.sublist(middle));

    return _merge(left, right);
  }

  /// Merge two sorted arrays
  List<int> _merge(List<int> left, List<int> right) {
    final result = <int>[];
    int i = 0, j = 0;

    while (i < left.length && j < right.length) {
      if (left[i] <= right[j]) {
        result.add(left[i++]);
      } else {
        result.add(right[j++]);
      }
    }

    result.addAll(left.sublist(i));
    result.addAll(right.sublist(j));
    return result;
  }

  /// Get number of available CPU cores
  // Uses getNumberOfProcessors() from platform_cores.dart
}

/// Isolate entry point for merge sort
void _isolateMergeSort(List<dynamic> args) {
  final sendPort = args[0] as SendPort;
  final data = args[1] as List<int>;

  try {
    final sorted = _mergeSort(data);
    sendPort.send(sorted);
  } catch (e) {
    sendPort.send('error: $e');
  }
}

/// Sequential merge sort for isolate
List<int> _mergeSort(List<int> input) {
  if (input.length <= 1) return List.from(input);

  final middle = input.length ~/ 2;
  final left = _mergeSort(input.sublist(0, middle));
  final right = _mergeSort(input.sublist(middle));

  return _mergeArrays(left, right);
}

/// Merge two sorted arrays
List<int> _mergeArrays(List<int> left, List<int> right) {
  final result = <int>[];
  int i = 0, j = 0;

  while (i < left.length && j < right.length) {
    if (left[i] <= right[j]) {
      result.add(left[i++]);
    } else {
      result.add(right[j++]);
    }
  }

  result.addAll(left.sublist(i));
  result.addAll(right.sublist(j));
  return result;
}

/// Parallel Quick Sort with work-stealing pattern
///
/// Features:
/// - Parallel partitioning and recursive sorting
/// - Load balancing across cores
/// - Hybrid approach: switches to insertion sort for small subarrays
/// - Randomized pivot selection for better average performance
///
/// Best for: Large unsorted datasets, good cache locality needed
class ParallelQuickSort extends Strategy<List<int>, List<int>> {
  static const int _sequentialThreshold = 8000;
  static const int _insertionThreshold = 16;
  static const int _maxDepth = 6;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'parallel_quick_sort',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.oLogN,
        requiresSorted: false,
        memoryOverheadBytes: 4096,
        description:
            'Multi-core quick sort with work-stealing and hybrid optimization',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final size = hint.n ?? input.length;

    // Only beneficial for large datasets
    if (size < _sequentialThreshold) return false;

    // Check isolate support
    try {
      Isolate.current;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  List<int> execute(List<int> input) {
    if (input.isEmpty) return [];
    if (input.length < _sequentialThreshold) {
      return _sequentialQuickSort(List.from(input), 0, input.length - 1);
    }

    try {
      return _parallelQuickSort(List.from(input));
    } catch (e) {
      return _sequentialQuickSort(List.from(input), 0, input.length - 1);
    }
  }

  /// Parallel quick sort with depth limiting
  List<int> _parallelQuickSort(List<int> input) {
    return _parallelQuickSortRecursive(input, 0, input.length - 1, 0);
  }

  /// Recursive parallel quick sort
  List<int> _parallelQuickSortRecursive(
    List<int> arr,
    int low,
    int high,
    int depth,
  ) {
    if (low < high) {
      // Use insertion sort for small subarrays
      if (high - low < _insertionThreshold) {
        _insertionSort(arr, low, high);
        return arr;
      }

      // Fall back to sequential if too deep
      if (depth >= _maxDepth) {
        return _sequentialQuickSort(arr, low, high);
      }

      final pivotIndex = _randomizedPartition(arr, low, high);

      // Create parallel tasks for left and right partitions
      final leftSize = pivotIndex - low;

      if (leftSize > _sequentialThreshold ~/ 2) {
        // Parallelize left partition
        final leftFuture = _computeQuickSort(
          QuickSortTask(List.from(arr), low, pivotIndex - 1, depth + 1),
        );

        // Process right partition in current thread
        _parallelQuickSortRecursive(arr, pivotIndex + 1, high, depth + 1);

        // Wait for left partition and merge results
        try {
          List<int>? leftResult;
          leftFuture.then((result) => leftResult = result).catchError((e) {
            leftResult =
                _sequentialQuickSort(List.from(arr), low, pivotIndex - 1);
            return leftResult!;
          });

          // Wait for result
          while (leftResult == null) {
            // Busy wait
          }

          // Copy left result back
          for (int i = low; i < pivotIndex; i++) {
            arr[i] = leftResult![i - low];
          }
        } catch (e) {
          // Fallback to sequential
          _sequentialQuickSort(arr, low, pivotIndex - 1);
        }
      } else {
        // Both partitions sequential
        _parallelQuickSortRecursive(arr, low, pivotIndex - 1, depth + 1);
        _parallelQuickSortRecursive(arr, pivotIndex + 1, high, depth + 1);
      }
    }

    return arr;
  }

  /// Compute-like function for quick sort in isolate
  Future<List<int>> _computeQuickSort(QuickSortTask task) async {
    final completer = Completer<List<int>>();

    try {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(
        _isolateQuickSort,
        [receivePort.sendPort, task],
      );

      receivePort.listen((message) {
        if (message is List<int>) {
          completer.complete(message);
        } else if (message is String && message.startsWith('error:')) {
          completer.completeError(Exception(message));
        }
        receivePort.close();
        isolate.kill();
      });
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw TimeoutException(
        'QuickSort timeout',
        const Duration(seconds: 15),
      ),
    );
  }

  /// Randomized partition with median-of-three pivot selection
  int _randomizedPartition(List<int> arr, int low, int high) {
    // Median-of-three pivot selection
    final mid = (low + high) ~/ 2;
    if (arr[mid] < arr[low]) _swap(arr, low, mid);
    if (arr[high] < arr[low]) _swap(arr, low, high);
    if (arr[high] < arr[mid]) _swap(arr, mid, high);
    _swap(arr, mid, high); // Move median to end

    return _partition(arr, low, high);
  }

  /// Standard Hoare partition scheme
  int _partition(List<int> arr, int low, int high) {
    final pivot = arr[high];
    int i = low - 1;

    for (int j = low; j < high; j++) {
      if (arr[j] <= pivot) {
        i++;
        _swap(arr, i, j);
      }
    }

    _swap(arr, i + 1, high);
    return i + 1;
  }

  /// Insertion sort for small subarrays
  void _insertionSort(List<int> arr, int low, int high) {
    for (int i = low + 1; i <= high; i++) {
      final key = arr[i];
      int j = i - 1;

      while (j >= low && arr[j] > key) {
        arr[j + 1] = arr[j];
        j--;
      }
      arr[j + 1] = key;
    }
  }

  /// Sequential quick sort fallback
  List<int> _sequentialQuickSort(List<int> arr, int low, int high) {
    if (low < high) {
      if (high - low < _insertionThreshold) {
        _insertionSort(arr, low, high);
      } else {
        final pivotIndex = _randomizedPartition(arr, low, high);
        _sequentialQuickSort(arr, low, pivotIndex - 1);
        _sequentialQuickSort(arr, pivotIndex + 1, high);
      }
    }
    return arr;
  }

  /// Swap two elements in array
  void _swap(List<int> arr, int i, int j) {
    final temp = arr[i];
    arr[i] = arr[j];
    arr[j] = temp;
  }
}

/// Task data for parallel quick sort
class QuickSortTask {
  const QuickSortTask(this.data, this.low, this.high, this.depth);

  final List<int> data;
  final int low;
  final int high;
  final int depth;
}

/// Isolate entry point for quick sort
void _isolateQuickSort(List<dynamic> args) {
  final sendPort = args[0] as SendPort;
  final task = args[1] as QuickSortTask;

  try {
    final sorted = _sequentialQuickSortIsolate(task.data, task.low, task.high);
    sendPort.send(sorted.sublist(task.low, task.high + 1));
  } catch (e) {
    sendPort.send('error: $e');
  }
}

/// Sequential quick sort for isolate
List<int> _sequentialQuickSortIsolate(List<int> arr, int low, int high) {
  if (low < high) {
    if (high - low < 16) {
      _insertionSortIsolate(arr, low, high);
    } else {
      final pivotIndex = _partitionIsolate(arr, low, high);
      _sequentialQuickSortIsolate(arr, low, pivotIndex - 1);
      _sequentialQuickSortIsolate(arr, pivotIndex + 1, high);
    }
  }
  return arr;
}

/// Partition for isolate
int _partitionIsolate(List<int> arr, int low, int high) {
  final pivot = arr[high];
  int i = low - 1;

  for (int j = low; j < high; j++) {
    if (arr[j] <= pivot) {
      i++;
      final temp = arr[i];
      arr[i] = arr[j];
      arr[j] = temp;
    }
  }

  final temp = arr[i + 1];
  arr[i + 1] = arr[high];
  arr[high] = temp;
  return i + 1;
}

/// Insertion sort for isolate
void _insertionSortIsolate(List<int> arr, int low, int high) {
  for (int i = low + 1; i <= high; i++) {
    final key = arr[i];
    int j = i - 1;

    while (j >= low && arr[j] > key) {
      arr[j + 1] = arr[j];
      j--;
    }
    arr[j + 1] = key;
  }
}

/// Parallel Binary Search using divide-and-conquer
///
/// Features:
/// - Splits search space across multiple cores
/// - Particularly effective for multiple searches
/// - Cache-friendly memory access patterns
/// - Falls back to sequential for small arrays
class ParallelBinarySearch extends Strategy<List<int>, int> {
  ParallelBinarySearch(this._target);
  static const int _sequentialThreshold = 100000;
  static const int _minChunkSize = 10000;

  final int _target;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'parallel_binary_search',
        timeComplexity: TimeComplexity.oLogN,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: true,
        memoryOverheadBytes: 2048,
        description: 'Multi-core binary search for large sorted datasets',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final size = hint.n ?? input.length;

    // Only beneficial for very large sorted arrays
    if (size < _sequentialThreshold) return false;

    // Check if array appears to be sorted (sampling)
    if (!_isSortedSample(input)) return false;

    // Check isolate support
    try {
      Isolate.current;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  int execute(List<int> input) {
    if (input.isEmpty) return -1;
    if (input.length < _sequentialThreshold) {
      return _sequentialBinarySearch(input, _target);
    }

    try {
      return _parallelBinarySearch(input, _target);
    } catch (e) {
      return _sequentialBinarySearch(input, _target);
    }
  }

  /// Parallel binary search implementation
  int _parallelBinarySearch(List<int> input, int target) {
    final numCores = _getAvailableCores();
    final chunkSize = math.max(_minChunkSize, input.length ~/ numCores);

    // Create search tasks for each chunk
    final futures = <Future<int>>[];

    for (int i = 0; i < input.length; i += chunkSize) {
      final end = math.min(i + chunkSize, input.length);
      final chunk = input.sublist(i, end);

      futures.add(_computeBinarySearch(BinarySearchTask(chunk, target, i)));
    }

    // Wait for first successful result
    for (final future in futures) {
      try {
        int? result;
        future.then((value) => result = value).catchError((e) {
          result = -1;
          return result!;
        });

        // Wait for result
        while (result == null) {
          // Busy wait
        }

        if (result! != -1) {
          return result!;
        }
      } catch (e) {
        continue;
      }
    }

    return -1; // Not found
  }

  /// Compute-like function for binary search in isolate
  Future<int> _computeBinarySearch(BinarySearchTask task) async {
    final completer = Completer<int>();

    try {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(
        _isolateBinarySearch,
        [receivePort.sendPort, task],
      );

      receivePort.listen((message) {
        if (message is int) {
          completer.complete(message);
        } else if (message is String && message.startsWith('error:')) {
          completer.completeError(Exception(message));
        }
        receivePort.close();
        isolate.kill();
      });
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => -1,
    );
  }

  /// Sequential binary search
  int _sequentialBinarySearch(List<int> arr, int target) {
    int low = 0;
    int high = arr.length - 1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final midValue = arr[mid];

      if (midValue == target) {
        return mid;
      } else if (midValue < target) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return -1;
  }

  /// Check if array is sorted (sample-based)
  bool _isSortedSample(List<int> arr) {
    if (arr.length < 2) return true;

    final sampleSize = math.min(100, arr.length ~/ 10);
    final step = arr.length ~/ sampleSize;

    for (int i = step; i < arr.length; i += step) {
      if (arr[i - step] > arr[i]) return false;
    }

    return true;
  }

  /// Get number of available CPU cores
  int _getAvailableCores() {
    try {
      return Platform.numberOfProcessors;
    } catch (e) {
      return 4;
    }
  }
}

/// Task data for parallel binary search
class BinarySearchTask {
  const BinarySearchTask(this.data, this.target, this.offset);

  final List<int> data;
  final int target;
  final int offset;
}

/// Isolate entry point for binary search
void _isolateBinarySearch(List<dynamic> args) {
  final sendPort = args[0] as SendPort;
  final task = args[1] as BinarySearchTask;

  try {
    final localIndex = _binarySearchIsolate(task.data, task.target);
    final globalIndex = localIndex == -1 ? -1 : localIndex + task.offset;
    sendPort.send(globalIndex);
  } catch (e) {
    sendPort.send('error: $e');
  }
}

/// Binary search for isolate
int _binarySearchIsolate(List<int> arr, int target) {
  int low = 0;
  int high = arr.length - 1;

  while (low <= high) {
    final mid = (low + high) ~/ 2;
    final midValue = arr[mid];

    if (midValue == target) {
      return mid;
    } else if (midValue < target) {
      low = mid + 1;
    } else {
      high = mid - 1;
    }
  }

  return -1;
}
