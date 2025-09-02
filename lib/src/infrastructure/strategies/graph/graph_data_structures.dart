/// Graph representation using adjacency list
class Graph<T> {
  Graph({bool isDirected = false, bool isWeighted = false})
      : _isDirected = isDirected,
        _isWeighted = isWeighted;
  final Map<T, List<Edge<T>>> _adjacencyList = {};
  final bool _isDirected;
  final bool _isWeighted;

  /// Add a vertex to the graph
  void addVertex(T vertex) {
    _adjacencyList.putIfAbsent(vertex, () => []);
  }

  /// Add an edge between two vertices
  void addEdge(T from, T to, {double weight = 1.0}) {
    addVertex(from);
    addVertex(to);

    _adjacencyList[from]!.add(Edge(to, weight));

    // For undirected graphs, add reverse edge
    if (!_isDirected) {
      _adjacencyList[to]!.add(Edge(from, weight));
    }
  }

  /// Remove an edge between two vertices
  void removeEdge(T from, T to) {
    _adjacencyList[from]?.removeWhere((edge) => edge.destination == to);

    if (!_isDirected) {
      _adjacencyList[to]?.removeWhere((edge) => edge.destination == from);
    }
  }

  /// Get all vertices in the graph
  Set<T> get vertices => _adjacencyList.keys.toSet();

  /// Get all edges from a vertex
  List<Edge<T>> getEdges(T vertex) {
    return _adjacencyList[vertex] ?? [];
  }

  /// Get all neighbors of a vertex
  Set<T> getNeighbors(T vertex) {
    return _adjacencyList[vertex]?.map((edge) => edge.destination).toSet() ??
        {};
  }

  /// Check if vertex exists
  bool hasVertex(T vertex) => _adjacencyList.containsKey(vertex);

  /// Check if edge exists
  bool hasEdge(T from, T to) {
    return _adjacencyList[from]?.any((edge) => edge.destination == to) ?? false;
  }

  /// Get weight of edge between two vertices
  double? getWeight(T from, T to) {
    final edge = _adjacencyList[from]?.firstWhere(
      (edge) => edge.destination == to,
      orElse: () => Edge(to, double.infinity),
    );
    return edge?.weight == double.infinity ? null : edge?.weight;
  }

  /// Get total number of vertices
  int get vertexCount => _adjacencyList.length;

  /// Get total number of edges
  int get edgeCount {
    final int count =
        _adjacencyList.values.fold(0, (sum, edges) => sum + edges.length);
    return _isDirected ? count : count ~/ 2;
  }

  /// Check if graph is directed
  bool get isDirected => _isDirected;

  /// Check if graph is weighted
  bool get isWeighted => _isWeighted;

  /// Get all edges in the graph
  List<GraphEdge<T>> getAllEdges() {
    final edges = <GraphEdge<T>>[];
    final visited = <String>{};

    for (final vertex in vertices) {
      for (final edge in getEdges(vertex)) {
        final edgeKey = _isDirected
            ? '$vertex->${edge.destination}'
            : ([vertex.toString(), edge.destination.toString()]..sort())
                .join('<->');

        if (!visited.contains(edgeKey)) {
          edges.add(GraphEdge(vertex, edge.destination, edge.weight));
          visited.add(edgeKey);
        }
      }
    }

    return edges;
  }

  /// Create a copy of the graph
  Graph<T> copy() {
    final newGraph = Graph<T>(isDirected: _isDirected, isWeighted: _isWeighted);

    for (final vertex in vertices) {
      newGraph.addVertex(vertex);
    }

    for (final vertex in vertices) {
      for (final edge in getEdges(vertex)) {
        if (_isDirected || vertex.hashCode <= edge.destination.hashCode) {
          newGraph.addEdge(vertex, edge.destination, weight: edge.weight);
        }
      }
    }

    return newGraph;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln(
        'Graph (${_isDirected ? "Directed" : "Undirected"}, ${_isWeighted ? "Weighted" : "Unweighted"})',);
    buffer.writeln('Vertices: $vertexCount, Edges: $edgeCount');

    for (final vertex in vertices) {
      final edges = getEdges(vertex);
      buffer.write('$vertex -> ');
      if (edges.isEmpty) {
        buffer.writeln('[]');
      } else {
        buffer.writeln(edges
            .map((e) => _isWeighted
                ? '${e.destination}(${e.weight})'
                : '${e.destination}',)
            .join(', '),);
      }
    }

    return buffer.toString();
  }
}

/// Represents an edge in the graph
class Edge<T> {
  const Edge(this.destination, this.weight);
  final T destination;
  final double weight;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Edge<T> &&
          other.destination == destination &&
          other.weight == weight);

  @override
  int get hashCode => Object.hash(destination, weight);

  @override
  String toString() => 'Edge(to: $destination, weight: $weight)';
}

