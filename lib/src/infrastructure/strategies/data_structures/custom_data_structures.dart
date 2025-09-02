import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';

/// Custom data structure: Priority Queue (Min-Heap implementation)
///
/// Features:
/// - Generic type support for any Comparable<T>
/// - O(log n) insertion and extraction
/// - O(1) peek operation
/// - Automatic ordering based on priority (lowest first)
///
/// Usage:
/// ```dart
/// final pq = PriorityQueue<int>();
/// pq.add(5);
/// pq.add(3);
/// pq.add(8);
/// print(pq.removeMin()); // 3
/// ```
class PriorityQueue<T extends Comparable<dynamic>> {
  final List<T> _heap = [];

  /// Check if the queue is empty
  bool get isEmpty => _heap.isEmpty;

  /// Get the number of elements
  int get length => _heap.length;

  /// Peek at the minimum element without removing it
  T? get min => _heap.isEmpty ? null : _heap.first;

  /// Add an element to the priority queue
  void add(T element) {
    _heap.add(element);
    _bubbleUp(_heap.length - 1);
  }

  /// Remove and return the minimum element
  T? removeMin() {
    if (_heap.isEmpty) return null;

    if (_heap.length == 1) {
      return _heap.removeLast();
    }

    final min = _heap.first;
    _heap[0] = _heap.removeLast();
    _bubbleDown(0);
    return min;
  }

  /// Convert to sorted list (destructive operation)
  List<T> toSortedList() {
    final result = <T>[];
    while (!isEmpty) {
      final min = removeMin();
      if (min != null) result.add(min);
    }
    return result;
  }

  /// Bubble up operation to maintain heap property
  void _bubbleUp(int index) {
    if (index <= 0) return;

    final parentIndex = (index - 1) ~/ 2;
    if (_heap[index].compareTo(_heap[parentIndex]) < 0) {
      _swap(index, parentIndex);
      _bubbleUp(parentIndex);
    }
  }

  /// Bubble down operation to maintain heap property
  void _bubbleDown(int index) {
    final leftChild = 2 * index + 1;
    final rightChild = 2 * index + 2;
    int smallest = index;

    if (leftChild < _heap.length &&
        _heap[leftChild].compareTo(_heap[smallest]) < 0) {
      smallest = leftChild;
    }

    if (rightChild < _heap.length &&
        _heap[rightChild].compareTo(_heap[smallest]) < 0) {
      smallest = rightChild;
    }

    if (smallest != index) {
      _swap(index, smallest);
      _bubbleDown(smallest);
    }
  }

  /// Swap two elements in the heap
  void _swap(int i, int j) {
    final temp = _heap[i];
    _heap[i] = _heap[j];
    _heap[j] = temp;
  }

  @override
  String toString() => 'PriorityQueue($_heap)';
}

/// Custom data structure: Binary Search Tree
///
/// Features:
/// - Generic type support for any Comparable<T>
/// - O(log n) average case for insertion, deletion, and search
/// - In-order traversal gives sorted order
/// - Supports duplicate values
///
/// Note: This is a simple BST without self-balancing
class BinarySearchTree<T extends Comparable<dynamic>> {
  BSTNode<T>? _root;

  /// Check if the tree is empty
  bool get isEmpty => _root == null;

  /// Insert a value into the tree
  void insert(T value) {
    _root = _insertRecursive(_root, value);
  }

  /// Search for a value in the tree
  bool contains(T value) {
    return _searchRecursive(_root, value);
  }

  /// Get all values in sorted order (in-order traversal)
  List<T> toSortedList() {
    final result = <T>[];
    _inOrderTraversal(_root, result);
    return result;
  }

  /// Get the minimum value
  T? get min {
    final node = _findMin(_root);
    return node?.value;
  }

  /// Get the maximum value
  T? get max {
    final node = _findMax(_root);
    return node?.value;
  }

  /// Recursive insertion
  BSTNode<T> _insertRecursive(BSTNode<T>? node, T value) {
    if (node == null) {
      return BSTNode(value);
    }

    if (value.compareTo(node.value) <= 0) {
      node.left = _insertRecursive(node.left, value);
    } else {
      node.right = _insertRecursive(node.right, value);
    }

    return node;
  }

