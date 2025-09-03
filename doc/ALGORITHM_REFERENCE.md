# AlgoMate Algorithm Reference 🔬

**Complete technical specification of all 50+ built-in algorithms with performance characteristics, edge cases, and use-case recommendations.**

---

## 📊 Sorting Algorithms (8 implementations)

### `InsertionSort`

- **Time Complexity**: O(n²) average/worst, O(n) best (nearly sorted)
- **Space Complexity**: O(1) - In-place algorithm
- **Stability**: ✅ Stable (maintains relative order of equal elements)
- **Memory Pattern**: Excellent cache locality, minimal allocations
- **Edge Cases**:
  - Empty list: O(1)
  - Single element: O(1)
  - Already sorted: O(n) - optimal for nearly sorted data
- **Best Use Cases**:
  - Small datasets (< 50 elements)
  - Nearly sorted data
  - Real-time applications requiring consistent performance
  - Embedded systems with memory constraints
- **Avoid When**:
  - Large datasets (> 1000 elements)
  - Random data distribution
  - Performance-critical batch processing

### `MergeSort`

- **Time Complexity**: O(n log n) guaranteed - consistent across all cases
- **Space Complexity**: O(n) - Requires auxiliary array
- **Stability**: ✅ Stable
- **Memory Pattern**: Predictable allocation pattern, good for GC
- **Edge Cases**:
  - Empty/single element: O(1)
  - All duplicates: O(n log n) but minimal comparisons
  - Worst case same as average case
- **Best Use Cases**:
  - Medium to large datasets (1K-100K elements)
  - When stability is required
  - Predictable performance needed
  - External sorting (disk-based)
- **Avoid When**:
  - Memory is severely constrained
  - Very small datasets (< 20 elements)

### `QuickSort` (Randomized)

- **Time Complexity**: O(n log n) average, O(n²) worst (rare with randomization)
- **Space Complexity**: O(log n) average - Stack space for recursion
- **Stability**: ❌ Not stable
- **Memory Pattern**: In-place partitioning, minimal allocations
- **Edge Cases**:
  - All elements equal: O(n²) → mitigated by 3-way partitioning
  - Already sorted: O(n²) → mitigated by random pivot selection
  - Nearly sorted: Can be slower than insertion sort for small segments
- **Best Use Cases**:
  - General-purpose sorting of random data
  - Large datasets where memory is constrained
  - When average-case performance matters most
- **Avoid When**:
  - Stability is required
  - Worst-case guarantees needed
  - Stack overflow risk (very deep recursion)

### `HeapSort`

- **Time Complexity**: O(n log n) guaranteed
- **Space Complexity**: O(1) - In-place algorithm
- **Stability**: ❌ Not stable
- **Memory Pattern**: Excellent - no additional allocations
- **Edge Cases**:
  - All equal elements: Still O(n log n)
  - Already sorted: O(n log n) (no best case optimization)
- **Best Use Cases**:
  - When O(n log n) guarantee + O(1) space required
  - Systems programming where predictability matters
  - Priority queue implementations
- **Avoid When**:
  - Cache performance is critical (poor locality)
  - Small datasets
  - Stability is required

### `ParallelMergeSort`

- **Time Complexity**: O(n log n) with ~P speedup (P = CPU cores)
- **Space Complexity**: O(n) per thread + synchronization overhead
- **Stability**: ✅ Stable
- **Memory Pattern**: Higher memory usage due to parallel copies
- **Edge Cases**:
  - Small datasets: Falls back to sequential merge sort
  - Single core: Equivalent to regular merge sort
  - Thread contention: Performance can degrade
- **Best Use Cases**:
  - Large datasets (> 100K elements)
  - Multi-core systems with available CPU
  - When stability + speed both required
- **Avoid When**:
  - Memory constrained environments
  - Single-core systems
  - Real-time systems (thread scheduling unpredictability)

### `ParallelQuickSort`

