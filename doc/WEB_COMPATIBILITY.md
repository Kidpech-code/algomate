# AlgoMate Flutter Web Compatibility Guide

## Overview

AlgoMate is now fully compatible with Flutter Web! This document explains how the library handles platform differences and provides guidance for web deployment.

## Platform-Aware Architecture

### Conditional Imports

AlgoMate uses Dart's conditional import feature to provide different implementations for native platforms vs web:

```dart
// Platform-aware parallel algorithm exports
export 'sort/parallel_sort_algorithms.dart'
    if (dart.library.html) 'sort/parallel_sort_algorithms_web.dart'
    if (dart.library.js_interop) 'sort/parallel_sort_algorithms_web.dart';
```

### Native vs Web Differences

| Feature             | Native Platform     | Web Platform              |
| ------------------- | ------------------- | ------------------------- |
| Isolates            | ✅ Full support     | ❌ Not available          |
| Parallel Processing | ✅ True parallelism | ⚠️ Sequential fallback    |
| File I/O            | ✅ Full dart:io     | ❌ Limited to downloads   |
| Performance         | 🚀 Optimal          | 🐌 JavaScript limitations |

## Web-Compatible Algorithms

### Sorting Algorithms

- **ParallelMergeSort** → Sequential merge sort with same API
- **ParallelQuickSort** → Sequential quick sort with randomization
- All other sorting algorithms work unchanged

### Search Algorithms

- **ParallelBinarySearch** → Sequential binary search
- Linear and binary search work unchanged

### Matrix Operations

- **ParallelMatrixMultiplication** → Block-based sequential multiplication
- **ParallelStrassenMultiplication** → Sequential Strassen algorithm

### Graph Algorithms

- **ParallelBFS** → Sequential breadth-first search
- **ParallelDFS** → Sequential depth-first search
- **ParallelConnectedComponents** → Sequential Union-Find

### String Processing

- All string algorithms work unchanged (no isolate dependency)

### Dynamic Programming

- All DP algorithms work unchanged (pure computation)

## Usage Examples

### Basic Usage (Same API)

```dart
import 'package:algomate/algomate.dart';

void main() {
  final selector = AlgoSelectorFacade.development();

  // Works on both native and web
  final result = selector.sort(
    input: [64, 34, 25, 12, 22, 11, 90],
    hint: SelectorHint(n: 7),
  );

  print('Sorted: ${result.fold((s) => s.output, (e) => e)}');
}
```

### Web-Specific Considerations

```dart
// Check if running on web
import 'dart:html' as html show window;

bool get isWeb => html.window != null;

void main() {
  if (isWeb) {
    print('Running on Flutter Web - using sequential fallbacks');
  } else {
    print('Running on native platform - using parallel algorithms');
  }

  // Same code works on both platforms
  final largeData = List.generate(100000, (i) => Random().nextInt(1000000));
  final selector = AlgoSelectorFacade.development();

  final result = selector.sort(
    input: largeData,
    hint: SelectorHint(n: largeData.length, preferParallel: true),
  );
}
```

## Performance Considerations

### Web Platform Limitations

1. **Single-threaded**: JavaScript runs in a single thread, so parallel algorithms fall back to sequential
2. **Memory**: Large datasets may cause memory pressure in the browser
3. **Execution time**: Complex algorithms may block the UI thread

### Optimization Strategies

```dart
// For web, prefer smaller datasets or chunked processing
final hint = SelectorHint(
  n: data.length,
  preferSimple: isWeb, // Use simpler algorithms on web
  memoryBudgetBytes: isWeb ? 10 * 1024 * 1024 : null, // 10MB limit on web
);
```

## Deployment

### Web Build Configuration

1. **pubspec.yaml** - Ensure web platform is enabled:

```yaml
platforms:
  web:
```

2. **Build for web**:

```bash
flutter build web --web-renderer html
```

3. **Test locally**:

```bash
flutter run -d chrome
```

### HTML Integration

Include the AlgoMate test in your web app:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>AlgoMate Web Demo</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="application/dart" src="main.dart"></script>
    <script src="flutter.js" defer></script>
  </body>
</html>
```

## Testing

### Running Web Tests

```bash
# Analyze for web compatibility
dart analyze example/web_demo.dart

# Run the web demo
dart run example/web_demo.dart

# Build and serve web version
flutter build web
cd build/web
python -m http.server 8000
# Open http://localhost:8000
```

### Expected Output

```
AlgoMate Web Compatibility Demo
=================================

1. Sorting Algorithms:
  ✅ MergeSort: [33, 35, 40, 42, 44]... (1000 elements)
  ✅ QuickSort: [33, 35, 40, 42, 44]... (1000 elements)
  ✅ InsertionSort: [40, 219, 407, 410, 609]... (50 elements)

2. Search Algorithms:
  ✅ BinarySearch for 500: found at index 250
  ✅ LinearSearch for 500: found at index 250

3. Dynamic Programming:
  ✅ Knapsack: max value 7
  ✅ CoinChange for amount 6: 2 coins
  ✅ LCS of "ABCDGH" and "AEDFHR": "ADH" (length 3)

4. String Processing:
  ✅ KMP pattern matching: found at positions [0, 5]
  ✅ Rabin-Karp: found at positions [0, 12]
  ✅ Longest palindrome in "racecar": "racecar"

5. Custom Data Structures:
  ✅ PriorityQueue: first 3 mins are [1, 2, 5]
  ✅ BST sorted: [apple, banana, cherry, date]
  ✅ CircularBuffer: [b, c, d]

Web compatibility test completed successfully! 🎉
```

## Common Issues and Solutions

### Issue: "dart:isolate is not available"

**Solution**: Use the conditional import system - it automatically falls back to web-compatible implementations.

### Issue: "dart:io is not available"

**Solution**: File operations are replaced with web-compatible alternatives or removed in web versions.

### Issue: Performance degradation on web

**Solution**: Use `SelectorHint(preferSimple: true)` for web deployments to choose lighter algorithms.

### Issue: Memory issues with large datasets

**Solution**: Set memory budget limits: `SelectorHint(memoryBudgetBytes: 10 * 1024 * 1024)`

## Browser Support

AlgoMate Web is compatible with:

- ✅ Chrome 90+
- ✅ Firefox 85+
- ✅ Safari 14+
- ✅ Edge 90+

## Architecture Benefits

1. **Single Codebase**: Same API works across all platforms
2. **Graceful Degradation**: Algorithms automatically adapt to platform capabilities
3. **Performance Optimization**: Platform-specific optimizations where possible
4. **Future Proof**: Easy to add new platform-specific optimizations

## Next Steps

- Consider using Web Workers for true parallel processing (future enhancement)
- Implement progressive loading for large datasets
- Add performance monitoring for web-specific optimizations

---

_For more information, see the main [README.md](../README.md) and [API documentation](https://pub.dev/documentation/algomate/)._
