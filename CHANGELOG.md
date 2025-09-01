# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- QuickSort algorithm implementation
- HeapSort algorithm implementation
- Enhanced error handling with sealed classes
- Performance regression testing
- Contract testing for mocks
- Memory usage tracking and limits
- Fallback mechanisms for strategy failures

### Changed

- Improved async support integration
- Enhanced documentation coverage

## [0.1.0] - 2025-09-01

### Added

- 🎯 **Intelligent Algorithm Selection**: Context-aware strategy selection based on data characteristics
- ⚡ **Performance-Focused Architecture**: Zero-allocation hot paths with traditional loops
- 🏗️ **Clean Architecture Implementation**: Complete DDD + Clean Architecture with 4 distinct layers
- 📊 **Built-in Algorithm Library**:
  - 6 sorting strategies (InsertionSort, InPlaceInsertionSort, BinaryInsertionSort, MergeSort, IterativeMergeSort, HybridMergeSort)
  - 2 search strategies (LinearSearch, BinarySearch)
- 🔧 **Comprehensive Infrastructure**:
  - Statistical benchmarking with `HarnessBenchmarkRunner`, `SimpleBenchmarkRunner`, `MockBenchmarkRunner`
  - Isolate execution with `DartIsolateExecutor`, `StubIsolateExecutor`, `MockIsolateExecutor`
  - Flexible logging with `ConsoleLogger`, `SilentLogger`, `BufferedLogger`
- 🧪 **Production-Ready Features**:
  - Functional error handling with `Result<T, Failure>` pattern
  - Resource management for isolate execution
  - Configurable logging levels and statistics
- 🔄 **Advanced Capabilities**:
  - CPU-intensive operations in isolates with timeout support
  - Performance measurement and comparison tools
  - Custom strategy registration system
- 📝 **Developer Experience**:
  - Simple facade API (`AlgoSelectorFacade.development()`)
  - Builder pattern configuration (`AlgoMate.createSelector()`)
  - Comprehensive documentation and examples
  - Type-safe strategy storage and execution

### Technical Details

- **Architecture**: Domain-Driven Design with Clean Architecture principles
- **Layers**: Domain (6 files), Application (4 files), Infrastructure (10 files), Interface (2 files)
- **Dependencies**: Flutter, Meta for annotations
- **Development Dependencies**: Flutter Test, Benchmark Harness, Flutter Lints
- **Total Files**: 25 implementation files
- **Test Coverage**: Basic unit tests with integration scenarios
- **Performance**: Optimized for speed with zero-allocation hot paths

### Breaking Changes

- N/A (Initial release)

### Deprecated

- N/A (Initial release)

### Removed

- N/A (Initial release)

### Fixed

- N/A (Initial release)

### Security

- N/A (Initial release)
