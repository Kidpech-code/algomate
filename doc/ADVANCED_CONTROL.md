# Advanced Control & Customization 🎛️

**Powerful features for fine-grained algorithm control, constraints, and custom implementations.**

---

## 🚧 Algorithm Constraints

### Force Specific Algorithm

```dart
// Force a specific algorithm regardless of data characteristics
final constrainedSelector = AlgoSelectorFacade.development()
  .withForcedAlgorithm('merge_sort') // Override automatic selection
  .build();

// Or using hint system
final result = selector.sort(
  input: data,
  hint: SelectorHint(
    forceAlgorithm: 'quick_sort',
    bypassAnalysis: true, // Skip data pattern analysis
  ),
);
```

### Complexity Constraints

```dart
// Limit maximum time complexity
final boundedSelector = AlgoSelectorFacade.development()
  .withMaxComplexity(TimeComplexity.nLogN) // No O(n²) algorithms
  .build();

// Exclude specific complexity classes
final result = selector.sort(
  input: data,
  hint: SelectorHint(
    maxComplexity: TimeComplexity.nLogN,
    excludeComplexities: [TimeComplexity.quadratic],
  ),
);
```

### Memory Constraints

```dart
// Disable memory-intensive algorithms
final memoryConstrainedSelector = AlgoSelectorFacade.production()
  .withMemoryConstraint(MemoryConstraint.low) // Max 16MB
  .withInPlacePreference(true) // Prefer in-place algorithms
  .build();

// Fine-grained memory control
final result = selector.sort(
  input: data,
  hint: SelectorHint(
    maxMemoryMB: 32,
    preferInPlace: true,
    avoidAllocation: true, // No auxiliary arrays
  ),
);
```

### Recursive Algorithm Control

```dart
// Avoid recursive algorithms (stack overflow protection)
final iterativeSelector = AlgoSelectorFacade.production()
  .withRecursionLimit(maxDepth: 100)
  .withPreferIterative(true)
  .build();

// Using hints
final result = selector.sort(
  input: data,
  hint: SelectorHint(
    allowRecursive: false, // Only iterative implementations
    maxStackDepth: 50,     // Limit recursion depth
  ),
);
```

---

## 🔧 Custom Algorithm Implementation

### Creating Custom Strategy

```dart
// Define your own sorting algorithm
class CocktailShakerSort extends SortingStrategy<int> {
  @override
  String get name => 'cocktail_shaker_sort';

  @override
  AlgorithmMetadata get metadata => AlgorithmMetadata(
    name: name,
    timeComplexity: TimeComplexity.quadratic,
    spaceComplexity: TimeComplexity.constant,
    isStable: true,
    isInPlace: true,
    description: 'Bidirectional bubble sort variant',
    bestCase: TimeComplexity.linear,
    averageCase: TimeComplexity.quadratic,
    worstCase: TimeComplexity.quadratic,
  );

  @override
  List<int> sort(List<int> input, {Comparator<int>? comparator}) {
    final data = List<int>.from(input);
    final compare = comparator ?? (a, b) => a.compareTo(b);

    int left = 0;
    int right = data.length - 1;
    bool swapped = true;

    while (swapped) {
      swapped = false;

      // Left to right pass
      for (int i = left; i < right; i++) {
        if (compare(data[i], data[i + 1]) > 0) {
          final temp = data[i];
          data[i] = data[i + 1];
          data[i + 1] = temp;
          swapped = true;
        }
      }
      right--;

      if (!swapped) break;

      // Right to left pass
      for (int i = right; i > left; i--) {
        if (compare(data[i], data[i - 1]) < 0) {
          final temp = data[i];
          data[i] = data[i - 1];
          data[i - 1] = temp;
          swapped = true;
        }
      }
      left++;
    }

    return data;
  }

  @override
  bool isApplicable(SelectorHint? hint) {
    // Define when this algorithm should be considered
    if (hint?.maxComplexity == TimeComplexity.quadratic) return true;
    if (hint?.preferInPlace == true && hint?.preferStable == true) return true;
    return hint?.n != null && hint!.n! < 100; // Small datasets only
  }

  @override
  int estimatePerformance(SelectorHint? hint) {
    // Return relative performance score (lower is better)
    final n = hint?.n ?? 100;

    // Nearly sorted data performs much better
    if (hint?.dataPattern == DataPattern.nearlySorted) {
      return (n * 1.5).round(); // Much better than O(n²)
    }

    return n * n; // O(n²) for random data
  }

  @override
  double estimateMemoryMB(SelectorHint? hint) {
    return 0.001; // In-place, minimal memory usage
  }
}
```

