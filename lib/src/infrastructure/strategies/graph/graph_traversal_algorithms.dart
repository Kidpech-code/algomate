import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/time_complexity.dart';
import '../../../domain/value_objects/selector_hint.dart';
import 'graph_data_structures.dart';

/// Breadth-First Search (BFS) traversal strategy
class BreadthFirstSearchStrategy<T>
    extends Strategy<BfsInput<T>, BfsResult<T>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'breadth_first_search',
        timeComplexity: TimeComplexity.oVPlusE, // O(V + E)
        spaceComplexity: TimeComplexity.oN, // O(V) for queue and visited set
        requiresSorted: false,
        memoryOverheadBytes:
            1024, // Estimated memory for queue and visited structures
      );

  @override
  bool canApply(BfsInput<T> input, SelectorHint hint) {
    // BFS can be applied to any graph with a valid start vertex
    return input.graph.hasVertex(input.startVertex);
  }

  @override
  BfsResult<T> execute(BfsInput<T> input) {
    final graph = input.graph;
    final startVertex = input.startVertex;

    if (!graph.hasVertex(startVertex)) {
      throw ArgumentError('Start vertex $startVertex not found in graph');
    }

    final visited = <T>{};
    final queue = <T>[startVertex];
    final traversalOrder = <T>[];
    final distances = <T, int>{startVertex: 0};
    final predecessors = <T, T?>{startVertex: null};

    visited.add(startVertex);

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      traversalOrder.add(current);

      final currentDistance = distances[current]!;

      for (final edge in graph.getEdges(current)) {
        final neighbor = edge.destination;

        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          queue.add(neighbor);
          distances[neighbor] = currentDistance + 1;
          predecessors[neighbor] = current;
        }
      }
    }

    return BfsResult<T>(
      traversalOrder: traversalOrder,
      visited: visited,
      distances: distances,
      predecessors: predecessors,
      startVertex: startVertex,
    );
  }
}

/// Depth-First Search (DFS) traversal strategy
class DepthFirstSearchStrategy<T> extends Strategy<DfsInput<T>, DfsResult<T>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'depth_first_search',
        timeComplexity: TimeComplexity.oVPlusE, // O(V + E)
        spaceComplexity: TimeComplexity.oN, // O(V) for recursion stack
        requiresSorted: false,
        memoryOverheadBytes:
            512, // Estimated memory for recursion and visited set
      );

  @override
  bool canApply(DfsInput<T> input, SelectorHint hint) {
    // DFS can be applied to any graph with a valid start vertex
    return input.graph.hasVertex(input.startVertex);
  }

  @override
  DfsResult<T> execute(DfsInput<T> input) {
    final graph = input.graph;
    final startVertex = input.startVertex;

    if (!graph.hasVertex(startVertex)) {
      throw ArgumentError('Start vertex $startVertex not found in graph');
    }

    final visited = <T>{};
    final traversalOrder = <T>[];
    final discoveryTimes = <T, int>{};
    final finishTimes = <T, int>{};
    final predecessors = <T, T?>{};
    var time = 0;

    void dfsVisit(T vertex, T? predecessor) {
      visited.add(vertex);
      traversalOrder.add(vertex);
      discoveryTimes[vertex] = time++;
      predecessors[vertex] = predecessor;

      for (final edge in graph.getEdges(vertex)) {
        final neighbor = edge.destination;

        if (!visited.contains(neighbor)) {
          dfsVisit(neighbor, vertex);
        }
      }

      finishTimes[vertex] = time++;
    }

    dfsVisit(startVertex, null);

    // Visit unvisited vertices (for disconnected graphs)
    for (final vertex in graph.vertices) {
      if (!visited.contains(vertex)) {
        dfsVisit(vertex, null);
      }
    }

    return DfsResult<T>(
      traversalOrder: traversalOrder,
      visited: visited,
      discoveryTimes: discoveryTimes,
      finishTimes: finishTimes,
      predecessors: predecessors,
      startVertex: startVertex,
    );
  }
}

/// Input for BFS algorithm
class BfsInput<T> {
  const BfsInput(this.graph, this.startVertex);
  final Graph<T> graph;
  final T startVertex;

  @override
  String toString() => 'BfsInput(startVertex: $startVertex)';
}

/// Input for DFS algorithm
class DfsInput<T> {
  const DfsInput(this.graph, this.startVertex);
  final Graph<T> graph;
  final T startVertex;

  @override
  String toString() => 'DfsInput(startVertex: $startVertex)';
}

/// Result of BFS traversal
class BfsResult<T> {
  const BfsResult({
    required this.traversalOrder,
    required this.visited,
    required this.distances,
    required this.predecessors,
    required this.startVertex,
  });
  final List<T> traversalOrder;
  final Set<T> visited;
  final Map<T, int> distances;
  final Map<T, T?> predecessors;
  final T startVertex;

  /// Get shortest path to a vertex (in terms of number of edges)
  List<T>? getPath(T destination) {
    if (!visited.contains(destination)) {
      return null;
    }

    final path = <T>[];
    T? current = destination;

    while (current != null) {
      path.insert(0, current);
      current = predecessors[current];
    }

    return path;
  }

  /// Get distance to a vertex
  int? getDistance(T vertex) => distances[vertex];

  /// Check if vertex is reachable
  bool isReachable(T vertex) => visited.contains(vertex);

  @override
  String toString() {
    return 'BfsResult(traversalOrder: $traversalOrder, '
        'visitedCount: ${visited.length}, '
        'startVertex: $startVertex)';
  }
}

/// Result of DFS traversal
class DfsResult<T> {
  const DfsResult({
    required this.traversalOrder,
    required this.visited,
    required this.discoveryTimes,
    required this.finishTimes,
    required this.predecessors,
    required this.startVertex,
  });
  final List<T> traversalOrder;
  final Set<T> visited;
  final Map<T, int> discoveryTimes;
  final Map<T, int> finishTimes;
  final Map<T, T?> predecessors;
  final T startVertex;

  /// Get path to a vertex
  List<T>? getPath(T destination) {
    if (!visited.contains(destination)) {
      return null;
    }

    final path = <T>[];
    T? current = destination;

    while (current != null) {
      path.insert(0, current);
      current = predecessors[current];
    }

    return path;
  }

  /// Get discovery time of a vertex
  int? getDiscoveryTime(T vertex) => discoveryTimes[vertex];

  /// Get finish time of a vertex
  int? getFinishTime(T vertex) => finishTimes[vertex];

  /// Check if vertex is reachable
  bool isReachable(T vertex) => visited.contains(vertex);

  /// Check if vertex u is an ancestor of vertex v in DFS tree
  bool isAncestor(T u, T v) {
    final uDiscovery = discoveryTimes[u];
    final uFinish = finishTimes[u];
    final vDiscovery = discoveryTimes[v];
    final vFinish = finishTimes[v];

    if (uDiscovery == null ||
        uFinish == null ||
        vDiscovery == null ||
        vFinish == null) {
      return false;
    }

    return uDiscovery < vDiscovery && vFinish < uFinish;
  }

  @override
  String toString() {
    return 'DfsResult(traversalOrder: $traversalOrder, '
        'visitedCount: ${visited.length}, '
        'startVertex: $startVertex)';
  }
}
