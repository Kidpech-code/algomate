import 'package:flutter/material.dart';
import 'package:algomate/algomate.dart';
import 'dart:math' as math;

class AlgorithmsScreen extends StatefulWidget {
  const AlgorithmsScreen({super.key});

  @override
  State<AlgorithmsScreen> createState() => _AlgorithmsScreenState();
}

class _AlgorithmsScreenState extends State<AlgorithmsScreen> {
  final AlgoSelectorFacade _selector = AlgoSelectorFacade.development();
  final List<AlgorithmDemo> _demos = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _initializeDemos();
  }

  void _initializeDemos() {
    _demos.addAll([
      AlgorithmDemo(
        category: 'Sorting',
        name: 'MergeSort',
        description: 'O(n log n) stable sorting algorithm',
        icon: Icons.sort,
        testFunction: _testSorting,
      ),
      AlgorithmDemo(
        category: 'Search',
        name: 'Binary Search',
        description: 'O(log n) search in sorted arrays',
        icon: Icons.search,
        testFunction: _testSearch,
      ),
      AlgorithmDemo(
        category: 'Dynamic Programming',
        name: 'Knapsack Problem',
        description: 'Find optimal value within weight constraint',
        icon: Icons.shopping_bag,
        testFunction: _testKnapsack,
      ),
      AlgorithmDemo(
        category: 'String Processing',
        name: 'KMP Pattern Matching',
        description: 'O(n+m) efficient pattern searching',
        icon: Icons.text_fields,
        testFunction: _testStringMatching,
      ),
      AlgorithmDemo(
        category: 'Graph',
        name: 'Breadth-First Search',
        description: 'O(V+E) graph traversal algorithm',
        icon: Icons.account_tree,
        testFunction: _testGraphTraversal,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🧬 Algorithm Demonstrations',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _isRunning ? null : _runAllDemos,
                icon: _isRunning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_isRunning ? 'Running...' : 'Run All Tests'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _demos.length,
              itemBuilder: (context, index) {
                return AlgorithmCard(
                  demo: _demos[index],
                  onRun: () => _runDemo(_demos[index]),
                  isRunning: _isRunning,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runAllDemos() async {
    setState(() => _isRunning = true);

    for (final demo in _demos) {
      await _runDemo(demo);
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }

    setState(() => _isRunning = false);
  }

  Future<void> _runDemo(AlgorithmDemo demo) async {
    setState(() {
      demo.isRunning = true;
      demo.result = null;
    });

    try {
      final stopwatch = Stopwatch()..start();
      final result = await demo.testFunction();
      stopwatch.stop();

      setState(() {
        demo.result = '$result\nExecuted in ${stopwatch.elapsedMicroseconds}μs';
        demo.isRunning = false;
      });
    } catch (e) {
      setState(() {
        demo.result = 'Error: $e';
        demo.isRunning = false;
      });
    }
  }

  Future<String> _testSorting() async {
    final data = List.generate(1000, (i) => math.Random().nextInt(1000));
    final result = _selector.sort(
      input: data,
      hint: SelectorHint(n: data.length),
    );

    return result.fold(
      (success) =>
          'Sorted ${data.length} elements: [${success.output.take(5).join(', ')}...]',
      (error) => 'Error: $error',
    );
  }

  Future<String> _testSearch() async {
    final data = List.generate(10000, (i) => i * 2);
    // ignore: prefer_const_declarations
    final target = 5000;

    final result = _selector.search(
      input: data,
      target: target,
      hint: SelectorHint(n: data.length, sorted: true),
    );

    return result.fold(
      (success) => 'Found $target at index: ${success.output}',
      (error) => 'Error: $error',
    );
  }

  Future<String> _testKnapsack() async {
    final knapsack = KnapsackDP();
    const input = KnapsackInput([2, 3, 4, 5], [3, 4, 5, 8], 8);
    final result = knapsack.execute(input);

    return 'Maximum value: ${result.maxValue}, Selected items: ${result.selectedItems}';
  }

  Future<String> _testStringMatching() async {
    final kmp = KnuthMorrisPrattAlgorithm();
    const input = KMPInput('ABABCABABA', 'ABAB');
    final result = kmp.execute(input);

    return 'Pattern found at positions: ${result.occurrences}';
  }

  Future<String> _testGraphTraversal() async {
    final graph = Graph<int>(isDirected: false);

    // Add vertices
    for (int i = 0; i < 6; i++) {
      graph.addVertex(i);
    }

    // Add edges
    graph.addEdge(0, 1);
    graph.addEdge(0, 2);
    graph.addEdge(1, 3);
    graph.addEdge(2, 4);
    graph.addEdge(3, 5);

    final bfs = BreadthFirstSearchStrategy<int>();
    final input = BfsInput(graph, 0);
    final result = bfs.execute(input);

    return 'BFS traversal order: ${result.traversalOrder}';
  }
}

class AlgorithmDemo {
  AlgorithmDemo({
    required this.category,
    required this.name,
    required this.description,
    required this.icon,
    required this.testFunction,
  });
  final String category;
  final String name;
  final String description;
  final IconData icon;
  final Future<String> Function() testFunction;

  bool isRunning = false;
  String? result;
}

class AlgorithmCard extends StatelessWidget {
  const AlgorithmCard({
    super.key,
    required this.demo,
    required this.onRun,
    required this.isRunning,
  });

  final AlgorithmDemo demo;
  final VoidCallback onRun;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(demo.icon, color: Colors.blue[600]),
        title: Text(demo.name),
        subtitle: Text('${demo.category} • ${demo.description}'),
        trailing: demo.isRunning
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: isRunning ? null : onRun,
              ),
        children: [
          if (demo.result != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  demo.result!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
