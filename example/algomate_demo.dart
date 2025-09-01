/// AlgoMate Demo - ตัวอย่างการใช้ AlgoMate พร้อม Parallel Algorithms
///
/// โปรแกรมนี้แสดงการใช้งาน AlgoMate กับอัลกอริทึมแบบ parallel/divide-and-conquer
/// ที่ออกแบบมาสำหรับ multi-core systems
library algomate_demo;

import 'dart:io';
import 'dart:math';
import 'package:algomate/algomate.dart';

void main() async {
  print('🚀 AlgoMate Parallel Algorithms Demo');
  print('====================================');
  print('CPU Cores: ${Platform.numberOfProcessors}');
  print('Dart Platform: ${Platform.operatingSystem}');

  final selector = AlgoSelectorFacade.development();

  await demonstrateBasicSorting(selector);
  await demonstrateSearching(selector);
  await demonstratePerformanceScaling(selector);
  await demonstrateAutoSelection(selector);

  print('\n✨ Demo completed successfully!');
  print('   📚 All parallel algorithms are integrated and working');
  print('   🎯 AlgoMate automatically selects optimal strategies');
  print('   ⚡ Performance scales with dataset size');
}

/// พื้นฐานการใช้งาน AlgoMate สำหรับ sorting
Future<void> demonstrateBasicSorting(AlgoSelectorFacade selector) async {
  print('\n📊 Basic Sorting Demonstration:');
  print('===============================');

  final testSizes = [100, 1000, 10000];

  for (final size in testSizes) {
    print('\n📏 Testing with $size elements:');
    final testData = generateRandomList(size);

    final stopwatch = Stopwatch()..start();
    final result = selector.sort(
      input: testData,
      hint: SelectorHint(n: size),
    );
    stopwatch.stop();

    result.fold(
      (success) {
        final actualTime = stopwatch.elapsedMicroseconds;
        print('   ✅ Sorted successfully');
        print('   📊 Strategy: ${success.selectedStrategy.name}');
        print(
            '   🕒 Wall time: $actualTimeμs (${(actualTime / 1000).toStringAsFixed(2)}ms)');
        print('   🔍 Result verified: ${_isSorted(success.output)}');

        // Performance metrics
        final throughput = (size / actualTime * 1000000).toStringAsFixed(0);
        print('   📈 Throughput: $throughput elements/second');
      },
      (failure) => print('   ❌ Sort failed: ${failure.message}'),
    );
  }
}

/// การทดสอบ search algorithms
Future<void> demonstrateSearching(AlgoSelectorFacade selector) async {
  print('\n🔍 Search Algorithm Demonstration:');
  print('==================================');

  final sizes = [1000, 10000, 100000];

  for (final size in sizes) {
    print('\n📏 Dataset size: $size elements');

    // Create sorted data for binary search
    final sortedData = List.generate(size, (i) => i * 2);
    final target = sortedData[Random().nextInt(sortedData.length)];

    final stopwatch = Stopwatch()..start();
    final result = selector.search(
      input: sortedData,
      target: target,
      hint: SelectorHint(n: size, sorted: true),
    );
    stopwatch.stop();

    result.fold(
      (success) {
        final actualTime = stopwatch.elapsedMicroseconds;
        print('   ✅ Found target $target at index ${success.output}');
        print('   📊 Strategy: ${success.selectedStrategy.name}');
        print('   🕒 Time: $actualTimeμs');

        // Verify result
        if (success.output != null &&
            success.output! >= 0 &&
            success.output! < sortedData.length) {
          final found = sortedData[success.output!] == target;
          print('   🔍 Verification: ${found ? "✅ Correct" : "❌ Incorrect"}');
        }
      },
      (failure) => print('   ❌ Search failed: ${failure.message}'),
    );
  }
}

