/// Represents the time complexity of an algorithm using Big O notation.
/// Ordered from best (O(1)) to worst (O(2^n)) for ranking purposes.
enum TimeComplexity {
  /// Constant time - O(1)
  o1('O(1)', 0),

  /// Logarithmic time - O(log n)
  oLogN('O(log n)', 1),

  /// Linear time - O(n)
  oN('O(n)', 2),

  /// Linearithmic time - O(n log n)
  oNLogN('O(n log n)', 3),

  /// Quadratic time - O(n²)
  oN2('O(n²)', 4),

  /// Cubic time - O(n³)
  oN3('O(n³)', 5),

  /// Exponential time - O(2^n)
  o2N('O(2^n)', 6);

  const TimeComplexity(this.notation, this.rankValue);

  /// Human-readable notation (e.g., "O(n log n)")
  final String notation;

  /// Numeric value for ranking (lower is better)
  final int rankValue;

  @override
  String toString() => notation;

  /// Compare complexities for sorting (better complexities come first)
  int compareTo(TimeComplexity other) => rankValue.compareTo(other.rankValue);

  /// Returns true if this complexity is better than or equal to the other
  bool isBetterThanOrEqualTo(TimeComplexity other) =>
      rankValue <= other.rankValue;

  /// Returns true if this complexity is strictly better than the other
  bool isBetterThan(TimeComplexity other) => rankValue < other.rankValue;
}
