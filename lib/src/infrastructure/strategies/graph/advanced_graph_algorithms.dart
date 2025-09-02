import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/time_complexity.dart';
import '../../../domain/value_objects/selector_hint.dart';
import 'graph_data_structures.dart';

/// Topological sort algorithm strategy
class TopologicalSortStrategy<T>
    extends Strategy<TopologicalSortInput<T>, TopologicalSortResult<T>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'topological_sort',
        timeComplexity: TimeComplexity.oVPlusE, // O(V + E)
        spaceComplexity:
            TimeComplexity.oN, // O(V) for recursion stack and result
        requiresSorted: false,
        memoryOverheadBytes: 1024,
      );

  @override
  bool canApply(TopologicalSortInput<T> input, SelectorHint hint) {
    // Topological sort only works on directed acyclic graphs (DAGs)
    return input.graph.isDirected;
  }

  @override
  TopologicalSortResult<T> execute(TopologicalSortInput<T> input) {
    final graph = input.graph;
    final vertices = graph.vertices;

    final visited = <T>{};
    final recursionStack = <T>{};
    final sortedVertices = <T>[];
    bool hasCycle = false;

    void dfsVisit(T vertex) {
      if (hasCycle) return;

      if (recursionStack.contains(vertex)) {
        hasCycle = true;
        return;
      }

      if (visited.contains(vertex)) {
        return;
      }

      visited.add(vertex);
      recursionStack.add(vertex);

      for (final edge in graph.getEdges(vertex)) {
        dfsVisit(edge.destination);
      }

      recursionStack.remove(vertex);
      sortedVertices.insert(0, vertex); // Insert at beginning for correct order
    }

    // Visit all vertices
    for (final vertex in vertices) {
      if (!visited.contains(vertex)) {
        dfsVisit(vertex);
      }
    }

    return TopologicalSortResult(
      hasCycle ? [] : sortedVertices,
      hasCycle,
    );
  }
}

/// Kosaraju's algorithm for strongly connected components
class KosarajuAlgorithmStrategy<T>
    extends Strategy<SccInput<T>, StronglyConnectedComponentsResult<T>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'kosaraju_algorithm',
        timeComplexity: TimeComplexity.oVPlusE, // O(V + E)
        spaceComplexity: TimeComplexity.oN, // O(V) for stacks and visited sets
        requiresSorted: false,
        memoryOverheadBytes: 2048,
      );

  @override
  bool canApply(SccInput<T> input, SelectorHint hint) {
    // Kosaraju's algorithm works on directed graphs
    return input.graph.isDirected;
  }

  @override
  StronglyConnectedComponentsResult<T> execute(SccInput<T> input) {
    final graph = input.graph;
    final vertices = graph.vertices;

    // Step 1: Fill vertices in stack according to their finishing times
    final visited = <T>{};
    final finishStack = <T>[];

    void fillOrder(T vertex) {
      visited.add(vertex);

      for (final edge in graph.getEdges(vertex)) {
        if (!visited.contains(edge.destination)) {
          fillOrder(edge.destination);
        }
      }

      finishStack.add(vertex);
    }

    for (final vertex in vertices) {
      if (!visited.contains(vertex)) {
        fillOrder(vertex);
      }
    }

    // Step 2: Create transpose graph
    final transposeGraph =
        Graph<T>(isDirected: true, isWeighted: graph.isWeighted);

    for (final vertex in vertices) {
      transposeGraph.addVertex(vertex);
    }

    for (final vertex in vertices) {
      for (final edge in graph.getEdges(vertex)) {
        transposeGraph.addEdge(edge.destination, vertex, weight: edge.weight);
      }
    }

    // Step 3: Process vertices in reverse finish order
    visited.clear();
    final components = <Set<T>>[];

    void dfsComponent(T vertex, Set<T> component) {
      visited.add(vertex);
      component.add(vertex);

      for (final edge in transposeGraph.getEdges(vertex)) {
        if (!visited.contains(edge.destination)) {
          dfsComponent(edge.destination, component);
        }
      }
    }

    while (finishStack.isNotEmpty) {
      final vertex = finishStack.removeLast();
      if (!visited.contains(vertex)) {
        final component = <T>{};
        dfsComponent(vertex, component);
        components.add(component);
      }
    }

    return StronglyConnectedComponentsResult(components);
  }
}

/// Tarjan's algorithm for strongly connected components
class TarjanAlgorithmStrategy<T>
    extends Strategy<SccInput<T>, StronglyConnectedComponentsResult<T>> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'tarjan_algorithm',
        timeComplexity: TimeComplexity.oVPlusE, // O(V + E)
        spaceComplexity: TimeComplexity.oN, // O(V) for stacks and arrays
        requiresSorted: false,
        memoryOverheadBytes: 3072,
      );

  @override
  bool canApply(SccInput<T> input, SelectorHint hint) {
    // Tarjan's algorithm works on directed graphs
    return input.graph.isDirected;
  }

  @override
  StronglyConnectedComponentsResult<T> execute(SccInput<T> input) {
    final graph = input.graph;
    final vertices = graph.vertices;

    final indices = <T, int>{};
    final lowLinks = <T, int>{};
    final onStack = <T>{};
    final stack = <T>[];
    final components = <Set<T>>[];

    var index = 0;

    void strongConnect(T vertex) {
      // Set the depth index for vertex to the smallest unused index
      indices[vertex] = index;
      lowLinks[vertex] = index;
      index++;
      stack.add(vertex);
      onStack.add(vertex);

      // Consider successors of vertex
      for (final edge in graph.getEdges(vertex)) {
        final successor = edge.destination;

        if (!indices.containsKey(successor)) {
          // Successor has not yet been visited; recurse on it
          strongConnect(successor);
          lowLinks[vertex] = [lowLinks[vertex]!, lowLinks[successor]!]
              .reduce((a, b) => a < b ? a : b);
        } else if (onStack.contains(successor)) {
          // Successor is in stack and hence in the current SCC
          lowLinks[vertex] = [lowLinks[vertex]!, indices[successor]!]
              .reduce((a, b) => a < b ? a : b);
        }
      }

      // If vertex is a root node, pop the stack and create an SCC
      if (lowLinks[vertex] == indices[vertex]) {
        final component = <T>{};
        T w;
        do {
          w = stack.removeLast();
          onStack.remove(w);
          component.add(w);
        } while (w != vertex);

        components.add(component);
      }
    }

    // Process all vertices
    for (final vertex in vertices) {
      if (!indices.containsKey(vertex)) {
        strongConnect(vertex);
      }
    }

    return StronglyConnectedComponentsResult(components);
  }
}

/// Input for topological sort
class TopologicalSortInput<T> {
  const TopologicalSortInput(this.graph);
  final Graph<T> graph;

  @override
  String toString() => 'TopologicalSortInput(vertices: ${graph.vertexCount})';
}

/// Input for strongly connected components algorithms
class SccInput<T> {
  const SccInput(this.graph);
  final Graph<T> graph;

  @override
  String toString() => 'SccInput(vertices: ${graph.vertexCount})';
}
