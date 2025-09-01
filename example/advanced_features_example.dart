import 'dart:math';
import 'package:algomate/algomate.dart';

/// Advanced AlgoMate features demonstration including:
/// - Production configuration
/// - Custom policies
/// - Benchmarking
/// - Concurrent execution
/// - Error handling patterns
/// - Performance optimization
void main() async {
  print('🚀 AlgoMate - Advanced Features Demonstration');
  print('==============================================\n');

  // Example 1: Production configuration
  await productionConfigExample();

  print('\n');

  // Example 2: Custom selection policy
  customPolicyExample();

  print('\n');

  // Example 3: Benchmarking and performance analysis
  benchmarkingExample();

  print('\n');

  // Example 4: Error handling patterns
  errorHandlingExample();

  print('\n');

  // Example 5: Complex data scenarios
  complexDataScenariosExample();

  print('\n');

  // Example 6: Algorithm comparison
  algorithmComparisonExample();
}

Future<void> productionConfigExample() async {
  print('🏭 1. Production Configuration');
  print('------------------------------');

  // Create a production-optimized selector
  final productionSelector = AlgoSelectorFacade.production();

  // Example production workload - sorting large datasets
  final largeDataset = List.generate(10000, (i) => Random().nextInt(100000));

  print('Processing ${largeDataset.length} elements in production mode...');

  final stopwatch = Stopwatch()..start();

  final result = productionSelector.sort(
    input: largeDataset,
    hint: SelectorHint(
      n: largeDataset.length,
      memoryBudgetBytes: 16 * 1024 * 1024, // 16MB memory limit
      preferStable: true, // Business requirement for stable sorting
    ),
  );

  stopwatch.stop();

  result.fold(
    (success) {
      print(
        '✅ Production sort completed in ${stopwatch.elapsedMilliseconds}ms',
      );
      print('   → Algorithm: ${success.selectedStrategy.name}');
      print('   → Complexity: ${success.selectedStrategy.timeComplexity}');
      print(
        '   → Is stable: ${success.selectedStrategy.spaceComplexity == TimeComplexity.o1 ? "In-place" : "Uses extra space"}',
      );
      print(
        '   → Sample output: ${success.output.take(5).toList()}...${success.output.skip(success.output.length - 5).toList()}',
      );
    },
    (failure) => print('❌ Production sort failed: $failure'),
  );
}

void customPolicyExample() {
  print('🎯 2. Custom Selection Policy');
  print('-----------------------------');

  // Create selector with development defaults first
  final selector = AlgoSelectorFacade.development();

  // Test with different dataset characteristics
  final testCases = <TestCase>[
    TestCase('Small random', List.generate(20, (i) => Random().nextInt(100))),
    TestCase('Medium sorted', List.generate(500, (i) => i)),
    TestCase('Large reverse', List.generate(2000, (i) => 2000 - i)),
    TestCase('With duplicates', List.generate(100, (i) => i % 10)),
  ];

  for (final testCase in testCases) {
    print('\nTesting: ${testCase.name} (${testCase.data.length} elements)');

    // Different hints to see how algorithm selection changes
    final hints = [
      ('Default', SelectorHint(n: testCase.data.length)),
      ('Memory-constrained', SelectorHint.lowMemory(n: testCase.data.length)),
      (
        'Stable preferred',
        SelectorHint(n: testCase.data.length, preferStable: true)
      ),
    ];

    for (final (hintName, hint) in hints) {
      final result = selector.sort(input: List.from(testCase.data), hint: hint);

      result.fold(
        (success) {
          print(
            '   $hintName → ${success.selectedStrategy.name} (${success.selectedStrategy.timeComplexity})',
          );
        },
        (failure) => print('   $hintName → Failed: $failure'),
      );
    }
  }
}

