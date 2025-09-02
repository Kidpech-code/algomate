/// Platform-aware parallel algorithm exports.
library algomate.src.infrastructure.strategies.parallel_algorithms;

///
/// This file provides the appropriate parallel algorithm implementations
/// based on the target platform:
/// - Native platforms: Full isolate support via native implementations
/// - Web platform: Sequential fallback implementations

// Conditional exports based on platform
export 'sort/parallel_sort_algorithms.dart'
    if (dart.library.html) 'sort/parallel_sort_algorithms_web.dart'
    if (dart.library.js_interop) 'sort/parallel_sort_algorithms_web.dart';

export 'matrix/parallel_matrix_algorithms.dart'
    if (dart.library.html) 'matrix/parallel_matrix_algorithms_web.dart'
    if (dart.library.js_interop) 'matrix/parallel_matrix_algorithms_web.dart';

export 'graph/parallel_graph_algorithms.dart'
    if (dart.library.html) 'graph/parallel_graph_algorithms_web.dart'
    if (dart.library.js_interop) 'graph/parallel_graph_algorithms_web.dart'
    hide Graph;
