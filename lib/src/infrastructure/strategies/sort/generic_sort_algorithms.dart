import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';

/// Generic Merge Sort that works with any Comparable type.
///
/// This implementation provides:
/// - Type-safe sorting for any T that implements Comparable
/// - Stable sorting (maintains relative order of equal elements)
/// - Guaranteed O(n log n) time complexity
/// - O(n) space complexity for the merge operation
///
/// Perfect for:
/// - Custom objects like Person, Product, Transaction
/// - DateTime, String, int, double or other built-in Comparable types
/// - When stability is important (equal elements keep their original order)
/// - Large datasets where consistent performance is needed
///
/// Usage example:
/// ```dart
/// class Person implements Comparable<Person> {
///   final String name;
///   final int age;
///
///   Person(this.name, this.age);
///
///   @override
///   int compareTo(Person other) => age.compareTo(other.age);
/// }
///
/// final strategy = GenericMergeSort<Person>();
/// final people = [Person('Alice', 30), Person('Bob', 25)];
/// final sorted = strategy.execute(people);
/// ```
class GenericMergeSort<T extends Comparable<dynamic>>
    extends Strategy<List<T>, List<T>> {
  /// Creates a generic merge sort strategy for type T.
  GenericMergeSort();

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'generic_merge_sort',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.oN,
        requiresSorted: false,
        memoryOverheadBytes: 0, // Will be calculated based on element size
        description: 'Stable merge sort for any Comparable type',
      );

  @override
  bool canApply(List<T> input, SelectorHint hint) {
    final n = hint.n ?? input.length;

    // Merge sort is excellent for medium to large datasets
    if (n < 10) return false; // Use insertion sort for very small arrays

    // Always applicable for Comparable types
    return true;
  }

  @override
  List<T> execute(List<T> input) {
    if (input.length <= 1) return List<T>.from(input);

    final result = List<T>.from(input);
    _mergeSort(result, 0, result.length - 1);
    return result;
  }

  /// Recursive merge sort implementation
  void _mergeSort(List<T> arr, int left, int right) {
    if (left >= right) return;

    final mid = left + (right - left) ~/ 2;

    _mergeSort(arr, left, mid);
    _mergeSort(arr, mid + 1, right);
    _merge(arr, left, mid, right);
  }

  /// Merge two sorted halves
  void _merge(List<T> arr, int left, int mid, int right) {
    // Create temporary arrays for left and right subarrays
    final leftArr = <T>[];
    final rightArr = <T>[];

    // Copy data to temporary arrays
    for (int i = left; i <= mid; i++) {
      leftArr.add(arr[i]);
    }
    for (int j = mid + 1; j <= right; j++) {
      rightArr.add(arr[j]);
    }

    // Merge the temporary arrays back
    int i = 0, j = 0, k = left;

    while (i < leftArr.length && j < rightArr.length) {
      if (leftArr[i].compareTo(rightArr[j]) <= 0) {
        arr[k] = leftArr[i];
        i++;
      } else {
        arr[k] = rightArr[j];
        j++;
      }
      k++;
    }

    // Copy remaining elements
    while (i < leftArr.length) {
      arr[k] = leftArr[i];
      i++;
      k++;
    }

    while (j < rightArr.length) {
      arr[k] = rightArr[j];
      j++;
      k++;
    }
  }
}

/// Generic Quick Sort for any Comparable type with hybrid optimization.
///
/// Features:
/// - Fast average-case performance O(n log n)
/// - In-place sorting with O(log n) space complexity
/// - Hybrid approach: switches to insertion sort for small subarrays
/// - Median-of-three pivot selection to avoid worst-case
/// - Tail recursion optimization
///
/// Best for:
/// - Large datasets with good cache performance requirements
/// - Custom objects where comparison is fast
/// - Memory-constrained environments
/// - General-purpose sorting when stability is not required
class GenericQuickSort<T extends Comparable<dynamic>>
    extends Strategy<List<T>, List<T>> {
  /// Creates a generic quick sort strategy for type T.
  GenericQuickSort();

  /// Threshold for switching to insertion sort
  static const int _insertionSortThreshold = 10;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'generic_quick_sort',
        timeComplexity: TimeComplexity.oNLogN, // Average case
        spaceComplexity: TimeComplexity.oLogN,
        requiresSorted: false,
        memoryOverheadBytes: 0,
        description: 'Fast in-place quick sort for any Comparable type',
      );

  @override
  bool canApply(List<T> input, SelectorHint hint) {
    final n = hint.n ?? input.length;

    // Quick sort works well for medium to large datasets
    if (n < _insertionSortThreshold) return false;

    // Avoid if stability is required (quick sort is not stable)
    if (hint.preferStable == true) return false;

    // Check memory constraints
    final stackMemoryEstimate =
        (n.bitLength * 8); // Rough recursion stack estimate
    if (hint.memoryBudgetBytes != null &&
        hint.memoryBudgetBytes! < stackMemoryEstimate) {
      return false;
    }

    return true;
  }

  @override
  List<T> execute(List<T> input) {
    final result = List<T>.from(input);
    _quickSort(result, 0, result.length - 1);
    return result;
  }

  /// Quick sort with hybrid optimization
  void _quickSort(List<T> arr, int low, int high) {
    while (low < high) {
      // Use insertion sort for small subarrays
      if (high - low < _insertionSortThreshold) {
        _insertionSort(arr, low, high);
        break;
      }

      // Partition and get pivot index
      final pi = _partition(arr, low, high);

      // Recursively sort smaller partition, iterate for larger
      // (Tail recursion optimization)
      if (pi - low < high - pi) {
        _quickSort(arr, low, pi - 1);
        low = pi + 1;
      } else {
        _quickSort(arr, pi + 1, high);
        high = pi - 1;
      }
    }
  }

  /// Lomuto partition scheme with median-of-three pivot
  int _partition(List<T> arr, int low, int high) {
    // Median-of-three pivot selection
    _medianOfThree(arr, low, high);

    final pivot = arr[high];
    int i = low - 1;

    for (int j = low; j < high; j++) {
      if (arr[j].compareTo(pivot) <= 0) {
        i++;
        _swap(arr, i, j);
      }
    }

    _swap(arr, i + 1, high);
    return i + 1;
  }

  /// Choose median of three as pivot
  void _medianOfThree(List<T> arr, int low, int high) {
    final mid = low + (high - low) ~/ 2;

    if (arr[mid].compareTo(arr[low]) < 0) _swap(arr, low, mid);
    if (arr[high].compareTo(arr[low]) < 0) _swap(arr, low, high);
    if (arr[high].compareTo(arr[mid]) < 0) _swap(arr, mid, high);

    // Move median to end
    _swap(arr, mid, high);
  }

  /// Insertion sort for small subarrays
  void _insertionSort(List<T> arr, int low, int high) {
    for (int i = low + 1; i <= high; i++) {
      final key = arr[i];
      int j = i - 1;

      while (j >= low && arr[j].compareTo(key) > 0) {
        arr[j + 1] = arr[j];
        j--;
      }

      arr[j + 1] = key;
    }
  }

  /// Efficient swap
  void _swap(List<T> arr, int i, int j) {
    if (i != j) {
      final temp = arr[i];
      arr[i] = arr[j];
      arr[j] = temp;
    }
  }
}