void benchmarkingExample() {
  print('📊 3. Benchmarking & Performance Analysis');
  print('-----------------------------------------');

  final selector = AlgoSelectorFacade.development();

  // Performance comparison across different dataset sizes
  final testSizes = [10, 50, 100, 500, 1000, 5000];
  final results = <String, List<BenchmarkResult>>{};

  print('Running performance benchmarks...\n');
  print(
    '${"Size".padRight(8)} | ${"Algorithm".padRight(20)} | ${"Time(μs)".padLeft(10)} | ${"Complexity".padRight(12)}',
  );
  print('-' * 60);

  for (final size in testSizes) {
    // Create worst-case data (reverse sorted)
    final data = List.generate(size, (i) => size - i);

    // Run multiple iterations for statistical significance
    const iterations = 5;
    var totalTime = 0;
    String? algorithmName;
    String? complexity;

    for (var i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();

      final result = selector.sort(
        input: List.from(data),
        hint: SelectorHint(n: size),
      );

      stopwatch.stop();

      result.fold(
        (success) {
          totalTime += stopwatch.elapsedMicroseconds;
          algorithmName = success.selectedStrategy.name;
          complexity = success.selectedStrategy.timeComplexity.toString();
        },
        (failure) => print('   Benchmark failed: $failure'),
      );
    }

    if (algorithmName != null && complexity != null) {
      final avgTime = totalTime ~/ iterations;
      print(
        '${size.toString().padRight(8)} | ${algorithmName!.padRight(20)} | ${avgTime.toString().padLeft(10)} | ${complexity!.padRight(12)}',
      );

      // Store results for analysis
      results
          .putIfAbsent(algorithmName!, () => [])
          .add(BenchmarkResult(size, avgTime, complexity!));
    }
  }

  // Analyze scaling behavior
  print('\n📈 Scaling Analysis:');
  for (final entry in results.entries) {
    final algorithmName = entry.key;
    final benchmarkResults = entry.value;

    if (benchmarkResults.length >= 3) {
      final firstResult = benchmarkResults.first;
      final lastResult = benchmarkResults.last;

      final sizeRatio = lastResult.size / firstResult.size;
      final timeRatio = lastResult.time / firstResult.time;

      print(
        '   $algorithmName: ${sizeRatio.toStringAsFixed(1)}x size → ${timeRatio.toStringAsFixed(1)}x time',
      );
    }
  }
}

void errorHandlingExample() {
  print('🛡️ 4. Error Handling Patterns');
  print('------------------------------');

  final selector = AlgoSelectorFacade.development();

  // Example 1: Handling empty input
  print('Testing empty input handling:');
  var result = selector.sort(input: <int>[], hint: const SelectorHint(n: 0));

  result.fold(
    (success) => print('   ✅ Empty input handled: ${success.output}'),
    (failure) => print('   ❌ Empty input failed: $failure'),
  );

  // Example 2: Handling very large input hints
  print('\nTesting extreme size hint:');
  final smallData = [3, 1, 4, 1, 5];
  result =
      selector.sort(input: smallData, hint: const SelectorHint(n: 1000000));

  result.fold(
    (success) {
      print('   ✅ Extreme hint handled gracefully');
      print('   → Selected: ${success.selectedStrategy.name}');
      print('   → Result: ${success.output}');
    },
    (failure) => print('   ❌ Extreme hint failed: $failure'),
  );

  // Example 3: Comprehensive error handling
  print('\nTesting comprehensive error handling:');
  final testScenarios = [
    ('Single element', [42]),
    ('Two elements', [2, 1]),
    ('All same', List.filled(10, 5)),
    ('Already sorted', [1, 2, 3, 4, 5]),
  ];

  for (final (name, data) in testScenarios) {
    final scenarioResult = selector.sort(
      input: data,
      hint: SelectorHint(n: data.length),
    );

    scenarioResult.fold(
      (success) => print(
        '   ✅ $name: ${success.output} via ${success.selectedStrategy.name}',
      ),
      (failure) => print('   ❌ $name failed: $failure'),
    );
  }
}

