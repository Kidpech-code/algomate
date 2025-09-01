/// Working AlgoMate Demo
///
/// This example demonstrates the complete AlgoMate functionality including
/// the new parallel algorithms for multi-core systems.
library final_demo;

import 'dart:io';
import 'dart:math';
import 'package:algomate/algomate.dart';

void main() async {
  print('🚀 AlgoMate Complete Demo');
  print('========================');
  print('CPU Cores: ${Platform.numberOfProcessors}');

  // Create AlgoMate selector facade
  final selector = AlgoSelectorFacade.development();

  await demonstrateBasicUsage(selector);
  await demonstrateAlgorithmComparison(selector);
  await demonstrateParallelAlgorithms(selector);
  await demonstrateAutoSelection(selector);
}

/// Basic usage demonstration
Future<void> demonstrateBasicUsage(AlgoSelectorFacade selector) async {
  print('\n📚 Basic AlgoMate Usage:');
  print('========================');

  final testData = generateRandomList(5000);

  print('\n1. Sorting Demo:');
  final sortResult = selector.sort(
    input: testData,
    hint: SelectorHint(n: testData.length),
  );

  sortResult.fold(
    (result) {
      print('   ✅ Sorted ${result.output.length} elements');
      print('   📊 Strategy: ${result.selectedStrategy.name}');
      final timeMs = result.executionTimeMicros! / 1000;
      print('   🕒 Time: ${timeMs.toStringAsFixed(2)}ms');
      print('   🔍 Preview: ${result.output.take(10).toList()}');
    },
    (failure) => print('   ❌ Sort failed: ${failure.message}'),
  );

  print('\n2. Search Demo:');
  final sortedData = List<int>.from(testData)..sort();
  final target = sortedData[Random().nextInt(sortedData.length)];

  final searchResult = selector.search(
    input: sortedData,
    target: target,
    hint: SelectorHint(n: sortedData.length),
  );

  searchResult.fold(
    (result) {
      print('   ✅ Found target $target');
      print('   📊 Strategy: ${result.selectedStrategy.name}');
      final timeMs = result.executionTimeMicros! / 1000;
      print('   🕒 Time: ${timeMs.toStringAsFixed(3)}ms');
      print('   🎯 Index: ${result.output}');
    },
    (failure) => print('   ❌ Search failed: ${failure.message}'),
  );
}

/// Algorithm comparison
Future<void> demonstrateAlgorithmComparison(AlgoSelectorFacade selector) async {
  print('\n⚡ Algorithm Performance Comparison:');
  print('===================================');

  final sizes = [1000, 10000, 50000];

  for (final size in sizes) {
    print('\n📊 Dataset size: $size elements');
    final testData = generateRandomList(size);

    // Test different sorting algorithms by providing hints
    final tests = [
      ('Default selection', SelectorHint(n: size)),
      ('Stable sort preferred', SelectorHint(n: size, preferStable: true)),
      (
        'Memory constrained',
        SelectorHint(n: size, memoryBudgetBytes: 1024 * 1024)
      ),
    ];

    for (final (testName, hint) in tests) {
      final result = selector.sort(
        input: List<int>.from(testData),
        hint: hint,
      );

      result.fold(
        (result) {
          final timeMs = result.executionTimeMicros! / 1000;
          print(
              '   🕒 $testName → ${result.selectedStrategy.name}: ${timeMs.toStringAsFixed(2)}ms');
        },
        (failure) => print('   ❌ $testName failed: ${failure.message}'),
      );
    }
  }
}

/// Demonstrate parallel algorithms for large datasets
Future<void> demonstrateParallelAlgorithms(AlgoSelectorFacade selector) async {
  print('\n🚀 Parallel Algorithm Demonstration:');
  print('====================================');

  // Large dataset for parallel processing
  final largeDataset = generateRandomList(100000);
  print('\\nTesting with ${largeDataset.length} elements...');

  print('\\n1. Large Dataset Sorting:');
  final parallelSortResult = selector.sort(
    input: largeDataset,
    hint: SelectorHint(n: largeDataset.length),
  );

  parallelSortResult.fold(
    (result) {
      final timeMs = result.executionTimeMicros! / 1000;
      print('   ✅ Parallel sort completed in ${timeMs.toStringAsFixed(2)}ms');
      print('   📊 Selected strategy: ${result.selectedStrategy.name}');
      print('   🔧 Cores utilized: ${Platform.numberOfProcessors}');
      print(
          '   📈 Throughput: ${(largeDataset.length / timeMs * 1000).toStringAsFixed(0)} elements/sec');
    },
    (failure) => print('   ❌ Parallel sort failed: ${failure.message}'),
  );

  print('\\n2. Direct Parallel Algorithm Usage:');

  // Demonstrate using parallel algorithms directly
  try {
    print('   🔧 Testing ParallelMergeSort directly...');
    final parallelMergeSort = ParallelMergeSort();

    if (parallelMergeSort.canApply(
        largeDataset, SelectorHint(n: largeDataset.length))) {
      final stopwatch = Stopwatch()..start();
      final directResult = parallelMergeSort.execute(List.from(largeDataset));
      stopwatch.stop();

      print(
          '   ✅ Direct parallel execution: ${stopwatch.elapsedMilliseconds}ms');
      print('   📏 Result length: ${directResult.length}');
      print('   ✓ Is sorted: ${_isSorted(directResult)}');
    } else {
      print('   ℹ️ Parallel algorithm not applicable for this dataset');
    }
  } catch (e) {
    print('   ❌ Direct parallel algorithm error: $e');
  }
}

/// Demonstrate automatic algorithm selection
Future<void> demonstrateAutoSelection(AlgoSelectorFacade selector) async {
  print('\\n🤖 Automatic Algorithm Selection:');
  print('==================================');

  final testCases = [
    (10, 'Very small dataset'),
    (100, 'Small dataset'),
    (5000, 'Medium dataset'),
    (50000, 'Large dataset'),
    (200000, 'Very large dataset'),
  ];

  for (final (size, description) in testCases) {
    final testData = generateRandomList(size);

    print('\\n📏 $description ($size elements):');

    // Let AlgoMate automatically select the best algorithm
    final result = selector.sort(
      input: testData,
      hint: SelectorHint(n: size), // Only provide size hint
    );

    result.fold(
      (result) {
        final timeMs = result.executionTimeMicros! / 1000;
        print('   🎯 Auto-selected: ${result.selectedStrategy.name}');
        print('   🕒 Execution time: ${timeMs.toStringAsFixed(2)}ms');

        // Calculate efficiency metrics
        final elementsPerMs = size / timeMs;
        print(
            '   📊 Throughput: ${elementsPerMs.toStringAsFixed(0)} elements/ms');
      },
      (failure) => print('   ❌ Auto-selection failed: ${failure.message}'),
    );
  }

  print('\\n✨ Summary:');
  print('   • AlgoMate automatically selects optimal algorithms');
  print('   • Parallel algorithms used for large datasets (>10K elements)');
  print('   • Sequential algorithms used for small datasets');
  print('   • Performance adapts to available CPU cores');
  print('   • Zero-allocation hot paths for maximum efficiency');
}

/// Utility functions
List<int> generateRandomList(int size) {
  final random = Random();
  return List.generate(size, (_) => random.nextInt(size * 2));
}

bool _isSorted(List<int> list) {
  for (int i = 1; i < list.length; i++) {
    if (list[i] < list[i - 1]) return false;
  }
  return true;
}
