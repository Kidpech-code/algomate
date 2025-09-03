# Professional Benchmarking Suite 📊

**Advanced benchmarking capabilities with dataset generation, visual output, and comprehensive algorithm comparison.**

---

## 🚀 Quick Start

### Basic Benchmark Run

```bash
# Run comprehensive benchmark suite
dart run tool/benchmark.dart

# Custom configuration
dart run tool/benchmark.dart --iterations 100 --seed 42 --json results.json --csv results.csv
```

### Visual Output Example

```
🚀 Starting AlgoMate Professional Benchmark Suite
Platform: macOS 14.0 Darwin
Dart: 3.1.0
═══════════════════════════════════════════════════════════

📊 Algorithm Performance Comparison
┌─────────────────┬──────────────┬──────────────┬──────────────┬─────────────┐
│ Algorithm       │ Dataset      │ Median (μs)  │ P95 (μs)     │ Throughput  │
├─────────────────┼──────────────┼──────────────┼──────────────┼─────────────┤
│ InsertionSort   │ Random-100   │     12.5     │     18.3     │  8.0M/sec   │
│ MergeSort       │ Random-100   │     45.2     │     52.1     │  2.2M/sec   │
│ QuickSort       │ Random-100   │     38.7     │     44.9     │  2.6M/sec   │
│ InsertionSort   │ Sorted-100   │      2.1     │      3.4     │ 47.6M/sec   │
│ MergeSort       │ Sorted-100   │     44.8     │     51.7     │  2.2M/sec   │
└─────────────────┴──────────────┴──────────────┴──────────────┴─────────────┘

🔍 Key Insights:
✅ InsertionSort excels on small sorted datasets (22x faster)
✅ MergeSort provides consistent performance across patterns
✅ QuickSort shows 15% speed advantage on random data
⚠️  Memory overhead: MergeSort uses 2x memory vs QuickSort
```

---

## 📈 Dataset Generators

### Comprehensive Test Scenarios

**Random Distribution**

```dart
// Uniform random distribution with configurable seed
final randomData = DataGenerator.random(
  size: 10000,
  seed: 42,
  range: (0, 100000), // Value range
);
```

**Sorted Data**

```dart
// Perfectly sorted ascending data
final sortedData = DataGenerator.sorted(size: 10000);
// Expected: [0, 1, 2, ..., 9999]
```

**Reverse Sorted**

```dart
// Worst case for quicksort
final reverseData = DataGenerator.reverse(size: 10000);
// Expected: [9999, 9998, 9997, ..., 0]
```

**Nearly Sorted (5% shuffled)**

```dart
// Real-world scenario - mostly ordered data
final nearlyData = DataGenerator.nearlySorted(
  size: 10000,
  shufflePercent: 0.05, // 5% elements out of place
  seed: 42,
);
```

**Duplicate Heavy**

```dart
// Tests behavior with many duplicates
final dupeData = DataGenerator.duplicateHeavy(
  size: 10000,
  uniqueValues: 100, // Only 100 unique values repeated
  seed: 42,
);
```

**Custom Patterns**

```dart
// Alternating high/low values
final alternatingData = DataGenerator.alternating(
  size: 10000,
  lowValue: 1,
  highValue: 1000,
);

// Gaussian (normal) distribution
final normalData = DataGenerator.gaussian(
  size: 10000,
  mean: 500,
  standardDeviation: 100,
  seed: 42,
);

// Power law distribution (common in real data)
final powerLawData = DataGenerator.powerLaw(
  size: 10000,
  exponent: 2.0,
  seed: 42,
);
```

---

## 🏁 Performance Comparison Framework

### vs Built-in Dart Collections

```dart
final benchmark = ComparisonBenchmark();

// Compare against Dart's List.sort()
final results = await benchmark.compare({
  'AlgoMate-Auto': () => selector.sort(input: data),
  'Dart-Builtin': () => data.sort(),
  'Manual-QuickSort': () => quickSortImpl(data),
  'Manual-MergeSort': () => mergeSortImpl(data),
});

// Sample Output:
// AlgoMate-Auto: 245μs (±12μs) - 8.2M elements/sec
// Dart-Builtin: 198μs (±8μs) - 10.1M elements/sec
// Manual-QuickSort: 267μs (±15μs) - 7.5M elements/sec
// Manual-MergeSort: 289μs (±9μs) - 6.9M elements/sec
```

