import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';

/// Merge sort strategy for stable, guaranteed O(n log n) sorting.
///
/// Time complexity: O(n log n) in all cases
/// Space complexity: O(n)
/// Stable sort that works well for larger datasets.
class MergeSortStrategy extends Strategy<List<int>, List<int>> {
  MergeSortStrategy();

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'merge_sort',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.oN,
        requiresSorted: false,
        memoryOverheadBytes:
            4096, // Estimated overhead for typical use (n * 4 bytes)
        description: 'Stable merge sort with guaranteed O(n log n) performance',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final n = hint.n ?? input.length;

    // Merge sort is good for larger datasets
    if (n <= 32) {
      return false; // Let insertion sort handle small arrays
    }

    // Check memory budget if provided
    if (hint.memoryBudgetBytes != null) {
      final requiredMemory = n * 4; // 4 bytes per int (approximate)
      if (requiredMemory > hint.memoryBudgetBytes!) {
        return false; // Not enough memory for auxiliary arrays
      }
    }

    return true;
  }

  @override
  List<int> execute(List<int> input) {
    if (input.length <= 1) return List.from(input);

    return _mergeSort(input, 0, input.length - 1);
  }

  List<int> _mergeSort(List<int> arr, int left, int right) {
    if (left >= right) {
      return [arr[left]];
    }

    final mid = left + ((right - left) >> 1);

    final leftSorted = _mergeSort(arr, left, mid);
    final rightSorted = _mergeSort(arr, mid + 1, right);

    return _merge(leftSorted, rightSorted);
  }

  List<int> _merge(List<int> left, List<int> right) {
    final result = <int>[];
    var leftIndex = 0;
    var rightIndex = 0;

    // Merge the two sorted arrays
    while (leftIndex < left.length && rightIndex < right.length) {
      if (left[leftIndex] <= right[rightIndex]) {
        result.add(left[leftIndex++]);
      } else {
        result.add(right[rightIndex++]);
      }
    }

    // Add remaining elements
    while (leftIndex < left.length) {
      result.add(left[leftIndex++]);
    }

    while (rightIndex < right.length) {
      result.add(right[rightIndex++]);
    }

    return result;
  }
}

/// Bottom-up merge sort that avoids recursion for better performance.
class IterativeMergeSortStrategy extends Strategy<List<int>, List<int>> {
  IterativeMergeSortStrategy();

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'iterative_merge_sort',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.oN,
        requiresSorted: false,
        memoryOverheadBytes: 4096, // Similar to regular merge sort
        description: 'Bottom-up merge sort without recursion',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final n = hint.n ?? input.length;

    // Good for large datasets where recursion depth might be a concern
    if (n <= 64) return false;

    // Check memory budget
    if (hint.memoryBudgetBytes != null) {
      final requiredMemory = n * 4;
      if (requiredMemory > hint.memoryBudgetBytes!) return false;
    }

    return true;
  }

  @override
  List<int> execute(List<int> input) {
    if (input.length <= 1) return List.from(input);

    final result = List<int>.from(input);
    final n = result.length;
    final temp = List<int>.filled(n, 0);

    // Bottom-up merge sort
    for (var size = 1; size < n; size *= 2) {
      for (var start = 0; start < n - size; start += size * 2) {
        final mid = start + size - 1;
        final end = (start + size * 2 - 1).clamp(0, n - 1);

        if (mid < end) {
          _mergeInPlace(result, temp, start, mid, end);
        }
      }
    }

    return result;
  }

  void _mergeInPlace(
    List<int> arr,
    List<int> temp,
    int left,
    int mid,
    int right,
  ) {
    // Copy data to temp arrays
    for (var i = left; i <= right; i++) {
      temp[i] = arr[i];
    }

    var i = left;
    var j = mid + 1;
    var k = left;

    // Merge back to original array
    while (i <= mid && j <= right) {
      if (temp[i] <= temp[j]) {
        arr[k++] = temp[i++];
      } else {
        arr[k++] = temp[j++];
      }
    }

    // Copy remaining elements
    while (i <= mid) {
      arr[k++] = temp[i++];
    }

    while (j <= right) {
      arr[k++] = temp[j++];
    }
  }
}

/// Hybrid merge sort that switches to insertion sort for small subarrays.
class HybridMergeSortStrategy extends Strategy<List<int>, List<int>> {
  HybridMergeSortStrategy({this.insertionThreshold = 16});

  final int insertionThreshold;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'hybrid_merge_sort',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.oN,
        requiresSorted: false,
        memoryOverheadBytes:
            3584, // Slightly less than regular merge sort (hybrid optimization)
        description:
            'Merge sort that switches to insertion sort for small subarrays',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final n = hint.n ?? input.length;

    // Hybrid approach is good for medium to large datasets
    if (n <= 8) return false;

    if (hint.memoryBudgetBytes != null) {
      final requiredMemory = n * 4;
      if (requiredMemory > hint.memoryBudgetBytes!) return false;
    }

    return true;
  }

  @override
  List<int> execute(List<int> input) {
    if (input.length <= 1) return List.from(input);

    final result = List<int>.from(input);
    _hybridMergeSort(result, 0, result.length - 1);
    return result;
  }

  void _hybridMergeSort(List<int> arr, int left, int right) {
    if (right - left + 1 <= insertionThreshold) {
      // Use insertion sort for small subarrays
      _insertionSort(arr, left, right);
      return;
    }

    final mid = left + ((right - left) >> 1);

    _hybridMergeSort(arr, left, mid);
    _hybridMergeSort(arr, mid + 1, right);

    _merge(arr, left, mid, right);
  }

  void _insertionSort(List<int> arr, int left, int right) {
    for (var i = left + 1; i <= right; i++) {
      final key = arr[i];
      var j = i - 1;

      while (j >= left && arr[j] > key) {
        arr[j + 1] = arr[j];
        j--;
      }

      arr[j + 1] = key;
    }
  }

  void _merge(List<int> arr, int left, int mid, int right) {
    final leftArr = arr.sublist(left, mid + 1);
    final rightArr = arr.sublist(mid + 1, right + 1);

    var i = 0, j = 0, k = left;

    while (i < leftArr.length && j < rightArr.length) {
      if (leftArr[i] <= rightArr[j]) {
        arr[k++] = leftArr[i++];
      } else {
        arr[k++] = rightArr[j++];
      }
    }

    while (i < leftArr.length) {
      arr[k++] = leftArr[i++];
    }

    while (j < rightArr.length) {
      arr[k++] = rightArr[j++];
    }
  }
}
