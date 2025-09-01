import 'package:meta/meta.dart';

/// Describes the domain and characteristics of a strategy for catalog lookup.
/// Used to find candidate strategies that match input/output types and categories.
@immutable
final class StrategySignature {
  const StrategySignature({required this.inputType, required this.outputType, required this.category, this.tag});

  /// Creates a signature for search algorithms
  factory StrategySignature.search({required Type inputType, required Type outputType, String? tag}) =>
      StrategySignature(inputType: inputType, outputType: outputType, category: 'search', tag: tag);

  /// Creates a signature for sorting algorithms
  factory StrategySignature.sort({required Type inputType, String? tag}) => StrategySignature(
        inputType: inputType,
        outputType: inputType, // Sort returns same type as input
        category: 'sort',
        tag: tag,
      );

  /// The input type this strategy can handle (e.g., List\<int\>)
  final Type inputType;

  /// The output type this strategy produces (e.g., int, List\<int\>)
  final Type outputType;

  /// Algorithm category (e.g., 'search', 'sort', 'graph')
  final String category;

  /// Optional specific tag for fine-grained matching (e.g., 'int_index', 'string_key')
  final String? tag;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StrategySignature &&
          other.inputType == inputType &&
          other.outputType == outputType &&
          other.category == category &&
          other.tag == tag);

  @override
  int get hashCode => Object.hash(inputType, outputType, category, tag);

  @override
  String toString() {
    final tagPart = tag != null ? ':$tag' : '';
    return '$category$tagPart<$inputType -> $outputType>';
  }

  /// Checks if this signature matches another signature
  bool matches(StrategySignature other) {
    return inputType == other.inputType &&
        outputType == other.outputType &&
        category == other.category &&
        (tag == null || other.tag == null || tag == other.tag);
  }
}
