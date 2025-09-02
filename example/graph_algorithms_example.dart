import 'package:algomate/algomate.dart';

/// Comprehensive example demonstrating all graph algorithms in AlgoMate
void main() async {
  print('🔮 AlgoMate Graph Algorithms Demo');
  print('=' * 50);

  await demonstrateGraphTraversal();
  print('\n${'=' * 50}\n');

  await demonstrateShortestPath();
  print('\n${'=' * 50}\n');

  await demonstrateMinimumSpanningTree();
  print('\n${'=' * 50}\n');

  await demonstrateAdvancedAlgorithms();
}

/// Demonstrate BFS and DFS traversal
Future<void> demonstrateGraphTraversal() async {
  print('🚶 GRAPH TRAVERSAL ALGORITHMS');
  print('-' * 30);

  // Create a sample graph representing a social network
  final graph = Graph<String>(isDirected: false);

  // Add vertices (people)
  const people = ['Alice', 'Bob', 'Carol', 'David', 'Eve', 'Frank'];
  for (final person in people) {
    graph.addVertex(person);
  }

  // Add edges (friendships)
  graph.addEdge('Alice', 'Bob');
  graph.addEdge('Alice', 'Carol');
  graph.addEdge('Bob', 'David');
  graph.addEdge('Carol', 'Eve');
  graph.addEdge('David', 'Frank');
  graph.addEdge('Eve', 'Frank');

  print('Social Network Graph:');
  print('Vertices: ${graph.vertices}');
  print('Edges: ${graph.edgeCount}');

  // Breadth-First Search
  print('\n🔍 Breadth-First Search from Alice:');
  final bfsStrategy = BreadthFirstSearchStrategy<String>();
  final bfsInput = BfsInput(graph, 'Alice');

  if (bfsStrategy.canApply(bfsInput, const SelectorHint())) {
    final bfsResult = bfsStrategy.execute(bfsInput);
    print('Traversal order: ${bfsResult.traversalOrder}');
    print('Distance to Frank: ${bfsResult.getDistance('Frank')}');
    print('Path to Frank: ${bfsResult.getPath('Frank')}');
  }

  // Depth-First Search
  print('\n📊 Depth-First Search from Alice:');
  final dfsStrategy = DepthFirstSearchStrategy<String>();
  final dfsInput = DfsInput(graph, 'Alice');

  if (dfsStrategy.canApply(dfsInput, const SelectorHint())) {
    final dfsResult = dfsStrategy.execute(dfsInput);
    print('Traversal order: ${dfsResult.traversalOrder}');
    print('Discovery time of Frank: ${dfsResult.getDiscoveryTime('Frank')}');
    print('Finish time of Frank: ${dfsResult.getFinishTime('Frank')}');
  }
}

/// Demonstrate shortest path algorithms
Future<void> demonstrateShortestPath() async {
  print('🗺️ SHORTEST PATH ALGORITHMS');
  print('-' * 30);

  // Create a weighted graph representing a road network
  final roadNetwork = Graph<String>(isDirected: true, isWeighted: true);

  // Add cities
  const cities = ['Bangkok', 'Chiang Mai', 'Phuket', 'Pattaya', 'Khon Kaen'];
  for (final city in cities) {
    roadNetwork.addVertex(city);
  }

  // Add roads with distances (km)
  roadNetwork.addEdge('Bangkok', 'Chiang Mai', weight: 700);
  roadNetwork.addEdge('Bangkok', 'Phuket', weight: 850);
  roadNetwork.addEdge('Bangkok', 'Pattaya', weight: 150);
  roadNetwork.addEdge('Bangkok', 'Khon Kaen', weight: 450);
  roadNetwork.addEdge('Chiang Mai', 'Khon Kaen', weight: 300);
  roadNetwork.addEdge('Pattaya', 'Phuket', weight: 750);

  print('Road Network:');
  print(roadNetwork);

  // Dijkstra's Algorithm
  print('🎯 Dijkstra\'s Algorithm from Bangkok:');
  final dijkstraStrategy = DijkstraAlgorithmStrategy<String>();
  final dijkstraInput = DijkstraInput(roadNetwork, 'Bangkok');

  if (dijkstraStrategy.canApply(dijkstraInput, const SelectorHint())) {
    final dijkstraResult = dijkstraStrategy.execute(dijkstraInput);

    for (final city in cities) {
      final distance = dijkstraResult.getDistance(city);
      final path = dijkstraResult.getPath(city);
      print('To $city: ${distance?.toStringAsFixed(0)}km via $path');
    }
  }

  // Bellman-Ford Algorithm (can handle negative weights)
  print('\n⚡ Bellman-Ford Algorithm from Bangkok:');
  final bellmanFordStrategy = BellmanFordAlgorithmStrategy<String>();
  final bellmanFordInput = BellmanFordInput(roadNetwork, 'Bangkok');

  if (bellmanFordStrategy.canApply(bellmanFordInput, const SelectorHint())) {
    final bellmanFordResult = bellmanFordStrategy.execute(bellmanFordInput);

    if (bellmanFordResult.hasNegativeCycle) {
      print('⚠️ Negative cycle detected!');
    } else {
      print('No negative cycles found.');
      print(
          'Distance to Phuket: ${bellmanFordResult.getDistance('Phuket')?.toStringAsFixed(0)}km',);
    }
  }

  // Floyd-Warshall Algorithm (all pairs shortest paths)
  print('\n🌐 Floyd-Warshall Algorithm (all pairs):');
  final floydWarshallStrategy = FloydWarshallAlgorithmStrategy<String>();
  final floydWarshallInput = FloydWarshallInput(roadNetwork);

  if (floydWarshallStrategy.canApply(
      floydWarshallInput, const SelectorHint(),)) {
    final floydWarshallResult =
        floydWarshallStrategy.execute(floydWarshallInput);

    print('Shortest distances between all city pairs:');
    for (final from in cities) {
      for (final to in cities) {
        if (from != to) {
          final distance = floydWarshallResult.getDistance(from, to);
          if (distance != null) {
            print('  $from → $to: ${distance.toStringAsFixed(0)}km');
          }
        }
      }
    }
  }
}