### Registering Custom Strategy

```dart
// Register your custom algorithm
final customSelector = AlgoMate.createSelector()
  .registerSortingStrategy(CocktailShakerSort())
  .withLogging(LogLevel.debug) // See when it gets selected
  .build();

// Now AlgoMate can automatically choose your algorithm
final result = customSelector.sort(
  input: smallNearlySortedData,
  hint: SelectorHint(preferInPlace: true, preferStable: true),
);

// Your algorithm will be considered alongside built-ins
result.fold(
  (success) {
    print('Selected algorithm: ${success.metadata.name}');
    // Might output: "Selected algorithm: cocktail_shaker_sort"
  },
  (failure) => print('Error: ${failure.message}'),
);
```

---

## 🏗️ Plugin Architecture

### Creating Algorithm Plugin

```dart
// Create a plugin that adds multiple related algorithms
class ExperimentalSortingPlugin extends AlgoMatePlugin {
  @override
  String get name => 'experimental_sorting';

  @override
  String get version => '1.0.0';

  @override
  List<String> get supportedOperations => ['sorting'];

  @override
  void initialize(AlgoMateConfig config) {
    // Plugin initialization logic
    print('🧪 Initializing experimental sorting algorithms...');
  }

  @override
  List<Strategy> getStrategies() => [
    CocktailShakerSort(),
    StoogeSortStrategy(),
    PancakeSortStrategy(),
    BogoSortStrategy(), // For fun/educational purposes only!
  ];

  @override
  Map<String, dynamic> getConfiguration() => {
    'enable_educational_algorithms': true,
    'warn_inefficient_selection': true,
    'max_bogo_sort_elements': 5, // Safety limit
  };

  @override
  void dispose() {
    // Cleanup resources
    print('🧪 Experimental plugin disposed');
  }
}

// Use plugin
final experimentalSelector = AlgoMate.createSelector()
  .addPlugin(ExperimentalSortingPlugin())
  .withSafetyConstraints(enabled: true) // Prevent accidental O(n!) selection
  .build();
```

### Machine Learning Strategy Selection

```dart
// Advanced: ML-based algorithm selection
class MLStrategySelectionPlugin extends AlgoMatePlugin {
  late MLModel _model;

  @override
  String get name => 'ml_strategy_selection';

  @override
  void initialize(AlgoMateConfig config) {
    _model = MLModel.loadFromAssets('assets/strategy_selection_model.tflite');
  }

  @override
  Strategy? selectOptimalStrategy(
    List<Strategy> candidates,
    SelectorHint? hint,
    DataAnalysis analysis,
  ) {
    final features = _extractFeatures(hint, analysis);
    final prediction = _model.predict(features);

    return candidates.firstWhere(
      (strategy) => strategy.name == prediction.strategyName,
      orElse: () => candidates.first, // Fallback to default selection
    );
  }

  List<double> _extractFeatures(SelectorHint? hint, DataAnalysis analysis) {
    return [
      (hint?.n ?? 0).toDouble(),                    // Dataset size
      analysis.entropyScore,                        // Data randomness
      analysis.inversionCount.toDouble(),           // Sortedness measure
      analysis.duplicateRatio,                      // Duplicate percentage
      Platform.numberOfProcessors.toDouble(),      // Available cores
      analysis.estimatedMemoryMB,                  // Memory requirement
    ];
  }
}
```

---

## 🎯 Advanced Selection Policies

### Custom Selection Policy

