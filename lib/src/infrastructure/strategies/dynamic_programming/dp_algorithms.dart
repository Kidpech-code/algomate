import 'dart:math';
import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';

/// Input for Knapsack problem
class KnapsackInput {
  const KnapsackInput(this.weights, this.values, this.capacity);
  final List<int> weights;
  final List<int> values;
  final int capacity;

  @override
  String toString() =>
      'KnapsackInput(items: ${weights.length}, capacity: $capacity)';
}

/// Result for Knapsack problem
class KnapsackResult {
  const KnapsackResult(this.maxValue, this.selectedItems);
  final int maxValue;
  final List<int> selectedItems;

  @override
  String toString() {
    return 'KnapsackOutput(maxValue: $maxValue, selectedItems: $selectedItems)';
  }
}

/// 0/1 Knapsack Problem using Dynamic Programming
class KnapsackDP extends Strategy<KnapsackInput, KnapsackResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'knapsack_dp',
        timeComplexity: TimeComplexity.oN2, // O(n*W)
        spaceComplexity: TimeComplexity.oN2,
        description: '0/1 Knapsack using Dynamic Programming',
        memoryOverheadBytes: 4096,
        requiresSorted: false,
      );

  @override
  bool canApply(KnapsackInput input, SelectorHint hint) {
    return input.weights.length == input.values.length &&
        input.weights.isNotEmpty &&
        input.capacity > 0;
  }

  @override
  KnapsackResult execute(KnapsackInput input) {
    final n = input.weights.length;
    final W = input.capacity;

    // DP table: dp[i][w] = maximum value using first i items with capacity w
    final dp = List.generate(n + 1, (_) => List.filled(W + 1, 0));

    // Fill the DP table
    for (int i = 1; i <= n; i++) {
      for (int w = 1; w <= W; w++) {
        if (input.weights[i - 1] <= w) {
          dp[i][w] = max(
            dp[i - 1][w],
            dp[i - 1][w - input.weights[i - 1]] + input.values[i - 1],
          );
        } else {
          dp[i][w] = dp[i - 1][w];
        }
      }
    }

    // Backtrack to find selected items
    final selectedItems = <int>[];
    int i = n, w = W;

    while (i > 0 && w > 0) {
      if (dp[i][w] != dp[i - 1][w]) {
        selectedItems.add(i - 1); // Add item index
        w -= input.weights[i - 1];
      }
      i--;
    }

    return KnapsackResult(dp[n][W], selectedItems.reversed.toList());
  }
}

/// Input for Longest Common Subsequence
class LCSInput {
  const LCSInput(this.text1, this.text2);
  final String text1;
  final String text2;

  @override
  String toString() => 'LCSInput(text1: "$text1", text2: "$text2")';
}

/// Result for Longest Common Subsequence
class LCSResult {
  const LCSResult(this.length, this.subsequence);
  final int length;
  final String subsequence;

  @override
  String toString() => 'LCSResult(length: $length, lcs: "$subsequence")';
}

/// Longest Common Subsequence using Dynamic Programming
class LongestCommonSubsequenceDP extends Strategy<LCSInput, LCSResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'lcs_dp',
        timeComplexity: TimeComplexity.oN2,
        spaceComplexity: TimeComplexity.oN2,
        description: 'Longest Common Subsequence using Dynamic Programming',
        memoryOverheadBytes: 2048,
        requiresSorted: false,
      );

  @override
  bool canApply(LCSInput input, SelectorHint hint) {
    return input.text1.isNotEmpty && input.text2.isNotEmpty;
  }

  @override
  LCSResult execute(LCSInput input) {
    final m = input.text1.length;
    final n = input.text2.length;

    // DP table: dp[i][j] = length of LCS of first i chars of text1 and first j chars of text2
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    // Fill the DP table
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (input.text1[i - 1] == input.text2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = max(dp[i - 1][j], dp[i][j - 1]);
        }
      }
    }

    // Backtrack to construct the LCS
    final lcs = StringBuffer();
    int i = m, j = n;

    while (i > 0 && j > 0) {
      if (input.text1[i - 1] == input.text2[j - 1]) {
        lcs.write(input.text1[i - 1]);
        i--;
        j--;
      } else if (dp[i - 1][j] > dp[i][j - 1]) {
        i--;
      } else {
        j--;
      }
    }

    final result = lcs.toString().split('').reversed.join();
    return LCSResult(dp[m][n], result);
  }
}

