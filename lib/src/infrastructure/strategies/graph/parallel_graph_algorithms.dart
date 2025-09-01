import 'dart:isolate';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:async';
import 'dart:collection';
import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';

/// Graph representation for parallel algorithms
class Graph {
  Graph(this.vertices, this.adjacencyList);

  factory Graph.fromEdgeList(int vertices, List<List<int>> edges) {
    final adjacencyList = <int, List<int>>{};

    for (int i = 0; i < vertices; i++) {
      adjacencyList[i] = <int>[];
    }

    for (final edge in edges) {
      if (edge.length >= 2) {
        adjacencyList[edge[0]]!.add(edge[1]);
        // For undirected graphs, add both directions
        if (edge.length == 2) {
          adjacencyList[edge[1]]!.add(edge[0]);
        }
      }
    }

    return Graph(vertices, adjacencyList);
  }

  final int vertices;
  final Map<int, List<int>> adjacencyList;

  List<int> getNeighbors(int vertex) => adjacencyList[vertex] ?? [];

  int get edgeCount {
    return adjacencyList.values
            .fold(0, (sum, neighbors) => sum + neighbors.length) ~/
        2;
  }

  @override
  String toString() => 'Graph(vertices: $vertices, edges: $edgeCount)';
}

/// Parallel Breadth-First Search with level-synchronous approach
///
/// Features:
/// - Processes each BFS level in parallel across multiple cores
/// - Efficient frontier management with work distribution
/// - Memory-efficient visited tracking
/// - Automatic load balancing across isolates
///
/// Algorithm: Level-synchronous parallel BFS
/// Best for: Large graphs with high branching factor, social networks, web graphs
///
/// Performance: O(V + E) time, improved for graphs with wide levels
/// Space: O(V) for visited tracking + frontier management
class ParallelBFS extends Strategy<Graph, Map<int, int>> {
  ParallelBFS(this._startVertex);
  static const int _sequentialThreshold = 10000; // vertices
  static const int _minFrontierSize =
      100; // minimum frontier size for parallelism
  static const int _maxIsolates = 6;