  /// Recursive search
  bool _searchRecursive(BSTNode<T>? node, T value) {
    if (node == null) return false;

    final comparison = value.compareTo(node.value);
    if (comparison == 0) return true;

    return comparison < 0
        ? _searchRecursive(node.left, value)
        : _searchRecursive(node.right, value);
  }

  /// In-order traversal for sorted output
  void _inOrderTraversal(BSTNode<T>? node, List<T> result) {
    if (node == null) return;

    _inOrderTraversal(node.left, result);
    result.add(node.value);
    _inOrderTraversal(node.right, result);
  }

  /// Find minimum node
  BSTNode<T>? _findMin(BSTNode<T>? node) {
    if (node == null) return null;
    while (node!.left != null) {
      node = node.left;
    }
    return node;
  }

  /// Find maximum node
  BSTNode<T>? _findMax(BSTNode<T>? node) {
    if (node == null) return null;
    while (node!.right != null) {
      node = node.right;
    }
    return node;
  }

  @override
  String toString() {
    if (isEmpty) return 'BST()';
    return 'BST(${toSortedList()})';
  }
}

/// Node for Binary Search Tree
class BSTNode<T extends Comparable<dynamic>> {
  BSTNode(this.value);
  T value;
  BSTNode<T>? left;
  BSTNode<T>? right;

  @override
  String toString() => 'BSTNode($value)';
}

/// Strategy for sorting using Priority Queue (Heap Sort variation)
class PriorityQueueSort<T extends Comparable<dynamic>>
    extends Strategy<List<T>, List<T>> {
  PriorityQueueSort();

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'priority_queue_sort',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.oN,
        requiresSorted: false,
        memoryOverheadBytes: 0, // Dynamic based on input size
        description: 'Sort using priority queue (min-heap)',
      );

  @override
  bool canApply(List<T> input, SelectorHint hint) {
    final n = hint.n ?? input.length;

    // Good for medium datasets when you need guaranteed O(n log n)
    if (n >= 100 && n <= 10000) return true;

    // Excellent when you need stable performance
    return hint.preferStable != false;
  }

  @override
  List<T> execute(List<T> input) {
    final pq = PriorityQueue<T>();

    // Add all elements to priority queue
    for (final element in input) {
      pq.add(element);
    }

    // Extract in sorted order
    return pq.toSortedList();
  }

  @override
  String toString() => 'PriorityQueueSort<$T>()';
}

/// Strategy for sorting using Binary Search Tree
class BinarySearchTreeSort<T extends Comparable<dynamic>>
    extends Strategy<List<T>, List<T>> {
  BinarySearchTreeSort();

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'binary_search_tree_sort',
        timeComplexity: TimeComplexity.oNLogN, // Average case
        spaceComplexity: TimeComplexity.oN,
        requiresSorted: false,
        memoryOverheadBytes: 0, // Dynamic based on tree structure
        description: 'Sort using binary search tree in-order traversal',
      );

  @override
  bool canApply(List<T> input, SelectorHint hint) {
    final n = hint.n ?? input.length;

    // BST sort is good for medium datasets
    if (n < 50 || n > 5000) return false;

    // Not efficient if data is already sorted (degenerates to linked list)
    if (hint.sorted == true) return false;

    // Good when you need the tree structure for other operations
    return true;
  }

  @override
  List<T> execute(List<T> input) {
    final bst = BinarySearchTree<T>();

    // Insert all elements into BST
    for (final element in input) {
      bst.insert(element);
    }

    // Return in-order traversal (sorted order)
    return bst.toSortedList();
  }

  @override
  String toString() => 'BinarySearchTreeSort<$T>()';
}

/// Strategy for searching in Priority Queue
class PriorityQueueSearch<T extends Comparable<dynamic>>
    extends Strategy<PriorityQueue<T>, T?> {
  PriorityQueueSearch(this.target);

  final T target;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'priority_queue_search',
        timeComplexity: TimeComplexity.oN, // Need to check all elements
        spaceComplexity: TimeComplexity.oN, // Need to copy for search
        requiresSorted: false,
        memoryOverheadBytes: 0,
        description: 'Search for element in priority queue',
      );

  @override
  bool canApply(PriorityQueue<T> input, SelectorHint hint) {
    return !input.isEmpty;
  }

  @override
  T? execute(PriorityQueue<T> input) {
    // Convert to list to search (preserves original queue)
    final tempQueue = PriorityQueue<T>();
    final elements = <T>[];

    // Extract all elements
    while (!input.isEmpty) {
      final element = input.removeMin()!;
      elements.add(element);
      tempQueue.add(element);
    }

    // Restore original queue
    for (final element in elements) {
      input.add(element);
    }

    // Search for target
    for (final element in elements) {
      if (element.compareTo(target) == 0) {
        return element;
      }
    }

    return null;
  }

  @override
  String toString() => 'PriorityQueueSearch<$T>(target: $target)';
}

