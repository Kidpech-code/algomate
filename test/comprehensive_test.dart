import 'package:test/test.dart';
import 'package:algomate/algomate.dart';

/// Comprehensive test suite covering edge cases, integration scenarios,
/// performance characteristics, and error handling for AlgoMate package.
void main() {
  group('AlgoMate Comprehensive Tests', () {
    late AlgoSelectorFacade selector;

    setUp(() {
      selector = AlgoSelectorFacade.development();
    });

    group('Edge Cases', () {
      test('should handle empty lists correctly', () {
        final result =
            selector.sort(input: <int>[], hint: SelectorHint.small());
        result.fold(
          (success) => expect(success.output, isEmpty),
          (failure) => fail('Should not fail on empty input: $failure'),
        );
      });

      test('should handle single element lists', () {
        final result = selector.sort(input: [42], hint: SelectorHint.small());
        result.fold(
          (success) => expect(success.output, equals([42])),
          (failure) => fail('Should not fail on single element: $failure'),
        );
      });

      test('should handle lists with duplicate elements', () {
        final input = [5, 2, 8, 2, 9, 1, 5, 5];
        final expected = [1, 2, 2, 5, 5, 5, 8, 9];

        final result = selector.sort(
          input: input,
          hint: SelectorHint(n: input.length),
        );
        result.fold(
          (success) => expect(success.output, equals(expected)),
          (failure) => fail('Should handle duplicates: $failure'),
        );
      });

      test('should handle already sorted lists efficiently', () {
        final input = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

        final result = selector.sort(
          input: input,
          hint: SelectorHint(n: input.length, sorted: true),
        );

        result.fold(
          (success) {
            expect(success.output, equals(input));
            // Should use an algorithm that benefits from sorted input
            expect(success.selectedStrategy.name, contains('insertion'));
          },
          (failure) => fail('Should handle sorted input: $failure'),
        );
      });

      test('should handle reverse sorted lists', () {
        final input = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
        final expected = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

        final result = selector.sort(
          input: input,
          hint: SelectorHint(n: input.length),
        );
        result.fold(
          (success) => expect(success.output, equals(expected)),
          (failure) => fail('Should handle reverse sorted: $failure'),
        );
      });

      test('should handle extreme values', () {
        final input = [-2147483648, 2147483647, 0, -1, 1];
        final expected = [-2147483648, -1, 0, 1, 2147483647];

        final result = selector.sort(
          input: input,
          hint: SelectorHint(n: input.length),
        );
        result.fold(
          (success) => expect(success.output, equals(expected)),
          (failure) => fail('Should handle extreme values: $failure'),
        );
      });
    });

    group('Algorithm Selection Logic', () {
      test('should select insertion sort for small datasets', () {
        final input = [3, 1, 4, 1, 5];
        final result = selector.sort(input: input, hint: SelectorHint.small());

        result.fold(
          (success) => expect(
            success.selectedStrategy.name,
            anyOf(contains('insertion'), contains('hybrid')),
          ),
          (failure) => fail('Should select appropriate algorithm: $failure'),
        );
      });

      test('should select merge sort for large datasets', () {
        final input = List.generate(1000, (i) => 1000 - i);
        final result = selector.sort(input: input, hint: SelectorHint.large());

        result.fold(
          (success) => expect(
            success.selectedStrategy.name,
            anyOf(contains('merge'), contains('quick'), contains('heap')),
          ),
          (failure) => fail('Should select scalable algorithm: $failure'),
        );
      });

      test('should respect memory constraints', () {
        final input = List.generate(100, (i) => 100 - i);
        final result =
            selector.sort(input: input, hint: SelectorHint.lowMemory());

        result.fold(
          (success) {
            // Should select in-place or low memory algorithm
            expect(
              success.selectedStrategy.spaceComplexity.rankValue,
              lessThanOrEqualTo(2),
            );
          },
          (failure) => fail('Should respect memory constraints: $failure'),
        );
      });
    });

    group('Performance Characteristics', () {
      test('should measure execution time', () {
        final input = List.generate(100, (i) => 100 - i);
        final result =
            selector.sort(input: input, hint: const SelectorHint(n: 100));

        result.fold(
          (success) {
            expect(success.executionTimeMicros, isNotNull);
            expect(success.executionTimeMicros!, greaterThan(0));
          },
          (failure) => fail('Should provide timing information: $failure'),
        );
      });

      test('should choose efficient algorithms for different sizes', () {
        final sizes = [10, 100, 1000];
        final results = <String>[];

        for (final size in sizes) {
          final input = List.generate(size, (i) => size - i);
          final result = selector.sort(
            input: input,
            hint: SelectorHint(n: size),
          );

          result.fold(
            (success) => results.add(success.selectedStrategy.name),
            (failure) =>
                fail('Should select algorithm for size $size: $failure'),
          );
        }

        // Different sizes should potentially select different algorithms
        expect(results, hasLength(3));
        // At least verify we get valid algorithm names
        for (final algorithmName in results) {
          expect(algorithmName, isNotEmpty);
        }
      });
    });

    group('Integration Tests', () {
      test('should handle complete workflow with custom strategy', () {
        // Create a simple custom strategy
        final customStrategy = _TestQuickSort();

        // Register custom strategy
        final signature = StrategySignature.sort(
          inputType: List<int>,
          tag: 'test_quick_sort',
        );

        final registrationResult = selector.register<List<int>, List<int>>(
          strategy: customStrategy,
          signature: signature,
        );
        expect(registrationResult.isSuccess, isTrue);

        // Use custom strategy
        final input = List.generate(50, (i) => 50 - i);
        final sortResult = selector.execute<List<int>, List<int>>(
          input: input,
          signature: signature,
          hint: const SelectorHint(n: 50),
        );

        sortResult.fold(
          (success) {
            expect(success.output, hasLength(50));
            expect(success.output.first, equals(1));
            expect(success.output.last, equals(50));
            expect(success.selectedStrategy.name, equals('test_quick_sort'));
          },
          (failure) => fail('Custom strategy integration failed: $failure'),
        );
      });

      test('should handle strategy fallback gracefully', () {
        // This test verifies that if a preferred strategy can't be applied,
        // the system falls back to another suitable strategy
        final input = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3];

        // Request sort on unsorted data
        const hint = SelectorHint(n: 10, sorted: false); // Explicitly unsorted
        final result = selector.sort(input: input, hint: hint);

        result.fold(
          (success) {
            // Should successfully sort despite conflicting hint
            expect(success.output, hasLength(10));
            // Should be sorted
            for (int i = 1; i < success.output.length; i++) {
              expect(
                success.output[i],
                greaterThanOrEqualTo(success.output[i - 1]),
              );
            }
          },
          (failure) => fail('Should fallback gracefully: $failure'),
        );
      });
    });

    group('Error Handling', () {
      test('should handle strategy registration errors', () {
        final invalidStrategy = _InvalidStrategy();
        final signature =
            StrategySignature.sort(inputType: List<int>, tag: 'invalid_test');

        final result = selector.register<List<int>, List<int>>(
          strategy: invalidStrategy,
          signature: signature,
        );

        expect(result.isFailure, isTrue);
      });

      test('should handle non-existent strategy signature', () {
        final input = [1, 2, 3];
        final invalidSignature =
            StrategySignature.sort(inputType: List<int>, tag: 'nonexistent');

        final result = selector.execute<List<int>, List<int>>(
          input: input,
          signature: invalidSignature,
          hint: SelectorHint.small(),
        );

        expect(result.isFailure, isTrue);
        result.fold(
          (success) => fail('Should fail with non-existent signature'),
          (failure) => expect(failure, isA<NoStrategyFailure>()),
        );
      });

      test('should provide detailed error information', () {
        final invalidSignature =
            StrategySignature.sort(inputType: List<int>, tag: 'missing_algo');

        final result = selector.execute<List<int>, List<int>>(
          input: [1, 2, 3],
          signature: invalidSignature,
          hint: SelectorHint.small(),
        );

        result.fold((success) => fail('Should fail with missing algorithm'),
            (failure) {
          expect(failure.message, isNotEmpty);
          expect(failure.details, isNotNull);
          expect(failure.toString(), contains('missing_algo'));
        });
      });
    });

    group('Memory and Resource Management', () {
      test('should handle memory budget constraints', () {
        final input = List.generate(1000, (i) => 1000 - i);
        const hint = SelectorHint(
          n: 1000,
          memoryBudgetBytes: 1024, // Very small memory budget
        );

        final result = selector.sort(input: input, hint: hint);

        result.fold(
          (success) {
            // Should select a memory-efficient algorithm
            final strategy = success.selectedStrategy;
            expect(strategy.memoryOverheadBytes, lessThanOrEqualTo(1024));
          },
          (failure) => fail('Should handle memory constraints: $failure'),
        );
      });
    });

    group('Statistics and Metadata', () {
      test('should provide facade statistics', () {
        expect(selector.strategyCount, greaterThan(0));
        expect(selector.signatures, isNotEmpty);

        final stats = selector.getStats();
        expect(stats.totalStrategies, greaterThan(0));
      });

      test('should track execution timing when enabled', () {
        final input = List.generate(50, (i) => 50 - i);

        // Execute multiple times to verify timing
        for (int i = 0; i < 3; i++) {
          final result =
              selector.sort(input: input, hint: const SelectorHint(n: 50));
          result.fold(
            (success) {
              // Should have timing information
              expect(success.executionTimeMicros, isNotNull);
              expect(success.executionTimeMicros!, greaterThan(0));
            },
            (failure) => fail('Iteration $i failed: $failure'),
          );
        }
      });
    });

    group('Strategy Management', () {
      test('should allow removing strategies', () {
        // First register a custom strategy
        final strategy = _TestQuickSort();
        final signature =
            StrategySignature.sort(inputType: List<int>, tag: 'removable_sort');

        selector.register<List<int>, List<int>>(
          strategy: strategy,
          signature: signature,
        );
        expect(
          selector.hasStrategy<List<int>, List<int>>(
            'test_quick_sort',
            signature,
          ),
          isTrue,
        );

        // Now remove it
        final removeResult = selector.removeStrategy<List<int>, List<int>>(
          strategyName: 'test_quick_sort',
          signature: signature,
        );

        removeResult.fold(
          (removed) => expect(removed, isTrue),
          (failure) => fail('Should successfully remove strategy: $failure'),
        );

        expect(
          selector.hasStrategy<List<int>, List<int>>(
            'test_quick_sort',
            signature,
          ),
          isFalse,
        );
      });

      test('should find specific strategies', () {
        final strategy = _TestQuickSort();
        final signature =
            StrategySignature.sort(inputType: List<int>, tag: 'findable_sort');

        selector.register<List<int>, List<int>>(
          strategy: strategy,
          signature: signature,
        );

        final found = selector.findStrategy<List<int>, List<int>>(
          'test_quick_sort',
          signature,
        );
        expect(found, isNotNull);
        expect(found!.meta.name, equals('test_quick_sort'));
      });
    });
  });
}

/// Test implementation of QuickSort for integration testing
class _TestQuickSort extends Strategy<List<int>, List<int>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'test_quick_sort',
        timeComplexity: TimeComplexity.oNLogN,
        spaceComplexity: TimeComplexity.oLogN,
        requiresSorted: false,
        memoryOverheadBytes: 0,
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) => true;

  @override
  List<int> execute(List<int> input) {
    final result = List<int>.from(input);
    result.sort(); // Simple implementation using Dart's built-in sort
    return result;
  }
}

/// Invalid strategy for testing error handling
class _InvalidStrategy extends Strategy<List<int>, List<int>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: '', // Invalid empty name
        timeComplexity: TimeComplexity.oN,
        spaceComplexity: TimeComplexity.o1,
      );

  @override
  bool canApply(List<int> input, SelectorHint hint) =>
      throw UnimplementedError();

  @override
  List<int> execute(List<int> input) => throw UnimplementedError();
}
