import 'package:algomate/algomate.dart';

/// Comprehensive example demonstrating basic usage of AlgoMate.
void main() {
  print('🤖 AlgoMate - Algorithm Selection Companion');
  print('==========================================\n');

  // Create a selector with development settings (includes logging)
  final selector = AlgoSelectorFacade.development();

  // Example 1: Basic sorting with automatic algorithm selection
  basicSortingExample(selector);

  print('\n');

  // Example 2: Algorithm selection based on different dataset sizes
  datasetSizeExample(selector);

  print('\n');

  // Example 3: Memory-constrained environments
  memoryConstraintExample(selector);

  print('\n');

  // Example 4: Search operations
  searchExample(selector);

  print('\n');

  // Example 5: Custom strategy registration
  customStrategyExample(selector);

  print('\n');

  // Example 6: Performance analysis
  performanceExample(selector);
}

void basicSortingExample(AlgoSelectorFacade selector) {
  print('📊 1. Basic Sorting Examples');
  print('----------------------------');

  final data = [64, 34, 25, 12, 22, 11, 90, 5];
  print('Original data: $data');

  // AlgoMate automatically chooses the best algorithm
  final result = selector.sort(
    input: data,
    hint: SelectorHint(n: data.length),
  );

  result.fold(
    (success) {
      print('✅ Sorted: ${success.output}');
      print('   Algorithm used: ${success.selectedStrategy.name}');
      print('   Time complexity: ${success.selectedStrategy.timeComplexity}');
      print('   Space complexity: ${success.selectedStrategy.spaceComplexity}');
    },
    (failure) => print('❌ Sorting failed: $failure'),
  );
}

void datasetSizeExample(AlgoSelectorFacade selector) {
  print('📏 2. Dataset Size-Based Selection');
  print('----------------------------------');

  // Small dataset (< 50 elements) - should prefer insertion sort
  final smallData = List.generate(10, (i) => 10 - i);
  print('Small dataset (${smallData.length} elements):');

  var result = selector.sort(input: smallData, hint: SelectorHint.small());
  result.fold(
    (success) {
      print('   → Selected: ${success.selectedStrategy.name}');
      print('   → Reason: Optimal for small datasets');
    },
    (failure) => print('   ❌ Failed: $failure'),
  );

  // Medium dataset (50-1000 elements) - may choose binary insertion
  final mediumData = List.generate(100, (i) => 100 - i);
  print('\nMedium dataset (${mediumData.length} elements):');

  result = selector.sort(
    input: mediumData,
    hint: SelectorHint(n: mediumData.length),
  );
  result.fold(
    (success) {
      print('   → Selected: ${success.selectedStrategy.name}');
      print('   → Complexity: ${success.selectedStrategy.timeComplexity}');
    },
    (failure) => print('   ❌ Failed: $failure'),
  );

  // Large dataset (> 1000 elements) - should prefer merge sort
  final largeData = List.generate(2000, (i) => 2000 - i);
  print('\nLarge dataset (${largeData.length} elements):');

  result = selector.sort(input: largeData, hint: SelectorHint.large());
  result.fold(
    (success) {
      print('   → Selected: ${success.selectedStrategy.name}');
      print('   → First 10: ${success.output.take(10).toList()}');
      print(
          '   → Last 10: ${success.output.skip(success.output.length - 10).toList()}',);
    },
    (failure) => print('   ❌ Failed: $failure'),
  );
}

void memoryConstraintExample(AlgoSelectorFacade selector) {
  print('💾 3. Memory Constraint Examples');
  print('--------------------------------');

  final data = List.generate(500, (i) => 500 - i);

  // Low memory constraint - should prefer in-place algorithms
  print('Low memory environment:');
  var result = selector.sort(
    input: List.from(data),
    hint: SelectorHint.lowMemory(n: data.length),
  );

  result.fold(
    (success) {
      print('   → Selected: ${success.selectedStrategy.name}');
      print(
          '   → Space complexity: ${success.selectedStrategy.spaceComplexity}',);
    },
    (failure) => print('   ❌ Failed: $failure'),
  );

  // Regular memory - can choose best time complexity
  print('\nRegular memory environment:');
  result = selector.sort(
    input: List.from(data),
    hint: SelectorHint(n: data.length),
  );

  result.fold(
    (success) {
      print('   → Selected: ${success.selectedStrategy.name}');
      print('   → Time complexity: ${success.selectedStrategy.timeComplexity}');
    },
    (failure) => print('   ❌ Failed: $failure'),
  );
}

