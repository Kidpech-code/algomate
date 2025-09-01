import '../../domain/entities/strategy.dart';
import '../../domain/repositories/strategy_catalog.dart';
import '../../domain/services/selector_policy.dart';
import '../../shared/errors.dart';
import '../../shared/result.dart';
import '../dto/execute_command.dart';
import '../dto/execute_result.dart';
import '../ports/clock.dart';
import '../ports/logger.dart';

/// Use case for executing algorithm strategies with intelligent selection.
///
/// Implements the core algorithm selection logic with performance measurement,
/// fallback handling, and comprehensive error management.
class ExecuteStrategyUseCase {
  const ExecuteStrategyUseCase({
    required this.catalog,
    required this.policy,
    required this.logger,
    this.clock = const SystemClock(),
    this.enableTiming = false,
  });

  final StrategyCatalog catalog;
  final SelectorPolicy policy;
  final Logger logger;
  final Clock clock;
  final bool enableTiming;

  /// Execute a strategy based on the provided command.
  ///
  /// Returns a Result containing either the execution result or a failure.
  /// This method never throws exceptions - all errors are wrapped in Results.
  Result<ExecuteResult<O>, AlgoMateFailure> call<I, O>(ExecuteCommand<I, O> command) {
    final selectionStopwatch = enableTiming ? clock.createStopwatch() : null;
    selectionStopwatch?.start();

    try {
      // 1. Find candidate strategies
      final candidates = catalog.list<I, O>(command.signature);

      if (candidates.isEmpty) {
        return Result.failure(NoStrategyFailure.forSignature(command.signature.toString()));
      }

      logger.debug('Found ${candidates.length} candidate strategies');

      // 2. Filter applicable strategies
      final applicable = _filterApplicable(candidates, command);

      if (applicable.isEmpty) {
        return _handleNoApplicableStrategies(command);
      }

      logger.debug('${applicable.length} strategies are applicable');

      // 3. Rank strategies by policy
      final ranked = policy.rank<I, O>(applicable, command.hint);

      selectionStopwatch?.stop();
      final selectionTimeMicros = selectionStopwatch?.elapsedMicroseconds;

      // 4. Execute the top-ranked strategy
      final chosenStrategy = ranked.first;

      logger.debug('Selected strategy: ${chosenStrategy.meta.name}');

      return _executeStrategy(
        strategy: chosenStrategy,
        input: command.input,
        candidateCount: candidates.length,
        selectionTimeMicros: selectionTimeMicros,
      );
    } catch (e, stackTrace) {
      logger.error('Unexpected error in strategy execution', e, stackTrace);
      return Result.failure(ExecutionFailure('Unexpected error during execution', e.toString()));
    }
  }

  /// Filter strategies that can be applied to the given command.
  /// Uses fast filtering with minimal allocations in the hot path.
  List<Strategy<I, O>> _filterApplicable<I, O>(List<Strategy<I, O>> candidates, ExecuteCommand<I, O> command) {
    final applicable = <Strategy<I, O>>[];

    // Use traditional for loop for best performance
    for (var i = 0; i < candidates.length; i++) {
      final strategy = candidates[i];

      try {
        if (strategy.canApply(command.input, command.hint)) {
          applicable.add(strategy);
        }
      } catch (e) {
        logger.warn('Strategy ${strategy.meta.name}.canApply() threw exception: $e');
        // Skip strategies that throw during canApply
      }
    }

    return applicable;
  }

  /// Handle the case where no strategies are applicable.
  Result<ExecuteResult<O>, AlgoMateFailure> _handleNoApplicableStrategies<I, O>(ExecuteCommand<I, O> command) {
    // Try fallback strategy if specified
    if (command.fallbackStrategyName != null) {
      final fallback = catalog.find<I, O>(command.fallbackStrategyName!, command.signature);

      if (fallback != null) {
        logger.info('Using fallback strategy: ${fallback.meta.name}');

        return _executeStrategy(strategy: fallback, input: command.input, candidateCount: 1, selectionTimeMicros: null);
      }
    }

    // Generate helpful error message
    final hint = command.hint;
    final details = <String>[];

    if (hint.sorted == true) {
      details.add('Consider strategies that work with unsorted data');
    }

    if (hint.n != null && hint.n! > 10000) {
      details.add('Consider strategies optimized for large datasets');
    }

    if (hint.memoryBudgetBytes != null) {
      details.add('Consider increasing memory budget or using in-place algorithms');
    }

    return Result.failure(
      InapplicableInputFailure('No strategies can be applied with the given hint and input', details.isEmpty ? null : details.join('; ')),
    );
  }

  /// Execute a single strategy with timing and error handling.
  Result<ExecuteResult<O>, AlgoMateFailure> _executeStrategy<I, O>({
    required Strategy<I, O> strategy,
    required I input,
    required int candidateCount,
    int? selectionTimeMicros,
  }) {
    final executionStopwatch = enableTiming ? clock.createStopwatch() : null;

    try {
      executionStopwatch?.start();
      final output = strategy.execute(input);
      executionStopwatch?.stop();

      final result = ExecuteResult<O>(
        output: output,
        selectedStrategy: strategy.meta,
        executionTimeMicros: executionStopwatch?.elapsedMicroseconds,
        candidateCount: candidateCount,
        selectionTimeMicros: selectionTimeMicros,
      );

      if (logger.isInfoEnabled) {
        logger.info('Executed ${strategy.meta.name} successfully');

        if (executionStopwatch != null) {
          logger.debug('Execution time: ${executionStopwatch.elapsedMicroseconds}μs');
        }
      }

      return Result.success(result);
    } catch (e, stackTrace) {
      logger.error('Strategy ${strategy.meta.name} failed during execution', e, stackTrace);

      return Result.failure(ExecutionFailure.strategyError(strategy.meta.name, e));
    }
  }
}