- **Time Complexity**: O(n log n) with ~P speedup
- **Space Complexity**: O(log n) per thread + work-stealing overhead
- **Stability**: ❌ Not stable
- **Memory Pattern**: Work-stealing queues, moderate overhead
- **Edge Cases**:
  - Poor pivot selection can reduce parallelism
  - Load balancing critical for performance
- **Best Use Cases**:
  - Very large datasets (> 1M elements)
  - High-core-count systems
  - When maximum speed is priority
- **Avoid When**:
  - Stability required
  - Memory constrained
  - Inconsistent performance acceptable

---

## 🔍 Search Algorithms (4 implementations)

### `LinearSearch`

- **Time Complexity**: O(n)
- **Space Complexity**: O(1)
- **Prerequisites**: None - works on unsorted data
- **Edge Cases**:
  - Empty collection: Returns -1 immediately
  - All duplicates: Returns first occurrence
  - Target not found: Scans entire collection
- **Best Use Cases**:
  - Small unsorted datasets (< 100 elements)
  - One-time searches
  - When sorting overhead not justified
- **Avoid When**:
  - Large datasets with multiple searches
  - Data can be kept sorted

### `BinarySearch`

- **Time Complexity**: O(log n)
- **Space Complexity**: O(1) iterative, O(log n) recursive
- **Prerequisites**: ⚠️ Requires sorted data
- **Edge Cases**:
  - Empty collection: Returns -1
  - Duplicates: Returns any valid index (implementation specific)
  - Target larger/smaller than all elements: -1
- **Best Use Cases**:
  - Sorted datasets with frequent lookups
  - Large datasets (> 1000 elements)
  - Dictionary/lookup table implementations
- **Avoid When**:
  - Data cannot be sorted
  - Infrequent searches on small datasets

### `ParallelBinarySearch` (for very large arrays)

- **Time Complexity**: O(log n) with reduced constant factor
- **Space Complexity**: O(1) with thread synchronization
- **Prerequisites**: Sorted data + very large dataset (> 10M elements)
- **Best Use Cases**:
  - Massive sorted arrays (databases, indices)
  - Concurrent search operations
- **Avoid When**:
  - Dataset fits in single cache
  - Thread overhead exceeds benefit

---

## 🌐 Graph Algorithms (15+ implementations)

### `BreadthFirstSearch (BFS)`

- **Time Complexity**: O(V + E) where V=vertices, E=edges
- **Space Complexity**: O(V) for queue and visited tracking
- **Use Cases**:
  - Shortest path in unweighted graphs
  - Connected components
  - Bipartite graph checking
- **Edge Cases**:
  - Disconnected graphs: Only explores reachable nodes
  - Self-loops: Handled correctly
  - Empty graph: Returns empty result

### `DepthFirstSearch (DFS)`

- **Time Complexity**: O(V + E)
- **Space Complexity**: O(V) for recursion stack/explicit stack
- **Use Cases**:
  - Topological sorting
  - Cycle detection
  - Path finding (not necessarily shortest)
- **Edge Cases**:
  - Cycles: Can run indefinitely without visited tracking
  - Deep graphs: Stack overflow risk with recursion

### `DijkstraAlgorithm` (Shortest Path)

- **Time Complexity**: O((V + E) log V) with binary heap
- **Space Complexity**: O(V) for distances + priority queue
- **Prerequisites**: Non-negative edge weights
- **Use Cases**:
  - GPS navigation systems
  - Network routing protocols
  - Social network analysis
- **Edge Cases**:
  - Negative weights: Produces incorrect results
  - Disconnected nodes: Distance remains infinity
  - Source = target: Distance = 0

### `BellmanFordAlgorithm` (Handles negative weights)

- **Time Complexity**: O(VE)
- **Space Complexity**: O(V)
- **Advantage**: Detects negative cycles
- **Use Cases**:
  - Currency exchange arbitrage
  - Network analysis with costs/penalties
