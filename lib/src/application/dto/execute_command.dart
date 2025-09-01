import 'package:meta/meta.dart';

import '../../domain/entities/strategy_signature.dart';
import '../../domain/value_objects/selector_hint.dart';

/// Command object that encapsulates algorithm execution requests.
///
/// This class follows the Command pattern to encapsulate all information needed
/// to execute an algorithm strategy, including input data, execution configuration,
/// and performance constraints.
@immutable
final class ExecuteCommand<I, O> {
  const ExecuteCommand({
    required this.input,
    required this.signature,
    required this.hint,
    this.timeoutMillis,
    this.fallbackStrategyName,
  });

  /// Factory for sort operations
  factory ExecuteCommand.sort({
    required I input,
    required SelectorHint hint,
    String? tag,
    int? timeoutMillis,
  }) =>
      ExecuteCommand<I, O>(
        input: input,
        signature: StrategySignature.sort(inputType: I, tag: tag),
        hint: hint,
        timeoutMillis: timeoutMillis,
      );

  /// Factory for search operations
  factory ExecuteCommand.search({
    required I input,
    required Type outputType,
    required SelectorHint hint,
    String? tag,
    int? timeoutMillis,
  }) =>
      ExecuteCommand<I, O>(
        input: input,
        signature: StrategySignature.search(
          inputType: I,
          outputType: outputType,
          tag: tag,
        ),
        hint: hint,
        timeoutMillis: timeoutMillis,
      );

  /// The input data to process
  final I input;

  /// Signature defining the required strategy characteristics
  final StrategySignature signature;

  /// Hints to guide strategy selection and optimization
  final SelectorHint hint;

  /// Optional timeout in milliseconds (null for no timeout)
  final int? timeoutMillis;

  /// Optional fallback strategy name if primary selection fails
  final String? fallbackStrategyName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExecuteCommand<I, O> &&
          other.input == input &&
          other.signature == signature &&
          other.hint == hint &&
          other.timeoutMillis == timeoutMillis &&
          other.fallbackStrategyName == fallbackStrategyName);

  @override
  int get hashCode =>
      Object.hash(input, signature, hint, timeoutMillis, fallbackStrategyName);

  @override
  String toString() => 'ExecuteCommand('
      'signature: $signature, '
      'hint: $hint, '
      'timeout: ${timeoutMillis}ms, '
      'fallback: $fallbackStrategyName'
      ')';

  /// Create a copy with optional field overrides
  ExecuteCommand<I, O> copyWith({
    I? input,
    StrategySignature? signature,
    SelectorHint? hint,
    int? timeoutMillis,
    String? fallbackStrategyName,
  }) =>
      ExecuteCommand<I, O>(
        input: input ?? this.input,
        signature: signature ?? this.signature,
        hint: hint ?? this.hint,
        timeoutMillis: timeoutMillis ?? this.timeoutMillis,
        fallbackStrategyName: fallbackStrategyName ?? this.fallbackStrategyName,
      );
}