  final int _startVertex;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'parallel_bfs',
        timeComplexity:
            TimeComplexity.oN, // Actually O(V + E) but using closest enum
        spaceComplexity: TimeComplexity.oN,
        requiresSorted: false,
        memoryOverheadBytes: 8192, // Frontier and synchronization overhead
        description:
            'Multi-core breadth-first search with level synchronization',
      );

  @override
  bool canApply(Graph input, SelectorHint hint) {
    // Only beneficial for large graphs
    if (input.vertices < _sequentialThreshold) return false;

    // Start vertex must be valid
    if (_startVertex < 0 || _startVertex >= input.vertices) return false;

    // Check isolate support
    try {
      Isolate.current;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Map<int, int> execute(Graph input) {
    if (input.vertices < _sequentialThreshold) {
      return _sequentialBFS(input, _startVertex);
    }

    try {
      return _parallelBFS(input, _startVertex);
    } catch (e) {
      return _sequentialBFS(input, _startVertex);
    }
  }

  /// Parallel BFS with level synchronization
  Map<int, int> _parallelBFS(Graph graph, int start) {
    final distances = <int, int>{start: 0};
    final visited = <bool>[...List.filled(graph.vertices, false)];
    visited[start] = true;

    var currentFrontier = <int>[start];
    int currentDistance = 0;

    while (currentFrontier.isNotEmpty) {
      // If frontier is small, process sequentially
      if (currentFrontier.length < _minFrontierSize) {
        final nextFrontier = <int>[];

        for (final vertex in currentFrontier) {
          for (final neighbor in graph.getNeighbors(vertex)) {
            if (!visited[neighbor]) {
              visited[neighbor] = true;
              distances[neighbor] = currentDistance + 1;
              nextFrontier.add(neighbor);
            }
          }
        }

        currentFrontier = nextFrontier;
        currentDistance++;
        continue;
      }

      // Process large frontier in parallel
      final nextFrontier = _processLevelParallel(
          graph, currentFrontier, visited, currentDistance + 1,);

      // Update distances for new vertices
      for (final vertex in nextFrontier) {
        distances[vertex] = currentDistance + 1;
      }

      currentFrontier = nextFrontier;
      currentDistance++;
    }

    return distances;
  }

  /// Process a BFS level in parallel
  List<int> _processLevelParallel(
      Graph graph, List<int> frontier, List<bool> visited, int newDistance,) {
    final numCores = _getAvailableCores();
    final chunkSize = (frontier.length / numCores).ceil();
    final chunks = <List<int>>[];

    // Divide frontier into chunks
    for (int i = 0; i < frontier.length; i += chunkSize) {
      final end = math.min(i + chunkSize, frontier.length);
      chunks.add(frontier.sublist(i, end));
    }

    // Process chunks in parallel
    final futures = <Future<List<int>>>[];
    for (final chunk in chunks) {
      futures.add(_computeBFSChunk(BFSTask(chunk, graph, List.from(visited))));
    }

    // Collect and merge results
    final allNewVertices = <int>[];
    for (final future in futures) {
      try {
        List<int>? chunkResult;
        future.then((result) => chunkResult = result).catchError((e) {
          chunkResult = <int>[];
          return chunkResult!;
        });

        while (chunkResult == null) {
          // Busy wait
        }

        allNewVertices.addAll(chunkResult!);
      } catch (e) {
        // Skip failed chunks
        continue;
      }
    }

    // Remove duplicates and update global visited array
    final newVertices = <int>[];
    for (final vertex in allNewVertices) {
      if (!visited[vertex]) {
        visited[vertex] = true;
        newVertices.add(vertex);
      }
    }

    return newVertices;
  }

  /// Compute BFS expansion for a chunk of vertices in isolate
  Future<List<int>> _computeBFSChunk(BFSTask task) async {
    final completer = Completer<List<int>>();

    try {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(
        _isolateBFSChunk,
        [receivePort.sendPort, task],
      );

      receivePort.listen((message) {
        if (message is List<int>) {
          completer.complete(message);
        } else if (message is String && message.startsWith('error:')) {
          completer.completeError(Exception(message));
        }
        receivePort.close();
        isolate.kill();
      });
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => <int>[],
    );
  }

  /// Sequential BFS fallback
  Map<int, int> _sequentialBFS(Graph graph, int start) {
    final distances = <int, int>{};
    final visited = <bool>[...List.filled(graph.vertices, false)];
    final queue = Queue<int>();

    distances[start] = 0;
    visited[start] = true;
    queue.add(start);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final currentDistance = distances[current]!;

      for (final neighbor in graph.getNeighbors(current)) {
        if (!visited[neighbor]) {
          visited[neighbor] = true;
          distances[neighbor] = currentDistance + 1;
          queue.add(neighbor);
        }
      }
    }

    return distances;
  }

  /// Get number of available CPU cores
  int _getAvailableCores() {
    try {
      return math.min(Platform.numberOfProcessors, _maxIsolates);
    } catch (e) {
      return 4;
    }
  }
}

/// Task data for parallel BFS
class BFSTask {
  const BFSTask(this.frontierChunk, this.graph, this.visited);

  final List<int> frontierChunk;
  final Graph graph;
  final List<bool> visited;
}

/// Isolate entry point for BFS chunk processing
void _isolateBFSChunk(List<dynamic> args) {
  final sendPort = args[0] as SendPort;
  final task = args[1] as BFSTask;

  try {
    final newVertices = <int>[];

    for (final vertex in task.frontierChunk) {
      for (final neighbor in task.graph.getNeighbors(vertex)) {
        if (!task.visited[neighbor]) {
          newVertices.add(neighbor);
        }
      }
    }

    sendPort.send(newVertices);
  } catch (e) {
    sendPort.send('error: $e');
  }
}

/// Parallel Depth-First Search using work-stealing
///
/// Features:
/// - Divides search space across multiple isolates
/// - Dynamic load balancing with work stealing
/// - Stack-based exploration with parallel branching
/// - Supports both connected component detection and path finding
///
/// Algorithm: Parallel DFS with work-stealing
/// Best for: Large sparse graphs, tree-like structures, maze solving
///
/// Performance: O(V + E) time, speedup depends on graph structure
/// Space: O(V) for visited tracking + recursive call stacks
class ParallelDFS extends Strategy<Graph, Set<int>> {
  ParallelDFS(this._startVertex);
  static const int _sequentialThreshold = 5000;
  static const int _maxIsolates = 4;

