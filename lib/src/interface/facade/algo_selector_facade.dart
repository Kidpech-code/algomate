import '../../application/dto/execute_command.dart';
import '../../application/dto/execute_result.dart';
import '../../application/ports/clock.dart';
import '../../application/ports/logger.dart';
import '../../application/usecases/execute_strategy_uc.dart';
import '../../application/usecases/register_strategy_uc.dart';
import '../../domain/entities/strategy.dart';
import '../../domain/entities/strategy_signature.dart';
import '../../domain/repositories/strategy_catalog.dart';
import '../../domain/services/selector_policy.dart';
import '../../domain/value_objects/selector_hint.dart';
import '../../shared/errors.dart';
import '../../shared/result.dart';
import '../config/selector_builder.dart';

/// Main facade for the AlgoMate algorithm selection system.
///
/// Provides a simple, type-safe interface for registering strategies,
/// executing algorithms, and managing the selection system.
class AlgoSelectorFacade {
  /// Create a facade from a builder result.
  factory AlgoSelectorFacade.fromBuilder(SelectorBuilderResult builderResult) {
    final logger = builderResult.loggerFactory.create('AlgoSelector');

    return AlgoSelectorFacade._(
      catalog: builderResult.catalog,
      policy: builderResult.policy,
      logger: logger,
      clock: const SystemClock(),
      enableTiming: builderResult.enableTiming,
    );
  }

  /// Create a facade with development-friendly defaults.
  factory AlgoSelectorFacade.development() {
    return AlgoSelectorFacade.fromBuilder(
        SelectorBuilder.development().build(),);
  }

  /// Create a facade with production-optimized settings.
  factory AlgoSelectorFacade.production() {
    return AlgoSelectorFacade.fromBuilder(SelectorBuilder.production().build());
  }
  AlgoSelectorFacade._(
      {required this.catalog,
      required this.policy,
      required this.logger,
      required this.clock,
      required this.enableTiming,})
      : _executeUC = ExecuteStrategyUseCase(
            catalog: catalog,
            policy: policy,
            logger: logger,
            clock: clock,
            enableTiming: enableTiming,),
        _registerUC = RegisterStrategyUseCase(catalog: catalog, logger: logger);

  final StrategyCatalog catalog;
  final SelectorPolicy policy;
  final Logger logger;
  final Clock clock;
  final bool enableTiming;

  final ExecuteStrategyUseCase _executeUC;
  final RegisterStrategyUseCase _registerUC;

  /// Register a new strategy.
  ///
  /// Returns a Result indicating success or failure of the registration.
  Result<void, AlgoMateFailure> register<I, O>(
      {required Strategy<I, O> strategy,
      required StrategySignature signature,
      bool allowReplace = false,}) {
    try {
      _registerUC.call<I, O>(
          strategy: strategy, signature: signature, allowReplace: allowReplace,);

      return const Result.success(null);
    } catch (e) {
      logger.error('Failed to register strategy', e);
      return Result.failure(
          ExecutionFailure('Strategy registration failed', e.toString()),);
    }
  }

  /// Execute an algorithm strategy based on input and hints.
  ///
  /// This is the main entry point for algorithm execution.
  /// Returns a Result containing either the execution result or a failure.
  Result<ExecuteResult<O>, AlgoMateFailure> execute<I, O>({
    required I input,
    required StrategySignature signature,
    required SelectorHint hint,
    int? timeoutMillis,
    String? fallbackStrategyName,
  }) {
    final command = ExecuteCommand<I, O>(
      input: input,
      signature: signature,
      hint: hint,
      timeoutMillis: timeoutMillis,
      fallbackStrategyName: fallbackStrategyName,
    );

    return _executeUC.call<I, O>(command);
  }

  /// Convenience method for search operations.
  Result<ExecuteResult<int?>, AlgoMateFailure> search(
      {required List<int> input,
      required int target,
      SelectorHint? hint,
      String? tag,}) {
    // Create a search-specific strategy signature
    final signature = StrategySignature.search(
        inputType: List<int>, outputType: int, tag: tag ?? 'index_search',);

    // For simplicity in this demo, we'll need a more sophisticated approach
    // to handle target values in practice
    return execute<List<int>, int?>(
      input: input,
      signature: signature,
      hint: hint ?? SelectorHint(n: input.length),
    );
  }

  /// Convenience method for sorting operations.
  Result<ExecuteResult<List<int>>, AlgoMateFailure> sort(
      {required List<int> input, SelectorHint? hint, String? tag,}) {
    final signature =
        StrategySignature.sort(inputType: List<int>, tag: tag ?? 'int_sort');

    return execute<List<int>, List<int>>(
      input: input,
      signature: signature,
      hint: hint ?? SelectorHint(n: input.length),
    );
  }

  /// Get statistics about registered strategies.
  CatalogStats getStats() => catalog.stats;

  /// Get the number of registered strategies.
  int get strategyCount => catalog.count;

  /// Get all registered signatures.
  List<StrategySignature> get signatures => catalog.signatures;

  /// Remove a strategy from the catalog.
  Result<bool, AlgoMateFailure> removeStrategy<I, O>(
      {required String strategyName, required StrategySignature signature,}) {
    try {
      final removed = _registerUC.removeStrategy<I, O>(
          strategyName: strategyName, signature: signature,);

      return Result.success(removed);
    } catch (e) {
      logger.error('Failed to remove strategy', e);
      return Result.failure(
          ExecutionFailure('Strategy removal failed', e.toString()),);
    }
  }

  /// Clear all registered strategies.
  void clear() {
    catalog.clear();
    logger.info('Cleared all registered strategies');
  }

  /// Check if a specific strategy is registered.
  bool hasStrategy<I, O>(String strategyName, StrategySignature signature) {
    return catalog.contains<I, O>(strategyName, signature);
  }

  /// Find a specific strategy by name and signature.
  Strategy<I, O>? findStrategy<I, O>(
      String strategyName, StrategySignature signature,) {
    return catalog.find<I, O>(strategyName, signature);
  }

  /// Get all strategies that match a signature.
  List<Strategy<I, O>> listStrategies<I, O>(StrategySignature signature) {
    return catalog.list<I, O>(signature);
  }

  @override
  String toString() => 'AlgoSelectorFacade('
      'strategies: $strategyCount, '
      'timing: $enableTiming'
      ')';
}