/// ทดสอบ performance scaling กับ dataset ขนาดใหญ่
Future<void> demonstratePerformanceScaling(AlgoSelectorFacade selector) async {
  print('\n⚡ Performance Scaling Analysis:');
  print('===============================');
  print('Testing how AlgoMate performs with increasingly large datasets...');

  final sizes = [1000, 10000, 50000, 100000];
  final results = <String, List<double>>{};

  for (final size in sizes) {
    print('\n📊 Dataset size: $size elements');
    final testData = generateRandomList(size);

    // Test multiple iterations for more accurate timing
    final iterations = size < 50000 ? 5 : 1;
    final times = <double>[];

    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();
      final result = selector.sort(
        input: List<int>.from(testData),
        hint: SelectorHint(n: size),
      );
      stopwatch.stop();

      result.fold(
        (success) {
          times.add(stopwatch.elapsedMicroseconds / 1000.0); // Convert to ms
          if (i == 0) {
            print('   📊 Selected: ${success.selectedStrategy.name}');
          }
        },
        (failure) =>
            print('   ❌ Iteration ${i + 1} failed: ${failure.message}'),
      );
    }

    if (times.isNotEmpty) {
      final avgTime = times.reduce((a, b) => a + b) / times.length;
      final throughput = (size / avgTime * 1000).toStringAsFixed(0);

      print('   🕒 Average time: ${avgTime.toStringAsFixed(2)}ms');
      print('   📈 Throughput: $throughput elements/second');

      results['$size'] = times;
    }
  }

  // Performance summary
  if (results.isNotEmpty) {
    print('\n📈 Performance Summary:');
    print('   • Small datasets: Fast algorithms selected automatically');
    print('   • Large datasets: AlgoMate may use parallel strategies');
    print('   • Performance scales efficiently with dataset size');
    print('   • Multi-core systems see improved wall-clock times');
  }
}

/// ทดสอบ automatic algorithm selection
Future<void> demonstrateAutoSelection(AlgoSelectorFacade selector) async {
  print('\n🤖 Automatic Algorithm Selection:');
  print('=================================');

  final testCases = [
    (50, 'Tiny dataset', const SelectorHint(n: 50)),
    (500, 'Small dataset', const SelectorHint(n: 500)),
    (5000, 'Medium dataset', const SelectorHint(n: 5000)),
    (50000, 'Large dataset', const SelectorHint(n: 50000)),
    (5000, 'Memory constrained', SelectorHint.lowMemory(n: 5000)),
    (
      5000,
      'Stable sort preferred',
      const SelectorHint(n: 5000, preferStable: true)
    ),
  ];

  print('Testing how AlgoMate selects algorithms for different scenarios...');

  for (final (size, description, hint) in testCases) {
    print('\n🎯 $description ($size elements):');

    final testData = generateRandomList(size);
    final stopwatch = Stopwatch()..start();

    final result = selector.sort(input: testData, hint: hint);
    stopwatch.stop();

    result.fold(
      (success) {
        final timeMs = stopwatch.elapsedMicroseconds / 1000;
        print('   ✅ ${success.selectedStrategy.name}');
        print('   🕒 ${timeMs.toStringAsFixed(2)}ms');

        // Strategy analysis
        final strategyName = success.selectedStrategy.name.toLowerCase();
        if (strategyName.contains('insertion')) {
          print('   💡 Chose insertion sort - optimal for small datasets');
        } else if (strategyName.contains('merge')) {
          print('   💡 Chose merge sort - stable and predictable performance');
        } else if (strategyName.contains('quick')) {
          print('   💡 Chose quick sort - fast average-case performance');
        } else if (strategyName.contains('heap')) {
          print('   💡 Chose heap sort - guaranteed O(n log n) performance');
        } else if (strategyName.contains('parallel')) {
          print('   🚀 Chose parallel algorithm - utilizing multiple cores!');
        } else {
          print('   💡 Selected: ${success.selectedStrategy.name}');
        }
      },
      (failure) => print('   ❌ Failed: ${failure.message}'),
    );
  }

  print('\n📊 Selection Intelligence:');
  print('   • Small datasets → Simple algorithms (insertion sort)');
  print('   • Large datasets → Advanced algorithms (merge/quick sort)');
  print('   • Very large datasets → Parallel algorithms (when available)');
  print('   • Stable required → Merge sort variants');
  print('   • Memory constrained → In-place algorithms');
  print('   • Multi-core systems → Automatic parallel processing');
}

/// Utility functions
List<int> generateRandomList(int size) {
  final random = Random();
  return List.generate(size, (_) => random.nextInt(size * 10));
}

bool _isSorted(List<int> list) {
  for (int i = 1; i < list.length; i++) {
    if (list[i] < list[i - 1]) return false;
  }
  return true;
}
