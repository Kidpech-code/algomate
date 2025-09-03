import '../../domain/repositories/strategy_catalog.dart';
import '../../domain/services/selector_policy.dart';
import '../../domain/value_objects/selector_hint.dart';
import '../../domain/entities/strategy_signature.dart';
import '../../shared/errors.dart';
import '../../shared/result.dart';
import '../dto/strategy_recommendation.dart';

/// Use case to recommend a strategy without executing it.
class RecommendStrategyUseCase {
  const RecommendStrategyUseCase({
    required this.catalog,
    required this.policy,
  });

  final StrategyCatalog catalog;
  final SelectorPolicy policy;

  Result<StrategyRecommendation, AlgoMateFailure> call<I, O>({
    required StrategySignature signature,
    required SelectorHint hint,
  }) {
    final candidates = catalog.list<I, O>(signature);
    if (candidates.isEmpty) {
      return Result.failure(
        NoStrategyFailure.forSignature(signature.toString()),
      );
    }

    // We cannot evaluate canApply() without concrete input here reliably.
    // Use policy ranking over all candidates based on hints only.
    final ranked = policy.rank<I, O>(candidates, hint);
    final chosen = ranked.first;

    final alternatives = <String>[];
    for (var i = 1; i < ranked.length; i++) {
      alternatives.add(ranked[i].meta.name);
    }

    final reason = _buildReason(hint, chosen.meta.name, ranked.length);

    return Result.success(
      StrategyRecommendation(
        name: chosen.meta.name,
        estimatedComplexity: chosen.meta.timeComplexity,
        estimatedMemoryBytes: chosen.meta.memoryOverheadBytes,
        reason: reason,
        alternatives: alternatives,
        selectedMeta: chosen.meta,
      ),
    );
  }

  String _buildReason(SelectorHint hint, String name, int candidates) {
    final parts = <String>['Selected "$name" among $candidates candidates'];
    if (hint.n != null) parts.add('n=${hint.n}');
    if (hint.preferStable == true) parts.add('preferStable');
    if (hint.sorted == true) parts.add('inputSorted');
    if (hint.memoryBudgetBytes != null) {
      parts.add('memory<=${hint.memoryBudgetBytes}');
    }
    return parts.join(', ');
  }
}
