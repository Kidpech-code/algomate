import 'dart:math' as math;
import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';

/// Quick Sort algorithm with randomized pivot selection.
///
/// Features:
/// - Randomized pivot to avoid O(n²) worst case on sorted data
/// - In-place sorting with O(log n) space complexity
/// - Falls back to insertion sort for small arrays (< 10 elements)
/// - Optimized for average case O(n log n) performance
///
/// Best for: Large datasets, general-purpose sorting, when average
/// performance is more important than worst-case guarantees.
///
/// Avoid for: Already sorted data (use merge sort), very small datasets
/// (use insertion sort), when worst-case performance is critical.
class RandomizedQuickSort extends Strategy<List<int>, List<int>> {
  static const int _insertionSortThreshold = 10;
  static final _random = math.Random();

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'randomized_quick_sort',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.oLogN,
        requiresSorted: false,
        memoryOverheadBytes: 0, // In-place algorithm
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    // Quick sort excels with large datasets
    final size = hint.n ?? input.length;

    // Not efficient for very small arrays
    if (size < _insertionSortThreshold) return false;

    // Great for general purpose sorting
    return true;
  }

  @override
  List<int> execute(List<int> input) {
    if (input.isEmpty) return [];

    final result = List<int>.from(input);
    _quickSort(result, 0, result.length - 1);
    return result;
  }

  /// Recursive quicksort implementation with randomized pivot
  void _quickSort(List<int> arr, int low, int high) {
    if (high - low + 1 <= _insertionSortThreshold) {
      _insertionSort(arr, low, high);
      return;
    }

    if (low < high) {
      final pivotIndex = _randomizedPartition(arr, low, high);
      _quickSort(arr, low, pivotIndex - 1);
      _quickSort(arr, pivotIndex + 1, high);
    }
  }

  /// Randomized partition using Hoare partition scheme
  int _randomizedPartition(List<int> arr, int low, int high) {
    // Randomize pivot to avoid worst-case on sorted/reverse-sorted data
    final randomPivot = low + _random.nextInt(high - low + 1);
    _swap(arr, randomPivot, high);

    return _partition(arr, low, high);
  }

  /// Hoare partition scheme - more efficient than Lomuto
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

  /// Efficient in-place swap
  void _swap(List<int> arr, int i, int j) {
    if (i != j) {
      final temp = arr[i];
      arr[i] = arr[j];
      arr[j] = temp;
    }
  }
}

/// Dual-pivot quicksort variant (used by Java's Arrays.sort)
///
/// More complex but often faster than single-pivot quicksort,
/// especially on datasets with many duplicates.
class DualPivotQuickSort extends Strategy<List<int>, List<int>> {
  static const int _insertionSortThreshold = 47;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'dual_pivot_quick_sort',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.oLogN,
        requiresSorted: false,
        memoryOverheadBytes: 0,
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final size = hint.n ?? input.length;

    // Dual pivot is more complex, so not worth it for small arrays
    if (size < _insertionSortThreshold) return false;

    // Good general-purpose choice for large arrays
    return size > 200;
  }

  @override
  List<int> execute(List<int> input) {
    if (input.isEmpty) return [];

    final result = List<int>.from(input);
    _dualPivotQuickSort(result, 0, result.length - 1);
    return result;
  }

  /// Dual-pivot quicksort implementation
  void _dualPivotQuickSort(List<int> arr, int low, int high) {
    if (high - low + 1 <= _insertionSortThreshold) {
      _insertionSort(arr, low, high);
      return;
    }

    if (low < high) {
      final pivots = _partition(arr, low, high);
      final pivot1 = pivots.first;
      final pivot2 = pivots.last;

      _dualPivotQuickSort(arr, low, pivot1 - 1);
      _dualPivotQuickSort(arr, pivot1 + 1, pivot2 - 1);
      _dualPivotQuickSort(arr, pivot2 + 1, high);
    }
  }

  /// Dual-pivot partition
  List<int> _partition(List<int> arr, int low, int high) {
    // Make sure arr[low] <= arr[high]
    if (arr[low] > arr[high]) {
      _swap(arr, low, high);
    }

    final pivot1 = arr[low];
    final pivot2 = arr[high];

    int i = low + 1;
    int lt = low + 1;
    int gt = high - 1;

    while (i <= gt) {
      if (arr[i] < pivot1) {
        _swap(arr, i, lt);
        lt++;
        i++;
      } else if (arr[i] > pivot2) {
        _swap(arr, i, gt);
        gt--;
      } else {
        i++;
      }
    }

    // Place pivots in their final positions
    _swap(arr, low, lt - 1);
    _swap(arr, high, gt + 1);

    return [lt - 1, gt + 1];
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

  /// Efficient in-place swap
  void _swap(List<int> arr, int i, int j) {
    if (i != j) {
      final temp = arr[i];
      arr[i] = arr[j];
      arr[j] = temp;
    }
  }
}

/// Three-way quicksort (Dijkstra's Dutch National Flag)
///
/// Optimized for arrays with many duplicate values.
/// Partitions into three sections: `< pivot`, `= pivot`, `> pivot`
class ThreeWayQuickSort extends Strategy<List<int>, List<int>> {
  static const int _insertionSortThreshold = 10;
  static final _random = math.Random();

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'three_way_quick_sort',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.oLogN,
        requiresSorted: false,
        memoryOverheadBytes: 0,
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final size = hint.n ?? input.length;

    if (size < _insertionSortThreshold) return false;

    // Check for duplicates in small sample if size > 50
    if (size > 50) {
      final sample = input.take(20).toSet();
      final duplicateRatio = 1.0 - (sample.length / 20);
      return duplicateRatio > 0.3; // 30% duplicates
    }

    return false;
  }

  @override
  List<int> execute(List<int> input) {
    if (input.isEmpty) return [];

    final result = List<int>.from(input);
    _threeWayQuickSort(result, 0, result.length - 1);
    return result;
  }

  /// Three-way quicksort implementation
  void _threeWayQuickSort(List<int> arr, int low, int high) {
    if (high - low + 1 <= _insertionSortThreshold) {
      _insertionSort(arr, low, high);
      return;
    }

    if (low < high) {
      final pivots = _threeWayPartition(arr, low, high);
      final lt = pivots[0];
      final gt = pivots[1];

      _threeWayQuickSort(arr, low, lt - 1);
      _threeWayQuickSort(arr, gt + 1, high);
    }
  }

  /// Three-way partition (Dutch National Flag)
  List<int> _threeWayPartition(List<int> arr, int low, int high) {
    // Randomize pivot
    final randomPivot = low + _random.nextInt(high - low + 1);
    _swap(arr, randomPivot, low);

    final pivot = arr[low];
    int i = low;
    int lt = low;
    int gt = high;

    while (i <= gt) {
      if (arr[i] < pivot) {
        _swap(arr, lt, i);
        lt++;
        i++;
      } else if (arr[i] > pivot) {
        _swap(arr, i, gt);
        gt--;
      } else {
        i++;
      }
    }

    return [lt, gt];
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

  /// Efficient in-place swap
  void _swap(List<int> arr, int i, int j) {
    if (i != j) {
      final temp = arr[i];
      arr[i] = arr[j];
      arr[j] = temp;
    }
  }
}