/// Input for Longest Increasing Subsequence
class LISInput {
  const LISInput(this.sequence);
  final List<int> sequence;

  @override
  String toString() => 'LISInput(sequence: $sequence)';
}

/// Result for Longest Increasing Subsequence
class LISResult {
  const LISResult(this.length, this.subsequence);
  final int length;
  final List<int> subsequence;

  @override
  String toString() => 'LISResult(length: $length, lis: $subsequence)';
}

/// Longest Increasing Subsequence using Dynamic Programming
class LongestIncreasingSubsequenceDP extends Strategy<LISInput, LISResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'lis_dp',
        timeComplexity: TimeComplexity.oN2,
        spaceComplexity: TimeComplexity.oN,
        description: 'Longest Increasing Subsequence using Dynamic Programming',
        memoryOverheadBytes: 1024,
        requiresSorted: false,
      );

  @override
  bool canApply(LISInput input, SelectorHint hint) {
    return input.sequence.isNotEmpty;
  }

  @override
  LISResult execute(LISInput input) {
    final arr = input.sequence;
    final n = arr.length;

    if (n == 0) return const LISResult(0, []);
    if (n == 1) return LISResult(1, [arr[0]]);

    // dp[i] = length of LIS ending at index i
    final dp = List.filled(n, 1);
    final parent = List.filled(n, -1);

    // Fill DP array
    for (int i = 1; i < n; i++) {
      for (int j = 0; j < i; j++) {
        if (arr[j] < arr[i] && dp[j] + 1 > dp[i]) {
          dp[i] = dp[j] + 1;
          parent[i] = j;
        }
      }
    }

    // Find the ending position of LIS
    int maxLength = dp[0];
    int maxIndex = 0;

    for (int i = 1; i < n; i++) {
      if (dp[i] > maxLength) {
        maxLength = dp[i];
        maxIndex = i;
      }
    }

    // Reconstruct LIS
    final lis = <int>[];
    int curr = maxIndex;

    while (curr != -1) {
      lis.add(arr[curr]);
      curr = parent[curr];
    }

    return LISResult(maxLength, lis.reversed.toList());
  }
}

/// Input for Coin Change problem
class CoinChangeInput {
  const CoinChangeInput(this.coins, this.amount);
  final List<int> coins;
  final int amount;

  @override
  String toString() => 'CoinChangeInput(coins: $coins, amount: $amount)';
}

/// Result for Coin Change problem
class CoinChangeResult {
  const CoinChangeResult(this.minCoins, this.coinCombination);
  final int minCoins;
  final List<int> coinCombination;

  @override
  String toString() =>
      'CoinChangeResult(minCoins: $minCoins, combination: $coinCombination)';
}

