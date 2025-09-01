import '../../../domain/entities/strategy.dart';
import '../../../domain/entities/strategy_signature.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/repositories/strategy_catalog.dart';
import '../../../shared/result.dart';
import '../../../shared/errors.dart';
import '../../../interface/performance/direct_executor.dart';

/// Concrete implementation of DirectExecutor
///
/// Provides fast path execution by bypassing algorithm selection
/// overhead when the specific strategy is already known.
class ConcreteDirectExecutor implements DirectExecutor {
  ConcreteDirectExecutor(this._catalog);

  final StrategyCatalog _catalog;

  @override
  Result<T, AlgoMateFailure> execute<T>(String strategyName, T input) {
    try {
      // Create appropriate signature based on input type
      final signature = _createSignature(input);

      // Find strategy by name and signature
      final strategy = _catalog.find<T, T>(strategyName, signature);

      if (strategy == null) {
        return Result.failure(
          NoStrategyFailure(
            'Strategy not found: $strategyName',
            'Ensure the strategy is registered with exact name match.',
          ),
        );
      }

      // Direct execution without selection overhead
      final result = strategy.execute(input);
      return Result.success(result);
    } catch (e) {
      return Result.failure(
        ExecutionFailure.strategyError(strategyName, e),
      );
    }
  }

  @override
  List<String> getAvailableStrategies() {
    // Get strategies for common signature patterns
    final strategies = <Strategy<dynamic, dynamic>>[];

    // Add sort strategies
    strategies.addAll(
      _catalog.list<List<int>, List<int>>(
        StrategySignature.sort(inputType: List<int>),
      ),
    );

    // Add search strategies
    strategies.addAll(
      _catalog.list<List<int>, int?>(
        StrategySignature.search(inputType: List<int>, outputType: int),
      ),
    );

    return strategies.map((s) => s.meta.name).toSet().toList();
  }

  @override
  AlgoMetadata? getStrategyInfo(String strategyName) {
    // Search across different signature types
    final signatures = [
      StrategySignature.sort(inputType: List<int>),
      StrategySignature.search(inputType: List<int>, outputType: int),
    ];

    for (final signature in signatures) {
      final strategy = _catalog.find<dynamic, dynamic>(strategyName, signature);
      if (strategy != null) {
        return strategy.meta;
      }
    }

    return null;
  }

  /// Create strategy signature based on input type
  StrategySignature _createSignature<T>(T input) {
    if (input is List<int>) {
      // Assume sorting for List<int> input
      return StrategySignature.sort(inputType: List<int>);
    } else if (input is List) {
      // Generic list sorting
      return StrategySignature.sort(inputType: List);
    } else {
      // Generic signature
      return StrategySignature(
        inputType: T,
        outputType: T,
        category: 'generic',
      );
    }
  }
}
