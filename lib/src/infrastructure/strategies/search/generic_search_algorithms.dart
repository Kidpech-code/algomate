import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';

/// Generic Binary Search for any Comparable type.
///
/// This implementation provides:
/// - Type-safe searching for any `T` that implements `Comparable<T>`
/// - O(log n) time complexity for sorted data
/// - O(1) space complexity
/// - Returns the index of the found element or null if not found
///
/// Perfect for:
/// - Custom objects like Person, Product, Transaction
/// - DateTime, String, or other built-in Comparable types
/// - Large sorted datasets where fast lookup is needed
/// - When you need to find specific elements efficiently
///
/// Usage example:
/// ```dart
/// class Product implements Comparable<Product> {
///   final String name;
///   final double price;
///
///   Product(this.name, this.price);
///
///   @override
///   int compareTo(Product other) => price.compareTo(other.price);
/// }
///
/// final strategy = GenericBinarySearch<Product>(Product('Target', 99.99));
/// final products = [Product('A', 50), Product('B', 100), Product('C', 150)];
/// final index = strategy.execute(products); // Returns index or null
/// ```
class GenericBinarySearch<T extends Comparable<dynamic>>
    extends Strategy<List<T>, int?> {
  /// Creates a generic binary search strategy for type T.
  GenericBinarySearch(this.target);

  /// The target value to search for
  final T target;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'generic_binary_search',
        timeComplexity: TimeComplexity.oLogN,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: true,
        memoryOverheadBytes: 0,
        description: 'Binary search for any Comparable type',
      );

  @override
  bool canApply(List<T> input, SelectorHint hint) {
    if (input.isEmpty) return false;

    // Binary search requires sorted input
    if (hint.sorted != true) return false;

    return true;
  }

  @override
  int? execute(List<T> input) {
    var left = 0;
    var right = input.length - 1;

    while (left <= right) {
      final mid = left + ((right - left) >> 1);
      final comparison = input[mid].compareTo(target);

      if (comparison == 0) {
        return mid; // Found
      } else if (comparison < 0) {
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }

    return null; // Not found
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GenericBinarySearch<T> && other.target == target);

  @override
  int get hashCode => Object.hash(meta.name, target);

  @override
  String toString() => 'GenericBinarySearch<$T>(target: $target)';
}

/// Generic Linear Search for any type with custom equality check.
///
/// Features:
/// - Works with any type T
/// - Uses custom equality function for flexible matching
/// - O(n) time complexity
/// - Works with unsorted data
/// - Early termination when element is found
///
/// Perfect for:
/// - Custom objects with complex equality logic
/// - When data is unsorted
/// - Small to medium datasets
/// - When you need custom search criteria
///
/// Usage example:
/// ```dart
/// class Person {
///   final String name;
///   final int age;
///   Person(this.name, this.age);
/// }
///
/// final strategy = GenericLinearSearch<Person>(
///   Person('Alice', 30),
///   (a, b) => a.name == b.name, // Custom equality
/// );
/// final people = [Person('Bob', 25), Person('Alice', 30)];
/// final index = strategy.execute(people); // Returns 1
/// ```
class GenericLinearSearch<T> extends Strategy<List<T>, int?> {
  /// Creates a generic linear search strategy for type T.
  GenericLinearSearch(this.target, [this.equalityCheck]);

  /// The target value to search for
  final T target;

  /// Custom equality check function. If null, uses == operator
  final bool Function(T a, T b)? equalityCheck;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'generic_linear_search',
        timeComplexity: TimeComplexity.oN,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: false,
        memoryOverheadBytes: 0,
        description: 'Linear search for any type with custom equality',
      );

  @override
  bool canApply(List<T> input, SelectorHint hint) {
    return input.isNotEmpty;
  }

  @override
  int? execute(List<T> input) {
    final checker = equalityCheck ?? (a, b) => a == b;

    for (var i = 0; i < input.length; i++) {
      if (checker(input[i], target)) {
        return i;
      }
    }

    return null; // Not found
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GenericLinearSearch<T> && other.target == target);

  @override
  int get hashCode => Object.hash(meta.name, target);

  @override
  String toString() => 'GenericLinearSearch<$T>(target: $target)';
}