void complexDataScenariosExample() {
  print('🧮 5. Complex Data Scenarios');
  print('----------------------------');

  final selector = AlgoSelectorFacade.development();

  // Scenario 1: Nearly sorted data
  print('Nearly sorted data optimization:');
  final nearlySorted = List.generate(100, (i) => i);
  // Introduce a few random swaps
  final random = Random();
  for (var i = 0; i < 5; i++) {
    final idx1 = random.nextInt(nearlySorted.length);
    final idx2 = random.nextInt(nearlySorted.length);
    final temp = nearlySorted[idx1];
    nearlySorted[idx1] = nearlySorted[idx2];
    nearlySorted[idx2] = temp;
  }

  final result1 = selector.sort(
    input: nearlySorted,
    hint: SelectorHint(
      n: nearlySorted.length,
      sorted: null,
    ), // Unknown sorted state
  );

  result1.fold(
    (success) {
      print('   → Algorithm: ${success.selectedStrategy.name}');
      print('   → Complexity: ${success.selectedStrategy.timeComplexity}');
      print('   → Sample: ${success.output.take(10).toList()}...');
    },
    (failure) => print('   ❌ Nearly sorted failed: $failure'),
  );

  // Scenario 2: Data with many duplicates
  print('\nMany duplicates scenario:');
  final manyDuplicates =
      List.generate(200, (i) => i % 5); // Only 5 unique values

  final result2 = selector.sort(
    input: manyDuplicates,
    hint: SelectorHint(n: manyDuplicates.length, preferStable: true),
  );

  result2.fold(
    (success) {
      print('   → Algorithm: ${success.selectedStrategy.name}');
      print(
        '   → Is stable sorting important: ${success.selectedStrategy.timeComplexity}',
      );
      print('   → Unique values in result: ${success.output.toSet().length}');
    },
    (failure) => print('   ❌ Many duplicates failed: $failure'),
  );

  // Scenario 3: Memory-constrained large dataset
  print('\nMemory-constrained large dataset:');
  final largeData = List.generate(2000, (i) => Random().nextInt(10000));

  final result3 = selector.sort(
    input: largeData,
    hint: SelectorHint.lowMemory(n: largeData.length),
  );

  result3.fold(
    (success) {
      print('   → Selected memory-efficient: ${success.selectedStrategy.name}');
      print(
        '   → Space complexity: ${success.selectedStrategy.spaceComplexity}',
      );
      print(
        '   → Time complexity trade-off: ${success.selectedStrategy.timeComplexity}',
      );
    },
    (failure) => print('   ❌ Memory-constrained failed: $failure'),
  );
}

void algorithmComparisonExample() {
  print('⚔️ 6. Algorithm Comparison');
  print('--------------------------');

  final selector = AlgoSelectorFacade.development();

  // Compare performance on different data patterns
  final dataPatterns = {
    'Random': List.generate(500, (i) => Random().nextInt(1000)),
    'Sorted': List.generate(500, (i) => i),
    'Reverse': List.generate(500, (i) => 500 - i),
    'Nearly sorted': (() {
      final list = List.generate(500, (i) => i);
      // Shuffle last 10 elements
      for (var i = 490; i < 500; i++) {
        final j = Random().nextInt(10) + 490;
        final temp = list[i];
        list[i] = list[j];
        list[j] = temp;
      }
      return list;
    })(),
  };

  print(
    '${"Pattern".padRight(15)} | ${"Algorithm".padRight(20)} | ${"Time Complexity".padRight(15)} | ${"Space Complexity"}',
  );
  print('-' * 70);

  for (final entry in dataPatterns.entries) {
    final patternName = entry.key;
    final data = entry.value;

    final result = selector.sort(
      input: data,
      hint: SelectorHint(n: data.length),
    );

    result.fold(
      (success) {
        print(
          '${patternName.padRight(15)} | ${success.selectedStrategy.name.padRight(20)} | ${success.selectedStrategy.timeComplexity.toString().padRight(15)} | ${success.selectedStrategy.spaceComplexity}',
        );
      },
      (failure) => print(
        '${patternName.padRight(15)} | ${"FAILED".padRight(20)} | ${failure.toString().substring(0, 15).padRight(15)} |',
      ),
    );
  }

  // Summary statistics
  print('\n📊 Summary:');
  final stats = selector.getStats();
  print('   → Total registered strategies: ${stats.totalStrategies}');
  print('   → Available signatures: ${selector.signatures.length}');

  // Strategy utilization analysis
  print('\n🎯 Strategy Utilization:');
  print(
    '   → This demo tested various scenarios to showcase intelligent selection',
  );
  print(
    '   → AlgoMate automatically chooses optimal algorithms based on data characteristics',
  );
  print(
    '   → Memory constraints, stability requirements, and dataset size all influence selection',
  );
}

// Helper classes for organized testing
class TestCase {
  const TestCase(this.name, this.data);

  final String name;
  final List<int> data;
}

class BenchmarkResult {
  const BenchmarkResult(this.size, this.time, this.complexity);

  final int size;
  final int time; // microseconds
  final String complexity;
}
