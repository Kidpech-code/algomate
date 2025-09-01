import '../entities/strategy.dart';
import '../value_objects/selector_hint.dart';
import '../value_objects/time_complexity.dart';
import 'complexity_ranker.dart';

/// Pure function service for ranking strategy candidates based on hints and heuristics.
///
/// Implements intelligent selection policies that consider dataset characteristics,
/// memory constraints, and performance trade-offs.
class SelectorPolicy {
  const SelectorPolicy({
    this.smallNThreshold = 32,
    this.complexityRanker = const ComplexityRanker(),
    this.memoryWeight = 0.1,
    this.stabilityWeight = 0.05,
  });

  /// Create a policy optimized for small datasets
  factory SelectorPolicy.forSmallData() {
    return SelectorPolicy(
      smallNThreshold: 50, // Increased threshold for small data benefits
      complexityRanker: ComplexityRanker.favorSimple(),
      memoryWeight: 0.05, // Less concern about memory for small data
    );
  }

  /// Create a policy optimized for large datasets
  factory SelectorPolicy.forLargeData() {
    return SelectorPolicy(
      smallNThreshold: 16, // Smaller threshold, large data needs efficiency
      complexityRanker: ComplexityRanker.favorScalable(),
      memoryWeight: 0.2, // More concern about memory for large data
    );
  }

  /// Create a policy optimized for memory-constrained environments
  factory SelectorPolicy.memoryConstrained() {
    return const SelectorPolicy(
      smallNThreshold: 32,
      memoryWeight: 0.3, // Heavy penalty for memory usage
      stabilityWeight: 0.02, // Less concern about stability vs memory
    );
  }

  /// Threshold below which simple algorithms are often faster despite higher Big-O
  final int smallNThreshold;

  /// Service for ranking time complexities
  final ComplexityRanker complexityRanker;

  /// Weight factor for memory overhead in ranking (0.0 to 1.0)
  final double memoryWeight;

  /// Weight factor for algorithm stability preference (0.0 to 1.0)
  final double stabilityWeight;

  /// Rank strategies from best to worst based on hint and heuristics.
  ///
  /// The ranking considers:
  /// 1. Time complexity appropriateness for dataset size
  /// 2. Memory constraints and overhead
  /// 3. Stability preferences
  /// 4. Special optimizations (e.g., sorted data)
  ///
  /// Returns a new sorted list without modifying the input.
  List<Strategy<I, O>> rank<I, O>(List<Strategy<I, O>> candidates, SelectorHint hint) {
    if (candidates.isEmpty) return [];
    if (candidates.length == 1) return [...candidates];

    // Create scoring list using growable list with initial capacity
    final scored = <_ScoredStrategy<I, O>>[];

    for (var i = 0; i < candidates.length; i++) {
      final strategy = candidates[i];
      final score = _calculateScore(strategy, hint);
      scored.add(_ScoredStrategy(strategy, score));
    }

    // Sort by score (lower = better)
    scored.sort((a, b) => a.score.compareTo(b.score));

    // Extract strategies in ranked order - direct list assignment for better performance
    final result = List<Strategy<I, O>>.generate(scored.length, (i) => scored[i].strategy);

    return result;
  }

  /// Calculate a composite score for a strategy given the hint.
  /// Lower scores indicate better matches.
  double _calculateScore<I, O>(Strategy<I, O> strategy, SelectorHint hint) {
    var score = 0.0;

    // Base score from time complexity
    score += complexityRanker.getRankValue(strategy.meta.timeComplexity).toDouble();

    // Adjust for dataset size characteristics
    final n = hint.n;
    if (n != null) {
      score += _calculateSizeAdjustment(strategy.meta.timeComplexity, n);
    }

    // Memory overhead penalty/rejection
    if (hint.memoryBudgetBytes != null && strategy.meta.memoryOverheadBytes > 0) {
      if (strategy.meta.memoryOverheadBytes > hint.memoryBudgetBytes!) {
        // Hard rejection for algorithms that exceed memory budget
        return double.infinity; // This will be filtered out
      }
      final memoryRatio = strategy.meta.memoryOverheadBytes / hint.memoryBudgetBytes!;
      score += memoryRatio * memoryWeight * 20; // Stronger penalty for memory usage
    }

    // Sorted data optimization bonus
    if (hint.sorted == true) {
      // Give substantial bonus to insertion sort for sorted data
      if (strategy.meta.name.contains('insertion')) {
        score -= 1.0; // Strong bonus for insertion sort on sorted data
      } else if (strategy.meta.requiresSorted) {
        score -= 0.3; // Lesser bonus for other algorithms that can use sorted property
      }
    }

    // Stability preference adjustment
    if (hint.preferStable == true) {
      // This would need to be part of metadata in a full implementation
      // For now, we approximate based on common stable algorithms
      if (_isLikelyStable(strategy.meta.name)) {
        score -= stabilityWeight;
      }
    }

    return score;
  }

  /// Adjust score based on dataset size and complexity interaction.
  double _calculateSizeAdjustment(TimeComplexity complexity, int n) {
    // For small datasets, simple algorithms often win due to lower constants
    if (n <= smallNThreshold) {
      return switch (complexity) {
        TimeComplexity.o1 => -0.2, // Always good
        TimeComplexity.oN => -0.1, // Good for small n
        TimeComplexity.oLogN => 0.1, // Overhead may not pay off
        TimeComplexity.oNLogN => 0.2, // Overhead definitely not worth it
        TimeComplexity.oN2 => 0.0, // Acceptable for very small n
        _ => 0.5, // Penalize heavily
      };
    }

    // For large datasets, scalability becomes crucial
    if (n > 1000) {
      return switch (complexity) {
        TimeComplexity.o1 => -0.3, // Excellent
        TimeComplexity.oLogN => -0.2, // Very good
        TimeComplexity.oNLogN => -0.1, // Good
        TimeComplexity.oN => 0.1, // OK but not ideal
        TimeComplexity.oN2 => 1.0, // Bad for large n
        TimeComplexity.oN3 => 2.0, // Very bad
        TimeComplexity.o2N => 3.0, // Terrible
      };
    }

    // Medium datasets - balanced approach
    return 0.0;
  }

  /// Heuristic to determine if an algorithm is likely stable.
  /// In a full implementation, this would be part of AlgoMetadata.
  bool _isLikelyStable(String algorithmName) {
    final stableNames = {'merge_sort', 'insertion_sort', 'bubble_sort'};
    return stableNames.contains(algorithmName.toLowerCase());
  }
}

/// Internal helper class for scoring strategies during ranking
class _ScoredStrategy<I, O> {
  const _ScoredStrategy(this.strategy, this.score);

  final Strategy<I, O> strategy;
  final double score;
}