### vs External Libraries

```dart
// Compare against popular sorting libraries
final benchmark = ExternalComparison();
await benchmark.addLibrary('sort_algorithms', SortAlgorithmsAdapter());
await benchmark.addLibrary('efficient_dart', EfficientDartAdapter());
await benchmark.addLibrary('fast_sort', FastSortAdapter());

final results = await benchmark.runSuite(datasets);
```

### Algorithm Selection Analysis

```dart
// Analyze which algorithms AlgoMate chooses
final selectionAnalyzer = SelectionAnalyzer();

for (final dataset in testDatasets) {
  final analysis = await selectionAnalyzer.analyze(
    selector: selector,
    data: dataset.data,
    expectedAlgorithm: dataset.expectedOptimal,
  );

  print('Dataset: ${dataset.name}');
  print('  AlgoMate chose: ${analysis.selectedAlgorithm}');
  print('  Expected: ${analysis.expectedAlgorithm}');
  print('  Performance: ${analysis.performanceRatio}x expected');
  print('  Selection accuracy: ${analysis.wasOptimal ? "✅" : "❌"}');
}
```

---

## 📊 Visual Output & Reporting

### ASCII Charts

```
📈 Performance Scaling Analysis

Throughput vs Dataset Size (Random Data):
10M ┤                                               ╭─
    │                                           ╭───╯
 8M ┤                                       ╭───╯
    │                                   ╭───╯
 6M ┤                               ╭───╯
    │                           ╭───╯
 4M ┤                       ╭───╯      QuickSort
    │                   ╭───╯
 2M ┤               ╭───╯        MergeSort
    │           ╭───╯
 0M ┼───────────╯─────────────────────────────────────
    0    1K    5K   10K   50K  100K  500K   1M   10M
                    Dataset Size (elements)

🔍 Algorithm Crossover Points:
• InsertionSort → QuickSort: ~47 elements
• QuickSort → ParallelQuick: ~125,000 elements
• MergeSort → ParallelMerge: ~89,000 elements
```

### Memory Usage Tracking

```
💾 Memory Allocation Analysis

Algorithm Memory Footprint:
┌─────────────────┬─────────────┬─────────────┬─────────────┐
│ Algorithm       │ Peak (MB)   │ Allocs      │ GC Cycles   │
├─────────────────┼─────────────┼─────────────┼─────────────┤
│ InsertionSort   │     0.1     │       3     │      0      │
│ MergeSort       │    15.2     │      45     │      2      │
│ QuickSort       │     0.3     │       8     │      0      │
│ ParallelMerge   │    31.8     │     156     │      4      │
└─────────────────┴─────────────┴─────────────┴─────────────┘

⚠️ Memory Pressure Events:
• MergeSort triggered GC at 10K elements
• ParallelMerge hit memory limit at 500K elements
```

### HTML Report Generation

```dart
// Generate comprehensive HTML report
final reportGenerator = HTMLReportGenerator();
await reportGenerator.generate(
  results: benchmarkResults,
  outputPath: 'benchmark_report.html',
  includeCharts: true,
  includeMemoryAnalysis: true,
  includeAlgorithmDetails: true,
);

// Opens interactive report with:
// - Sortable performance tables
// - Interactive charts (Chart.js)
// - Algorithm selection decision trees
// - Performance regression tracking
// - Export to CSV/JSON functionality
```

---

## 🎛️ Advanced Configuration

### Custom Benchmark Scenarios

```dart
// Define domain-specific benchmarks
final ecommerceBenchmark = CustomBenchmark(
  name: 'E-commerce Product Sorting',
  dataGenerator: () => generateProductData(count: 50000),
  scenarios: [
    Scenario('Price-ascending', sortBy: 'price'),
    Scenario('Rating-descending', sortBy: 'rating', reverse: true),
    Scenario('Alphabetical', sortBy: 'name'),
  ],
  performanceTargets: {
    'median_time': Duration(milliseconds: 10),
    'p95_time': Duration(milliseconds: 25),
    'memory_mb': 16,
  },
);
```