void searchExample(AlgoSelectorFacade selector) {
  print('🔍 4. Search Operations');
  print('-----------------------');

  final sortedData = [1, 3, 5, 7, 9, 11, 13, 15, 17, 19];
  final unsortedData = [64, 34, 25, 12, 22, 11, 90];

  // Binary search on sorted data
  print('Binary search on sorted data:');
  var result = selector.search(
      input: sortedData, target: 7, hint: const SelectorHint(sorted: true),);

  result.fold(
    (success) {
      if (success.output != null) {
        print('   → Found 7 at index: ${success.output}');
      } else {
        print('   → 7 not found in data');
      }
      print('   → Algorithm: ${success.selectedStrategy.name}');
      print('   → Complexity: ${success.selectedStrategy.timeComplexity}');
    },
    (failure) => print('   ❌ Search failed: $failure'),
  );

  // Linear search on unsorted data
  print('\nLinear search on unsorted data:');
  result = selector.search(
      input: unsortedData, target: 25, hint: const SelectorHint(sorted: false),);

  result.fold(
    (success) {
      if (success.output != null) {
        print('   → Found 25 at index: ${success.output}');
      } else {
        print('   → 25 not found in data');
      }
      print('   → Algorithm: ${success.selectedStrategy.name}');
    },
    (failure) => print('   ❌ Search failed: $failure'),
  );
}

void customStrategyExample(AlgoSelectorFacade selector) {
  print('🛠️ 5. Custom Strategy Registration');
  print('-----------------------------------');

  // Create a custom bubble sort strategy
  final customStrategy = _CustomBubbleSortStrategy();
  final signature = StrategySignature.sort(inputType: List<int>);

  // Register the custom strategy
  final registerResult = selector.register<List<int>, List<int>>(
      strategy: customStrategy, signature: signature, allowReplace: true,);

  registerResult.fold(
    (success) {
      print('✅ Custom bubble sort registered successfully');

      // Use the custom strategy by providing conditions where it's optimal
      final data = [
        5,
        2,
        8,
        1,
        9,
      ]; // Very small dataset where bubble sort is acceptable
      final result = selector.sort(
        input: data,
        hint: SelectorHint(n: data.length),
      );

      result.fold(
        (success) {
          print('   → Result: ${success.output}');
          print('   → Strategy: ${success.selectedStrategy.name}');
        },
        (failure) => print('   ❌ Custom sort failed: $failure'),
      );
    },
    (failure) => print('❌ Failed to register custom strategy: $failure'),
  );
}

void performanceExample(AlgoSelectorFacade selector) {
  print('⚡ 6. Performance Analysis');
  print('-------------------------');

  // Test different dataset sizes and compare performance
  final testSizes = [10, 50, 100, 500];

  for (final size in testSizes) {
    final data =
        List.generate(size, (i) => size - i); // Reverse sorted (worst case)

    final result = selector.sort(
      input: data,
      hint: SelectorHint(n: size),
    );

    result.fold(
      (success) {
        print('Size $size:');
        print('   → Algorithm: ${success.selectedStrategy.name}');
        print('   → Complexity: ${success.selectedStrategy.timeComplexity}');
      },
      (failure) => print('Size $size: ❌ Failed: $failure'),
    );
  }

  // Show algorithm selection statistics
  print('\n📈 Selection Statistics:');
  final stats = selector.getStats();
  print('   → Total strategies: ${stats.totalStrategies}');
  print('   → Total signatures: ${selector.signatures.length}');

  print('\n📋 Available Signatures:');
  for (final signature in selector.signatures) {
    print('   • $signature');
  }
}

/// Custom bubble sort implementation for demonstration
class _CustomBubbleSortStrategy extends Strategy<List<int>, List<int>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
      name: 'custom_bubble_sort',
      timeComplexity: TimeComplexity.oN2,
      spaceComplexity: TimeComplexity.o1,
      requiresSorted: false,);

  @override
  bool canApply(List<int> input, SelectorHint hint) {
    // Only use bubble sort for very small datasets where simplicity matters
    final n = hint.n ?? input.length;
    return n <= 5; // Very restrictive - only for tiny datasets
  }

  @override
  List<int> execute(List<int> input) {
    final result = List<int>.from(input);
    final n = result.length;

    for (var i = 0; i < n - 1; i++) {
      for (var j = 0; j < n - i - 1; j++) {
        if (result[j] > result[j + 1]) {
          // Swap elements
          final temp = result[j];
          result[j] = result[j + 1];
          result[j + 1] = temp;
        }
      }
    }

    return result;
  }
}