/// Represents a graph edge with source and destination
class GraphEdge<T> {
  const GraphEdge(this.source, this.destination, this.weight);
  final T source;
  final T destination;
  final double weight;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GraphEdge<T> &&
          other.source == source &&
          other.destination == destination &&
          other.weight == weight);

  @override
  int get hashCode => Object.hash(source, destination, weight);

  @override
  String toString() => 'GraphEdge($source -> $destination, weight: $weight)';
}

/// Result of shortest path algorithms
class ShortestPathResult<T> {
  const ShortestPathResult(this.distances, this.predecessors, this.source);
  final Map<T, double> distances;
  final Map<T, T?> predecessors;
  final T source;

  /// Get shortest distance to a vertex
  double? getDistance(T vertex) => distances[vertex];

  /// Get shortest path to a vertex
  List<T>? getPath(T destination) {
    if (!distances.containsKey(destination) ||
        distances[destination] == double.infinity) {
      return null;
    }

    final path = <T>[];
    T? current = destination;

    while (current != null) {
      path.insert(0, current);
      current = predecessors[current];
    }

    return path.isEmpty ? null : path;
  }

  /// Check if vertex is reachable from source
  bool isReachable(T vertex) {
    return distances.containsKey(vertex) &&
        distances[vertex] != double.infinity;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('ShortestPathResult from $source:');

    for (final entry in distances.entries) {
      final distance =
          entry.value == double.infinity ? '∞' : entry.value.toString();
      final path = getPath(entry.key);
      buffer.writeln('  To ${entry.key}: distance=$distance, path=$path');
    }

    return buffer.toString();
  }
}

/// Result of minimum spanning tree algorithms
class MinimumSpanningTreeResult<T> {
  const MinimumSpanningTreeResult(this.edges, this.totalWeight);
  final List<GraphEdge<T>> edges;
  final double totalWeight;

  /// Get all vertices in the MST
  Set<T> get vertices {
    final result = <T>{};
    for (final edge in edges) {
      result.add(edge.source);
      result.add(edge.destination);
    }
    return result;
  }

  /// Check if the MST spans all vertices
  bool spansAllVertices(int totalVertices) {
    return vertices.length == totalVertices;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Minimum Spanning Tree:');
    buffer.writeln('Total Weight: $totalWeight');
    buffer.writeln('Edges:');

    for (final edge in edges) {
      buffer
          .writeln('  ${edge.source} <-> ${edge.destination} (${edge.weight})');
    }

    return buffer.toString();
  }
}

/// Result of topological sort
class TopologicalSortResult<T> {
  const TopologicalSortResult(this.sortedVertices, this.hasCycle);
  final List<T> sortedVertices;
  final bool hasCycle;

  /// Check if topological sort was successful
  bool get isValid => !hasCycle;

  @override
  String toString() {
    if (hasCycle) {
      return 'TopologicalSortResult: Cycle detected, no valid topological ordering';
    }
    return 'TopologicalSortResult: ${sortedVertices.join(' -> ')}';
  }
}

/// Result of strongly connected components
class StronglyConnectedComponentsResult<T> {
  const StronglyConnectedComponentsResult(this.components);
  final List<Set<T>> components;

  /// Get number of strongly connected components
  int get componentCount => components.length;

  /// Check if two vertices are in the same component
  bool areInSameComponent(T vertex1, T vertex2) {
    return components.any((component) =>
        component.contains(vertex1) && component.contains(vertex2),);
  }

  /// Get component containing a vertex
  Set<T>? getComponent(T vertex) {
    return components.firstWhere(
      (component) => component.contains(vertex),
      orElse: () => <T>{},
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer
        .writeln('Strongly Connected Components ($componentCount components):');

    for (int i = 0; i < components.length; i++) {
      buffer.writeln('  Component ${i + 1}: {${components[i].join(', ')}}');
    }

    return buffer.toString();
  }
}

/// Union-Find data structure for Kruskal's algorithm
class UnionFind<T> {
  final Map<T, T> _parent = {};
  final Map<T, int> _rank = {};

  /// Make set for a vertex
  void makeSet(T vertex) {
    _parent[vertex] = vertex;
    _rank[vertex] = 0;
  }

  /// Find the root of a vertex with path compression
  T find(T vertex) {
    if (_parent[vertex] != vertex) {
      _parent[vertex] = find(_parent[vertex] as T); // Path compression
    }
    return _parent[vertex]!;
  }

  /// Union two sets by rank
  bool union(T vertex1, T vertex2) {
    final root1 = find(vertex1);
    final root2 = find(vertex2);

    if (root1 == root2) {
      return false; // Already in same set
    }

    // Union by rank
    final rank1 = _rank[root1]!;
    final rank2 = _rank[root2]!;

    if (rank1 < rank2) {
      _parent[root1] = root2;
    } else if (rank1 > rank2) {
      _parent[root2] = root1;
    } else {
      _parent[root2] = root1;
      _rank[root1] = rank1 + 1;
    }

    return true;
  }

  /// Check if two vertices are in the same set
  bool connected(T vertex1, T vertex2) {
    return find(vertex1) == find(vertex2);
  }
}