/// Coin Change Problem using Dynamic Programming
class CoinChangeDP extends Strategy<CoinChangeInput, CoinChangeResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'coin_change_dp',
        timeComplexity: TimeComplexity.oN, // O(amount * coins.length)
        spaceComplexity: TimeComplexity.oN,
        description: 'Coin Change using Dynamic Programming',
        memoryOverheadBytes: 512,
        requiresSorted: false,
      );

  @override
  bool canApply(CoinChangeInput input, SelectorHint hint) {
    return input.coins.isNotEmpty &&
        input.amount >= 0 &&
        input.coins.every((coin) => coin > 0);
  }

  @override
  CoinChangeResult execute(CoinChangeInput input) {
    final amount = input.amount;
    final coins = input.coins;

    if (amount == 0) return const CoinChangeResult(0, []);

    // dp[i] = minimum coins needed to make amount i
    final dp = List.filled(amount + 1, amount + 1);
    final parent = List.filled(amount + 1, -1);

    dp[0] = 0;

    // Fill DP array
    for (int i = 1; i <= amount; i++) {
      for (int coin in coins) {
        if (coin <= i && dp[i - coin] + 1 < dp[i]) {
          dp[i] = dp[i - coin] + 1;
          parent[i] = coin;
        }
      }
    }

    if (dp[amount] > amount) {
      return const CoinChangeResult(-1, []); // No solution
    }

    // Reconstruct solution
    final combination = <int>[];
    int curr = amount;

    while (curr > 0) {
      final coin = parent[curr];
      combination.add(coin);
      curr -= coin;
    }

    return CoinChangeResult(dp[amount], combination);
  }
}

/// Input for Edit Distance
class EditDistanceInput {
  const EditDistanceInput(this.word1, this.word2);
  final String word1;
  final String word2;

  @override
  String toString() => 'EditDistanceInput(word1: "$word1", word2: "$word2")';
}

/// Result for Edit Distance
class EditDistanceResult {
  const EditDistanceResult(this.distance, this.operations);
  final int distance;
  final List<String> operations;

  @override
  String toString() =>
      'EditDistanceResult(distance: $distance, operations: $operations)';
}

/// Edit Distance (Levenshtein Distance) using Dynamic Programming
class EditDistanceDP extends Strategy<EditDistanceInput, EditDistanceResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'edit_distance_dp',
        timeComplexity: TimeComplexity.oN2,
        spaceComplexity: TimeComplexity.oN2,
        description: 'Edit Distance (Levenshtein) using Dynamic Programming',
        memoryOverheadBytes: 2048,
        requiresSorted: false,
      );

  @override
  bool canApply(EditDistanceInput input, SelectorHint hint) {
    return true; // Can handle empty strings too
  }

  @override
  EditDistanceResult execute(EditDistanceInput input) {
    final word1 = input.word1;
    final word2 = input.word2;
    final m = word1.length;
    final n = word2.length;

    // dp[i][j] = edit distance between first i chars of word1 and first j chars of word2
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    // Base cases
    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
    }

    // Fill DP table
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (word1[i - 1] == word2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 +
              min(
                min(dp[i - 1][j], dp[i][j - 1]), // Delete or Insert
                dp[i - 1][j - 1], // Replace
              );
        }
      }
    }

    // Backtrack to find operations
    final operations = <String>[];
    int i = m, j = n;

    while (i > 0 || j > 0) {
      if (i > 0 && j > 0 && word1[i - 1] == word2[j - 1]) {
        i--;
        j--;
      } else if (i > 0 && j > 0 && dp[i][j] == dp[i - 1][j - 1] + 1) {
        operations.add('Replace ${word1[i - 1]} with ${word2[j - 1]}');
        i--;
        j--;
      } else if (i > 0 && dp[i][j] == dp[i - 1][j] + 1) {
        operations.add('Delete ${word1[i - 1]}');
        i--;
      } else {
        operations.add('Insert ${word2[j - 1]}');
        j--;
      }
    }

    return EditDistanceResult(dp[m][n], operations.reversed.toList());
  }
}

/// Input for Matrix Chain Multiplication
class MatrixChainInput {
  // dimensions[i] is rows of matrix i, dimensions[i+1] is cols of matrix i

  const MatrixChainInput(this.dimensions);
  final List<int> dimensions;

  @override
  String toString() => 'MatrixChainInput(dimensions: $dimensions)';
}

/// Result for Matrix Chain Multiplication
class MatrixChainResult {
  const MatrixChainResult(this.minOperations, this.optimalParentheses);
  final int minOperations;
  final String optimalParentheses;

  @override
  String toString() =>
      'MatrixChainResult(minOps: $minOperations, parentheses: "$optimalParentheses")';
}

