import 'package:meta/meta.dart';

import '../../domain/value_objects/algo_metadata.dart';

/// Result object containing the outcome of algorithm strategy execution.
///
/// This class encapsulates both successful results and failure information,
/// following the Result pattern to provide type-safe error handling without exceptions.
@immutable
final class ExecuteResult<O> {
  const ExecuteResult({
    required this.output,
    required this.selectedStrategy,
    this.executionTimeMicros,
    this.candidateCount,
    this.selectionTimeMicros,
  });

  /// Create a minimal result without timing information
  factory ExecuteResult.simple(
          {required O output, required AlgoMetadata selectedStrategy,}) =>
      ExecuteResult<O>(output: output, selectedStrategy: selectedStrategy);

  /// Create a result with timing information
  factory ExecuteResult.withTiming({
    required O output,
    required AlgoMetadata selectedStrategy,
    required int executionTimeMicros,
    int? candidateCount,
    int? selectionTimeMicros,
  }) =>
      ExecuteResult<O>(
        output: output,
        selectedStrategy: selectedStrategy,
        executionTimeMicros: executionTimeMicros,
        candidateCount: candidateCount,
        selectionTimeMicros: selectionTimeMicros,
      );

  /// The result of the algorithm execution
  final O output;

  /// Metadata of the strategy that was selected and executed
  final AlgoMetadata selectedStrategy;

  /// Actual execution time in microseconds (null if not measured)
  final int? executionTimeMicros;

  /// Number of candidate strategies that were considered
  final int? candidateCount;

  /// Time spent on strategy selection in microseconds (null if not measured)
  final int? selectionTimeMicros;

  /// Total operation time (selection + execution) in microseconds
  int? get totalTimeMicros {
    final selection = selectionTimeMicros;
    final execution = executionTimeMicros;

    if (selection != null && execution != null) {
      return selection + execution;
    }
    return execution; // Return execution time if selection time not available
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExecuteResult<O> &&
          other.output == output &&
          other.selectedStrategy == selectedStrategy &&
          other.executionTimeMicros == executionTimeMicros &&
          other.candidateCount == candidateCount &&
          other.selectionTimeMicros == selectionTimeMicros);

  @override
  int get hashCode => Object.hash(output, selectedStrategy, executionTimeMicros,
      candidateCount, selectionTimeMicros,);

  @override
  String toString() {
    final parts = <String>[
      'strategy: ${selectedStrategy.name}',
      'complexity: ${selectedStrategy.timeComplexity.notation}',
    ];

    if (candidateCount != null) {
      parts.add('candidates: $candidateCount');
    }

    if (executionTimeMicros != null) {
      parts.add('execution: $executionTimeMicrosμs');
    }

    if (selectionTimeMicros != null) {
      parts.add('selection: $selectionTimeMicrosμs');
    }

    return 'ExecuteResult(${parts.join(', ')})';
  }

  /// Create a copy with optional field overrides
  ExecuteResult<O> copyWith(
          {O? output,
          AlgoMetadata? selectedStrategy,
          int? executionTimeMicros,
          int? candidateCount,
          int? selectionTimeMicros,}) =>
      ExecuteResult<O>(
        output: output ?? this.output,
        selectedStrategy: selectedStrategy ?? this.selectedStrategy,
        executionTimeMicros: executionTimeMicros ?? this.executionTimeMicros,
        candidateCount: candidateCount ?? this.candidateCount,
        selectionTimeMicros: selectionTimeMicros ?? this.selectionTimeMicros,
      );
}
