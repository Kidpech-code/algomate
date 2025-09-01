import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';

/// Heap Sort algorithm implementation.
///
/// Features:
/// - Guaranteed O(n log n) time complexity (no worst-case issues)
/// - In-place sorting with O(1) space complexity
/// - Not stable (relative order of equal elements may change)
/// - Good cache performance compared to QuickSort
///
/// Best for: When consistent performance is needed, memory-constrained
/// environments, when worst-case performance matters more than average case.
///
/// Avoid for: When stability is required, very small datasets (use insertion sort).
class HeapSort extends Strategy<List<int>, List<int>> {
  static const int _insertionSortThreshold = 15;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'heap_sort',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: false,
        memoryOverheadBytes: 0, // In-place algorithm
        description:
            'Guaranteed O(n log n) in-place sorting with consistent performance',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final size = hint.n ?? input.length;

    // Not efficient for very small arrays
    if (size < _insertionSortThreshold) return false;

    // Excellent when consistent performance is needed
    // Good for memory-constrained environments
    return true;
  }

  @override
  List<int> execute(List<int> input) {
    if (input.isEmpty) return [];

    final result = List<int>.from(input);
    _heapSort(result);
    return result;
  }

  /// Main heap sort implementation
  void _heapSort(List<int> arr) {
    final n = arr.length;

    // Build max heap from bottom up
    for (int i = n ~/ 2 - 1; i >= 0; i--) {
      _heapify(arr, n, i);
    }

    // Extract elements from heap one by one
    for (int i = n - 1; i > 0; i--) {
      // Move current root to end
      _swap(arr, 0, i);

      // Restore heap property for reduced heap
      _heapify(arr, i, 0);
    }
  }

  /// Heapify a subtree rooted at index i
  /// n is size of heap
  void _heapify(List<int> arr, int n, int i) {
    int largest = i; // Initialize largest as root
    final int left = 2 * i + 1; // left child
    final int right = 2 * i + 2; // right child

    // If left child is larger than root
    if (left < n && arr[left] > arr[largest]) {
      largest = left;
    }

    // If right child is larger than largest so far
    if (right < n && arr[right] > arr[largest]) {
      largest = right;
    }

    // If largest is not root
    if (largest != i) {
      _swap(arr, i, largest);

      // Recursively heapify the affected sub-tree
      _heapify(arr, n, largest);
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

/// Optimized HeapSort with iterative heapify to avoid recursion overhead
class OptimizedHeapSort extends Strategy<List<int>, List<int>> {
  static const int _insertionSortThreshold = 15;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'optimized_heap_sort',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: false,
        memoryOverheadBytes: 0,
        description: 'Heap sort with iterative heapify for better performance',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final size = hint.n ?? input.length;

    // Not efficient for very small arrays
    if (size < _insertionSortThreshold) return false;

    // Good for large datasets where consistent performance matters
    return size > 100;
  }

  @override
  List<int> execute(List<int> input) {
    if (input.isEmpty) return [];

    final result = List<int>.from(input);
    _heapSort(result);
    return result;
  }

  /// Heap sort with iterative heapify
  void _heapSort(List<int> arr) {
    final n = arr.length;

    // Build max heap
    _buildMaxHeap(arr);

    // Extract elements from heap one by one
    for (int i = n - 1; i > 0; i--) {
      // Move current root to end
      _swap(arr, 0, i);

      // Restore heap property iteratively
      _iterativeHeapify(arr, i, 0);
    }
  }

  /// Build max heap using Floyd's method
  void _buildMaxHeap(List<int> arr) {
    final n = arr.length;
    // Start from the last non-leaf node and heapify all nodes
    for (int i = n ~/ 2 - 1; i >= 0; i--) {
      _iterativeHeapify(arr, n, i);
    }
  }

  /// Iterative heapify to avoid recursion overhead
  void _iterativeHeapify(List<int> arr, int heapSize, int rootIndex) {
    int current = rootIndex;

    while (true) {
      int largest = current;
      final left = 2 * current + 1;
      final right = 2 * current + 2;

      // Find the largest among root, left child and right child
      if (left < heapSize && arr[left] > arr[largest]) {
        largest = left;
      }

      if (right < heapSize && arr[right] > arr[largest]) {
        largest = right;
      }

      // If largest is still the current node, heap property is satisfied
      if (largest == current) {
        break;
      }

      // Otherwise, swap and continue with the child
      _swap(arr, current, largest);
      current = largest;
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

/// MinHeap-based HeapSort (for descending order or educational purposes)
class MinHeapSort extends Strategy<List<int>, List<int>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'min_heap_sort',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: false,
        memoryOverheadBytes: 0,
        description: 'Min-heap based sorting (ascending order)',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final size = hint.n ?? input.length;
    return size >= 15; // Only for medium to large datasets
  }

  @override
  List<int> execute(List<int> input) {
    if (input.isEmpty) return [];

    final result = List<int>.from(input);
    _minHeapSort(result);
    return result;
  }

  /// Min heap sort implementation
  void _minHeapSort(List<int> arr) {
    final n = arr.length;

    // Build min heap
    for (int i = n ~/ 2 - 1; i >= 0; i--) {
      _minHeapify(arr, n, i);
    }

    // Extract elements from heap one by one
    for (int i = n - 1; i > 0; i--) {
      // Move current root (minimum) to end
      _swap(arr, 0, i);

      // Restore min heap property
      _minHeapify(arr, i, 0);
    }

    // Reverse the array to get ascending order
    _reverse(arr);
  }

  /// Min heapify a subtree rooted at index i
  void _minHeapify(List<int> arr, int n, int i) {
    int smallest = i;
    final left = 2 * i + 1;
    final right = 2 * i + 2;

    if (left < n && arr[left] < arr[smallest]) {
      smallest = left;
    }

    if (right < n && arr[right] < arr[smallest]) {
      smallest = right;
    }

    if (smallest != i) {
      _swap(arr, i, smallest);
      _minHeapify(arr, n, smallest);
    }
  }

  /// Reverse array in-place
  void _reverse(List<int> arr) {
    int left = 0;
    int right = arr.length - 1;

    while (left < right) {
      _swap(arr, left, right);
      left++;
      right--;
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
