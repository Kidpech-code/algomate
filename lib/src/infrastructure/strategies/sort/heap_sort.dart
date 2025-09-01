import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/time_complexity.dart';
import '../../../domain/value_objects/selector_hint.dart';

/// HeapSort implementation using binary max-heap.
///
/// HeapSort is a comparison-based sorting algorithm that uses a binary heap
/// data structure. It divides input into sorted and unsorted regions and
/// iteratively shrinks the unsorted region by extracting the largest element.
///
/// **Time Complexity:**
/// - Best/Average/Worst: O(n log n) - consistent performance
///
/// **Space Complexity:** O(1) - in-place sorting algorithm
///
/// **Characteristics:**
/// - Not stable (relative order of equal elements may change)
/// - In-place sorting with O(1) extra space
/// - Predictable O(n log n) performance regardless of input
/// - Not cache-friendly due to random memory access patterns
/// - Good for systems requiring guaranteed performance bounds
///
/// **Best Use Cases:**
/// - When consistent O(n log n) performance is required
/// - Memory-constrained environments (true in-place sorting)
/// - Systems where worst-case performance matters more than average case
/// - When stability is not required
class HeapSort extends Strategy<List<int>, List<int>> {
  /// Creates a HeapSort strategy instance.
  HeapSort();

  @override
  AlgoMetadata get meta => const AlgoMetadata(
    name: 'heap_sort',
    timeComplexity: TimeComplexity.oNLogN,
    spaceComplexity: TimeComplexity.o1, // True in-place algorithm
    requiresSorted: false,
    memoryOverheadBytes: 0, // No extra memory needed
    description: 'In-place sorting with guaranteed O(n log n) performance',
  );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final n = hint.n ?? input.length;

    // HeapSort is excellent for memory-constrained environments
    if (hint.memoryBudgetBytes != null && hint.memoryBudgetBytes! < 512) {
      return true; // Perfect for low memory situations
    }

    // Good for medium to large datasets where consistent performance is needed
    if (n >= 100) return true;

    // Not optimal for very small arrays (insertion sort is better)
    if (n < 20) return false;

    return true;
  }

  @override
  List<int> execute(List<int> input) {
    if (input.isEmpty || input.length == 1) return List.from(input);

    final result = List<int>.from(input);
    _heapSort(result);
    return result;
  }

  /// Main HeapSort algorithm implementation.
  ///
  /// 1. Build a max heap from the input array
  /// 2. Repeatedly extract the maximum element and place it at the end
  /// 3. Reduce heap size and re-heapify
  void _heapSort(List<int> arr) {
    final n = arr.length;

    // Step 1: Build max heap (heapify)
    // Start from the last non-leaf node and heapify each node
    for (int i = n ~/ 2 - 1; i >= 0; i--) {
      _heapify(arr, n, i);
    }

    // Step 2: Extract elements from heap one by one
    for (int i = n - 1; i > 0; i--) {
      // Move current root (maximum) to end
      _swap(arr, 0, i);

      // Call heapify on the reduced heap
      _heapify(arr, i, 0);
    }
  }

  /// Maintains the max-heap property for subtree rooted at index [i].
  ///
  /// Assumes that the binary trees rooted at left and right children
  /// of [i] are max-heaps, but [i] might be smaller than its children.
  ///
  /// [arr] - The array representing the heap
  /// [heapSize] - Size of the heap (may be less than array length)
  /// [rootIndex] - Index of the root of subtree to heapify
  void _heapify(List<int> arr, int heapSize, int rootIndex) {
    int largest = rootIndex; // Initialize largest as root
    final leftChild = 2 * rootIndex + 1; // Left child index
    final rightChild = 2 * rootIndex + 2; // Right child index

    // Check if left child exists and is greater than root
    if (leftChild < heapSize && arr[leftChild] > arr[largest]) {
      largest = leftChild;
    }

    // Check if right child exists and is greater than current largest
    if (rightChild < heapSize && arr[rightChild] > arr[largest]) {
      largest = rightChild;
    }

    // If largest is not root, swap and recursively heapify affected subtree
    if (largest != rootIndex) {
      _swap(arr, rootIndex, largest);
      _heapify(arr, heapSize, largest);
    }
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

/// Iterative HeapSort implementation to avoid recursion overhead.
///
/// This variant uses an iterative approach to heapify, which can be
/// more efficient in terms of memory usage and might perform better
/// on systems where function call overhead is significant.
///
/// **Advantages over recursive HeapSort:**
/// - No recursion stack overhead
/// - Better performance on some architectures
/// - More predictable memory usage
/// - Suitable for systems with limited stack space
class IterativeHeapSort extends Strategy<List<int>, List<int>> {
  /// Creates an IterativeHeapSort strategy instance.
  IterativeHeapSort();

  @override
  AlgoMetadata get meta => const AlgoMetadata(
    name: 'iterative_heap_sort',
    timeComplexity: TimeComplexity.oNLogN,
    spaceComplexity: TimeComplexity.o1,
    requiresSorted: false,
    memoryOverheadBytes: 0,
    description: 'Iterative HeapSort with no recursion overhead',
  );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final n = hint.n ?? input.length;

    // Excellent choice for all sizes when memory is very constrained
    if (hint.memoryBudgetBytes != null && hint.memoryBudgetBytes! < 256) {
      return n >= 10; // Only skip very small arrays
    }

    // Good for medium to large datasets
    if (n >= 50) return true;

    // Not optimal for small arrays
    if (n < 15) return false;

    return true;
  }

  @override
  List<int> execute(List<int> input) {
    if (input.isEmpty || input.length == 1) return List.from(input);

    final result = List<int>.from(input);
    _heapSort(result);
    return result;
  }

  /// Iterative HeapSort implementation.
  void _heapSort(List<int> arr) {
    final n = arr.length;

    // Build max heap
    for (int i = n ~/ 2 - 1; i >= 0; i--) {
      _heapifyIterative(arr, n, i);
    }

    // Extract elements from heap
    for (int i = n - 1; i > 0; i--) {
      _swap(arr, 0, i);
      _heapifyIterative(arr, i, 0);
    }
  }

  /// Iterative heapify to maintain max-heap property.
  ///
  /// Uses a loop instead of recursion to heapify the subtree.
  /// This avoids potential stack overflow and reduces overhead.
  void _heapifyIterative(List<int> arr, int heapSize, int startIndex) {
    int current = startIndex;

    while (true) {
      int largest = current;
      final leftChild = 2 * current + 1;
      final rightChild = 2 * current + 2;

      // Find the largest among current, left child, and right child
      if (leftChild < heapSize && arr[leftChild] > arr[largest]) {
        largest = leftChild;
      }

      if (rightChild < heapSize && arr[rightChild] > arr[largest]) {
        largest = rightChild;
      }

      // If current is already largest, heap property is satisfied
      if (largest == current) break;

      // Swap and continue with the affected child
      _swap(arr, current, largest);
      current = largest;
    }
  }

  /// Swaps two elements in the array.
  void _swap(List<int> arr, int i, int j) {
    final temp = arr[i];
    arr[i] = arr[j];
    arr[j] = temp;
  }
}