```dart
// Define custom algorithm selection logic
class GameOptimizedPolicy extends SelectorPolicy {
  @override
  String get name => 'game_optimized';

  @override
  Strategy? selectStrategy(
    List<Strategy> candidates,
    SelectorHint? hint,
    DataAnalysis analysis,
  ) {
    // Gaming-specific selection logic

    // Real-time requirement: prefer consistent performance
    if (hint?.context == ExecutionContext.gaming) {
      return candidates
          .where((s) => s.metadata.worstCase == s.metadata.averageCase)
          .firstOrNull ?? // Consistent time complexity
          candidates.first;
    }

    // Leaderboard updates: stability important
    if (hint?.useCase == 'leaderboard') {
      return candidates
          .where((s) => s.metadata.isStable)
          .reduce((a, b) =>
              a.estimatePerformance(hint) < b.estimatePerformance(hint) ? a : b);
    }

    // AI pathfinding: memory-constrained
    if (hint?.useCase == 'pathfinding') {
      return candidates
          .where((s) => s.metadata.spaceComplexity.order <= 1) // O(1) or O(log n)
          .reduce((a, b) =>
              a.estimatePerformance(hint) < b.estimatePerformance(hint) ? a : b);
    }

    return null; // Fall back to default policy
  }

  @override
  bool shouldOverride(SelectorHint? hint) {
    return hint?.context == ExecutionContext.gaming ||
           hint?.useCase?.contains('game') == true;
  }
}

// Apply custom policy
final gameSelector = AlgoMate.createSelector()
  .withSelectionPolicy(GameOptimizedPolicy())
  .withLogging(LogLevel.debug) // See policy decisions
  .build();
```

---

## 🔒 Safety & Validation

### Algorithm Validation

```dart
// Validate custom algorithms automatically
final validator = AlgorithmValidator();

// Test your custom algorithm
final validationResult = await validator.validate(
  strategy: CocktailShakerSort(),
  testCases: [
    ValidationCase.empty(),
    ValidationCase.singleElement(),
    ValidationCase.random(size: 1000),
    ValidationCase.sorted(size: 1000),
    ValidationCase.reverse(size: 1000),
    ValidationCase.duplicates(size: 1000, uniqueCount: 10),
    ValidationCase.stressTest(size: 100000),
  ],
);

if (validationResult.passed) {
  print('✅ Algorithm validation passed');
  print('   Correctness: ${validationResult.correctnessScore}/100');
  print('   Performance: ${validationResult.performanceScore}/100');
  print('   Stability: ${validationResult.stabilityVerified ? "✅" : "❌"}');
} else {
  print('❌ Validation failed:');
  for (final error in validationResult.errors) {
    print('   ${error.testCase}: ${error.message}');
  }
}
```

### Performance Regression Detection

```dart
// Automatically detect performance regressions
final regressionDetector = PerformanceRegressionDetector();

await regressionDetector.baseline(
  algorithm: CocktailShakerSort(),
  datasets: standardTestSuite,
  iterations: 1000,
);

// Later, after algorithm modifications
final regressionResult = await regressionDetector.check(
  algorithm: CocktailShakerSort(),
  threshold: 0.05, // 5% performance degradation threshold
);

if (regressionResult.hasRegression) {
  print('🚨 Performance regression detected!');
  print('   Slowdown: ${regressionResult.percentSlower}%');
  print('   Affected datasets: ${regressionResult.affectedDatasets}');
}
```

---

## 🎮 Interactive Algorithm Explorer

### Algorithm Playground

