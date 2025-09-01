import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/time_complexity.dart';
import '../../../domain/value_objects/selector_hint.dart';

/// QuickSort implementation using Lomuto partition scheme.
///
/// QuickSort is a divide-and-conquer algorithm that works by selecting a
/// 'pivot' element and partitioning the array around it. Elements smaller
/// than the pivot go to the left, larger elements go to the right.
///
/// **Time Complexity:**
/// - Best/Average: O(n log n) - when pivot divides array evenly
/// - Worst: O(n²) - when pivot is always smallest/largest element
///
/// **Space Complexity:** O(log n) - recursive call stack
///
/// **Characteristics:**
/// - Not stable (relative order of equal elements may change)
/// - In-place sorting (only O(log n) extra space for recursion)
/// - Cache-efficient due to good locality of reference
/// - Performs well on already partially sorted data
///
/// **Best Use Cases:**
/// - General-purpose sorting for large datasets
/// - When average-case performance is more important than worst-case
/// - Systems with good cache performance requirements
/// - When in-place sorting is preferred
class QuickSort extends Strategy<List<int>, List<int>> {
  /// Creates a QuickSort strategy instance.
  QuickSort();

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'quick_sort',
        timeComplexity: TimeComplexity.oNLogN, // Average case
        spaceComplexity: TimeComplexity.oLogN, // Recursion stack
        requiresSorted: false,
        memoryOverheadBytes: 0, // In-place algorithm
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    // QuickSort works well for medium to large datasets
    // Avoid for very small arrays (insertion sort is better)
    // Avoid for very large arrays if memory is constrained (mergeSort might be better)
    final n = hint.n ?? input.length;

    if (n < 10) return false; // Too small, insertion sort is better
    if (hint.memoryBudgetBytes != null && hint.memoryBudgetBytes! < 1024) {
      return false; // Low memory, use iterative algorithms
    }

    return true;
  }

  @override
  List<int> execute(List<int> input) {
    if (input.isEmpty || input.length == 1) return List.from(input);

    final result = List<int>.from(input);
    _quickSort(result, 0, result.length - 1);
    return result;
  }

  /// Recursively sorts the array using QuickSort algorithm.
  ///
  /// [arr] - The array to sort
  /// [low] - Starting index of the partition
  /// [high] - Ending index of the partition
  void _quickSort(List<int> arr, int low, int high) {
    if (low < high) {
      // Partition the array and get the pivot index
      final pivotIndex = _partition(arr, low, high);

      // Recursively sort elements before and after partition
      _quickSort(arr, low, pivotIndex - 1);
      _quickSort(arr, pivotIndex + 1, high);
    }
  }

  /// Partitions the array using Lomuto partition scheme.
  ///
  /// Takes the last element as pivot, places it at correct position,
  /// and puts all smaller elements to left and all greater to right.
  ///
  /// [arr] - The array to partition
  /// [low] - Starting index
  /// [high] - Ending index (contains the pivot)
  ///
  /// Returns the final position of the pivot element.
  int _partition(List<int> arr, int low, int high) {
    // Choose the last element as pivot
    final pivot = arr[high];

    // Index of smaller element (indicates right position of pivot)
    int i = low - 1;

    // Traverse through array and rearrange elements
    for (int j = low; j < high; j++) {
      // If current element is smaller than or equal to pivot
      if (arr[j] <= pivot) {
        i++; // Increment index of smaller element
        _swap(arr, i, j);
      }
    }

    // Place pivot at correct position
    _swap(arr, i + 1, high);
    return i + 1; // Return the pivot index
  }

  /// Swaps two elements in the array.
  ///
  /// [arr] - The array containing elements to swap
  /// [i] - Index of first element
  /// [j] - Index of second element
  void _swap(List<int> arr, int i, int j) {
    final temp = arr[i];
    arr[i] = arr[j];
    arr[j] = temp;
  }
}

/// Optimized QuickSort with median-of-three pivot selection.
///
/// This variant improves performance by choosing a better pivot using
/// the median of the first, middle, and last elements. This reduces
/// the likelihood of worst-case O(n²) behavior.
///
/// **Improvements over basic QuickSort:**
/// - Better pivot selection reduces worst-case probability
/// - Hybrid approach: switches to insertion sort for small arrays
/// - Tail recursion optimization to reduce stack usage
class OptimizedQuickSort extends Strategy<List<int>, List<int>> {
  /// Creates an OptimizedQuickSort strategy instance.
  OptimizedQuickSort();

  /// Threshold for switching to insertion sort for small arrays.
  static const int _insertionSortThreshold = 10;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'optimized_quick_sort',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.oLogN,
        requiresSorted: false,
        memoryOverheadBytes: 0,
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    // Optimized version works well for all sizes above threshold
    final n = hint.n ?? input.length;

    if (n < _insertionSortThreshold) return false;
    if (hint.memoryBudgetBytes != null && hint.memoryBudgetBytes! < 2048) {
      return false; // Needs slightly more memory for optimization
    }

    return true;
  }

  @override
  List<int> execute(List<int> input) {
    if (input.isEmpty || input.length == 1) return List.from(input);

    final result = List<int>.from(input);
    _quickSort(result, 0, result.length - 1);
    return result;
  }

  /// Optimized QuickSort with hybrid approach.
  void _quickSort(List<int> arr, int low, int high) {
    while (low < high) {
      // Use insertion sort for small arrays
      if (high - low < _insertionSortThreshold) {
        _insertionSort(arr, low, high);
        break;
      }

      // Partition with median-of-three pivot
      final pivotIndex = _partitionWithMedianOfThree(arr, low, high);

      // Recursively sort the smaller partition first (tail recursion optimization)
      if (pivotIndex - low < high - pivotIndex) {
        _quickSort(arr, low, pivotIndex - 1);
        low = pivotIndex + 1; // Tail recursion
      } else {
        _quickSort(arr, pivotIndex + 1, high);
        high = pivotIndex - 1; // Tail recursion
      }
    }
  }

  /// Insertion sort for small arrays.
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

  /// Partitions using median-of-three pivot selection.
  int _partitionWithMedianOfThree(List<int> arr, int low, int high) {
    // Choose median of first, middle, and last elements as pivot
    _medianOfThree(arr, low, (low + high) ~/ 2, high);

    // Standard Lomuto partition
    return _partition(arr, low, high);
  }

  /// Arranges first, middle, last elements so middle is the median.
  void _medianOfThree(List<int> arr, int low, int mid, int high) {
    if (arr[mid] < arr[low]) _swap(arr, low, mid);
    if (arr[high] < arr[low]) _swap(arr, low, high);
    if (arr[high] < arr[mid]) _swap(arr, mid, high);

    // Place median at the end (will be used as pivot)
    _swap(arr, mid, high);
  }

  /// Standard Lomuto partition scheme.
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

  /// Swaps two elements in the array.
  void _swap(List<int> arr, int i, int j) {
    final temp = arr[i];
    arr[i] = arr[j];
    arr[j] = temp;
  }
}
