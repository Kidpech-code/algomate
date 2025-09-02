import 'dart:math' as math;
import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';

/// Web-compatible parallel merge sort (falls back to sequential)
///
/// Features:
/// - Falls back to sequential merge sort on web platform
/// - No isolate usage (web limitation)
/// - Same API as native parallel version
///
/// Best for: Large datasets on web platform where parallel processing isn't available
///
/// Performance: O(n log n) time, sequential execution
/// Space: O(n) for temporary arrays
class ParallelMergeSort extends Strategy<List<int>, List<int>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'parallel_merge_sort_web',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.oN,
        description: 'Web-compatible merge sort with sequential fallback',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final n = hint.n ?? input.length;
    return n > 100; // Suitable for medium to large datasets
  }

  @override
  List<int> execute(List<int> input) {
    if (input.isEmpty) return [];
    if (input.length <= 1) return List.from(input);

    // Use sequential merge sort for web compatibility
    return _sequentialMergeSort(input);
  }

  List<int> _sequentialMergeSort(List<int> arr) {
    if (arr.length <= 1) return arr;

    final mid = arr.length ~/ 2;
    final left = _sequentialMergeSort(arr.sublist(0, mid));
    final right = _sequentialMergeSort(arr.sublist(mid));

    return _merge(left, right);
  }

  List<int> _merge(List<int> left, List<int> right) {
    final result = <int>[];
    int leftIndex = 0;
    int rightIndex = 0;

    while (leftIndex < left.length && rightIndex < right.length) {
      if (left[leftIndex] <= right[rightIndex]) {
        result.add(left[leftIndex]);
        leftIndex++;
      } else {
        result.add(right[rightIndex]);
        rightIndex++;
      }
    }

    result.addAll(left.sublist(leftIndex));
    result.addAll(right.sublist(rightIndex));

    return result;
  }
}

/// Web-compatible parallel quick sort (falls back to sequential)
///
/// Features:
/// - Falls back to sequential quick sort on web platform
/// - No isolate usage (web limitation)
/// - Uses randomized pivot selection
/// - Hybrid with insertion sort for small arrays
///
/// Best for: General-purpose sorting on web platform
///
/// Performance: O(n log n) average, O(n²) worst case
/// Space: O(log n) stack space
class ParallelQuickSort extends Strategy<List<int>, List<int>> {
  static const int _hybridThreshold = 10;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'parallel_quick_sort_web',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.oLogN,
        description:
            'Web-compatible randomized quick sort with sequential fallback',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final n = hint.n ?? input.length;
    // Quick sort works well for most data but not ideal for already sorted
    if (hint.sorted == true) return false;
    return n > 50; // Suitable for medium to large datasets
  }

  @override
  List<int> execute(List<int> input) {
    if (input.isEmpty) return [];
    if (input.length <= 1) return List.from(input);

    final arr = List<int>.from(input);
    _sequentialQuickSort(arr, 0, arr.length - 1);
    return arr;
  }

  void _sequentialQuickSort(List<int> arr, int low, int high) {
    while (low < high) {
      if (high - low + 1 < _hybridThreshold) {
        _insertionSort(arr, low, high);
        break;
      }

      final pi = _randomizedPartition(arr, low, high);

      if (pi - low < high - pi) {
        _sequentialQuickSort(arr, low, pi - 1);
        low = pi + 1;
      } else {
        _sequentialQuickSort(arr, pi + 1, high);
        high = pi - 1;
      }
    }
  }

  int _randomizedPartition(List<int> arr, int low, int high) {
    final random = math.Random();
    final randomIndex = low + random.nextInt(high - low + 1);
    _swap(arr, randomIndex, high);
    return _partition(arr, low, high);
  }

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

  void _swap(List<int> arr, int i, int j) {
    final temp = arr[i];
    arr[i] = arr[j];
    arr[j] = temp;
  }
}

/// Web-compatible parallel binary search (falls back to sequential)
///
/// Features:
/// - Falls back to sequential binary search on web platform
/// - No isolate usage (web limitation)
/// - Same API as native parallel version
///
/// Best for: Searching in very large sorted arrays on web platform
///
/// Performance: O(log n) time
/// Space: O(1)
class ParallelBinarySearch extends Strategy<List<dynamic>, int> {
  ParallelBinarySearch(this.target);
  final dynamic target;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'parallel_binary_search_web',
        timeComplexity: TimeComplexity.oLogN,
        spaceComplexity: TimeComplexity.o1,
        description: 'Web-compatible binary search with sequential fallback',
      );

  @override
  bool canApply(List<dynamic> input, SelectorHint hint) {
    return hint.sorted == true && input.isNotEmpty;
  }

  @override
  int execute(List<dynamic> input) {
    if (input.isEmpty) return -1;

    return _binarySearch(input, target, 0, input.length - 1);
  }

  int _binarySearch(List<dynamic> arr, dynamic target, int left, int right) {
    while (left <= right) {
      final mid = left + (right - left) ~/ 2;

      if (arr[mid] == target) {
        return mid;
      } else if ((arr[mid] as Comparable).compareTo(target) < 0) {
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }

    return -1;
  }
}
