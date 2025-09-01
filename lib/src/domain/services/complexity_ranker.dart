import '../value_objects/time_complexity.dart';

/// Fast, allocation-free ranking service for time complexities.
///
/// Provides consistent ranking of Big-O complexities with configurable
/// weights for fine-tuning selection policies.
class ComplexityRanker {
  const ComplexityRanker([this.weights = defaultWeights]);

  /// Create a ranker that heavily favors scalable algorithms for large datasets
  factory ComplexityRanker.favorScalable() {
    return const ComplexityRanker({
      TimeComplexity.o1: 0,
      TimeComplexity.oLogN: 1,
      TimeComplexity.oNLogN: 2,
      TimeComplexity.oN: 3, // Linear is less preferred for large n
      TimeComplexity.oN2: 4,
      TimeComplexity.oN3: 5,
      TimeComplexity.o2N: 6,
    });
  }

  /// Create a ranker that heavily favors simple algorithms for small datasets
  factory ComplexityRanker.favorSimple() {
    return const ComplexityRanker({
      TimeComplexity.o1: 0,
      TimeComplexity.oN: 1, // Favor linear over log for small n
      TimeComplexity.oLogN: 2,
      TimeComplexity.oNLogN: 3,
      TimeComplexity.oN2: 4,
      TimeComplexity.oN3: 5,
      TimeComplexity.o2N: 6,
    });
  }

  /// Default weight mapping: lower weights indicate better (preferred) complexities
  static const Map<TimeComplexity, int> defaultWeights = {
    TimeComplexity.o1: 0,
    TimeComplexity.oLogN: 1,
    TimeComplexity.oN: 2,
    TimeComplexity.oNLogN: 3,
    TimeComplexity.oN2: 4,
    TimeComplexity.oN3: 5,
    TimeComplexity.o2N: 6,
  };

  /// Weight mapping for complexity ranking (lower = better)
  final Map<TimeComplexity, int> weights;

  /// Get the rank weight for a given complexity.
  /// Returns a high value for unknown complexities to deprioritize them.
  int getRankValue(TimeComplexity complexity) {
    return weights[complexity] ?? 999;
  }

  /// Compare two complexities for sorting (-1, 0, 1).
  /// Returns negative if [a] is better than [b], positive if worse, 0 if equal.
  int compare(TimeComplexity a, TimeComplexity b) {
    return getRankValue(a).compareTo(getRankValue(b));
  }

  /// Returns true if complexity [a] is better than or equal to [b]
  bool isBetterOrEqual(TimeComplexity a, TimeComplexity b) {
    return getRankValue(a) <= getRankValue(b);
  }

  /// Returns true if complexity [a] is strictly better than [b]
  bool isBetter(TimeComplexity a, TimeComplexity b) {
    return getRankValue(a) < getRankValue(b);
  }

  /// Sort complexities in-place from best to worst
  void sortInPlace(List<TimeComplexity> complexities) {
    complexities.sort(compare);
  }

  /// Create a ranker with custom weights
  ComplexityRanker withWeights(Map<TimeComplexity, int> customWeights) {
    return ComplexityRanker({...defaultWeights, ...customWeights});
  }
}
