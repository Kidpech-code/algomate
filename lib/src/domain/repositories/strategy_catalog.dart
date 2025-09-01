import '../entities/strategy.dart';
import '../entities/strategy_signature.dart';

/// Repository port for storing and retrieving algorithm strategies.
///
/// Provides type-safe storage and fast lookup of strategies based on
/// their signatures and characteristics. Implementations should optimize
/// for fast lookup in the hot path.
abstract class StrategyCatalog {
  /// Register a strategy with the given signature.
  ///
  /// Throws [ArgumentError] if a strategy with the same name and signature
  /// is already registered (use [replace] to update existing strategies).
  void register<I, O>(Strategy<I, O> strategy, StrategySignature signature);

  /// Replace an existing strategy or register a new one.
  ///
  /// This is useful for overriding built-in strategies with custom implementations.
  void replace<I, O>(Strategy<I, O> strategy, StrategySignature signature);

  /// Remove a strategy by name and signature.
  ///
  /// Returns true if the strategy was found and removed, false otherwise.
  bool remove<I, O>(String strategyName, StrategySignature signature);

  /// List all strategies that match the given signature.
  ///
  /// Returns strategies that can handle the input/output types and category.
  /// The returned list should be safe to modify (defensive copy).
  ///
  /// Type parameters must match exactly - no covariance/contravariance.
  List<Strategy<I, O>> list<I, O>(StrategySignature signature);

  /// Find a specific strategy by name and signature.
  ///
  /// Returns null if no matching strategy is found.
  Strategy<I, O>? find<I, O>(String strategyName, StrategySignature signature);

  /// Check if a strategy exists with the given name and signature.
  bool contains<I, O>(String strategyName, StrategySignature signature);

  /// Get the total number of registered strategies.
  int get count;

  /// Get all registered signatures (useful for debugging/introspection).
  List<StrategySignature> get signatures;

  /// Clear all registered strategies.
  ///
  /// Use with caution - typically only needed for testing.
  void clear();

  /// Register multiple strategies at once.
  ///
  /// This can be more efficient than individual registrations for batch operations.
  void registerBatch<I, O>(List<Strategy<I, O>> strategies, StrategySignature signature);

  /// Get statistics about the catalog (for debugging/monitoring).
  CatalogStats get stats;
}

/// Statistics about the strategy catalog.
class CatalogStats {
  const CatalogStats({required this.totalStrategies, required this.categoryCounts, required this.typeCounts});

  /// Total number of registered strategies
  final int totalStrategies;

  /// Number of strategies per category (e.g., {'search': 3, 'sort': 5})
  final Map<String, int> categoryCounts;

  /// Number of strategies per input type (e.g., {'List\<int\>': 6, 'String': 2})
  final Map<String, int> typeCounts;

  @override
  String toString() => 'CatalogStats('
      'total: $totalStrategies, '
      'categories: $categoryCounts, '
      'types: $typeCounts'
      ')';
}
