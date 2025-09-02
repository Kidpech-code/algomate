# AlgoMate Flutter Web Demo

A comprehensive Flutter Web application demonstrating the AlgoMate algorithm library's web compatibility features.

## 🌟 Features

- **Algorithm Demonstrations**: Interactive examples of sorting, searching, dynamic programming, string processing, and graph algorithms
- **Performance Benchmarking**: Real-time performance analysis with execution time and memory usage metrics
- **Comprehensive Documentation**: Complete API reference and usage examples
- **Web-Optimized**: Fully compatible with Flutter Web using sequential fallback algorithms

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=2.17.0)
- Web browser (Chrome, Firefox, Safari, Edge)

### Installation

1. **Clone the repository:**

```bash
git clone <repository-url>
cd algomate/example/flutter_web_app
```

2. **Install dependencies:**

```bash
flutter pub get
```

3. **Run the web application:**

```bash
flutter run -d web-server --web-port 8080
```

4. **Open in browser:**

```
http://localhost:8080
```

## 📱 Application Structure

### Home Screen

- Overview of AlgoMate features
- Quick start guide
- Web compatibility highlights

### Algorithms Screen

- Interactive algorithm demonstrations
- Real-time execution with results
- Categories: Sorting, Search, DP, String Processing, Graph

### Performance Screen

- Comprehensive benchmarking suite
- Execution time measurements
- Memory usage analysis
- Performance ratings and visualizations

### Documentation Screen

- Complete API reference
- Usage examples and best practices
- Web-specific optimization tips
- Configuration guides

## 🛠️ Technical Implementation

### Web Compatibility Features

The application showcases AlgoMate's web compatibility through:

1. **Conditional Imports**: Automatic platform detection and appropriate algorithm selection
2. **Sequential Fallbacks**: Web-optimized versions of parallel algorithms
3. **JavaScript Compilation**: Full compatibility with Dart-to-JavaScript compilation
4. **Memory Management**: Browser-optimized memory usage patterns

### Algorithm Categories

#### Sorting Algorithms

- **MergeSort**: O(n log n) stable sorting with web optimization
- **QuickSort**: O(n log n) average case with iterative implementation
- **HeapSort**: O(n log n) guaranteed performance

#### Search Algorithms

- **Binary Search**: O(log n) for sorted arrays
- **Linear Search**: O(n) fallback for unsorted data

#### Dynamic Programming

- **Knapsack Problem**: Classic optimization with web-friendly memory usage
- **Longest Common Subsequence**: String comparison algorithms
- **Fibonacci**: Optimized recursive calculations

#### String Processing

- **KMP Algorithm**: O(n+m) pattern matching
- **Rabin-Karp**: Rolling hash implementation
- **Longest Palindrome**: Efficient palindrome detection

#### Graph Algorithms

- **BFS/DFS**: Graph traversal with web-compatible queue implementation
- **Connected Components**: Component analysis using Union-Find
- **Path Finding**: Shortest path algorithms

## 🔧 Configuration

### Build Configuration

The application uses the following configuration:

```yaml
# pubspec.yaml
flutter:
  uses-material-design: true
  assets:
    - assets/

dev_dependencies:
  flutter_web_plugins:
    sdk: flutter
```

### Web-Specific Settings

```yaml
# web/index.html
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta charset="UTF-8">
<meta name="description" content="AlgoMate Flutter Web Demo">
```

## 📊 Performance Metrics

The application includes comprehensive performance monitoring:

- **Execution Time**: Microsecond precision timing
- **Memory Usage**: Real-time memory tracking
- **Algorithm Comparison**: Side-by-side performance analysis
- **Browser Compatibility**: Cross-browser performance validation

### Benchmark Results

Typical performance on modern web browsers:

| Algorithm     | Data Size   | Execution Time | Memory Usage |
| ------------- | ----------- | -------------- | ------------ |
| MergeSort     | 10,000      | ~15ms          | ~80KB        |
| Binary Search | 100,000     | ~50μs          | ~400KB       |
| KMP Search    | Text: 10KB  | ~2ms           | ~20KB        |
| BFS Traversal | 1,000 nodes | ~8ms           | ~32KB        |

## 🌐 Web Deployment

### Build for Production

```bash
flutter build web --release --web-renderer html
```

### Deploy to Web Server

1. **Static Hosting** (GitHub Pages, Netlify, Vercel):

```bash
# Copy build/web contents to your hosting provider
cp -r build/web/* /path/to/hosting/directory/
```

2. **Firebase Hosting**:

```bash
firebase init hosting
firebase deploy
```

3. **Custom Server**:

```bash
# Serve the build/web directory
python -m http.server 8080 --directory build/web
```

## 🧪 Testing

### Run Tests

```bash
flutter test
```

### Web-Specific Tests

```bash
flutter test --platform web-server
```

### Performance Testing

```bash
flutter run --profile -d web-server
```

## 📋 Browser Compatibility

Tested and validated on:

- ✅ Chrome (90+)
- ✅ Firefox (88+)
- ✅ Safari (14+)
- ✅ Edge (90+)

### Known Limitations

- **Large Datasets**: Performance may degrade with datasets > 100K elements
- **Memory Constraints**: Browser memory limits may affect very large operations
- **Parallel Processing**: Uses sequential algorithms (no Web Workers implementation)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on multiple browsers
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.

## 🔗 Links

- [AlgoMate Documentation](../../doc/WEB_COMPATIBILITY.md)
- [Flutter Web Guide](https://flutter.dev/web)
- [Dart Web Platform](https://dart.dev/web)

## 📞 Support

For questions and support:

- Create an issue in the repository
- Check the documentation screen in the app
- Review the web compatibility guide

---

**Note**: This is a demonstration application. For production use, consider implementing additional optimizations based on your specific requirements.
