import 'dart:math';
import 'package:algomate/algomate.dart';

// Import specific classes for the example
import 'package:algomate/src/infrastructure/adapters/execution/concrete_direct_executor.dart';
import 'package:algomate/src/interface/performance/direct_executor.dart';

/// Example demonstrating DirectExecutor and OverheadAnalyzer
///
/// Shows how to use the fast path API for performance-critical scenarios
/// and analyze the overhead differences between direct execution and
/// selector-based execution.
void main() async {
  print('🎯 AlgoMate DirectExecutor & Performance Analysis Demo');
  print('====================================================\n');

  await demonstrateDirectExecution();
  await demonstrateBoundStrategy();
  await demonstrateOverheadAnalysis();

  print('\n✅ All DirectExecutor demonstrations completed!');
}

/// Demonstrate direct strategy execution
Future<void> demonstrateDirectExecution() async {
  print('⚡ Direct Strategy Execution');
  print('----------------------------');

  // Create a direct executor (would normally be injected)
  final catalog = InMemoryStrategyCatalog();
  final directExecutor = ConcreteDirectExecutor(catalog);

  // Register some strategies
  _registerStrategies(catalog);

  // List available strategies
  final availableStrategies = directExecutor.getAvailableStrategies();
  print('Available strategies: ${availableStrategies.join(", ")}');

  // Test data
  final testData = [64, 34, 25, 12, 22, 11, 90, 88, 7, 50];
  print('Input data: $testData');

  // Direct execution examples
  print('\n1. Direct MergeSort execution:');
  final mergeSortResult = directExecutor.execute('merge_sort', testData);

  mergeSortResult.fold(
    (dynamic sorted) {
      final sortedList = sorted as List<int>;
      print('   ✓ Sorted: $sortedList');
      print(
          '   ✓ Verification: ${_isArraySorted(sortedList) ? "PASSED" : "FAILED"}',);
    },
    (failure) => print('   ❌ Failed: $failure'),
  );

  print('\n2. Direct QuickSort execution:');
  final quickSortResult =
      directExecutor.execute('quick_sort', List<int>.from(testData));

  quickSortResult.fold(
    (dynamic sorted) {
      final sortedList = sorted as List<int>;
      print('   ✓ Sorted: $sortedList');
      print(
          '   ✓ Verification: ${_isArraySorted(sortedList) ? "PASSED" : "FAILED"}',);
    },
    (failure) => print('   ❌ Failed: $failure'),
  );

  // Strategy info lookup
  print('\n3. Strategy Metadata:');
  final mergeInfo = directExecutor.getStrategyInfo('merge_sort');
  if (mergeInfo != null) {
    print('   ✓ MergeSort: ${mergeInfo.description}');
    print('   ✓ Time Complexity: ${mergeInfo.timeComplexity}');
    print('   ✓ Space Complexity: ${mergeInfo.spaceComplexity}');
    print('   ✓ Memory Overhead: ${mergeInfo.memoryOverheadBytes} bytes');
  }

  // Error handling example
  print('\n4. Error Handling:');
  final invalidResult = directExecutor.execute('nonexistent_sort', testData);
  invalidResult.fold(
    (success) => print('   Unexpected success: $success'),
    (failure) => print('   ✓ Expected failure: ${failure.message}'),
  );
}

/// Demonstrate BoundStrategy for compile-time optimization
Future<void> demonstrateBoundStrategy() async {
  print('\n\n🔗 BoundStrategy (Compile-time Optimization)');
  print('--------------------------------------------');

  // Test data
  final testData = List.generate(20, (i) => Random().nextInt(100));
  print('Input data: $testData');

  // Create bound strategies for zero-overhead execution
  print('\n1. Strategy-bound execution (fastest):');
  final mergeSort = MergeSortStrategy();
  final boundMergeSort = BoundStrategy.fromStrategy(mergeSort);

  final stopwatch1 = Stopwatch()..start();
  final result1 = boundMergeSort.execute(testData);
  stopwatch1.stop();

  result1.fold(
    (sorted) {
      print('   ✓ Sorted in ${stopwatch1.elapsedMicroseconds}μs');
      print('   ✓ Strategy: ${boundMergeSort.strategyName}');
      print('   ✓ Result: ${sorted.take(10).join(", ")}...');
    },
    (failure) => print('   ❌ Failed: $failure'),
  );

  print('\n2. Name-bound execution (slower fallback):');
  const boundByName = BoundStrategy<List<int>, List<int>>('heap_sort');

  final stopwatch2 = Stopwatch()..start();
  final result2 = boundByName.execute(List.from(testData));
  stopwatch2.stop();

  result2.fold(
    (sorted) {
      print('   ✓ Executed in ${stopwatch2.elapsedMicroseconds}μs');
      print('   ✓ Strategy: ${boundByName.strategyName}');
    },
    (failure) =>
        print('   ❌ Expected failure (not registered): ${failure.message}'),
  );

  // Multiple bound strategies
  print('\n3. Performance comparison of bound strategies:');
  final strategies = [
    BoundStrategy<List<int>, List<int>>.fromStrategy(MergeSortStrategy()),
    BoundStrategy<List<int>, List<int>>.fromStrategy(QuickSort()),
    BoundStrategy<List<int>, List<int>>.fromStrategy(InsertionSortStrategy()),
  ];

  final largerData = List.generate(1000, (i) => Random().nextInt(1000));

  for (final boundStrategy in strategies) {
    final stopwatch = Stopwatch()..start();
    final result = boundStrategy.execute(List<int>.from(largerData));
    stopwatch.stop();

    result.fold(
      (sorted) => print(
          '   ✓ ${boundStrategy.strategyName}: ${stopwatch.elapsedMilliseconds}ms',),
      (failure) => print('   ❌ ${boundStrategy.strategyName}: $failure'),
    );
  }
}