/// Generic Insertion Sort for any Comparable type.
///
/// Perfect for:
/// - Small datasets (< 50 elements)
/// - Nearly sorted data
/// - When simplicity and low overhead are important
/// - Online sorting (can sort data as it arrives)
///
/// Features:
/// - Stable sorting algorithm
/// - Adaptive: O(n) best case for sorted data
/// - In-place: O(1) space complexity
/// - Simple and reliable implementation
class GenericInsertionSort<T extends Comparable<dynamic>>
    extends Strategy<List<T>, List<T>> {
  /// Creates a generic insertion sort strategy for type T.
  GenericInsertionSort();

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'generic_insertion_sort',
        timeComplexity: TimeComplexity.oN2, // Worst case
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: false,
        memoryOverheadBytes: 0,
        description: 'Simple and stable insertion sort for any Comparable type',
      );

  @override
  bool canApply(List<T> input, SelectorHint hint) {
    final n = hint.n ?? input.length;

    // Excellent for small datasets
    if (n <= 50) return true;

    // Good for nearly sorted data regardless of size
    if (hint.sorted == true || hint.nearlySorted == true) return true;

    // Good when simplicity is preferred
    if (hint.preferSimple == true) return true;

    return false;
  }

  @override
  List<T> execute(List<T> input) {
    final result = List<T>.from(input);

    for (int i = 1; i < result.length; i++) {
      final key = result[i];
      int j = i - 1;

      // Move elements that are greater than key one position ahead
      while (j >= 0 && result[j].compareTo(key) > 0) {
        result[j + 1] = result[j];
        j--;
      }

      result[j + 1] = key;
    }

    return result;
  }
}

/// Generic Heap Sort for any Comparable type.
///
/// Features:
/// - Guaranteed O(n log n) time complexity
/// - In-place sorting with O(1) space complexity
/// - Not stable (relative order may change)
/// - Good worst-case performance
///
/// Best for:
/// - Memory-constrained environments
/// - When worst-case performance guarantees are needed
/// - Large datasets where consistent performance matters
class GenericHeapSort<T extends Comparable<dynamic>>
    extends Strategy<List<T>, List<T>> {
  /// Creates a generic heap sort strategy for type T.
  GenericHeapSort();

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'generic_heap_sort',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: false,
        memoryOverheadBytes: 0,
        description: 'In-place heap sort for any Comparable type',
      );

  @override
  bool canApply(List<T> input, SelectorHint hint) {
    final n = hint.n ?? input.length;

    // Not efficient for very small arrays
    if (n < 10) return false;

    // Excellent when memory is constrained
    if (hint.memoryBudgetBytes != null && hint.memoryBudgetBytes! < 1024) {
      return true;
    }

    // Good when stability is not required
    if (hint.preferStable != true) return true;

    return false;
  }

  @override
  List<T> execute(List<T> input) {
    final result = List<T>.from(input);
    final n = result.length;

    // Build heap (rearrange array)
    for (int i = n ~/ 2 - 1; i >= 0; i--) {
      _heapify(result, n, i);
    }

    // Extract elements from heap one by one
    for (int i = n - 1; i > 0; i--) {
      // Move current root to end
      _swap(result, 0, i);

      // Call heapify on the reduced heap
      _heapify(result, i, 0);
    }

    return result;
  }

  /// Heapify a subtree rooted with node i
  void _heapify(List<T> arr, int n, int i) {
    int largest = i; // Initialize largest as root
    final left = 2 * i + 1;
    final right = 2 * i + 2;

    // If left child is larger than root
    if (left < n && arr[left].compareTo(arr[largest]) > 0) {
      largest = left;
    }

    // If right child is larger than largest so far
    if (right < n && arr[right].compareTo(arr[largest]) > 0) {
      largest = right;
    }

    // If largest is not root
    if (largest != i) {
      _swap(arr, i, largest);

      // Recursively heapify the affected sub-tree
      _heapify(arr, n, largest);
    }
  }

  /// Efficient swap
  void _swap(List<T> arr, int i, int j) {
    if (i != j) {
      final temp = arr[i];
      arr[i] = arr[j];
      arr[j] = temp;
    }
  }
}