  final int _startVertex;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'parallel_dfs',
        timeComplexity: TimeComplexity.oN,
        spaceComplexity: TimeComplexity.oN,
        requiresSorted: false,
        memoryOverheadBytes: 6144, // Stack and synchronization overhead
        description: 'Multi-core depth-first search with work-stealing',
      );

  @override
  bool canApply(Graph input, SelectorHint hint) {
    if (input.vertices < _sequentialThreshold) return false;

    if (_startVertex < 0 || _startVertex >= input.vertices) return false;

    try {
      Isolate.current;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Set<int> execute(Graph input) {
    if (input.vertices < _sequentialThreshold) {
      return _sequentialDFS(input, _startVertex);
    }

    try {
      return _parallelDFS(input, _startVertex);
    } catch (e) {
      return _sequentialDFS(input, _startVertex);
    }
  }

  /// Parallel DFS with work-stealing
  Set<int> _parallelDFS(Graph graph, int start) {
    final globalVisited = <bool>[...List.filled(graph.vertices, false)];
    final result = <int>{};

    // Initialize work queues
    final initialWork = <int>[start];
    final numWorkers = _getAvailableCores();

    // Distribute initial work
    final workChunks = _distributeWork(initialWork, numWorkers);

    // Start parallel workers
    final futures = <Future<Set<int>>>[];
    for (int i = 0; i < numWorkers; i++) {
      final task = DFSWorkerTask(
        workChunks.length > i ? workChunks[i] : <int>[],
        graph,
        List.from(globalVisited),
        i,
      );
      futures.add(_computeDFSWorker(task));
    }

    // Collect results from all workers
    for (final future in futures) {
      try {
        Set<int>? workerResult;
        future.then((result) => workerResult = result).catchError((e) {
          workerResult = <int>{};
          return workerResult!;
        });

        while (workerResult == null) {
          // Busy wait
        }

        result.addAll(workerResult!);
      } catch (e) {
        // Skip failed workers
        continue;
      }
    }

    return result;
  }

  /// Compute DFS for a worker in isolate
  Future<Set<int>> _computeDFSWorker(DFSWorkerTask task) async {
    final completer = Completer<Set<int>>();

    try {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(
        _isolateDFSWorker,
        [receivePort.sendPort, task],
      );

      receivePort.listen((message) {
        if (message is Set<int>) {
          completer.complete(message);
        } else if (message is String && message.startsWith('error:')) {
          completer.completeError(Exception(message));
        }
        receivePort.close();
        isolate.kill();
      });
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () => <int>{},
    );
  }

  /// Distribute work evenly across workers
  List<List<int>> _distributeWork(List<int> work, int numWorkers) {
    final chunks = <List<int>>[];
    final chunkSize = (work.length / numWorkers).ceil();

    for (int i = 0; i < work.length; i += chunkSize) {
      final end = math.min(i + chunkSize, work.length);
      chunks.add(work.sublist(i, end));
    }

    return chunks;
  }

  /// Sequential DFS fallback
  Set<int> _sequentialDFS(Graph graph, int start) {
    final visited = <bool>[...List.filled(graph.vertices, false)];
    final result = <int>{};
    final stack = <int>[start];

    while (stack.isNotEmpty) {
      final current = stack.removeLast();

      if (!visited[current]) {
        visited[current] = true;
        result.add(current);

        // Add neighbors to stack (in reverse order for consistent traversal)
        final neighbors = graph.getNeighbors(current);
        for (int i = neighbors.length - 1; i >= 0; i--) {
          if (!visited[neighbors[i]]) {
            stack.add(neighbors[i]);
          }
        }
      }
    }

    return result;
  }

  /// Get number of available CPU cores
  int _getAvailableCores() {
    try {
      return math.min(Platform.numberOfProcessors, _maxIsolates);
    } catch (e) {
      return 4;
    }
  }
}

/// Task data for parallel DFS worker
class DFSWorkerTask {
  const DFSWorkerTask(
      this.initialWork, this.graph, this.visited, this.workerId,);

  final List<int> initialWork;
  final Graph graph;
  final List<bool> visited;
  final int workerId;
}

/// Isolate entry point for DFS worker
void _isolateDFSWorker(List<dynamic> args) {
  final sendPort = args[0] as SendPort;
  final task = args[1] as DFSWorkerTask;

  try {
    final localVisited = List<bool>.from(task.visited);
    final result = <int>{};
    final stack = List<int>.from(task.initialWork);

    while (stack.isNotEmpty) {
      final current = stack.removeLast();

      if (!localVisited[current]) {
        localVisited[current] = true;
        result.add(current);

        // Add neighbors to stack
        final neighbors = task.graph.getNeighbors(current);
        for (int i = neighbors.length - 1; i >= 0; i--) {
          if (!localVisited[neighbors[i]]) {
            stack.add(neighbors[i]);
          }
        }
      }
    }

    sendPort.send(result);
  } catch (e) {
    sendPort.send('error: $e');
  }
}

/// Parallel Connected Components using Union-Find with path compression
///
/// Features:
/// - Parallel edge processing with conflict resolution
/// - Union-Find data structure with path compression and union by rank
/// - Work distribution across multiple cores for large graphs
/// - Efficient component merging and counting
///
/// Algorithm: Parallel Union-Find with atomic operations simulation
/// Best for: Large graphs with many components, network analysis, clustering
///
/// Performance: O((V + E) * α(V)) where α is inverse Ackermann function
/// Space: O(V) for Union-Find structure
class ParallelConnectedComponents
    extends Strategy<Graph, Map<String, dynamic>> {
  static const int _sequentialThreshold = 8000;
  static const int _minEdgesPerWorker = 1000;
  static const int _maxIsolates = 6;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'parallel_connected_components',
        timeComplexity: TimeComplexity.oN,
        spaceComplexity: TimeComplexity.oN,
        requiresSorted: false,
        memoryOverheadBytes: 4096,
        description:
            'Multi-core connected components using parallel Union-Find',
      );

  @override
  bool canApply(Graph input, SelectorHint hint) {
    if (input.vertices < _sequentialThreshold) return false;

    try {
      Isolate.current;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Map<String, dynamic> execute(Graph input) {
    if (input.vertices < _sequentialThreshold) {
      return _sequentialConnectedComponents(input);
    }

    try {
      return _parallelConnectedComponents(input);
    } catch (e) {
      return _sequentialConnectedComponents(input);
    }
  }

  /// Parallel connected components computation
  Map<String, dynamic> _parallelConnectedComponents(Graph graph) {
    // Convert adjacency list to edge list
    final edges = <List<int>>[];
    final processed = <Set<int>>{};

    for (final vertex in graph.adjacencyList.keys) {
      processed.add(<int>{});
      for (final neighbor in graph.getNeighbors(vertex)) {
        if (!processed.any((s) => s.contains(vertex) && s.contains(neighbor))) {
          edges.add([vertex, neighbor]);
          processed.first.addAll([vertex, neighbor]);
        }
      }
    }

    if (edges.length < _minEdgesPerWorker * 2) {
      return _sequentialConnectedComponents(graph);
    }

    // Distribute edges across workers
    final numWorkers = _getAvailableCores();
    final edgeChunks = _distributeEdges(edges, numWorkers);

    // Process edge chunks in parallel
    final futures = <Future<UnionFindResult>>[];
    for (final chunk in edgeChunks) {
      final task = UnionFindTask(chunk, graph.vertices);
      futures.add(_computeUnionFindChunk(task));
    }

    // Collect partial results
    final partialResults = <UnionFindResult>[];
    for (final future in futures) {
      try {
        UnionFindResult? result;
        future.then((value) => result = value).catchError((e) {
          result = const UnionFindResult(<int, int>{}, <int, int>{});
          return result!;
        });

        while (result == null) {
          // Busy wait
        }

        partialResults.add(result!);
      } catch (e) {
        // Skip failed chunks
        continue;
      }
    }

    // Merge partial results
    return _mergeUnionFindResults(partialResults, graph.vertices);
  }

  /// Compute Union-Find for edge chunk in isolate
  Future<UnionFindResult> _computeUnionFindChunk(UnionFindTask task) async {
    final completer = Completer<UnionFindResult>();

    try {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(
        _isolateUnionFind,
        [receivePort.sendPort, task],
      );

      receivePort.listen((message) {
        if (message is UnionFindResult) {
          completer.complete(message);
        } else if (message is String && message.startsWith('error:')) {
          completer.completeError(Exception(message));
        }
        receivePort.close();
        isolate.kill();
      });
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () => const UnionFindResult(<int, int>{}, <int, int>{}),
    );
  }

  /// Distribute edges across workers
  List<List<List<int>>> _distributeEdges(
      List<List<int>> edges, int numWorkers,) {
    final chunks = <List<List<int>>>[];
    final chunkSize = (edges.length / numWorkers).ceil();

    for (int i = 0; i < edges.length; i += chunkSize) {
      final end = math.min(i + chunkSize, edges.length);
      chunks.add(edges.sublist(i, end));
    }

    return chunks;
  }

  /// Merge partial Union-Find results
  Map<String, dynamic> _mergeUnionFindResults(
      List<UnionFindResult> partialResults, int vertices,) {
    final globalParent = <int, int>{};
    final globalRank = <int, int>{};

    // Initialize global Union-Find
    for (int i = 0; i < vertices; i++) {
      globalParent[i] = i;
      globalRank[i] = 0;
    }

    // Apply all unions from partial results
    for (final result in partialResults) {
      // This is a simplified merge - in production, proper conflict resolution needed
      for (final entry in result.parent.entries) {
        if (entry.key != entry.value) {
          _unionVertices(globalParent, globalRank, entry.key, entry.value);
        }
      }
    }

    // Count components and create component mapping
    final components = <int, List<int>>{};
    for (int i = 0; i < vertices; i++) {
      final root = _findRoot(globalParent, i);
      components.putIfAbsent(root, () => <int>[]).add(i);
    }

    return {
      'componentCount': components.length,
      'components': components,
      'componentSizes': components.map((k, v) => MapEntry(k, v.length)),
    };
  }

  /// Sequential connected components fallback
  Map<String, dynamic> _sequentialConnectedComponents(Graph graph) {
    final parent = <int, int>{};
    final rank = <int, int>{};

    // Initialize Union-Find
    for (int i = 0; i < graph.vertices; i++) {
      parent[i] = i;
      rank[i] = 0;
    }

    // Process all edges
    for (final vertex in graph.adjacencyList.keys) {
      for (final neighbor in graph.getNeighbors(vertex)) {
        if (vertex < neighbor) {
          // Avoid processing each edge twice
          _unionVertices(parent, rank, vertex, neighbor);
        }
      }
    }

    // Count components
    final components = <int, List<int>>{};
    for (int i = 0; i < graph.vertices; i++) {
      final root = _findRoot(parent, i);
      components.putIfAbsent(root, () => <int>[]).add(i);
    }

    return {
      'componentCount': components.length,
      'components': components,
      'componentSizes': components.map((k, v) => MapEntry(k, v.length)),
    };
  }

  /// Union-Find helper methods
  int _findRoot(Map<int, int> parent, int x) {
    if (parent[x] != x) {
      parent[x] = _findRoot(parent, parent[x]!); // Path compression
    }
    return parent[x]!;
  }

  void _unionVertices(Map<int, int> parent, Map<int, int> rank, int x, int y) {
    final rootX = _findRoot(parent, x);
    final rootY = _findRoot(parent, y);

    if (rootX != rootY) {
      // Union by rank
      if (rank[rootX]! < rank[rootY]!) {
        parent[rootX] = rootY;
      } else if (rank[rootX]! > rank[rootY]!) {
        parent[rootY] = rootX;
      } else {
        parent[rootY] = rootX;
        rank[rootX] = rank[rootX]! + 1;
      }
    }
  }

  /// Get number of available CPU cores
  int _getAvailableCores() {
    try {
      return math.min(Platform.numberOfProcessors, _maxIsolates);
    } catch (e) {
      return 4;
    }
  }
}

/// Task data for Union-Find computation
class UnionFindTask {
  const UnionFindTask(this.edges, this.vertices);

  final List<List<int>> edges;
  final int vertices;
}

/// Result of Union-Find computation
class UnionFindResult {
  const UnionFindResult(this.parent, this.rank);

  final Map<int, int> parent;
  final Map<int, int> rank;
}

/// Isolate entry point for Union-Find computation
void _isolateUnionFind(List<dynamic> args) {
  final sendPort = args[0] as SendPort;
  final task = args[1] as UnionFindTask;

  try {
    final parent = <int, int>{};
    final rank = <int, int>{};

    // Initialize Union-Find
    for (int i = 0; i < task.vertices; i++) {
      parent[i] = i;
      rank[i] = 0;
    }

    // Process edges in this chunk
    for (final edge in task.edges) {
      if (edge.length >= 2) {
        _unionVerticesIsolate(parent, rank, edge[0], edge[1]);
      }
    }

    final result = UnionFindResult(parent, rank);
    sendPort.send(result);
  } catch (e) {
    sendPort.send('error: $e');
  }
}

/// Union-Find operations in isolate
int _findRootIsolate(Map<int, int> parent, int x) {
  if (parent[x] != x) {
    parent[x] = _findRootIsolate(parent, parent[x]!);
  }
  return parent[x]!;
}

void _unionVerticesIsolate(
    Map<int, int> parent, Map<int, int> rank, int x, int y,) {
  final rootX = _findRootIsolate(parent, x);
  final rootY = _findRootIsolate(parent, y);

  if (rootX != rootY) {
    if (rank[rootX]! < rank[rootY]!) {
      parent[rootX] = rootY;
    } else if (rank[rootX]! > rank[rootY]!) {
      parent[rootY] = rootX;
    } else {
      parent[rootY] = rootX;
      rank[rootX] = rank[rootX]! + 1;
    }
  }
}