### Statistical Analysis

```dart
// Advanced statistical metrics
final statisticalAnalyzer = StatisticalAnalyzer();
final analysis = await statisticalAnalyzer.analyze(results);

print('Performance Distribution Analysis:');
print('  Mean: ${analysis.mean.toStringAsFixed(2)}μs');
print('  Median: ${analysis.median.toStringAsFixed(2)}μs');
print('  Standard Deviation: ${analysis.stdDev.toStringAsFixed(2)}μs');
print('  Coefficient of Variation: ${analysis.coefficientOfVariation}%');
print('  Confidence Interval (95%): ${analysis.confidenceInterval}');

// Outlier detection
if (analysis.outliers.isNotEmpty) {
  print('⚠️ Performance outliers detected:');
  for (final outlier in analysis.outliers) {
    print('  ${outlier.value}μs (${outlier.deviations}σ from mean)');
  }
}
```

### Regression Testing

```dart
// Track performance over time
final regressionTracker = RegressionTracker();
await regressionTracker.recordBaseline(results, version: '0.2.4');

// Later runs
final currentResults = await runBenchmarks();
final regression = await regressionTracker.detectRegression(
  current: currentResults,
  threshold: 0.05, // 5% performance degradation threshold
);

if (regression.detected) {
  print('🚨 Performance regression detected!');
  print('  Algorithm: ${regression.algorithm}');
  print('  Degradation: ${regression.percentageSlower}%');
  print('  Confidence: ${regression.confidence}');
}
```

---

## 🔧 Integration with CI/CD

### GitHub Actions Example

```yaml
name: Performance Benchmarks
on: [push, pull_request]

jobs:
  benchmark:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1

      - name: Run benchmarks
        run: |
          dart pub get
          dart run tool/benchmark.dart --json benchmark_results.json --csv benchmark_results.csv

      - name: Upload results
        uses: actions/upload-artifact@v4
        with:
          name: benchmark-results
          path: |
            benchmark_results.json
            benchmark_results.csv

      - name: Performance regression check
        run: dart run tool/regression_check.dart benchmark_results.json
```

### Performance Dashboard

```dart
// Publish results to monitoring dashboard
final dashboard = PerformanceDashboard(
  endpoint: 'https://metrics.yourcompany.com/algomate',
  apiKey: Platform.environment['METRICS_API_KEY'],
);

await dashboard.publish(
  results: benchmarkResults,
  metadata: {
    'git_commit': Platform.environment['GITHUB_SHA'],
    'branch': Platform.environment['GITHUB_REF_NAME'],
    'build_number': Platform.environment['GITHUB_RUN_NUMBER'],
  },
);
```

---

## 🎯 Performance Targets & SLAs

### Recommended Performance Thresholds

| Dataset Size  | Target Median | Target P95 | Memory Limit |
| ------------- | ------------- | ---------- | ------------ |
| 100 elements  | < 50μs        | < 100μs    | < 1MB        |
| 1K elements   | < 200μs       | < 400μs    | < 5MB        |
| 10K elements  | < 2ms         | < 5ms      | < 25MB       |
| 100K elements | < 25ms        | < 50ms     | < 100MB      |
| 1M elements   | < 300ms       | < 600ms    | < 500MB      |

### Quality Gates

```dart
// Automated quality gate checks
final qualityGate = PerformanceQualityGate([
  Threshold('median_sort_10k', max: Duration(milliseconds: 2)),
  Threshold('p95_sort_10k', max: Duration(milliseconds: 5)),
  Threshold('memory_sort_100k', max: 100 * 1024 * 1024), // 100MB
  Threshold('selection_accuracy', min: 0.95), // 95% optimal selections
]);

final gateResult = await qualityGate.evaluate(benchmarkResults);
if (!gateResult.passed) {
  print('❌ Performance quality gate failed:');
  for (final failure in gateResult.failures) {
    print('  ${failure.metric}: ${failure.actual} (expected: ${failure.expected})');
  }
  exit(1); // Fail CI build
}
```

---

**🚀 Pro Tip**: Run benchmarks in CI to catch performance regressions early, but also run locally with `--iterations 1000` for more accurate results during development.