/// Matrix Chain Multiplication using Dynamic Programming
class MatrixChainMultiplicationDP
    extends Strategy<MatrixChainInput, MatrixChainResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'matrix_chain_dp',
        timeComplexity: TimeComplexity.oN3, // O(n³)
        spaceComplexity: TimeComplexity.oN2,
        description: 'Matrix Chain Multiplication using Dynamic Programming',
        memoryOverheadBytes: 3072,
        requiresSorted: false,
      );

  @override
  bool canApply(MatrixChainInput input, SelectorHint hint) {
    return input.dimensions.length >= 2;
  }

  @override
  MatrixChainResult execute(MatrixChainInput input) {
    final p = input.dimensions;
    final n = p.length - 1; // Number of matrices

    if (n == 1) return const MatrixChainResult(0, 'M1');

    // dp[i][j] = minimum operations to multiply matrices from i to j
    final dp = List.generate(n, (_) => List.filled(n, 0));
    final split = List.generate(n, (_) => List.filled(n, 0));

    // Fill DP table for chain lengths from 2 to n
    for (int length = 2; length <= n; length++) {
      for (int i = 0; i <= n - length; i++) {
        final j = i + length - 1;
        dp[i][j] = double.maxFinite.toInt();

        for (int k = i; k < j; k++) {
          final cost = dp[i][k] + dp[k + 1][j] + p[i] * p[k + 1] * p[j + 1];
          if (cost < dp[i][j]) {
            dp[i][j] = cost;
            split[i][j] = k;
          }
        }
      }
    }

    // Construct optimal parenthesization
    String buildParentheses(int i, int j) {
      if (i == j) {
        return 'M${i + 1}';
      } else {
        final k = split[i][j];
        return '(${buildParentheses(i, k)} × ${buildParentheses(k + 1, j)})';
      }
    }

    final parentheses = buildParentheses(0, n - 1);
    return MatrixChainResult(dp[0][n - 1], parentheses);
  }
}

/// Input for Subset Sum problem
class SubsetSumInput {
  const SubsetSumInput(this.numbers, this.target);
  final List<int> numbers;
  final int target;

  @override
  String toString() => 'SubsetSumInput(numbers: $numbers, target: $target)';
}

/// Result for Subset Sum problem
class SubsetSumResult {
  const SubsetSumResult(this.isPossible, this.subset);
  final bool isPossible;
  final List<int> subset;

  @override
  String toString() =>
      'SubsetSumResult(possible: $isPossible, subset: $subset)';
}

/// Subset Sum Problem using Dynamic Programming
class SubsetSumDP extends Strategy<SubsetSumInput, SubsetSumResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'subset_sum_dp',
        timeComplexity: TimeComplexity.oN2, // O(n * sum)
        spaceComplexity: TimeComplexity.oN2,
        description: 'Subset Sum using Dynamic Programming',
        memoryOverheadBytes: 2048,
        requiresSorted: false,
      );

  @override
  bool canApply(SubsetSumInput input, SelectorHint hint) {
    return input.numbers.isNotEmpty &&
        input.target >= 0 &&
        input.numbers.every((n) => n >= 0);
  }

  @override
  SubsetSumResult execute(SubsetSumInput input) {
    final nums = input.numbers;
    final target = input.target;
    final n = nums.length;

    // dp[i][j] = true if sum j is possible using first i numbers
    final dp = List.generate(n + 1, (_) => List.filled(target + 1, false));

    // Base case: sum 0 is always possible with empty subset
    for (int i = 0; i <= n; i++) {
      dp[i][0] = true;
    }

    // Fill DP table
    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= target; j++) {
        dp[i][j] = dp[i - 1][j]; // Don't include current number

        if (j >= nums[i - 1]) {
          dp[i][j] =
              dp[i][j] || dp[i - 1][j - nums[i - 1]]; // Include current number
        }
      }
    }

    if (!dp[n][target]) {
      return const SubsetSumResult(false, []);
    }

    // Backtrack to find the subset
    final subset = <int>[];
    int i = n, j = target;

    while (i > 0 && j > 0) {
      if (!dp[i - 1][j]) {
        // Current number is included
        subset.add(nums[i - 1]);
        j -= nums[i - 1];
      }
      i--;
    }

    return SubsetSumResult(true, subset.reversed.toList());
  }
}

