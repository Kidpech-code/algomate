import '../../application/ports/logger.dart';
import '../../application/usecases/register_strategy_uc.dart';
import '../../domain/repositories/strategy_catalog.dart';
import '../../domain/services/selector_policy.dart';
import '../../domain/entities/strategy_signature.dart';
import '../../infrastructure/adapters/logging/console_logger.dart';
import '../../infrastructure/adapters/registry/registry_in_memory.dart';
import '../../infrastructure/strategies/search/linear_search.dart';
import '../../infrastructure/strategies/search/binary_search.dart';
import '../../infrastructure/strategies/sort/insertion_sort.dart';
import '../../infrastructure/strategies/sort/merge_sort.dart';

/// Builder for configuring and creating AlgoSelector instances.
///
/// Provides a fluent interface for setting up the algorithm selection system
/// with sensible defaults and common configurations.
class SelectorBuilder {
  StrategyCatalog? _catalog;
  SelectorPolicy? _policy;
  LoggerFactory? _loggerFactory;
  bool _enableTiming = false;

  /// Use in-memory registry for strategy storage (default).
  SelectorBuilder useInMemoryRegistry() {
    _catalog = InMemoryStrategyCatalog();
    return this;
  }

  /// Use a custom catalog implementation.
  SelectorBuilder useCatalog(StrategyCatalog catalog) {
    _catalog = catalog;
    return this;
  }

  /// Use the default selection policy with optional customizations.
  SelectorBuilder useDefaultPolicy(
      {int smallNThreshold = 32,
      double memoryWeight = 0.1,
      double stabilityWeight = 0.05,}) {
    _policy = SelectorPolicy(
        smallNThreshold: smallNThreshold,
        memoryWeight: memoryWeight,
        stabilityWeight: stabilityWeight,);
    return this;
  }

  /// Use a policy optimized for small datasets.
  SelectorBuilder usePolicyForSmallData() {
    _policy = SelectorPolicy.forSmallData();
    return this;
  }

  /// Use a policy optimized for large datasets.
  SelectorBuilder usePolicyForLargeData() {
    _policy = SelectorPolicy.forLargeData();
    return this;
  }

  /// Use a policy optimized for memory-constrained environments.
  SelectorBuilder useMemoryConstrainedPolicy() {
    _policy = SelectorPolicy.memoryConstrained();
    return this;
  }

  /// Use a custom selection policy.
  SelectorBuilder usePolicy(SelectorPolicy policy) {
    _policy = policy;
    return this;
  }

  /// Enable console logging with the specified level.
  SelectorBuilder enableLogging([LogLevel level = LogLevel.info]) {
    _loggerFactory = ConsoleLoggerFactory(level);
    return this;
  }

  /// Use silent logging (disabled).
  SelectorBuilder useSilentLogging() {
    _loggerFactory = ConsoleLoggerFactory.silent();
    return this;
  }

  /// Use a custom logger factory.
  SelectorBuilder useLoggerFactory(LoggerFactory factory) {
    _loggerFactory = factory;
    return this;
  }

  /// Enable execution timing measurements.
  SelectorBuilder enableTiming([bool enable = true]) {
    _enableTiming = enable;
    return this;
  }

  /// Register built-in search strategies for integer lists.
  SelectorBuilder withBuiltInSearchInt() {
    final catalog = _catalog ?? InMemoryStrategyCatalog();
    final logger = (_loggerFactory ?? ConsoleLoggerFactory.silent())
        .create('SelectorBuilder');

    final registerUC =
        RegisterStrategyUseCase(catalog: catalog, logger: logger);

    // Register search strategies with different targets
    // Note: In practice, you'd want to register factory methods or
    // use a more dynamic approach for target values
    final signature = StrategySignature.search(
        inputType: List<int>, outputType: int, tag: 'index_search',);

    // For demo purposes, register with a placeholder target
    // Real implementation would handle target specification differently
    registerUC.call(
        strategy: LinearSearchStrategy(0),
        signature: signature,
        allowReplace: true,);

    registerUC.call(
        strategy: BinarySearchStrategy(0),
        signature: signature,
        allowReplace: true,);

    _catalog = catalog;
    return this;
  }

  /// Register built-in sorting strategies for integer lists.
  SelectorBuilder withBuiltInSortInt() {
    final catalog = _catalog ?? InMemoryStrategyCatalog();
    final logger = (_loggerFactory ?? ConsoleLoggerFactory.silent())
        .create('SelectorBuilder');

    final registerUC =
        RegisterStrategyUseCase(catalog: catalog, logger: logger);

    final signature =
        StrategySignature.sort(inputType: List<int>, tag: 'int_sort');

    registerUC.call(
        strategy: InsertionSortStrategy(),
        signature: signature,
        allowReplace: true,);

    registerUC.call(
        strategy: InPlaceInsertionSortStrategy(),
        signature: signature,
        allowReplace: true,);

    registerUC.call(
        strategy: BinaryInsertionSortStrategy(),
        signature: signature,
        allowReplace: true,);

    registerUC.call(
        strategy: MergeSortStrategy(),
        signature: signature,
        allowReplace: true,);

    registerUC.call(
        strategy: IterativeMergeSortStrategy(),
        signature: signature,
        allowReplace: true,);

    registerUC.call(
        strategy: HybridMergeSortStrategy(),
        signature: signature,
        allowReplace: true,);

    _catalog = catalog;
    return this;
  }

  /// Register all built-in strategies.
  SelectorBuilder withAllBuiltIns() {
    return withBuiltInSearchInt().withBuiltInSortInt();
  }

  /// Build the final AlgoSelector instance.
  SelectorBuilderResult build() {
    final catalog = _catalog ?? InMemoryStrategyCatalog();
    final policy = _policy ?? const SelectorPolicy();
    final loggerFactory = _loggerFactory ?? ConsoleLoggerFactory.silent();

    // Validate that catalog has at least some strategies if explicitly configured
    if (catalog.count == 0 && _catalog != null) {
      // Log warning if catalog was explicitly set but is empty
      loggerFactory.create('SelectorBuilder').warn(
          'Building selector with empty strategy catalog. Consider calling withAllBuiltIns().',);
    }

    return SelectorBuilderResult(
        catalog: catalog,
        policy: policy,
        loggerFactory: loggerFactory,
        enableTiming: _enableTiming,);
  }

  /// Create a builder with sensible defaults for development.
  static SelectorBuilder development() {
    return SelectorBuilder()
        .useInMemoryRegistry()
        .useDefaultPolicy()
        .enableLogging(LogLevel.debug)
        .enableTiming()
        .withAllBuiltIns();
  }

  /// Create a builder with production-optimized settings.
  static SelectorBuilder production() {
    return SelectorBuilder()
        .useInMemoryRegistry()
        .useDefaultPolicy()
        .useSilentLogging()
        .withAllBuiltIns();
  }

  /// Create a builder for memory-constrained environments.
  static SelectorBuilder memoryConstrained() {
    return SelectorBuilder()
        .useInMemoryRegistry()
        .useMemoryConstrainedPolicy()
        .useSilentLogging();
  }
}

/// Result of the builder containing all configured components.
class SelectorBuilderResult {
  const SelectorBuilderResult(
      {required this.catalog,
      required this.policy,
      required this.loggerFactory,
      required this.enableTiming,});

  final StrategyCatalog catalog;
  final SelectorPolicy policy;
  final LoggerFactory loggerFactory;
  final bool enableTiming;
}
