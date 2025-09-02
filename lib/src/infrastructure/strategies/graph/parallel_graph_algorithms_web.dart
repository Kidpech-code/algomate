import 'dart:collection';
import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';
import '../graph/graph_data_structures.dart';

/// Web-compatible parallel BFS (falls back to sequential)
///
/// Features:
/// - Falls back to sequential BFS on web platform
/// - No isolate usage (web limitation)
/// - Level-by-level traversal
///
/// Best for: Finding shortest paths in unweighted graphs on web platform
///
/// Performance: O(V + E) time, sequential execution
/// Space: O(V) for visited array and queue
class ParallelBFS extends Strategy<Graph<int>, Map<int, int>> {
  ParallelBFS({required this.startVertex});
  final int startVertex;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'parallel_bfs_web',
        timeComplexity: TimeComplexity.oN,
        spaceComplexity: TimeComplexity.oN,
        description:
            'Web-compatible breadth-first search with sequential fallback',
      );

  @override
  bool canApply(Graph<int> input, SelectorHint hint) {
    return input.vertices.contains(startVertex);
  }

  @override
  Map<int, int> execute(Graph<int> graph) {
    final distances = <int, int>{};
    final visited = <int>{};

    final queue = Queue<int>();
    queue.add(startVertex);
    visited.add(startVertex);
    distances[startVertex] = 0;

    while (queue.isNotEmpty) {
      final vertex = queue.removeFirst();
      final currentDistance = distances[vertex]!;

      for (final neighbor in graph.getNeighbors(vertex)) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          distances[neighbor] = currentDistance + 1;
          queue.add(neighbor);
        }
      }
    }

    return distances;
  }
}

/// Web-compatible parallel DFS (falls back to sequential)
///
/// Features:
/// - Falls back to sequential DFS on web platform
/// - No isolate usage (web limitation)
/// - Stack-based iterative implementation
///
/// Best for: Graph traversal and cycle detection on web platform
///
/// Performance: O(V + E) time, sequential execution
/// Space: O(V) for visited array and stack
class ParallelDFS extends Strategy<Graph<int>, List<int>> {
  ParallelDFS({required this.startVertex});
  final int startVertex;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'parallel_dfs_web',
        timeComplexity: TimeComplexity.oN,
        spaceComplexity: TimeComplexity.oN,
        description:
            'Web-compatible depth-first search with sequential fallback',
      );

  @override
  bool canApply(Graph<int> input, SelectorHint hint) {
    return input.vertices.contains(startVertex);
  }

  @override
  List<int> execute(Graph<int> graph) {
    final result = <int>[];
    final visited = <int>{};

    final stack = <int>[startVertex];

    while (stack.isNotEmpty) {
      final vertex = stack.removeLast();

      if (!visited.contains(vertex)) {
        visited.add(vertex);
        result.add(vertex);

        // Add neighbors in reverse order for consistent traversal
        final neighbors = graph.getNeighbors(vertex).toList()..sort();
        for (int i = neighbors.length - 1; i >= 0; i--) {
          if (!visited.contains(neighbors[i])) {
            stack.add(neighbors[i]);
          }
        }
      }
    }

    return result;
  }
}

/// Union-Find data structure for connected components (web version)
class WebUnionFind {
  WebUnionFind(int n) {
    parent = List.generate(n, (i) => i);
    rank = List.filled(n, 0);
  }
  late List<int> parent;
  late List<int> rank;

  int find(int x) {
    if (parent[x] != x) {
      parent[x] = find(parent[x]); // Path compression
    }
    return parent[x];
  }

  bool union(int x, int y) {
    final rootX = find(x);
    final rootY = find(y);

    if (rootX == rootY) return false;

    // Union by rank
    if (rank[rootX] < rank[rootY]) {
      parent[rootX] = rootY;
    } else if (rank[rootX] > rank[rootY]) {
      parent[rootY] = rootX;
    } else {
      parent[rootY] = rootX;
      rank[rootX]++;
    }

    return true;
  }
}

/// Web-compatible parallel connected components (falls back to sequential)
///
/// Features:
/// - Falls back to sequential Union-Find algorithm on web platform
/// - No isolate usage (web limitation)
/// - Uses path compression and union by rank
///
/// Best for: Finding connected components in undirected graphs on web platform
///
/// Performance: O(E * α(V)) time where α is inverse Ackermann function
/// Space: O(V) for Union-Find data structure
class ParallelConnectedComponents
    extends Strategy<Graph<int>, Map<int, List<int>>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'parallel_connected_components_web',
        timeComplexity: TimeComplexity.oN,
        spaceComplexity: TimeComplexity.oN,
        description:
            'Web-compatible Union-Find connected components with sequential fallback',
      );

  @override
  bool canApply(Graph<int> input, SelectorHint hint) {
    return input.vertices.isNotEmpty;
  }

  @override
  Map<int, List<int>> execute(Graph<int> graph) {
    final vertices = graph.vertices.toList()..sort();
    final vertexMap = <int, int>{};
    for (int i = 0; i < vertices.length; i++) {
      vertexMap[vertices[i]] = i;
    }

    final unionFind = WebUnionFind(vertices.length);

    // Process all edges
    for (final vertex in vertices) {
      final vertexIndex = vertexMap[vertex]!;
      for (final neighbor in graph.getNeighbors(vertex)) {
        final neighborIndex = vertexMap[neighbor];
        if (neighborIndex != null && vertex < neighbor) {
          // Process each edge only once
          unionFind.union(vertexIndex, neighborIndex);
        }
      }
    }

    // Group vertices by their root component
    final components = <int, List<int>>{};
    for (int i = 0; i < vertices.length; i++) {
      final root = unionFind.find(i);
      components.putIfAbsent(root, () => <int>[]).add(vertices[i]);
    }

    return components;
  }
}