/// Generic Search that returns the insertion point for binary search.
///
/// Features:
/// - Finds where an element should be inserted to maintain sort order
/// - O(log n) time complexity for sorted data
/// - Returns index where element should be inserted
/// - Perfect for maintaining sorted collections
///
/// Usage example:
/// ```dart
/// final strategy = GenericBinarySearchInsertion<int>(25);
/// final sorted = [10, 20, 30, 40];
/// final insertAt = strategy.execute(sorted); // Returns 2
/// // Insert 25 at index 2 to keep array sorted
/// ```
class GenericBinarySearchInsertion<T extends Comparable<dynamic>>
    extends Strategy<List<T>, int> {
  /// Creates a generic binary search insertion strategy for type T.
  GenericBinarySearchInsertion(this.target);

  /// The target value to find insertion point for
  final T target;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'generic_binary_search_insertion',
        timeComplexity: TimeComplexity.oLogN,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: true,
        memoryOverheadBytes: 0,
        description: 'Find insertion point for any Comparable type',
      );

  @override
  bool canApply(List<T> input, SelectorHint hint) {
    // Can work with empty lists (insertion at index 0)
    return hint.sorted != false; // Accept null or true
  }

  @override
  int execute(List<T> input) {
    var left = 0;
    var right = input.length;

    while (left < right) {
      final mid = left + ((right - left) >> 1);

      if (input[mid].compareTo(target) < 0) {
        left = mid + 1;
      } else {
        right = mid;
      }
    }

    return left; // Insertion point
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GenericBinarySearchInsertion<T> && other.target == target);

  @override
  int get hashCode => Object.hash(meta.name, target);

  @override
  String toString() => 'GenericBinarySearchInsertion<$T>(target: $target)';
}

/// Generic search that finds all occurrences of a target.
///
/// Features:
/// - Returns list of all indices where target is found
/// - O(n) time complexity
/// - Works with unsorted data
/// - Supports custom equality checking
///
/// Perfect for:
/// - Finding all duplicate elements
/// - Multi-match scenarios
/// - When you need all occurrences, not just the first one
class GenericLinearSearchAll<T> extends Strategy<List<T>, List<int>> {
  /// Creates a search strategy that finds all occurrences.
  GenericLinearSearchAll(this.target, [this.equalityCheck]);

  /// The target value to search for
  final T target;

  /// Custom equality check function. If null, uses == operator
  final bool Function(T a, T b)? equalityCheck;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'generic_linear_search_all',
        timeComplexity: TimeComplexity.oN,
        spaceComplexity: TimeComplexity.oN, // Could return up to n indices
        requiresSorted: false,
        memoryOverheadBytes: 0, // Dynamic based on matches found
        description: 'Find all occurrences of target in list',
      );

  @override
  bool canApply(List<T> input, SelectorHint hint) {
    return input.isNotEmpty;
  }

  @override
  List<int> execute(List<T> input) {
    final checker = equalityCheck ?? (a, b) => a == b;
    final results = <int>[];

    for (var i = 0; i < input.length; i++) {
      if (checker(input[i], target)) {
        results.add(i);
      }
    }

    return results;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GenericLinearSearchAll<T> && other.target == target);

  @override
  int get hashCode => Object.hash(meta.name, target);

  @override
  String toString() => 'GenericLinearSearchAll<$T>(target: $target)';
}

/// Generic search with predicate function for complex filtering.
///
/// Features:
/// - Uses custom predicate function for matching
/// - Returns first matching index or null
/// - O(n) time complexity
/// - Extremely flexible matching criteria
///
/// Usage example:
/// ```dart
/// class Employee {
///   final String name;
///   final String department;
///   final double salary;
///   Employee(this.name, this.department, this.salary);
/// }
///
/// final strategy = GenericPredicateSearch<Employee>(
///   (employee) => employee.department == 'Engineering' && employee.salary > 100000
/// );
/// final employees = [/* ... */];
/// final index = strategy.execute(employees); // First high-paid engineer
/// ```
class GenericPredicateSearch<T> extends Strategy<List<T>, int?> {
  /// Creates a predicate-based search strategy.
  GenericPredicateSearch(this.predicate);

  /// The predicate function that returns true for matching elements
  final bool Function(T element) predicate;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'generic_predicate_search',
        timeComplexity: TimeComplexity.oN,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: false,
        memoryOverheadBytes: 0,
        description: 'Search with custom predicate function',
      );

  @override
  bool canApply(List<T> input, SelectorHint hint) {
    return input.isNotEmpty;
  }

  @override
  int? execute(List<T> input) {
    for (var i = 0; i < input.length; i++) {
      if (predicate(input[i])) {
        return i;
      }
    }

    return null; // Not found
  }

  @override
  String toString() => 'GenericPredicateSearch<$T>(predicate: $predicate)';
}