- **Edge Cases**:
  - Negative cycles: Detectable and reported
  - Dense graphs: Can be slower than Dijkstra

### `FloydWarshallAlgorithm` (All-pairs shortest path)

- **Time Complexity**: O(V³)
- **Space Complexity**: O(V²)
- **Use Cases**:
  - Small graphs where all distances needed
  - Transitive closure computation
- **Avoid When**: Large graphs (V > 1000)

### `PrimAlgorithm` (Minimum Spanning Tree)

- **Time Complexity**: O(E log V) with priority queue
- **Space Complexity**: O(V + E)
- **Use Cases**:
  - Network cable layout optimization
  - Cluster analysis
- **Edge Cases**:
  - Disconnected graphs: Returns forest of MSTs

### `KruskalAlgorithm` (MST with Union-Find)

- **Time Complexity**: O(E log E)
- **Space Complexity**: O(V + E)
- **Better than Prim when**: Sparse graphs (E << V²)
- **Use Cases**: Same as Prim, better for sparse graphs

---

## 🧮 Dynamic Programming (10+ algorithms)

### `KnapsackDP` (0/1 Knapsack)

- **Time Complexity**: O(nW) where n=items, W=capacity
- **Space Complexity**: O(nW) or O(W) space-optimized
- **Use Cases**:
  - Resource allocation optimization
  - Budget allocation problems
  - Portfolio optimization
- **Edge Cases**:
  - Zero capacity: Return empty selection
  - All items too heavy: Return empty selection

### `LongestCommonSubsequenceDP`

- **Time Complexity**: O(nm) where n,m = string lengths
- **Space Complexity**: O(nm) or O(min(n,m)) optimized
- **Use Cases**:
  - DNA sequence alignment
  - Version control diff algorithms
  - Plagiarism detection
- **Edge Cases**:
  - Empty strings: LCS length = 0
  - Identical strings: LCS = entire string

### `EditDistanceDP` (Levenshtein Distance)

- **Time Complexity**: O(nm)
- **Space Complexity**: O(nm) or O(min(n,m)) optimized
- **Use Cases**:
  - Spell checkers
  - Fuzzy string matching
  - Data deduplication
- **Edge Cases**:
  - Empty strings: Distance = length of other string
  - Identical strings: Distance = 0

### `CoinChangeDP`

- **Time Complexity**: O(nW) where n=coin types, W=target amount
- **Space Complexity**: O(W)
- **Use Cases**:
  - Making change algorithms
  - Resource optimization
  - Dynamic pricing
- **Edge Cases**:
  - No solution exists: Returns -1 or infinity
  - Target = 0: Returns 0 coins

---

## 🔤 String Processing (12+ algorithms)

### `KnuthMorrisPrattAlgorithm` (KMP)

- **Time Complexity**: O(n + m) where n=text, m=pattern
- **Space Complexity**: O(m) for failure function
- **Preprocessing**: O(m) to build failure function
- **Use Cases**:
  - Text editors (find/replace)
  - Log file analysis
  - Bioinformatics (DNA pattern matching)
- **Edge Cases**:
  - Empty pattern: Matches at every position
  - Pattern longer than text: No matches
  - Multiple occurrences: Finds all efficiently

### `RabinKarpAlgorithm` (Rolling Hash)

- **Time Complexity**: O(nm) worst case, O(n + m) average
- **Space Complexity**: O(1)
- **Advantage**: Can extend to multiple pattern search
- **Use Cases**:
  - Plagiarism detection
  - Multiple pattern matching
- **Edge Cases**:
  - Hash collisions: Requires verification step
  - Overflow handling in hash computation

### `AhoCorasickAlgorithm` (Multiple Pattern Matching)

- **Time Complexity**: O(n + m + z) where z=matches found
- **Space Complexity**: O(m) for trie structure
- **Use Cases**:
  - Spam filtering (multiple keyword detection)
  - Intrusion detection systems
  - Content filtering
