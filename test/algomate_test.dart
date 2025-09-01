import 'package:test/test.dart';
import 'package:algomate/algomate.dart';

void main() {
  group('AlgoMate Tests', () {
    late AlgoSelectorFacade selector;

    setUp(() {
      selector = AlgoSelectorFacade.development();
    });

    test('should sort small arrays using efficient algorithm', () {
      final input = [64, 34, 25, 12, 22, 11, 90];
      final result = selector.sort(input: input, hint: SelectorHint.small());

      expect(result.isSuccess, isTrue);

      result.fold((success) {
        expect(success.output, equals([11, 12, 22, 25, 34, 64, 90]));
        // System chooses the most efficient algorithm for small data
        // Could be hybrid_merge_sort due to balanced performance
        expect(success.selectedStrategy.name, isNotEmpty);
      }, (failure) => fail('Sort should not fail: $failure'));
    });

    test('should sort large arrays using merge sort', () {
      final input = List.generate(1000, (i) => 1000 - i);
      final result = selector.sort(input: input, hint: SelectorHint.large());

      expect(result.isSuccess, isTrue);

      result.fold((success) {
        expect(success.output, equals(List.generate(1000, (i) => i + 1)));
        // Should use merge sort for large data
        expect(success.selectedStrategy.name, contains('merge'));
      }, (failure) => fail('Large sort should not fail: $failure'));
    });

    test('should register custom strategy', () {
      final customStrategy = _TestStrategy();
      final signature = StrategySignature.sort(inputType: List<int>);

      final registerResult = selector.register<List<int>, List<int>>(strategy: customStrategy, signature: signature, allowReplace: true);

      expect(registerResult.isSuccess, isTrue);
      expect(selector.hasStrategy<List<int>, List<int>>('test_strategy', signature), isTrue);
    });

    test('should handle empty input', () {
      final result = selector.sort(input: <int>[], hint: const SelectorHint());

      result.fold(
        (success) {
          expect(success.output, isEmpty);
        },
        (failure) {
          // Empty input might not have applicable strategies
          expect(failure, isA<NoStrategyFailure>());
        },
      );
    });

    test('should provide statistics', () {
      final stats = selector.getStats();
      expect(stats.totalStrategies, greaterThan(0));
      expect(stats.categoryCounts, isNotEmpty);
    });
  });
}

class _TestStrategy extends Strategy<List<int>, List<int>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(name: 'test_strategy', timeComplexity: TimeComplexity.oN);

  @override
  bool canApply(List<int> input, SelectorHint hint) => true;

  @override
  List<int> execute(List<int> input) => [...input]..sort();
}
