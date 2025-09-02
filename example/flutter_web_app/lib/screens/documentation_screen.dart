import 'package:flutter/material.dart';

class DocumentationScreen extends StatefulWidget {
  const DocumentationScreen({super.key});

  @override
  State<DocumentationScreen> createState() => _DocumentationScreenState();
}

class _DocumentationScreenState extends State<DocumentationScreen> {
  final List<DocumentationSection> _sections = [];

  @override
  void initState() {
    super.initState();
    _initializeSections();
  }

  void _initializeSections() {
    _sections.addAll([
      DocumentationSection(
        title: '🚀 Getting Started',
        content: '''
# AlgoMate - Flutter Web Compatible

AlgoMate is a comprehensive algorithm library designed to work seamlessly on both native platforms and Flutter Web.

## Installation

```yaml
dependencies:
  algomate: ^1.0.0
```

## Basic Usage

```dart
import 'package:algomate/algomate.dart';

void main() {
  final selector = AlgoSelectorFacade.development();
  
  // Sorting
  final data = [3, 1, 4, 1, 5, 9];
  final result = selector.sort(
    input: data,
    hint: SelectorHint(n: data.length),
  );
  
  result.fold(
    (success) => print('Sorted: \${success.output}'),
    (error) => print('Error: \$error'),
  );
}
```
        ''',
      ),
      DocumentationSection(
        title: '📚 Algorithm Categories',
        content: '''
# Algorithm Categories

## Sorting Algorithms
- **MergeSort**: O(n log n) stable sorting
- **QuickSort**: O(n log n) average case
- **HeapSort**: O(n log n) guaranteed

## Search Algorithms  
- **Binary Search**: O(log n) for sorted arrays
- **Linear Search**: O(n) for unsorted arrays

## Dynamic Programming
- **Knapsack Problem**: Classic optimization
- **Longest Common Subsequence**: String matching
- **Fibonacci**: Optimized calculation

## String Processing
- **KMP Algorithm**: O(n+m) pattern matching
- **Rabin-Karp**: Rolling hash search
- **Longest Palindrome**: Efficient palindrome detection

## Graph Algorithms
- **BFS/DFS**: Graph traversal
- **Connected Components**: Component analysis
- **Shortest Path**: Path finding algorithms

## Matrix Operations
- **Matrix Multiplication**: Optimized computation
- **Matrix Transpose**: Efficient transformation
- **Matrix Determinant**: Linear algebra operations
        ''',
      ),
      DocumentationSection(
        title: '🌐 Web Compatibility',
        content: '''
# Web Compatibility Features

## Automatic Platform Detection
AlgoMate automatically detects the platform and selects appropriate implementations:

- **Native Platforms**: Uses `dart:isolate` for parallel processing
- **Web Platform**: Uses sequential algorithms with same API

## Conditional Imports
The library uses conditional imports to provide platform-specific implementations:

```dart
// lib/src/infrastructure/strategies/parallel_algorithms.dart
export 'sort/parallel_sort_algorithms_native.dart'
    if (dart.library.html) 'sort/parallel_sort_algorithms_web.dart';
```

## Web-Specific Optimizations
- Sequential fallback algorithms
- Memory-efficient implementations  
- JavaScript compilation optimizations
- No `dart:isolate` or `dart:io` dependencies on web

## Performance Considerations
- Web algorithms are optimized for single-threaded execution
- Memory usage is minimized for browser constraints
- Algorithms maintain the same complexity guarantees
        ''',
      ),
      DocumentationSection(
        title: '💡 Usage Examples',
        content: '''
# Practical Examples

## Sorting Large Datasets
```dart
final facade = AlgoSelectorFacade.development();
final largeData = List.generate(10000, (i) => Random().nextInt(10000));

final result = facade.sort(
  input: largeData,
  hint: SelectorHint(n: largeData.length),
);

result.fold(
  (success) {
    print('Sorted \${largeData.length} elements');
    print('First 10: \${success.output.take(10)}');
  },
  (error) => print('Sorting failed: \$error'),
);
```

## Graph Analysis
```dart
final graph = Graph<String>(isDirected: false);

// Add vertices
['A', 'B', 'C', 'D'].forEach(graph.addVertex);

// Add edges  
graph.addEdge('A', 'B');
graph.addEdge('B', 'C');
graph.addEdge('C', 'D');

final bfs = BreadthFirstSearchStrategy<String>();
final result = bfs.execute(BfsInput(graph, 'A'));

print('BFS traversal: \${result.traversalOrder}');
```

## Dynamic Programming
```dart
final knapsack = KnapsackDP();
final input = KnapsackInput(
  [2, 3, 4, 5],      // weights
  [3, 4, 5, 8],      // values  
  8,                 // capacity
);

final result = knapsack.execute(input);
print('Max value: \${result.maxValue}');
print('Selected items: \${result.selectedItems}');
```

## String Processing
```dart
final kmp = KnuthMorrisPrattAlgorithm();
final input = KMPInput('ABABCABABA', 'ABAB');
final result = kmp.execute(input);

print('Pattern found at: \${result.occurrences}');
```
        ''',
      ),
      DocumentationSection(
        title: '🔧 Configuration',
        content: '''
# Configuration Options

## Selector Hints
Control algorithm selection with hints:

```dart
final hint = SelectorHint(
  n: dataSize,
  sorted: true,        // Data is already sorted
  complexity: 'nlogn', // Preferred complexity
  parallel: false,     // Disable parallelism
);
```

## Development vs Production
Choose appropriate facade for your needs:

```dart
// Development: Includes logging and debugging
final devSelector = AlgoSelectorFacade.development();

// Production: Optimized for performance  
final prodSelector = AlgoSelectorFacade.production();
```

## Custom Algorithm Selection
Implement custom selection logic:

```dart
class CustomSelector extends AlgorithmSelector {
  @override
  Algorithm<Input, Output> select(SelectorHint hint) {
    // Custom selection logic
    if (hint.n < 100) return QuickSort();
    return MergeSort();
  }
}
```
        ''',
      ),
      DocumentationSection(
        title: '🚀 Performance Tips',
        content: '''
# Performance Optimization

## Web-Specific Tips
1. **Use appropriate data sizes**: Avoid extremely large datasets in browsers
2. **Leverage browser caching**: Reuse algorithm instances when possible  
3. **Monitor memory usage**: Use browser dev tools to track memory
4. **Consider chunked processing**: Break large operations into smaller parts

## Algorithm Selection
- **Small datasets (< 100)**: Simple algorithms (QuickSort, Linear Search)
- **Medium datasets (100-10k)**: Standard algorithms (MergeSort, Binary Search)  
- **Large datasets (> 10k)**: Optimized algorithms with careful memory management

## Memory Management
```dart
// Efficient memory usage
final result = selector.sort(input: data, hint: hint);
result.fold(
  (success) {
    // Process result
    final processed = processData(success.output);
    // Clear references to help GC
    success.output.clear();
    return processed;
  },
  (error) => handleError(error),
);
```

## Benchmarking
Use the built-in performance screen to benchmark algorithms:
- Compare execution times
- Monitor memory usage  
- Identify performance bottlenecks
- Validate web compatibility
        ''',
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
          const Text(
            '📖 Documentation & API Reference',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                return DocumentationCard(section: _sections[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentationSection {
  DocumentationSection({
    required this.title,
    required this.content,
    this.isExpanded = false,
  });
  final String title;
  final String content;
  bool isExpanded;
}

class DocumentationCard extends StatefulWidget {
  const DocumentationCard({super.key, required this.section});

  final DocumentationSection section;

  @override
  State<DocumentationCard> createState() => _DocumentationCardState();
}

class _DocumentationCardState extends State<DocumentationCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          widget.section.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: widget.section.isExpanded,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: SelectableText(
                widget.section.content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
