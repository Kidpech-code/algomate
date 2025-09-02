import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/time_complexity.dart';
import '../../../domain/value_objects/selector_hint.dart';
import 'graph_data_structures.dart';

/// Dijkstra's shortest path algorithm strategy
class DijkstraAlgorithmStrategy<T>
    extends Strategy<DijkstraInput<T>, ShortestPathResult<T>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'dijkstra_algorithm',
        timeComplexity: TimeComplexity
            .oN2, // O(V²) with simple implementation, O((V + E) log V) with heap
        spaceComplexity:
            TimeComplexity.oN, // O(V) for distances and visited sets
        requiresSorted: false,
        memoryOverheadBytes: 2048,
      );

  @override
  bool canApply(DijkstraInput<T> input, SelectorHint hint) {
    // Dijkstra requires non-negative weights
    return !input.hasNegativeWeights && input.graph.hasVertex(input.source);
  }

  @override
  ShortestPathResult<T> execute(DijkstraInput<T> input) {
    final graph = input.graph;
    final source = input.source;

    if (!graph.hasVertex(source)) {
      throw ArgumentError('Source vertex $source not found in graph');
    }

    final vertices = graph.vertices;
    final distances = <T, double>{};
    final predecessors = <T, T?>{};
    final visited = <T>{};

    // Initialize distances
    for (final vertex in vertices) {
      distances[vertex] = vertex == source ? 0.0 : double.infinity;
      predecessors[vertex] = null;
    }

    while (visited.length < vertices.length) {
      // Find unvisited vertex with minimum distance
      T? current;
      double minDistance = double.infinity;

      for (final vertex in vertices) {
        if (!visited.contains(vertex) && distances[vertex]! < minDistance) {
          current = vertex;
          minDistance = distances[vertex]!;
        }
      }

      if (current == null || minDistance == double.infinity) {
        break; // No more reachable vertices
      }

      visited.add(current);

      // Update distances to neighbors
      for (final edge in graph.getEdges(current)) {
        final neighbor = edge.destination;
        final weight = edge.weight;

        if (!visited.contains(neighbor)) {
          final newDistance = distances[current]! + weight;
          if (newDistance < distances[neighbor]!) {
            distances[neighbor] = newDistance;
            predecessors[neighbor] = current;
          }
        }
      }
    }

    return ShortestPathResult(distances, predecessors, source);
  }
}

/// Bellman-Ford shortest path algorithm strategy
class BellmanFordAlgorithmStrategy<T>
    extends Strategy<BellmanFordInput<T>, BellmanFordResult<T>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'bellman_ford_algorithm',
        timeComplexity: TimeComplexity.oN3, // O(VE) ≈ O(V³) in dense graphs
        spaceComplexity:
            TimeComplexity.oN, // O(V) for distances and predecessors
        requiresSorted: false,
        memoryOverheadBytes: 1024,
      );

  @override
  bool canApply(BellmanFordInput<T> input, SelectorHint hint) {
    // Bellman-Ford can handle negative weights
    return input.graph.hasVertex(input.source);
  }

  @override
  BellmanFordResult<T> execute(BellmanFordInput<T> input) {
    final graph = input.graph;
    final source = input.source;

    if (!graph.hasVertex(source)) {
      throw ArgumentError('Source vertex $source not found in graph');
    }

    final vertices = graph.vertices;
    final distances = <T, double>{};
    final predecessors = <T, T?>{};

    // Initialize distances
    for (final vertex in vertices) {
      distances[vertex] = vertex == source ? 0.0 : double.infinity;
      predecessors[vertex] = null;
    }

    // Relax edges repeatedly
    for (int i = 0; i < vertices.length - 1; i++) {
      for (final vertex in vertices) {
        if (distances[vertex] != double.infinity) {
          for (final edge in graph.getEdges(vertex)) {
            final neighbor = edge.destination;
            final weight = edge.weight;
            final newDistance = distances[vertex]! + weight;

            if (newDistance < distances[neighbor]!) {
              distances[neighbor] = newDistance;
              predecessors[neighbor] = vertex;
            }
          }
        }
      }
    }

    // Check for negative cycles
    bool hasNegativeCycle = false;
    for (final vertex in vertices) {
      if (distances[vertex] != double.infinity) {
        for (final edge in graph.getEdges(vertex)) {
          final neighbor = edge.destination;
          final weight = edge.weight;
          final newDistance = distances[vertex]! + weight;

          if (newDistance < distances[neighbor]!) {
            hasNegativeCycle = true;
            break;
          }
        }
        if (hasNegativeCycle) break;
      }
    }

    return BellmanFordResult(
      ShortestPathResult(distances, predecessors, source),
      hasNegativeCycle,
    );
  }
}

