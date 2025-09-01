import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';

/// Binary search strategy for finding elements in sorted lists.
///
/// Time complexity: O(log n)
/// Space complexity: O(1)
/// Requires sorted input for correct operation.
class BinarySearchStrategy extends Strategy<List<int>, int?> {
  BinarySearchStrategy(this.target);

  final int target;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'binary_search',
        timeComplexity: TimeComplexity.oLogN,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: true,
        memoryOverheadBytes: 0,
        description: 'Binary search through sorted list',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    // Binary search requires sorted input
    if (input.isEmpty) return false;

    // Only proceed if we're confident the input is sorted
    return hint.sorted == true;
  }

  @override
  int? execute(List<int> input) {
    // Optimized binary search with bit shifting for division
    var left = 0;
    var right = input.length - 1;

    while (left <= right) {
      final mid = left +
          ((right - left) >>
              1); // Equivalent to (left + right) / 2 but avoids overflow
      final midValue = input[mid];

      if (midValue == target) {
        return mid;
      } else if (midValue < target) {
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
      (other is BinarySearchStrategy && other.target == target);

  @override
  int get hashCode => Object.hash(meta.name, target);

  @override
  String toString() => 'BinarySearchStrategy(target: $target)';
}

/// Binary search with bounds checking and debug assertions.
class SafeBinarySearchStrategy extends Strategy<List<int>, int?> {
  SafeBinarySearchStrategy(this.target);

  final int target;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'safe_binary_search',
        timeComplexity: TimeComplexity.oLogN,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: true,
        memoryOverheadBytes: 0,
        description: 'Binary search with safety checks and assertions',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    if (input.isEmpty) return false;

    // Be more conservative and verify sorting in debug mode
    assert(_isSorted(input), 'Input must be sorted for binary search');

    return hint.sorted == true;
  }

  @override
  int? execute(List<int> input) {
    if (input.isEmpty) return null;

    var left = 0;
    var right = input.length - 1;

    while (left <= right) {
      final mid = left + ((right - left) >> 1);
      final midValue = input[mid];

      if (midValue == target) {
        return mid;
      } else if (midValue < target) {
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }

    return null;
  }

  /// Verify that the input list is sorted (used in debug assertions).
  bool _isSorted(List<int> list) {
    for (var i = 1; i < list.length; i++) {
      if (list[i] < list[i - 1]) {
        return false;
      }
    }
    return true;
  }
}

/// Generic binary search that finds the insertion point for a target.
class BinarySearchInsertionStrategy extends Strategy<List<int>, int> {
  BinarySearchInsertionStrategy(this.target);

  final int target;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'binary_search_insertion',
        timeComplexity: TimeComplexity.oLogN,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: true,
        memoryOverheadBytes: 0,
        description: 'Binary search to find insertion point',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    // Can work with empty lists (insertion at index 0)
    return hint.sorted != false; // Accept null or true
  }

  @override
  int execute(List<int> input) {
    var left = 0;
    var right = input.length;

    while (left < right) {
      final mid = left + ((right - left) >> 1);

      if (input[mid] < target) {
        left = mid + 1;
      } else {
        right = mid;
      }
    }

    return left; // Insertion point
  }
}