/// Input for Fibonacci
class FibonacciInput {
  const FibonacciInput(this.n);
  final int n;

  @override
  String toString() => 'FibonacciInput(n: $n)';
}

/// Result for Fibonacci
class FibonacciResult {
  const FibonacciResult(this.value, this.method);
  final int value;
  final String method;

  @override
  String toString() => 'FibonacciResult(value: $value, method: $method)';
}

/// Fibonacci using Top-Down DP (Memoization)
class FibonacciTopDownDP extends Strategy<FibonacciInput, FibonacciResult> {
  final Map<int, int> _memo = {};

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'fibonacci_top_down_dp',
        timeComplexity: TimeComplexity.oN,
        spaceComplexity: TimeComplexity.oN,
        description: 'Fibonacci using Top-Down DP (Memoization)',
        memoryOverheadBytes: 256,
        requiresSorted: false,
      );

  @override
  bool canApply(FibonacciInput input, SelectorHint hint) {
    return input.n >= 0;
  }

  @override
  FibonacciResult execute(FibonacciInput input) {
    _memo.clear();
    final result = _fibMemo(input.n);
    return FibonacciResult(result, 'Top-Down DP');
  }

  int _fibMemo(int n) {
    if (n <= 1) return n;

    if (_memo.containsKey(n)) {
      return _memo[n]!;
    }

    _memo[n] = _fibMemo(n - 1) + _fibMemo(n - 2);
    return _memo[n]!;
  }
}

/// Fibonacci using Bottom-Up DP (Tabulation)
class FibonacciBottomUpDP extends Strategy<FibonacciInput, FibonacciResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'fibonacci_bottom_up_dp',
        timeComplexity: TimeComplexity.oN,
        spaceComplexity: TimeComplexity.oN,
        description: 'Fibonacci using Bottom-Up DP (Tabulation)',
        memoryOverheadBytes: 128,
        requiresSorted: false,
      );

  @override
  bool canApply(FibonacciInput input, SelectorHint hint) {
    return input.n >= 0;
  }

  @override
  FibonacciResult execute(FibonacciInput input) {
    final n = input.n;

    if (n <= 1) return FibonacciResult(n, 'Bottom-Up DP');

    final dp = List.filled(n + 1, 0);
    dp[0] = 0;
    dp[1] = 1;

    for (int i = 2; i <= n; i++) {
      dp[i] = dp[i - 1] + dp[i - 2];
    }

    return FibonacciResult(dp[n], 'Bottom-Up DP');
  }
}

/// Space-Optimized Fibonacci using Bottom-Up DP
class FibonacciOptimizedDP extends Strategy<FibonacciInput, FibonacciResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'fibonacci_optimized_dp',
        timeComplexity: TimeComplexity.oN,
        spaceComplexity: TimeComplexity.o1,
        description: 'Space-Optimized Fibonacci using Bottom-Up DP',
        memoryOverheadBytes: 8,
        requiresSorted: false,
      );

  @override
  bool canApply(FibonacciInput input, SelectorHint hint) {
    return input.n >= 0;
  }

  @override
  FibonacciResult execute(FibonacciInput input) {
    final n = input.n;

    if (n <= 1) return FibonacciResult(n, 'Optimized DP');

    int prev2 = 0, prev1 = 1, current = 0;

    for (int i = 2; i <= n; i++) {
      current = prev1 + prev2;
      prev2 = prev1;
      prev1 = current;
    }

    return FibonacciResult(current, 'Optimized DP');
  }
}