/// Demonstrate minimum spanning tree algorithms
Future<void> demonstrateMinimumSpanningTree() async {
  print('🌳 MINIMUM SPANNING TREE ALGORITHMS');
  print('-' * 30);

  // Create a weighted undirected graph representing network connections
  final network = Graph<String>(isDirected: false, isWeighted: true);

  // Add network nodes
  const nodes = ['Server1', 'Server2', 'Server3', 'Server4', 'Server5'];
  for (final node in nodes) {
    network.addVertex(node);
  }

  // Add connections with costs
  network.addEdge('Server1', 'Server2', weight: 100);
  network.addEdge('Server1', 'Server3', weight: 200);
  network.addEdge('Server2', 'Server3', weight: 50);
  network.addEdge('Server2', 'Server4', weight: 150);
  network.addEdge('Server3', 'Server4', weight: 75);
  network.addEdge('Server3', 'Server5', weight: 120);
  network.addEdge('Server4', 'Server5', weight: 80);

  print('Network Graph:');
  print('Nodes: ${network.vertices}');
  print('Total possible connections: ${network.edgeCount}');

  // Prim's Algorithm
  print('\n🌿 Prim\'s Algorithm:');
  final primStrategy = PrimAlgorithmStrategy<String>();
  final mstInput = MstInput(network);

  if (primStrategy.canApply(mstInput, const SelectorHint())) {
    final primResult = primStrategy.execute(mstInput);

    print('Minimum Spanning Tree (Prim):');
    print('Total cost: \$${primResult.totalWeight.toStringAsFixed(0)}');
    print('Connections needed:');
    for (final edge in primResult.edges) {
      print(
          '  ${edge.source} ↔ ${edge.destination} (\$${edge.weight.toStringAsFixed(0)})',);
    }
  }

  // Kruskal's Algorithm
  print('\n🔗 Kruskal\'s Algorithm:');
  final kruskalStrategy = KruskalAlgorithmStrategy<String>();

  if (kruskalStrategy.canApply(mstInput, const SelectorHint())) {
    final kruskalResult = kruskalStrategy.execute(mstInput);

    print('Minimum Spanning Tree (Kruskal):');
    print('Total cost: \$${kruskalResult.totalWeight.toStringAsFixed(0)}');
    print('Connections needed:');
    for (final edge in kruskalResult.edges) {
      print(
          '  ${edge.source} ↔ ${edge.destination} (\$${edge.weight.toStringAsFixed(0)})',);
    }
  }
}