/// Floyd-Warshall all-pairs shortest path algorithm strategy
class FloydWarshallAlgorithmStrategy<T>
    extends Strategy<FloydWarshallInput<T>, FloydWarshallResult<T>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'floyd_warshall_algorithm',
        timeComplexity: TimeComplexity.oN3, // O(V³)
        spaceComplexity: TimeComplexity.oN2, // O(V²) for distance matrix
        requiresSorted: false,
        memoryOverheadBytes: 4096,
      );

  @override
  bool canApply(FloydWarshallInput<T> input, SelectorHint hint) {
    // Floyd-Warshall works on any graph
    return input.graph.vertexCount > 0;
  }

  @override
  FloydWarshallResult<T> execute(FloydWarshallInput<T> input) {
    final graph = input.graph;
    final vertices = graph.vertices.toList();
    final vertexCount = vertices.length;

    // Create vertex index mapping
    final vertexIndex = <T, int>{};
    for (int i = 0; i < vertexCount; i++) {
      vertexIndex[vertices[i]] = i;
    }

    // Initialize distance matrix
    final distances = List.generate(
      vertexCount,
      (i) => List.filled(vertexCount, double.infinity),
    );

    final predecessors = List.generate(
      vertexCount,
      (i) => List<T?>.filled(vertexCount, null),
    );

    // Set diagonal to 0
    for (int i = 0; i < vertexCount; i++) {
      distances[i][i] = 0.0;
    }

    // Initialize with direct edges
    for (final vertex in vertices) {
      final i = vertexIndex[vertex]!;
      for (final edge in graph.getEdges(vertex)) {
        final j = vertexIndex[edge.destination]!;
        distances[i][j] = edge.weight;
        predecessors[i][j] = vertex;
      }
    }

    // Floyd-Warshall main algorithm
    for (int k = 0; k < vertexCount; k++) {
      for (int i = 0; i < vertexCount; i++) {
        for (int j = 0; j < vertexCount; j++) {
          final throughK = distances[i][k] + distances[k][j];
          if (throughK < distances[i][j]) {
            distances[i][j] = throughK;
            predecessors[i][j] = predecessors[k][j];
          }
        }
      }
    }

    // Check for negative cycles
    bool hasNegativeCycle = false;
    for (int i = 0; i < vertexCount && !hasNegativeCycle; i++) {
      if (distances[i][i] < 0) {
        hasNegativeCycle = true;
      }
    }

    return FloydWarshallResult(
      vertices,
      vertexIndex,
      distances,
      predecessors,
      hasNegativeCycle,
    );
  }
}

/// Input for Dijkstra's algorithm
class DijkstraInput<T> {
  DijkstraInput(this.graph, this.source, {this.hasNegativeWeights = false});
  final Graph<T> graph;
  final T source;
  final bool hasNegativeWeights;

  @override
  String toString() =>
      'DijkstraInput(source: $source, hasNegativeWeights: $hasNegativeWeights)';
}

/// Input for Bellman-Ford algorithm
class BellmanFordInput<T> {
  const BellmanFordInput(this.graph, this.source);
  final Graph<T> graph;
  final T source;

  @override
  String toString() => 'BellmanFordInput(source: $source)';
}

/// Input for Floyd-Warshall algorithm
class FloydWarshallInput<T> {
  const FloydWarshallInput(this.graph);
  final Graph<T> graph;

  @override
  String toString() => 'FloydWarshallInput(vertices: ${graph.vertexCount})';
}

/// Result of Bellman-Ford algorithm
class BellmanFordResult<T> {
  const BellmanFordResult(this.shortestPaths, this.hasNegativeCycle);
  final ShortestPathResult<T> shortestPaths;
  final bool hasNegativeCycle;

  /// Get shortest distance to a vertex
  double? getDistance(T vertex) => shortestPaths.getDistance(vertex);

  /// Get shortest path to a vertex
  List<T>? getPath(T destination) => shortestPaths.getPath(destination);

  /// Check if vertex is reachable from source
  bool isReachable(T vertex) => shortestPaths.isReachable(vertex);

  @override
  String toString() {
    return 'BellmanFordResult(hasNegativeCycle: $hasNegativeCycle, '
        'source: ${shortestPaths.source})';
  }
}

/// Result of Floyd-Warshall algorithm
class FloydWarshallResult<T> {
  const FloydWarshallResult(
    this.vertices,
    this.vertexIndex,
    this.distances,
    this.predecessors,
    this.hasNegativeCycle,
  );
  final List<T> vertices;
  final Map<T, int> vertexIndex;
  final List<List<double>> distances;
  final List<List<T?>> predecessors;
  final bool hasNegativeCycle;

  /// Get shortest distance between two vertices
  double? getDistance(T source, T destination) {
    final i = vertexIndex[source];
    final j = vertexIndex[destination];

    if (i == null || j == null) return null;

    final distance = distances[i][j];
    return distance == double.infinity ? null : distance;
  }

  /// Get shortest path between two vertices
  List<T>? getPath(T source, T destination) {
    final i = vertexIndex[source];
    final j = vertexIndex[destination];

    if (i == null || j == null || distances[i][j] == double.infinity) {
      return null;
    }

    final path = <T>[];

    void buildPath(int from, int to) {
      if (predecessors[from][to] == null) {
        path.add(vertices[from]);
        if (from != to) {
          path.add(vertices[to]);
        }
      } else {
        final k = vertexIndex[predecessors[from][to]]!;
        buildPath(from, k);
        path.removeLast(); // Remove duplicate vertex
        buildPath(k, to);
      }
    }

    buildPath(i, j);
    return path;
  }

  /// Check if two vertices are connected
  bool areConnected(T source, T destination) {
    return getDistance(source, destination) != null;
  }

  /// Get all shortest distances from a source vertex
  Map<T, double> getDistancesFrom(T source) {
    final i = vertexIndex[source];
    if (i == null) return {};

    final result = <T, double>{};
    for (int j = 0; j < vertices.length; j++) {
      final distance = distances[i][j];
      if (distance != double.infinity) {
        result[vertices[j]] = distance;
      }
    }
    return result;
  }

  @override
  String toString() {
    return 'FloydWarshallResult(vertices: ${vertices.length}, '
        'hasNegativeCycle: $hasNegativeCycle)';
  }
}
