import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';

/// Linear search strategy for finding elements in unsorted lists.
///
/// Time complexity: O(n)
/// Space complexity: O(1)
/// Works with unsorted data and provides early termination.
class LinearSearchStrategy extends Strategy<List<int>, int?> {
  LinearSearchStrategy(this.target);

  final int target;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'linear_search',
        timeComplexity: TimeComplexity.oN,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: false,
        memoryOverheadBytes: 0,
        description: 'Linear search through unsorted list',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    // Linear search works with any input
    return input.isNotEmpty;
  }

  @override
  int? execute(List<int> input) {
    // Optimized loop for performance
    for (var i = 0; i < input.length; i++) {
      if (input[i] == target) {
        return i;
      }
    }
    return null; // Not found
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinearSearchStrategy && other.target == target);

  @override
  int get hashCode => Object.hash(meta.name, target);

  @override
  String toString() => 'LinearSearchStrategy(target: $target)';
}

/// Generic linear search strategy that can be configured with different targets.
class ConfigurableLinearSearchStrategy
    extends ConfigurableStrategy<List<int>, int?, int> {
  ConfigurableLinearSearchStrategy(super.config);

  /// The target value to search for
  int get target => config;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'configurable_linear_search',
        timeComplexity: TimeComplexity.oN,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: false,
        memoryOverheadBytes: 0,
        description: 'Configurable linear search through unsorted list',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    return input.isNotEmpty;
  }

  @override
  int? execute(List<int> input) {
    for (var i = 0; i < input.length; i++) {
      if (input[i] == target) {
        return i;
      }
    }
    return null;
  }

  @override
  ConfigurableLinearSearchStrategy withConfig(int newConfig) {
    return ConfigurableLinearSearchStrategy(newConfig);
  }
}

/// Linear search strategy with execution statistics.
class LinearSearchWithStatsStrategy extends Strategy<List<int>, int?>
    with ExecutionStats<List<int>, int?> {
  LinearSearchWithStatsStrategy(this.target);

  final int target;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'linear_search_with_stats',
        timeComplexity: TimeComplexity.oN,
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: false,
        memoryOverheadBytes: 0,
        description: 'Linear search with execution statistics',
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    return input.isNotEmpty;
  }

  @override
  int? execute(List<int> input) {
    for (var i = 0; i < input.length; i++) {
      if (input[i] == target) {
        return i;
      }
    }
    return null;
  }
}
