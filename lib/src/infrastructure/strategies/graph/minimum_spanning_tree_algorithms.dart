import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/time_complexity.dart';
import '../../../domain/value_objects/selector_hint.dart';
import 'graph_data_structures.dart';

/// Prim's minimum spanning tree algorithm strategy
class PrimAlgorithmStrategy<T>
    extends Strategy<MstInput<T>, MinimumSpanningTreeResult<T>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'prim_algorithm',
        timeComplexity: TimeComplexity.oN2, // O(V²) with simple implementation
        spaceComplexity: TimeComplexity.oN, // O(V) for key and parent arrays
        requiresSorted: false,
        memoryOverheadBytes: 1024,
      );

  @override
  bool canApply(MstInput<T> input, SelectorHint hint) {
    // Prim's algorithm works on connected, undirected, weighted graphs
    return !input.graph.isDirected && input.graph.isWeighted;
  }

  @override
  MinimumSpanningTreeResult<T> execute(MstInput<T> input) {
    final graph = input.graph;
    final vertices = graph.vertices.toList();

    if (vertices.isEmpty) {
      return const MinimumSpanningTreeResult([], 0.0);
    }

    final inMST = <T>{};
    final keys = <T, double>{};
    final parents = <T, T?>{};
    final mstEdges = <GraphEdge<T>>[];

    // Initialize keys and parents
    for (final vertex in vertices) {
      keys[vertex] = double.infinity;
      parents[vertex] = null;
    }

    // Start with first vertex
    final startVertex = vertices.first;
    keys[startVertex] = 0.0;

    while (inMST.length < vertices.length) {
      // Find vertex with minimum key value
      T? minVertex;
      double minKey = double.infinity;

      for (final vertex in vertices) {
        if (!inMST.contains(vertex) && keys[vertex]! < minKey) {
          minVertex = vertex;
          minKey = keys[vertex]!;
        }
      }

      if (minVertex == null) {
        break; // Graph is disconnected
      }

      inMST.add(minVertex);

      // Add edge to MST (except for start vertex)
      if (parents[minVertex] != null) {
        mstEdges.add(
          GraphEdge(parents[minVertex] as T, minVertex, keys[minVertex]!),
        );
      }

      // Update keys of adjacent vertices
      for (final edge in graph.getEdges(minVertex)) {
        final neighbor = edge.destination;
        final weight = edge.weight;

        if (!inMST.contains(neighbor) && weight < keys[neighbor]!) {
          keys[neighbor] = weight;
          parents[neighbor] = minVertex;
        }
      }
    }

    final totalWeight = mstEdges.fold(0.0, (sum, edge) => sum + edge.weight);
    return MinimumSpanningTreeResult(mstEdges, totalWeight);
  }
}

/// Kruskal's minimum spanning tree algorithm strategy
class KruskalAlgorithmStrategy<T>
    extends Strategy<MstInput<T>, MinimumSpanningTreeResult<T>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'kruskal_algorithm',
        timeComplexity: TimeComplexity.oNLogN, // O(E log E) for sorting edges
        spaceComplexity: TimeComplexity.oN, // O(V) for union-find structure
        requiresSorted: false,
        memoryOverheadBytes: 2048,
      );

  @override
  bool canApply(MstInput<T> input, SelectorHint hint) {
    // Kruskal's algorithm works on connected, undirected, weighted graphs
    return !input.graph.isDirected && input.graph.isWeighted;
  }

  @override
  MinimumSpanningTreeResult<T> execute(MstInput<T> input) {
    final graph = input.graph;
    final vertices = graph.vertices;

    if (vertices.isEmpty) {
      return const MinimumSpanningTreeResult([], 0.0);
    }

    // Get all edges and sort by weight
    final edges = graph.getAllEdges();
    edges.sort((a, b) => a.weight.compareTo(b.weight));

    // Initialize union-find
    final unionFind = UnionFind<T>();
    for (final vertex in vertices) {
      unionFind.makeSet(vertex);
    }

    final mstEdges = <GraphEdge<T>>[];
    double totalWeight = 0.0;

    // Process edges in order of increasing weight
    for (final edge in edges) {
      if (unionFind.union(edge.source, edge.destination)) {
        mstEdges.add(edge);
        totalWeight += edge.weight;

        // Stop when we have V-1 edges
        if (mstEdges.length == vertices.length - 1) {
          break;
        }
      }
    }

    return MinimumSpanningTreeResult(mstEdges, totalWeight);
  }
}

/// Input for minimum spanning tree algorithms
class MstInput<T> {
  const MstInput(this.graph);
  final Graph<T> graph;

  @override
  String toString() =>
      'MstInput(vertices: ${graph.vertexCount}, edges: ${graph.edgeCount})';
}
