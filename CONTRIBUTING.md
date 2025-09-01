# Contributing to AlgoMate 🤝

Thank you for your interest in contributing to AlgoMate! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Algorithm Implementation](#algorithm-implementation)
- [Testing Requirements](#testing-requirements)
- [Performance Benchmarking](#performance-benchmarking)
- [Code Review Process](#code-review-process)
- [Release Process](#release-process)

## Code of Conduct

This project follows the [Dart Code of Conduct](https://dart.dev/community). Please be respectful and inclusive in all interactions.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/yourusername/algomate.git
   cd algomate
   ```
3. **Install dependencies**:
   ```bash
   dart pub get
   ```
4. **Run tests** to ensure everything works:
   ```bash
   dart test
   ```

## Development Setup

### Prerequisites

- Dart SDK 3.0.0 or higher
- Git
- A code editor with Dart support (VS Code recommended)

### Project Structure

```
lib/
├── src/
│   ├── domain/           # Core business logic (entities, value objects)
│   ├── application/      # Use cases and ports
│   ├── infrastructure/   # Algorithm implementations, adapters
│   ├── interface/        # Facade, builders, configuration
│   └── shared/           # Common utilities (Result, errors)
├── algomate.dart         # Public API exports
test/                     # Test files
tool/                     # Build scripts, benchmarks
```

### Code Style

- Follow [Dart style guide](https://dart.dev/effective-dart/style)
- Use `dart format` for formatting
- Run `dart analyze` to check for issues
- Maximum line length: 120 characters
- Use descriptive variable names and comprehensive documentation

## Contributing Guidelines

### Types of Contributions

1. **Bug Reports**: Use GitHub Issues with bug report template
2. **Feature Requests**: Use GitHub Issues with feature request template
3. **Algorithm Implementations**: New sorting/searching algorithms
4. **Performance Optimizations**: Improvements to existing algorithms
5. **Documentation**: README, code comments, examples
6. **Tests**: Unit tests, integration tests, benchmarks

### Pull Request Process

1. **Create a feature branch**:

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the guidelines below

3. **Write/update tests** for your changes

4. **Run the test suite**:

   ```bash
   dart test
   dart analyze
   dart format --set-exit-if-changed .
   ```

5. **Run benchmarks** (if applicable):

   ```bash
   dart run tool/benchmark.dart
   ```

6. **Update documentation** if needed

7. **Commit with conventional commits**:

   ```bash
   git commit -m "feat: add randomized quicksort algorithm"
   git commit -m "fix: handle empty list in binary search"
   git commit -m "docs: update algorithm comparison table"
   ```

8. **Push and create PR**:
   ```bash
   git push origin feature/your-feature-name
   ```

### Commit Message Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` new features
- `fix:` bug fixes
- `docs:` documentation changes
- `test:` adding/updating tests
- `perf:` performance improvements
- `refactor:` code refactoring
- `chore:` maintenance tasks

## Algorithm Implementation

### Adding New Algorithms

1. **Create the strategy class**:

   ```dart
   // lib/src/infrastructure/strategies/sort/your_algorithm.dart
   class YourAlgorithm extends Strategy<List<int>, List<int>> {
     @override
     AlgoMetadata get meta => const AlgoMetadata(
       name: 'your_algorithm',
       timeComplexity: TimeComplexity.oNLogN,
       spaceComplexity: TimeComplexity.o1,
       requiresSorted: false,
       memoryOverheadBytes: 0,
       description: 'Brief description of your algorithm',
     );

     @override
     bool canApply(List<int> input, SelectorHint hint) {
       // Implement applicability logic
       final size = hint.n ?? input.length;
       return size > 10; // Example condition
     }

     @override
     List<int> execute(List<int> input) {
       // Implement the algorithm
       if (input.isEmpty) return [];
       final result = List<int>.from(input);
       // Your sorting logic here
       return result;
     }
   }
   ```

2. **Add comprehensive tests**:

   ```dart
   // test/your_algorithm_test.dart
   void main() {
     group('YourAlgorithm', () {
       late YourAlgorithm algorithm;

       setUp(() {
         algorithm = YourAlgorithm();
       });

       test('should sort empty list', () {
         expect(algorithm.execute([]), isEmpty);
       });

       test('should sort random data', () {
         final input = [3, 1, 4, 1, 5, 9, 2, 6, 5];
         final result = algorithm.execute(input);
         expect(result, [1, 1, 2, 3, 4, 5, 5, 6, 9]);
       });

       // Add edge cases, performance tests, etc.
     });
   }
   ```

3. **Register in selector builder**:

   ```dart
   // Update AlgoSelectorBuilder to include your strategy
   ```

4. **Add benchmark**:
   ```dart
   // Add your algorithm to benchmark suite
   ```

### Algorithm Requirements

- **Correctness**: Must produce correct results for all valid inputs
- **Performance**: Should have clearly defined time/space complexity
- **Edge Cases**: Handle empty inputs, single elements, duplicates
- **Memory Safety**: No memory leaks or excessive allocations
- **Documentation**: Clear docstrings with complexity analysis
- **Tests**: Comprehensive test coverage including edge cases

## Testing Requirements

### Test Categories

1. **Unit Tests**: Individual algorithm correctness
2. **Integration Tests**: End-to-end functionality
3. **Performance Tests**: Benchmark regression testing
4. **Edge Case Tests**: Boundary conditions, error handling

### Test Standards

- **Coverage**: Minimum 90% line coverage
- **Performance**: No regressions > 10% without justification
- **Edge Cases**: Empty inputs, single elements, large datasets
- **Error Handling**: Invalid inputs, resource exhaustion

### Running Tests

```bash
# All tests
dart test

# With coverage
dart test --coverage=coverage

# Specific test file
dart test test/your_test.dart

# Performance tests
dart run tool/benchmark.dart
```

## Performance Benchmarking

### Benchmark Requirements

- **Statistical Rigor**: Multiple runs, median/P95/P99 reporting
- **Platform Coverage**: Test on Linux, macOS, Windows
- **Data Variety**: Random, sorted, reverse, nearly-sorted, duplicates
- **Size Scaling**: Test multiple input sizes (100, 1K, 10K, 100K)
- **Regression Detection**: Compare against baseline

### Adding Benchmarks

```dart
// tool/benchmark.dart - Add to benchmark suite
await _benchmarkSort(size, 'your_scenario', generateYourData(size));
```

### Performance Guidelines

- **No Regressions**: New algorithms shouldn't slow existing ones
- **Memory Efficiency**: Monitor memory usage and allocations
- **Worst-Case Analysis**: Document and test worst-case scenarios
- **Comparison**: Compare against standard library implementations

## Code Review Process

### Review Criteria

1. **Correctness**: Algorithm produces correct results
2. **Performance**: Meets documented complexity bounds
3. **Code Quality**: Follows style guide, well-documented
4. **Tests**: Comprehensive coverage with edge cases
5. **Architecture**: Follows domain-driven design principles
6. **Documentation**: Clear API documentation and examples

### Review Timeline

- **Response**: Maintainers respond within 48 hours
- **Review**: Initial review within 1 week
- **Merge**: After approval and CI passes

## Release Process

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **Major** (1.0.0): Breaking API changes
- **Minor** (0.1.0): New features, backward compatible
- **Patch** (0.1.1): Bug fixes, backward compatible

### Release Checklist

- [ ] All tests pass
- [ ] Benchmarks show no regressions
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version bumped in pubspec.yaml
- [ ] Git tag created
- [ ] Published to pub.dev

## Getting Help

- **Questions**: Open a GitHub Discussion
- **Bugs**: File a GitHub Issue
- **Features**: Open a feature request issue
- **Chat**: Join our community discussions

## Recognition

All contributors will be recognized in:

- GitHub contributors list
- CHANGELOG.md for significant contributions
- README.md acknowledgments section

---

**Thank you for contributing to AlgoMate!** 🎉

Your contributions help make algorithmic programming more accessible and efficient for the Dart/Flutter community.
