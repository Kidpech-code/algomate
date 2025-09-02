import 'package:algomate/algomate.dart';

/// Example demonstrating Dynamic Programming algorithms in AlgoMate
///
/// This example shows how to use various DP algorithms for optimization problems
void main() {
  print('🧮 AlgoMate Dynamic Programming Demo');
  print('=====================================\n');

  demonstrateKnapsackProblem();
  demonstrateLCS();
  demonstrateLIS();
  demonstrateCoinChange();
  demonstrateEditDistance();
  demonstrateMatrixChainMultiplication();
  demonstrateSubsetSum();
  demonstrateFibonacci();

  print('\n✅ All Dynamic Programming demonstrations completed!');
}

/// Demonstrate Knapsack Problem
void demonstrateKnapsackProblem() {
  print('🎒 Knapsack Problem');
  print('-------------------');

  // Example: weights, values, capacity
  final weights = [2, 3, 4, 5, 9];
  final values = [3, 4, 5, 8, 10];
  const capacity = 20;

  print('Items: weights=$weights, values=$values');
  print('Knapsack capacity: $capacity');

  final knapsackDP = KnapsackDP();
  final input = KnapsackInput(weights, values, capacity);

  if (knapsackDP.canApply(input, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result = knapsackDP.execute(input);
    stopwatch.stop();

    print('✓ Maximum value: ${result.maxValue}');
    print('✓ Selected items (indices): ${result.selectedItems}');
    print('✓ Time: ${stopwatch.elapsedMicroseconds}μs');
    print('✓ Algorithm: ${knapsackDP.meta.description}');

    // Show selected items details
    int totalWeight = 0, totalValue = 0;
    for (final idx in result.selectedItems) {
      totalWeight += weights[idx];
      totalValue += values[idx];
      print('  - Item $idx: weight=${weights[idx]}, value=${values[idx]}');
    }
    print('✓ Total weight: $totalWeight, Total value: $totalValue\n');
  }
}

/// Demonstrate Longest Common Subsequence
void demonstrateLCS() {
  print('🔤 Longest Common Subsequence (LCS)');
  print('-----------------------------------');

  const text1 = 'ABCDGH';
  const text2 = 'AEDFHR';

  print('Text 1: "$text1"');
  print('Text 2: "$text2"');

  final lcsDP = LongestCommonSubsequenceDP();
  const input = LCSInput(text1, text2);

  if (lcsDP.canApply(input, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result = lcsDP.execute(input);
    stopwatch.stop();

    print('✓ LCS length: ${result.length}');
    print('✓ LCS: "${result.subsequence}"');
    print('✓ Time: ${stopwatch.elapsedMicroseconds}μs');
    print('✓ Algorithm: ${lcsDP.meta.description}\n');
  }
}

/// Demonstrate Longest Increasing Subsequence
void demonstrateLIS() {
  print('📈 Longest Increasing Subsequence (LIS)');
  print('---------------------------------------');

  final sequence = [10, 9, 2, 5, 3, 7, 101, 18];

  print('Sequence: $sequence');

  final lisDP = LongestIncreasingSubsequenceDP();
  final input = LISInput(sequence);

  if (lisDP.canApply(input, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result = lisDP.execute(input);
    stopwatch.stop();

    print('✓ LIS length: ${result.length}');
    print('✓ LIS: ${result.subsequence}');
    print('✓ Time: ${stopwatch.elapsedMicroseconds}μs');
    print('✓ Algorithm: ${lisDP.meta.description}\n');
  }
}

/// Demonstrate Coin Change Problem
void demonstrateCoinChange() {
  print('🪙 Coin Change Problem');
  print('----------------------');

  final coins = [1, 3, 4];
  const amount = 6;

  print('Coins: $coins');
  print('Amount: $amount');

  final coinChangeDP = CoinChangeDP();
  final input = CoinChangeInput(coins, amount);

  if (coinChangeDP.canApply(input, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result = coinChangeDP.execute(input);
    stopwatch.stop();

    if (result.minCoins == -1) {
      print('✗ No solution possible');
    } else {
      print('✓ Minimum coins needed: ${result.minCoins}');
      print('✓ Coin combination: ${result.coinCombination}');
      print('✓ Time: ${stopwatch.elapsedMicroseconds}μs');
      print('✓ Algorithm: ${coinChangeDP.meta.description}');

      // Verify the sum
      final sum = result.coinCombination.reduce((a, b) => a + b);
      print('✓ Verification: sum = $sum\n');
    }
  }
}

/// Demonstrate Edit Distance
void demonstrateEditDistance() {
  print('✏️  Edit Distance (Levenshtein Distance)');
  print('----------------------------------------');

  const word1 = 'horse';
  const word2 = 'ros';

  print('Word 1: "$word1"');
  print('Word 2: "$word2"');

  final editDistanceDP = EditDistanceDP();
  const input = EditDistanceInput(word1, word2);

  if (editDistanceDP.canApply(input, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result = editDistanceDP.execute(input);
    stopwatch.stop();

    print('✓ Edit distance: ${result.distance}');
    print('✓ Operations needed:');
    for (final op in result.operations) {
      print('  - $op');
    }
    print('✓ Time: ${stopwatch.elapsedMicroseconds}μs');
    print('✓ Algorithm: ${editDistanceDP.meta.description}\n');
  }
}

/// Demonstrate Matrix Chain Multiplication
void demonstrateMatrixChainMultiplication() {
  print('⛓️  Matrix Chain Multiplication');
  print('-------------------------------');

  // Dimensions: A1(1x2), A2(2x3), A3(3x4), A4(4x5)
  final dimensions = [1, 2, 3, 4, 5];

  print('Matrix dimensions: $dimensions');
  print('Matrices: A1(1x2) × A2(2x3) × A3(3x4) × A4(4x5)');

  final matrixChainDP = MatrixChainMultiplicationDP();
  final input = MatrixChainInput(dimensions);

  if (matrixChainDP.canApply(input, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result = matrixChainDP.execute(input);
    stopwatch.stop();

    print('✓ Minimum scalar multiplications: ${result.minOperations}');
    print('✓ Optimal parenthesization: ${result.optimalParentheses}');
    print('✓ Time: ${stopwatch.elapsedMicroseconds}μs');
    print('✓ Algorithm: ${matrixChainDP.meta.description}\n');
  }
}

/// Demonstrate Subset Sum Problem
void demonstrateSubsetSum() {
  print('🎯 Subset Sum Problem');
  print('---------------------');

  final numbers = [3, 34, 4, 12, 5, 2];
  const target = 9;

  print('Numbers: $numbers');
  print('Target sum: $target');

  final subsetSumDP = SubsetSumDP();
  final input = SubsetSumInput(numbers, target);

  if (subsetSumDP.canApply(input, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result = subsetSumDP.execute(input);
    stopwatch.stop();

    if (result.isPossible) {
      print('✓ Subset sum is possible');
      print('✓ Subset: ${result.subset}');
      final sum = result.subset.reduce((a, b) => a + b);
      print('✓ Sum verification: $sum');
    } else {
      print('✗ No subset with target sum exists');
    }
    print('✓ Time: ${stopwatch.elapsedMicroseconds}μs');
    print('✓ Algorithm: ${subsetSumDP.meta.description}\n');
  }
}

/// Demonstrate Fibonacci with different DP approaches
void demonstrateFibonacci() {
  print('🌀 Fibonacci with Dynamic Programming');
  print('-------------------------------------');

  const n = 30;
  print('Computing Fibonacci($n) using different DP approaches:\n');

  // Top-Down DP (Memoization)
  final fibTopDown = FibonacciTopDownDP();
  const input = FibonacciInput(n);

  if (fibTopDown.canApply(input, const SelectorHint())) {
    final stopwatch1 = Stopwatch()..start();
    final result1 = fibTopDown.execute(input);
    stopwatch1.stop();

    print('1. ${result1.method}:');
    print('   ✓ Fibonacci($n) = ${result1.value}');
    print('   ✓ Time: ${stopwatch1.elapsedMicroseconds}μs');
    print('   ✓ Algorithm: ${fibTopDown.meta.description}');
  }

  // Bottom-Up DP (Tabulation)
  final fibBottomUp = FibonacciBottomUpDP();

  if (fibBottomUp.canApply(input, const SelectorHint())) {
    final stopwatch2 = Stopwatch()..start();
    final result2 = fibBottomUp.execute(input);
    stopwatch2.stop();

    print('\n2. ${result2.method}:');
    print('   ✓ Fibonacci($n) = ${result2.value}');
    print('   ✓ Time: ${stopwatch2.elapsedMicroseconds}μs');
    print('   ✓ Algorithm: ${fibBottomUp.meta.description}');
  }

  // Space-Optimized DP
  final fibOptimized = FibonacciOptimizedDP();

  if (fibOptimized.canApply(input, const SelectorHint())) {
    final stopwatch3 = Stopwatch()..start();
    final result3 = fibOptimized.execute(input);
    stopwatch3.stop();

    print('\n3. ${result3.method}:');
    print('   ✓ Fibonacci($n) = ${result3.value}');
    print('   ✓ Time: ${stopwatch3.elapsedMicroseconds}μs');
    print('   ✓ Algorithm: ${fibOptimized.meta.description}');
    print('   ✓ Space: ${fibOptimized.meta.spaceComplexity}');
  }

  print(
      '\n💡 Note: All three approaches give the same result but with different',);
  print('   time and space trade-offs. The optimized version uses O(1) space.');
}