/// Demonstrate advanced graph algorithms
Future<void> demonstrateAdvancedAlgorithms() async {
  print('🔬 ADVANCED GRAPH ALGORITHMS');
  print('-' * 30);

  // Topological Sort Example
  print('📋 Topological Sort (Course Prerequisites):');

  final courseGraph = Graph<String>(isDirected: true);

  // Add courses
  const courses = [
    'Math101',
    'Math201',
    'CS101',
    'CS201',
    'CS301',
    'Physics101',
    'DataStructures',
    'Algorithms',
  ];

  for (final course in courses) {
    courseGraph.addVertex(course);
  }

  // Add prerequisites (edge from prerequisite to course)
  courseGraph.addEdge('Math101', 'Math201');
  courseGraph.addEdge('Math101', 'Physics101');
  courseGraph.addEdge('CS101', 'CS201');
  courseGraph.addEdge('CS101', 'DataStructures');
  courseGraph.addEdge('CS201', 'CS301');
  courseGraph.addEdge('DataStructures', 'Algorithms');
  courseGraph.addEdge('Math201', 'Algorithms');

  final topologicalSortStrategy = TopologicalSortStrategy<String>();
  final topSortInput = TopologicalSortInput(courseGraph);

  if (topologicalSortStrategy.canApply(topSortInput, const SelectorHint())) {
    final topSortResult = topologicalSortStrategy.execute(topSortInput);

    if (topSortResult.isValid) {
      print('Course order (no cycles):');
      print('📚 ${topSortResult.sortedVertices.join(' → ')}');
    } else {
      print('⚠️ Prerequisite cycle detected!');
    }
  }

  // Strongly Connected Components Example
  print('\n🔄 Strongly Connected Components (Web Page Links):');

  final webGraph = Graph<String>(isDirected: true);

  // Add web pages
  const pages = ['HomePage', 'About', 'Products', 'Blog', 'Contact', 'Support'];
  for (final page in pages) {
    webGraph.addVertex(page);
  }

  // Add links between pages
  webGraph.addEdge('HomePage', 'About');
  webGraph.addEdge('HomePage', 'Products');
  webGraph.addEdge('About', 'HomePage');
  webGraph.addEdge('Products', 'Blog');
  webGraph.addEdge('Blog', 'Products');
  webGraph.addEdge('Contact', 'Support');
  webGraph.addEdge('Support', 'Contact');

  // Kosaraju's Algorithm
  print('\n🔍 Kosaraju\'s Algorithm:');
  final kosarajuStrategy = KosarajuAlgorithmStrategy<String>();
  final sccInput = SccInput(webGraph);

  if (kosarajuStrategy.canApply(sccInput, const SelectorHint())) {
    final kosarajuResult = kosarajuStrategy.execute(sccInput);

    print('Strongly Connected Components (${kosarajuResult.componentCount}):');
    for (int i = 0; i < kosarajuResult.components.length; i++) {
      print(
          '  Component ${i + 1}: {${kosarajuResult.components[i].join(', ')}}',);
    }
  }

  // Tarjan's Algorithm
  print('\n⚡ Tarjan\'s Algorithm:');
  final tarjanStrategy = TarjanAlgorithmStrategy<String>();

  if (tarjanStrategy.canApply(sccInput, const SelectorHint())) {
    final tarjanResult = tarjanStrategy.execute(sccInput);

    print('Strongly Connected Components (${tarjanResult.componentCount}):');
    for (int i = 0; i < tarjanResult.components.length; i++) {
      print('  Component ${i + 1}: {${tarjanResult.components[i].join(', ')}}');
    }
  }
}

/// Performance comparison of different algorithms
Future<void> compareAlgorithmPerformance() async {
  print('\n📊 ALGORITHM PERFORMANCE COMPARISON');
  print('-' * 30);

  // Create graphs of different sizes
  final sizes = [10, 50, 100, 500];

  for (final size in sizes) {
    print('\nGraph size: $size vertices');

    // Create random graph
    final graph = _createRandomGraph(size);

    // Test BFS
    final bfsStrategy = BreadthFirstSearchStrategy<int>();
    final bfsInput = BfsInput(graph, 0);

    final stopwatch = Stopwatch()..start();
    final bfsResult = bfsStrategy.execute(bfsInput);
    stopwatch.stop();

    print(
        '  BFS: ${stopwatch.elapsedMicroseconds}μs, visited: ${bfsResult.visited.length}',);

    // Test DFS
    final dfsStrategy = DepthFirstSearchStrategy<int>();
    final dfsInput = DfsInput(graph, 0);

    stopwatch.reset();
    stopwatch.start();
    final dfsResult = dfsStrategy.execute(dfsInput);
    stopwatch.stop();

    print(
        '  DFS: ${stopwatch.elapsedMicroseconds}μs, visited: ${dfsResult.visited.length}',);
  }
}

/// Create a random graph for testing
Graph<int> _createRandomGraph(int size) {
  final graph = Graph<int>(isDirected: false, isWeighted: true);

  // Add vertices
  for (int i = 0; i < size; i++) {
    graph.addVertex(i);
  }

  // Add random edges
  final random = Random();
  for (int i = 0; i < size; i++) {
    for (int j = i + 1; j < size; j++) {
      if (random.nextDouble() < 0.3) {
        // 30% chance of edge
        graph.addEdge(i, j, weight: random.nextDouble() * 100);
      }
    }
  }

  return graph;
}

class Random {
  factory Random() => _instance;
  Random._internal();
  static final _instance = Random._internal();

  int _seed = DateTime.now().millisecondsSinceEpoch;

  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed / 0x7fffffff;
  }

  int nextInt(int max) => (nextDouble() * max).floor();
}