/// Demonstrate overhead analysis
Future<void> demonstrateOverheadAnalysis() async {
  print('\n\n📊 Overhead Analysis');
  print('--------------------');

  // This is a simplified demo - real implementation would need
  // proper DirectExecutor and AlgoSelectorFacade integration
  print('Note: This is a demonstration of the API structure.');
  print('Full implementation requires integration with strategy catalog.\n');

  // Show what the API would look like
  print('1. Overhead Analysis API:');
  print('```dart');
  print('final overheadResults = await OverheadAnalyzer.analyzeOverhead(');
  print('  "merge_sort",');
  print('  largeDataset,');
  print('  iterations: 1000,');
  print('  directExecutor: directExecutor,');
  print('  selector: AlgoSelectorFacade.production(),');
  print(');');
  print('```');

  print('\n2. Strategy Benchmarking API:');
  print('```dart');
  print('final benchmarkResults = await OverheadAnalyzer.benchmarkStrategy(');
  print('  "quick_sort",');
  print('  dataset,');
  print('  iterations: 5000,');
  print('  directExecutor: directExecutor,');
  print(');');
  print('```');

  // Simulate some results
  print('\n3. Example Analysis Results:');
  print('   📈 Direct Execution:     125μs (median)');
  print('   📈 Selector Execution:   187μs (median)');
  print('   📈 Overhead:             62μs (49.6%)');
  print('   📈 Recommendation: Use DirectExecutor for hot paths');

  print('\n4. Detailed Benchmark Results:');
  print('   📊 Strategy: merge_sort');
  print('   📊 Iterations: 5000');
  print('   📊 Success Rate: 100%');
  print('   📊 Median: 125μs');
  print('   📊 Mean: 127.3μs');
  print('   📊 P95: 145μs');
  print('   📊 P99: 189μs');
  print('   📊 Std Dev: 12.7μs');

  // Performance guidance
  print('\n💡 Performance Guidance:');
  print('   • Use BoundStrategy.fromStrategy() for maximum performance');
  print('   • Use DirectExecutor when algorithm is known at runtime');
  print('   • Use AlgoSelector for algorithm selection scenarios');
  print('   • DirectExecutor overhead is ~50% less than full selector');
  print('   • BoundStrategy has near-zero overhead vs direct algorithm calls');
}

/// Helper function to register strategies for testing
void _registerStrategies(InMemoryStrategyCatalog catalog) {
  // Register sorting strategies
  final sortSignature = StrategySignature.sort(inputType: List<int>);

  catalog.register(MergeSortStrategy(), sortSignature);
  catalog.register(QuickSort(), sortSignature);
  catalog.register(InsertionSortStrategy(), sortSignature);
  catalog.register(HeapSort(), sortSignature);

  // Register search strategies (if available)
  // final searchSignature = StrategySignature.search(
  //   inputType: List<int>,
  //   outputType: int,
  // );

  // Would register search strategies here if available
  // catalog.register(BinarySearchStrategy(target: 0), searchSignature);
}

/// Helper function to check if array is sorted
bool _isArraySorted(List<int> array) {
  for (int i = 1; i < array.length; i++) {
    if (array[i] < array[i - 1]) return false;
  }
  return true;
}

/// Performance testing utility
class PerformanceTester {
  /// Run a simple performance comparison
  static Future<Map<String, double>> compareExecutionMethods() async {
    final testData = List.generate(10000, (i) => Random().nextInt(100000));
    const iterations = 100;

    // Direct algorithm call (baseline)
    final directTimes = <int>[];
    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();
      _directMergeSort(List.from(testData));
      stopwatch.stop();
      directTimes.add(stopwatch.elapsedMicroseconds);
    }

    // BoundStrategy execution
    final boundStrategy =
        BoundStrategy<List<int>, List<int>>.fromStrategy(MergeSortStrategy());
    final boundTimes = <int>[];
    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();
      boundStrategy.execute(List<int>.from(testData));
      stopwatch.stop();
      boundTimes.add(stopwatch.elapsedMicroseconds);
    }

    final directMedian = _median(directTimes).toDouble();
    final boundMedian = _median(boundTimes).toDouble();

    return {
      'direct_median_us': directMedian,
      'bound_strategy_median_us': boundMedian,
      'bound_overhead_percent':
          ((boundMedian - directMedian) / directMedian) * 100,
    };
  }

  static List<int> _directMergeSort(List<int> list) {
    if (list.length <= 1) return list;

    final middle = list.length ~/ 2;
    final left = _directMergeSort(list.sublist(0, middle));
    final right = _directMergeSort(list.sublist(middle));

    return _merge(left, right);
  }

  static List<int> _merge(List<int> left, List<int> right) {
    final result = <int>[];
    int i = 0, j = 0;

    while (i < left.length && j < right.length) {
      if (left[i] <= right[j]) {
        result.add(left[i++]);
      } else {
        result.add(right[j++]);
      }
    }

    result.addAll(left.sublist(i));
    result.addAll(right.sublist(j));
    return result;
  }

  static int _median(List<int> values) {
    final sorted = List<int>.from(values)..sort();
    return sorted[sorted.length ~/ 2];
  }
}
