import '../../../domain/entities/strategy.dart';
import '../../../domain/entities/strategy_signature.dart';
import '../../../domain/repositories/strategy_catalog.dart';

/// In-memory implementation of StrategyCatalog optimized for fast lookup.
///
/// **Performance**: Uses type-aware storage with List-based collections for performance.
/// Avoids dynamic types and reflection for hot path efficiency.
///
/// **Thread Safety**: This implementation is NOT thread-safe. For concurrent access,
/// external synchronization is required or consider using a thread-safe implementation.
/// Most usage patterns (single-threaded setup, then read-only access) are safe.
class InMemoryStrategyCatalog implements StrategyCatalog {
  InMemoryStrategyCatalog();

  // Storage organized by signature key for fast lookup
  final Map<String, List<_StrategyEntry>> _strategies = {};

  // Additional index by category for statistics
  final Map<String, int> _categoryCount = {};
  final Map<String, int> _typeCount = {};

  @override
  void register<I, O>(Strategy<I, O> strategy, StrategySignature signature) {
    final key = _createKey(signature);

    // Check for duplicate
    final entries = _strategies[key];
    if (entries != null) {
      for (final entry in entries) {
        if (entry.strategyName == strategy.meta.name) {
          throw ArgumentError(
              'Strategy "${strategy.meta.name}" already registered for signature $signature',);
        }
      }
    }

    _doRegister(strategy, signature, key);
  }

  @override
  void replace<I, O>(Strategy<I, O> strategy, StrategySignature signature) {
    final key = _createKey(signature);

    // Remove existing strategy with same name if it exists
    remove<I, O>(strategy.meta.name, signature);

    _doRegister(strategy, signature, key);
  }

  @override
  bool remove<I, O>(String strategyName, StrategySignature signature) {
    final key = _createKey(signature);
    final entries = _strategies[key];

    if (entries == null) return false;

    for (var i = 0; i < entries.length; i++) {
      if (entries[i].strategyName == strategyName) {
        entries.removeAt(i);

        // Update statistics
        _categoryCount[signature.category] =
            (_categoryCount[signature.category] ?? 0) - 1;
        _typeCount[signature.inputType.toString()] =
            (_typeCount[signature.inputType.toString()] ?? 0) - 1;

        // Remove empty entries list
        if (entries.isEmpty) {
          _strategies.remove(key);
        }

        return true;
      }
    }

    return false;
  }

  @override
  List<Strategy<I, O>> list<I, O>(StrategySignature signature) {
    final key = _createKey(signature);
    final entries = _strategies[key];

    if (entries == null) return [];

    // Return defensive copy with type casting
    final result = <Strategy<I, O>>[];
    for (final entry in entries) {
      if (entry.strategy is Strategy<I, O>) {
        result.add(entry.strategy as Strategy<I, O>);
      }
    }

    return result;
  }

  @override
  Strategy<I, O>? find<I, O>(String strategyName, StrategySignature signature) {
    final key = _createKey(signature);
    final entries = _strategies[key];

    if (entries == null) return null;

    for (final entry in entries) {
      if (entry.strategyName == strategyName &&
          entry.strategy is Strategy<I, O>) {
        return entry.strategy as Strategy<I, O>;
      }
    }

    return null;
  }

  @override
  bool contains<I, O>(String strategyName, StrategySignature signature) {
    return find<I, O>(strategyName, signature) != null;
  }

  @override
  int get count {
    var total = 0;
    for (final entries in _strategies.values) {
      total += entries.length;
    }
    return total;
  }

  @override
  List<StrategySignature> get signatures {
    final result = <StrategySignature>[];

    for (final entries in _strategies.values) {
      if (entries.isNotEmpty) {
        result.add(entries.first.signature);
      }
    }

    return result;
  }

  @override
  void clear() {
    _strategies.clear();
    _categoryCount.clear();
    _typeCount.clear();
  }

  @override
  void registerBatch<I, O>(
      List<Strategy<I, O>> strategies, StrategySignature signature,) {
    for (final strategy in strategies) {
      register<I, O>(strategy, signature);
    }
  }

  @override
  CatalogStats get stats {
    return CatalogStats(
        totalStrategies: count,
        categoryCounts: Map.from(_categoryCount),
        typeCounts: Map.from(_typeCount),);
  }

  /// Internal method to perform the registration
  void _doRegister<I, O>(
      Strategy<I, O> strategy, StrategySignature signature, String key,) {
    // Add to main storage
    final entries = _strategies[key] ??= <_StrategyEntry>[];
    entries.add(_StrategyEntry(
        strategy: strategy,
        strategyName: strategy.meta.name,
        signature: signature,),);

    // Update statistics
    _categoryCount[signature.category] =
        (_categoryCount[signature.category] ?? 0) + 1;
    _typeCount[signature.inputType.toString()] =
        (_typeCount[signature.inputType.toString()] ?? 0) + 1;
  }

  /// Create a consistent key for strategy lookup
  String _createKey(StrategySignature signature) {
    final typeKey = '${signature.inputType}->${signature.outputType}';
    final categoryKey = signature.category;
    final tagKey = signature.tag ?? '';

    return '$typeKey:$categoryKey:$tagKey';
  }

  /// Debug method to inspect catalog contents
  Map<String, List<String>> debugDump() {
    final result = <String, List<String>>{};

    for (final entry in _strategies.entries) {
      final strategyNames = entry.value.map((e) => e.strategyName).toList();
      result[entry.key] = strategyNames;
    }

    return result;
  }
}

/// Internal class for storing strategy entries with metadata
class _StrategyEntry {
  const _StrategyEntry(
      {required this.strategy,
      required this.strategyName,
      required this.signature,});

  final Strategy<dynamic, dynamic>
      strategy; // Using dynamic Strategy for storage efficiency
  final String strategyName;
  final StrategySignature signature;
}