- **Edge Cases**:
  - Overlapping patterns: Finds all occurrences
  - Empty pattern set: No matches

### `ManacherAlgorithm` (Linear Palindromes)

- **Time Complexity**: O(n)
- **Space Complexity**: O(n)
- **Advantage**: Finds all palindromes in linear time
- **Use Cases**:
  - DNA analysis (palindromic sequences)
  - Text processing optimization
- **Alternative**: Naive O(n³) approach

### `SuffixArrayAlgorithm`

- **Time Complexity**: O(n log n) construction
- **Space Complexity**: O(n)
- **Use Cases**:
  - Full-text indexing
  - Burrows-Wheeler transform
  - Longest common substring
- **Query Time**: O(m log n) for pattern matching

### `TrieAlgorithm` (Prefix Tree)

- **Construction**: O(total_length_of_all_strings)
- **Space Complexity**: O(total_length) worst case
- **Lookup**: O(string_length)
- **Use Cases**:
  - Auto-complete systems
  - IP routing tables
  - Dictionary implementations
- **Edge Cases**:
  - Empty string: Typically stored at root
  - Prefix queries: Traversal from matched node

---

## 🎛️ Algorithm Selection Matrix

| Dataset Size | Random Data    | Nearly Sorted  | Memory Limited | Stability Required |
| ------------ | -------------- | -------------- | -------------- | ------------------ |
| < 50         | Insertion      | Insertion      | Insertion      | Insertion          |
| 50-1K        | Quick          | Insertion      | Heap           | Merge              |
| 1K-100K      | Quick          | Merge          | Heap           | Merge              |
| 100K-1M      | Parallel Quick | Merge          | Heap           | Parallel Merge     |
| > 1M         | Parallel Quick | Parallel Merge | Heap           | Parallel Merge     |

## ⚠️ Common Pitfalls & Edge Cases

### Memory Allocation Patterns

- **Merge Sort**: Allocates O(n) auxiliary space - can trigger GC
- **Quick Sort**: In-place but O(log n) stack - stack overflow risk
- **Parallel Algorithms**: Memory per thread - can exceed available RAM

### Numerical Stability

- **Floating Point**: Quick sort partitioning with floats can have precision issues
- **Integer Overflow**: Large datasets with sum operations
- **Hash Functions**: Rabin-Karp rolling hash overflow handling

### Thread Safety

- **Parallel Algorithms**: Input data must not be modified during execution
- **Shared State**: Global counters/statistics require synchronization
- **Resource Contention**: Too many threads can hurt performance

### Input Validation

- **Null Safety**: All algorithms handle null/empty inputs gracefully
- **Type Constraints**: Generic algorithms require `Comparable<T>`
- **Graph Validity**: Negative weights with Dijkstra produce incorrect results

---

## 🎯 Performance Recommendations

### When Dataset Size Unknown

```dart
// Let AlgoMate decide based on runtime characteristics
final result = selector.sort(
  input: data,
  hint: SelectorHint.adaptive(), // Analyzes data pattern
);
```

### Memory-Constrained Environments

```dart
final selector = AlgoSelectorFacade.production()
  .withMemoryConstraint(MemoryConstraint.low)
  .build();
```

### Predictable Performance Required

```dart
// Force deterministic algorithms (no randomized quick sort)
final result = selector.sort(
  input: data,
  hint: SelectorHint(
    preferDeterministic: true,
    maxTimeComplexity: TimeComplexity.nLogN,
  ),
);
```

### Maximum Speed (Trade-offs Acceptable)

```dart
final result = selector.sort(
  input: data,
  hint: SelectorHint(
    performancePriority: PerformancePriority.speed,
    stabilityRequired: false, // Allow unstable but faster algorithms
  ),
);
```

---

**💡 Pro Tip**: Use `AlgoSelectorFacade.development()` to see algorithm selection reasoning during development, then switch to `AlgoSelectorFacade.production()` to minimize overhead.
