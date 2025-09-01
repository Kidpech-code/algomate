import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';

/// Insertion sort strategy optimized for small datasets.
///
/// Time complexity: O(n²) worst case, O(n) best case (sorted)
/// Space complexity: O(1)
/// Stable sort that works well for small lists.
class InsertionSortStrategy extends Strategy<List<int>, List<int>> {
  InsertionSortStrategy();

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'insertion_sort',
        timeComplexity: TimeComplexity.oN2,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: false,
        memoryOverheadBytes: 0,
        description: 'Stable insertion sort, efficient for small lists',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final n = hint.n ?? input.length;

    // Always available for small datasets
    if (n <= 50) return true;

    // For larger datasets, only use if there are strict memory constraints
    if (hint.memoryBudgetBytes != null && hint.memoryBudgetBytes! < 2048) {
      return true; // Fall back to in-place sorting when memory is very limited
    }

    return false; // Otherwise let more efficient algorithms handle large data
  }

  @override
  List<int> execute(List<int> input) {
    // Create a copy to avoid modifying the original list
    final result = List<int>.from(input);

    // Optimized insertion sort
    for (var i = 1; i < result.length; i++) {
      final key = result[i];
      var j = i - 1;

      // Shift elements that are greater than key to one position ahead
      while (j >= 0 && result[j] > key) {
        result[j + 1] = result[j];
        j--;
      }

      result[j + 1] = key;
    }

    return result;
  }

  @override
  bool operator ==(Object other) => other is InsertionSortStrategy;

  @override
  int get hashCode => meta.name.hashCode;

  @override
  String toString() => 'InsertionSortStrategy()';
}

/// In-place insertion sort strategy that modifies the input list.
class InPlaceInsertionSortStrategy extends Strategy<List<int>, List<int>> {
  InPlaceInsertionSortStrategy();

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'in_place_insertion_sort',
        timeComplexity: TimeComplexity.oN2,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: false,
        memoryOverheadBytes: 0,
        description: 'In-place insertion sort, modifies original list',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final n = hint.n ?? input.length;

    // Always available for small to medium datasets
    if (n <= 100) return true;

    // For larger datasets, use when memory is extremely constrained
    if (hint.memoryBudgetBytes != null && hint.memoryBudgetBytes! < 2048) {
      return true; // In-place sorting is the best option for severe memory limits
    }

    return false;
  }

  @override
  List<int> execute(List<int> input) {
    // Sort in-place for memory efficiency
    for (var i = 1; i < input.length; i++) {
      final key = input[i];
      var j = i - 1;

      while (j >= 0 && input[j] > key) {
        input[j + 1] = input[j];
        j--;
      }

      input[j + 1] = key;
    }

    return input; // Return the same list (now sorted)
  }
}

/// Binary insertion sort that uses binary search to find insertion point.
class BinaryInsertionSortStrategy extends Strategy<List<int>, List<int>> {
  BinaryInsertionSortStrategy();

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'binary_insertion_sort',
        timeComplexity: TimeComplexity.oN2, // Still O(n²) due to shifting
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: false,
        memoryOverheadBytes: 0,
        description: 'Insertion sort with binary search for insertion point',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    final n = hint.n ?? input.length;
    // Binary insertion sort has better comparison complexity but same shifting cost
    // Useful for data where comparisons are expensive
    return n <= 64;
  }

  @override
  List<int> execute(List<int> input) {
    final result = List<int>.from(input);

    for (var i = 1; i < result.length; i++) {
      final key = result[i];

      // Binary search to find insertion point
      var left = 0;
      var right = i;

      while (left < right) {
        final mid = left + ((right - left) >> 1);
        if (result[mid] <= key) {
          left = mid + 1;
        } else {
          right = mid;
        }
      }

      // Shift elements to make room for insertion
      for (var j = i; j > left; j--) {
        result[j] = result[j - 1];
      }

      result[left] = key;
    }

    return result;
  }
}
