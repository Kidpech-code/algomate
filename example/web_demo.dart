import 'package:algomate/algomate.dart';
import 'dart:math';

void main() {
  print('AlgoMate Web Compatibility Demo');
  print('=================================\n');

  // Test sorting algorithms
  print('1. Sorting Algorithms:');
  testSortingAlgorithms();

  print('\n2. Search Algorithms:');
  testSearchAlgorithms();

  print('\n3. Dynamic Programming:');
  testDynamicProgramming();

  print('\n4. String Processing:');
  testStringProcessing();

  print('\n5. Custom Data Structures:');
  testCustomDataStructures();

  print('\nWeb compatibility test completed successfully! 🎉');
}

void testSortingAlgorithms() {
  final data = generateRandomData(1000);

  // Test merge sort
  final mergeSort = MergeSortStrategy();
  final mergeSorted = mergeSort.execute(data);
  print(
    '  ✅ MergeSort: ${mergeSorted.take(5).toList()}... (${mergeSorted.length} elements)',
  );

  // Test quick sort
  final quickSort = QuickSort();
  final quickSorted = quickSort.execute(data);
  print(
    '  ✅ QuickSort: ${quickSorted.take(5).toList()}... (${quickSorted.length} elements)',
  );

  // Test insertion sort (small data)
  final smallData = data.take(50).toList();
  final insertionSort = InsertionSortStrategy();
  final insertionSorted = insertionSort.execute(smallData);
  print(
    '  ✅ InsertionSort: ${insertionSorted.take(5).toList()}... (${insertionSorted.length} elements)',
  );
}

void testSearchAlgorithms() {
  final data = List.generate(1000, (i) => i * 2); // Sorted even numbers

  // Test binary search
  final binarySearch = BinarySearchStrategy(500);
  final index = binarySearch.execute(data);
  print('  ✅ BinarySearch for 500: found at index $index');

  // Test linear search
  final linearSearch = LinearSearchStrategy(500);
  final linearIndex = linearSearch.execute(data);
  print('  ✅ LinearSearch for 500: found at index $linearIndex');
}

void testDynamicProgramming() {
  // Test knapsack
  final knapsack = KnapsackDP();
  final knapsackResult =
      knapsack.execute(const KnapsackInput([2, 3, 4], [3, 4, 5], 5));
  print('  ✅ Knapsack: max value ${knapsackResult.maxValue}');

  // Test coin change
  final coinChange = CoinChangeDP();
  final coinResult = coinChange.execute(const CoinChangeInput([1, 3, 4], 6));
  print('  ✅ CoinChange for amount 6: ${coinResult.minCoins} coins');

  // Test LCS
  final lcs = LongestCommonSubsequenceDP();
  final lcsResult = lcs.execute(const LCSInput('ABCDGH', 'AEDFHR'));
  print(
    '  ✅ LCS of "ABCDGH" and "AEDFHR": "${lcsResult.subsequence}" (length ${lcsResult.length})',
  );
}

void testStringProcessing() {
  // Test KMP
  final kmp = KnuthMorrisPrattAlgorithm();
  final kmpResult = kmp.execute(const KMPInput('ABABCABABA', 'ABAB'));
  print(
    '  ✅ KMP pattern matching: found at positions ${kmpResult.occurrences}',
  );

  // Test Rabin-Karp
  final rabinKarp = RabinKarpAlgorithm();
  final rabinResult =
      rabinKarp.execute(const RabinKarpInput('hello world hello', 'hello'));
  print('  ✅ Rabin-Karp: found at positions ${rabinResult.occurrences}');

  // Test palindrome detection
  final manacher = ManacherAlgorithm();
  final palindrome = manacher.execute(const ManacherInput('racecar'));
  print(
    '  ✅ Longest palindrome in "racecar": "${palindrome.longestPalindrome}"',
  );
}

void testCustomDataStructures() {
  // Test priority queue
  final pq = PriorityQueue<int>();
  [5, 2, 8, 1, 9].forEach(pq.add);
  final minValues = <int>[];
  for (int i = 0; i < 3; i++) {
    final min = pq.removeMin();
    if (min != null) minValues.add(min);
  }
  print('  ✅ PriorityQueue: first 3 mins are $minValues');

  // Test BST
  final bst = BinarySearchTree<String>();
  ['banana', 'apple', 'cherry', 'date'].forEach(bst.insert);
  final sortedList = bst.toSortedList();
  print('  ✅ BST sorted: $sortedList');

  // Test circular buffer
  final buffer = CircularBuffer<String>(3);
  buffer.add('a');
  buffer.add('b');
  buffer.add('c');
  buffer.add('d'); // Should overwrite 'a'
  print('  ✅ CircularBuffer: ${buffer.toList()}');
}

List<int> generateRandomData(int size) {
  final random = Random(42); // Fixed seed for reproducible results
  return List.generate(size, (_) => random.nextInt(10000));
}
