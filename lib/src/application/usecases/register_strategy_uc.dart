import '../../domain/entities/strategy.dart';
import '../../domain/entities/strategy_signature.dart';
import '../../domain/repositories/strategy_catalog.dart';
import '../ports/logger.dart';

/// Use case for registering new algorithm strategies in the catalog.
///
/// Provides validation, conflict detection, and logging for strategy registration.
class RegisterStrategyUseCase {
  const RegisterStrategyUseCase({required this.catalog, required this.logger});

  final StrategyCatalog catalog;
  final Logger logger;

  /// Register a new strategy with validation and conflict checking.
  ///
  /// Throws [ArgumentError] if:
  /// - Strategy name is empty or contains invalid characters
  /// - A strategy with the same name and signature already exists
  /// - Strategy fails basic validation
  void call<I, O>({
    required Strategy<I, O> strategy,
    required StrategySignature signature,
    bool allowReplace = false,
  }) {
    // Validate strategy name
    _validateStrategyName(strategy.meta.name);

    // Validate signature compatibility
    _validateSignatureCompatibility<I, O>(signature);

    // Check for existing strategy unless replacement is allowed
    if (!allowReplace &&
        catalog.contains<I, O>(strategy.meta.name, signature)) {
      throw ArgumentError(
        'Strategy "${strategy.meta.name}" already exists for signature $signature. '
        'Use allowReplace: true to replace existing strategy.',
      );
    }

    // Register the strategy
    if (allowReplace) {
      catalog.replace<I, O>(strategy, signature);
      logger.info('Replaced strategy: ${strategy.meta.name} for $signature');
    } else {
      catalog.register<I, O>(strategy, signature);
      logger.info('Registered strategy: ${strategy.meta.name} for $signature');
    }

    // Log strategy characteristics
    if (logger.isDebugEnabled) {
      logger.debug('Strategy details: ${strategy.meta}', {
        'signature': signature.toString(),
        'timeComplexity': strategy.meta.timeComplexity.notation,
        'requiresSorted': strategy.meta.requiresSorted,
        'memoryOverhead': strategy.meta.memoryOverheadBytes,
      });
    }
  }

  /// Register multiple strategies in a batch for efficiency.
  void registerBatch<I, O>({
    required List<Strategy<I, O>> strategies,
    required StrategySignature signature,
    bool allowReplace = false,
  }) {
    if (strategies.isEmpty) {
      logger.warn('Attempted to register empty batch of strategies');
      return;
    }

    for (final strategy in strategies) {
      try {
        call<I, O>(
          strategy: strategy,
          signature: signature,
          allowReplace: allowReplace,
        );
      } catch (e) {
        logger.error(
          'Failed to register strategy ${strategy.meta.name} in batch',
          e,
        );
        rethrow;
      }
    }

    logger.info('Registered ${strategies.length} strategies for $signature');
  }

  /// Remove a strategy from the catalog.
  bool removeStrategy<I, O>({
    required String strategyName,
    required StrategySignature signature,
  }) {
    final removed = catalog.remove<I, O>(strategyName, signature);

    if (removed) {
      logger.info('Removed strategy: $strategyName for $signature');
    } else {
      logger
          .warn('Strategy not found for removal: $strategyName for $signature');
    }

    return removed;
  }

  /// Get information about registered strategies.
  CatalogStats getStatistics() {
    final stats = catalog.stats;

    logger.debug('Catalog statistics: $stats');

    return stats;
  }

  /// Validate strategy name format and content.
  void _validateStrategyName(String name) {
    if (name.trim().isEmpty) {
      throw ArgumentError('Strategy name cannot be empty');
    }

    if (name.length > 64) {
      throw ArgumentError('Strategy name too long (max 64 characters): $name');
    }

    // Check for invalid characters (allow letters, numbers, underscore, dash)
    final validPattern = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!validPattern.hasMatch(name)) {
      throw ArgumentError(
        'Strategy name contains invalid characters. '
        'Use only letters, numbers, underscore, and dash: $name',
      );
    }
  }

  /// Validate that signature matches the strategy's generic types.
  void _validateSignatureCompatibility<I, O>(StrategySignature signature) {
    // Basic type checking - in a more advanced implementation,
    // this could use reflection or code generation for stricter validation

    if (signature.inputType == dynamic || signature.outputType == dynamic) {
      logger.warn(
        'Strategy signature uses dynamic types, consider explicit typing',
      );
    }

    // Validate category format
    if (signature.category.trim().isEmpty) {
      throw ArgumentError('Strategy signature category cannot be empty');
    }

    if (signature.category.length > 32) {
      throw ArgumentError(
        'Strategy signature category too long (max 32 characters)',
      );
    }
  }
}
