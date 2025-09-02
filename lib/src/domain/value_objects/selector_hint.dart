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
    this.nearlySorted,
    this.preferSimple,
  });

  /// Creates a hint for small datasets (typically < 100 elements)
  factory SelectorHint.small({bool? sorted, bool? nearlySorted}) =>
      SelectorHint(
        n: 32, // Threshold where simple algorithms often outperform complex ones
        sorted: sorted,
        nearlySorted: nearlySorted,
        preferSimple: true,
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

  /// Whether input is nearly sorted (most elements are in correct position)
  final bool? nearlySorted;

  /// Available memory budget in bytes (null for unlimited)
  final int? memoryBudgetBytes;

  /// Whether to prefer stable algorithms (maintains relative order of equal elements)
  final bool? preferStable;

  /// Whether to prefer simple algorithms (lower code complexity)
  final bool? preferSimple;

  /// Maximum acceptable time complexity (null for no limit)
  final String? maxTimeComplexity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SelectorHint &&
          other.n == n &&
          other.sorted == sorted &&
          other.nearlySorted == nearlySorted &&
          other.memoryBudgetBytes == memoryBudgetBytes &&
          other.preferStable == preferStable &&
          other.preferSimple == preferSimple &&
          other.maxTimeComplexity == maxTimeComplexity);

  @override
  int get hashCode => Object.hash(
        n,
        sorted,
        nearlySorted,
        memoryBudgetBytes,
        preferStable,
        preferSimple,
        maxTimeComplexity,
      );

  @override
  String toString() => 'SelectorHint('
      'n: $n, '
      'sorted: $sorted, '
      'nearlySorted: $nearlySorted, '
      'memoryBudget: ${memoryBudgetBytes != null ? "${memoryBudgetBytes! ~/ 1024}KB" : "unlimited"}, '
      'preferStable: $preferStable, '
      'preferSimple: $preferSimple, '
      'maxComplexity: $maxTimeComplexity'
      ')';

  /// Creates a copy of this hint with optional field overrides
  SelectorHint copyWith({
    int? n,
    bool? sorted,
    bool? nearlySorted,
    int? memoryBudgetBytes,
    bool? preferStable,
    bool? preferSimple,
    String? maxTimeComplexity,
  }) =>
      SelectorHint(
        n: n ?? this.n,
        sorted: sorted ?? this.sorted,
        nearlySorted: nearlySorted ?? this.nearlySorted,
        memoryBudgetBytes: memoryBudgetBytes ?? this.memoryBudgetBytes,
        preferStable: preferStable ?? this.preferStable,
        preferSimple: preferSimple ?? this.preferSimple,
        maxTimeComplexity: maxTimeComplexity ?? this.maxTimeComplexity,
      );
}
