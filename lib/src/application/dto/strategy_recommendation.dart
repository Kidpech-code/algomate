import '../../domain/value_objects/time_complexity.dart';
import '../../domain/value_objects/algo_metadata.dart';

/// A recommendation describing which strategy would be selected and why,
/// without executing it.
class StrategyRecommendation {
  const StrategyRecommendation({
    required this.name,
    required this.estimatedComplexity,
    required this.estimatedMemoryBytes,
    required this.reason,
    this.alternatives = const [],
    this.selectedMeta,
  });

  /// Strategy name that would be chosen.
  final String name;

  /// Estimated time complexity per metadata.
  final TimeComplexity estimatedComplexity;

  /// Estimated peak additional memory usage in bytes.
  final int estimatedMemoryBytes;

  /// Human-readable explanation of the choice.
  final String reason;

  /// Alternative strategy names in ranked order (best first).
  final List<String> alternatives;

  /// Optional metadata of the selected strategy (if available), useful for logging.
  final AlgoMetadata? selectedMeta;

  @override
  String toString() => 'StrategyRecommendation(name: '
      '$name, complexity: $estimatedComplexity, mem: '
      '$estimatedMemoryBytes, reason: $reason, alternatives: $alternatives)';
}
