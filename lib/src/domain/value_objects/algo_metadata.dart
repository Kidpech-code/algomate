import 'package:meta/meta.dart';
import 'time_complexity.dart';

/// Immutable metadata describing an algorithm's characteristics and requirements.
@immutable
final class AlgoMetadata {
  const AlgoMetadata({
    required this.name,
    required this.timeComplexity,
    this.spaceComplexity = TimeComplexity.o1,
    this.requiresSorted = false,
    this.memoryOverheadBytes = 0,
    this.description,
  });

  /// Human-readable name of the algorithm (e.g., "binary_search", "merge_sort")
  final String name;

  /// Time complexity of the algorithm
  final TimeComplexity timeComplexity;

  /// Space complexity of the algorithm (additional memory used)
  final TimeComplexity spaceComplexity;

  /// Whether the algorithm requires sorted input
  final bool requiresSorted;

  /// Additional memory overhead in bytes (0 for in-place algorithms)
  final int memoryOverheadBytes;

  /// Optional description of the algorithm
  final String? description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlgoMetadata &&
          other.name == name &&
          other.timeComplexity == timeComplexity &&
          other.spaceComplexity == spaceComplexity &&
          other.requiresSorted == requiresSorted &&
          other.memoryOverheadBytes == memoryOverheadBytes &&
          other.description == description);

  @override
  int get hashCode => Object.hash(
        name,
        timeComplexity,
        spaceComplexity,
        requiresSorted,
        memoryOverheadBytes,
        description,
      );

  @override
  String toString() => 'AlgoMetadata('
      'name: $name, '
      'time: ${timeComplexity.notation}, '
      'space: ${spaceComplexity.notation}, '
      'requiresSorted: $requiresSorted, '
      'memoryOverhead: ${memoryOverheadBytes}B'
      ')';

  /// Creates a copy of this metadata with optional field overrides
  AlgoMetadata copyWith({
    String? name,
    TimeComplexity? timeComplexity,
    TimeComplexity? spaceComplexity,
    bool? requiresSorted,
    int? memoryOverheadBytes,
    String? description,
  }) =>
      AlgoMetadata(
        name: name ?? this.name,
        timeComplexity: timeComplexity ?? this.timeComplexity,
        spaceComplexity: spaceComplexity ?? this.spaceComplexity,
        requiresSorted: requiresSorted ?? this.requiresSorted,
        memoryOverheadBytes: memoryOverheadBytes ?? this.memoryOverheadBytes,
        description: description ?? this.description,
      );
}