/// Strategy for searching in Binary Search Tree
class BinarySearchTreeSearch<T extends Comparable<dynamic>>
    extends Strategy<BinarySearchTree<T>, bool> {
  BinarySearchTreeSearch(this.target);

  final T target;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'binary_search_tree_search',
        timeComplexity: TimeComplexity.oLogN, // Average case
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: false, // BST maintains its own ordering
        memoryOverheadBytes: 0,
        description: 'Search for element in binary search tree',
      );

  @override
  bool canApply(BinarySearchTree<T> input, SelectorHint hint) {
    return !input.isEmpty;
  }

  @override
  bool execute(BinarySearchTree<T> input) {
    return input.contains(target);
  }

  @override
  String toString() => 'BinarySearchTreeSearch<$T>(target: $target)';
}

/// Custom data structure: Circular Buffer (Ring Buffer)
///
/// Features:
/// - Fixed-size buffer with automatic wraparound
/// - O(1) insertion and removal
/// - Memory efficient for streaming data
/// - Overwrites oldest data when full
class CircularBuffer<T> {
  /// Create a circular buffer with given capacity
  CircularBuffer(int capacity) {
    _capacity = capacity;
    _buffer = List<T?>.filled(capacity, null);
  }
  late List<T?> _buffer;
  int _head = 0;
  int _tail = 0;
  int _size = 0;
  late int _capacity;

  /// Check if buffer is empty
  bool get isEmpty => _size == 0;

  /// Check if buffer is full
  bool get isFull => _size == _capacity;

  /// Get current number of elements
  int get length => _size;

  /// Get buffer capacity
  int get capacity => _capacity;

  /// Add element to buffer (overwrites oldest if full)
  void add(T element) {
    _buffer[_tail] = element;
    _tail = (_tail + 1) % _capacity;

    if (_size < _capacity) {
      _size++;
    } else {
      // Buffer is full, move head forward
      _head = (_head + 1) % _capacity;
    }
  }

  /// Remove and return oldest element
  T? removeFirst() {
    if (isEmpty) return null;

    final element = _buffer[_head];
    _buffer[_head] = null;
    _head = (_head + 1) % _capacity;
    _size--;

    return element;
  }

  /// Peek at oldest element without removing
  T? get first => isEmpty ? null : _buffer[_head];

  /// Peek at newest element without removing
  T? get last => isEmpty ? null : _buffer[(_tail - 1 + _capacity) % _capacity];

  /// Convert to list (oldest to newest)
  List<T> toList() {
    final result = <T>[];
    for (int i = 0; i < _size; i++) {
      final index = (_head + i) % _capacity;
      final element = _buffer[index];
      if (element != null) result.add(element);
    }
    return result;
  }

  /// Clear all elements
  void clear() {
    _buffer = List<T?>.filled(_capacity, null);
    _head = 0;
    _tail = 0;
    _size = 0;
  }

  @override
  String toString() => 'CircularBuffer(${toList()})';
}

/// Strategy for searching in Circular Buffer
class CircularBufferSearch<T> extends Strategy<CircularBuffer<T>, int?> {
  CircularBufferSearch(this.target, [this.equalityCheck]);

  final T target;
  final bool Function(T a, T b)? equalityCheck;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'circular_buffer_search',
        timeComplexity: TimeComplexity.oN,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: false,
        memoryOverheadBytes: 0,
        description: 'Search for element in circular buffer',
      );

  @override
  bool canApply(CircularBuffer<T> input, SelectorHint hint) {
    return !input.isEmpty;
  }

  @override
  int? execute(CircularBuffer<T> input) {
    final checker = equalityCheck ?? (a, b) => a == b;
    final elements = input.toList();

    for (var i = 0; i < elements.length; i++) {
      if (checker(elements[i], target)) {
        return i;
      }
    }

    return null;
  }

  @override
  String toString() => 'CircularBufferSearch<$T>(target: $target)';
}