```dart
// Interactive tool for algorithm exploration
class AlgorithmPlayground {
  final AlgoSelectorFacade selector;

  AlgorithmPlayground() : selector = AlgoSelectorFacade.development();

  Future<void> interactiveExploration() async {
    print('🎮 AlgoMate Interactive Playground');
    print('Enter dataset size (or "quit"):');

    while (true) {
      final input = stdin.readLineSync();
      if (input == 'quit') break;

      final size = int.tryParse(input ?? '');
      if (size == null) {
        print('Invalid input. Enter a number:');
        continue;
      }

      await _exploreDataset(size);
    }
  }

  Future<void> _exploreDataset(int size) async {
    final datasets = {
      'Random': DataGenerator.random(size: size, seed: 42),
      'Sorted': DataGenerator.sorted(size: size),
      'Reverse': DataGenerator.reverse(size: size),
      'Nearly Sorted': DataGenerator.nearlySorted(size: size, shufflePercent: 0.05),
      'Duplicates': DataGenerator.duplicateHeavy(size: size, uniqueValues: size ~/ 10),
    };

    print('\n📊 Analysis for $size elements:');
    print('─' * 50);

    for (final entry in datasets.entries) {
      final analysis = await _analyzeDataset(entry.key, entry.value);
      print('${entry.key.padRight(15)}: ${analysis}');
    }

    print('\n🔧 Try different constraints:');
    await _tryConstraints(datasets['Random']!);
  }

  Future<String> _analyzeDataset(String name, List<int> data) async {
    final result = selector.sort(
      input: List.from(data),
      hint: SelectorHint(n: data.length),
    );

    return result.fold(
      (success) {
        final throughput = (data.length / success.executionTime * 1000000).round();
        return '${success.metadata.name.padRight(12)} ${success.executionTime}μs (${throughput} elem/sec)';
      },
      (failure) => 'Error: ${failure.message}',
    );
  }

  Future<void> _tryConstraints(List<int> data) async {
    final constraints = [
      ('Memory Constrained', SelectorHint(maxMemoryMB: 1, preferInPlace: true)),
      ('No Recursion', SelectorHint(allowRecursive: false)),
      ('Stable Required', SelectorHint(preferStable: true)),
      ('Max O(n log n)', SelectorHint(maxComplexity: TimeComplexity.nLogN)),
      ('Force QuickSort', SelectorHint(forceAlgorithm: 'quick_sort')),
    ];

    for (final constraint in constraints) {
      final result = selector.sort(
        input: List.from(data),
        hint: constraint.$2,
      );

      result.fold(
        (success) => print('${constraint.$1.padRight(18)}: ${success.metadata.name}'),
        (failure) => print('${constraint.$1.padRight(18)}: ${failure.message}'),
      );
    }
  }
}

// Usage
void main() async {
  final playground = AlgorithmPlayground();
  await playground.interactiveExploration();
}
```

---

## 🚀 Advanced Usage Examples

### Dynamic Strategy Switching

```dart
// Change strategies based on runtime conditions
class AdaptiveProcessor {
  AlgoSelectorFacade _selector;

  AdaptiveProcessor() : _selector = AlgoSelectorFacade.production();

  Future<void> processDataStream(Stream<List<int>> dataStream) async {
    await for (final batch in dataStream) {
      // Adapt based on current system state
      _selector = _adaptToSystemState(batch.length);

      final result = _selector.sort(input: batch);
      result.fold(
        (success) => _processSortedData(success.output),
        (failure) => _handleError(failure),
      );
    }
  }

  AlgoSelectorFacade _adaptToSystemState(int dataSize) {
    final memoryUsage = _getCurrentMemoryUsage();
    final cpuLoad = _getCurrentCpuLoad();
    final batteryLevel = _getBatteryLevel(); // Mobile devices

    if (batteryLevel != null && batteryLevel < 0.2) {
      // Battery saving mode: prefer efficient algorithms
      return AlgoSelectorFacade.production()
        .withPerformancePriority(PerformancePriority.memory)
        .withParallelExecutionDisabled()
        .build();
    }

    if (memoryUsage > 0.8) {
      // High memory pressure: prefer in-place algorithms
      return AlgoSelectorFacade.production()
        .withMemoryConstraint(MemoryConstraint.veryLow)
        .withInPlacePreference(true)
        .build();
    }

    if (cpuLoad < 0.3 && dataSize > 100000) {
      // Plenty of CPU available: use parallel algorithms
      return AlgoSelectorFacade.production()
        .withParallelExecution(enabled: true)
        .withMaxIsolates(Platform.numberOfProcessors)
        .build();
    }

    return AlgoSelectorFacade.production();
  }
}
```

---

**🎯 Pro Tip**: Start with built-in constraints and selection hints, then gradually implement custom strategies and plugins as your requirements become more specific.
