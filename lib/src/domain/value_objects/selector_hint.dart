import 'package:meta/meta.dart';

/// Immutable hints to guide algorithm selection and optimization.
/// Provides performance hints without making assumptions about data correctness.
@immutable
final class SelectorHint {
  const SelectorHint({
    this.n,
    this.sorted,
    this.memoryBudgetBytes,
    this.preferStable,
    this.maxTimeComplexity,
  });

  /// Creates a hint for small datasets (typically < 100 elements)
  factory SelectorHint.small({bool? sorted}) => SelectorHint(
        n: 32, // Threshold where simple algorithms often outperform complex ones
        sorted: sorted,
      );

  /// Creates a hint for large datasets (> 1000 elements)
  factory SelectorHint.large({bool? sorted, bool? preferStable}) =>
      SelectorHint(n: 10000, sorted: sorted, preferStable: preferStable);

  /// Creates a hint for memory-constrained environments
  factory SelectorHint.lowMemory({int? n, bool? sorted}) => SelectorHint(
        n: n,
        sorted: sorted,
        memoryBudgetBytes: 1024 * 1024, // 1MB limit
      );

  /// Approximate size of the input data (null if unknown)
  final int? n;

  /// Whether input is sorted (null if unknown, false if unsorted, true if sorted)
  /// WARNING: Providing incorrect sorted hint may lead to incorrect results
  final bool? sorted;

  /// Available memory budget in bytes (null for unlimited)
  final int? memoryBudgetBytes;

  /// Whether to prefer stable algorithms (maintains relative order of equal elements)
  final bool? preferStable;

  /// Maximum acceptable time complexity (null for no limit)
  final String? maxTimeComplexity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SelectorHint &&
          other.n == n &&
          other.sorted == sorted &&
          other.memoryBudgetBytes == memoryBudgetBytes &&
          other.preferStable == preferStable &&
          other.maxTimeComplexity == maxTimeComplexity);

  @override
  int get hashCode => Object.hash(
        n,
        sorted,
        memoryBudgetBytes,
        preferStable,
        maxTimeComplexity,
      );

  @override
  String toString() => 'SelectorHint('
      'n: $n, '
      'sorted: $sorted, '
      'memoryBudget: ${memoryBudgetBytes != null ? "${memoryBudgetBytes! ~/ 1024}KB" : "unlimited"}, '
      'preferStable: $preferStable, '
      'maxComplexity: $maxTimeComplexity'
      ')';

  /// Creates a copy of this hint with optional field overrides
  SelectorHint copyWith({
    int? n,
    bool? sorted,
    int? memoryBudgetBytes,
    bool? preferStable,
    String? maxTimeComplexity,
  }) =>
      SelectorHint(
        n: n ?? this.n,
        sorted: sorted ?? this.sorted,
        memoryBudgetBytes: memoryBudgetBytes ?? this.memoryBudgetBytes,
        preferStable: preferStable ?? this.preferStable,
        maxTimeComplexity: maxTimeComplexity ?? this.maxTimeComplexity,
      );
}
