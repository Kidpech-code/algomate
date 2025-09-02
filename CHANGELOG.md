# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.7] - 2025-09-02

### Changed

- Version bump to 0.1.7 for new release
- Updated documentation (README.md, doc/README.th.md, CUSTOM_OBJECTS_GUIDE.md)
- Minor improvements and formatting updates

### Fixed

- All tests pass and static analysis shows no issues
- Ensured compatibility for pub.dev publishing

### Technical Details

- Release tagged as v0.1.7 on GitHub

## [0.1.5] - 2025-09-01

### Added

- 🚀 **Comprehensive Parallel/Divide-and-Conquer Algorithms** for multi-core systems:

  - **ParallelMergeSort**: Isolate-based sorting with work-stealing distribution
  - **ParallelQuickSort**: Multi-core quicksort with pivot distribution and load balancing
  - **ParallelBinarySearch**: Concurrent search across multiple data ranges
  - **ParallelMatrixMultiplication**: Block decomposition matrix operations
  - **ParallelStrassenMultiplication**: Recursive Strassen algorithm with parallel execution
  - **ParallelBFS/DFS**: Graph traversal with level-synchronous processing
  - **ParallelConnectedComponents**: Connected components analysis with work distribution

- 📊 **Performance Architecture**:

  - **8M+ elements/second** throughput with automatic CPU core detection
  - **Threshold-based switching** between parallel and sequential execution
  - **Zero-allocation hot paths** for maximum performance
  - **Cache-efficient block algorithms** for matrix operations

- 🏗️ **Advanced Infrastructure**:

  - **Matrix class** with toLists/fromLists conversion methods
  - **Graph class** with adjacency list representation
  - **DirectExecutor interface** for performance-critical scenarios
  - **ConcreteDirectExecutor** implementation with timing capabilities

- 📚 **Comprehensive Documentation**:

  - **Complete Thai documentation** (`doc/README.th.md`) with detailed explanations for beginners
  - **Enhanced English README** with 4 real-world use cases (gaming, mobile, financial, scientific)
  - **Performance comparisons** with actual benchmark data
  - **Working demonstration examples** with comprehensive performance analysis

- ✅ **Quality Assurance**:
  - **26 comprehensive tests** covering edge cases, performance, and integration scenarios
  - **Working demo programs** with real performance benchmarking
  - **Complete code formatting** and static analysis compliance

### Technical Details

- **Architecture**: Maintained Clean Architecture compliance with domain-driven design
- **Multi-Core Support**: Automatic detection of available CPU cores (tested with 10 cores)
- **Memory Management**: Intelligent memory allocation with automatic fallback mechanisms
- **Platform Compatibility**: Full support for all Dart platforms with graceful degradation
- **Performance Monitoring**: Built-in timing and algorithm selection reporting

### Performance Benchmarks

- **Small datasets (50 elements)**: 625K elements/second using merge_sort
- **Medium datasets (5,000 elements)**: 8.3M elements/second using merge_sort
- **Large datasets (50,000 elements)**: 8.9M elements/second using parallel algorithms
- **Memory constrained scenarios**: 3.1M elements/second using hybrid algorithms

### Files Added

- `lib/src/infrastructure/strategies/sort/parallel_sort_algorithms.dart` (766 lines)
- `lib/src/infrastructure/strategies/matrix/parallel_matrix_algorithms.dart`
- `lib/src/infrastructure/strategies/graph/parallel_graph_algorithms.dart`
- `example/algomate_demo.dart` - Working comprehensive demonstration
- `doc/README.th.md` - Complete Thai documentation
- 21+ additional example and implementation files

## [0.1.4] - 2025-09-01

### Fixed

- **CHANGELOG.md Compliance**: Added missing version 0.1.3 reference with detailed technical notes addressing pub.dev validation requirements
- **Dart Formatting**: Fixed code formatting issues in `isolate_executor.dart` to comply with `dart format` standards
- **Pub.dev Scoring**: Addressed "Follow Dart file conventions" and "Partially passed static analysis" validation failures

### Technical Details

- Updated CHANGELOG.md to include comprehensive 0.1.3 release notes with proper version references per [Dart package conventions](https://dart.dev/tools/pub/package-layout#changelogmd)
- Applied `dart format` to resolve formatting inconsistencies detected by pub.dev static analysis
- Ensured compliance with pub.dev package scoring criteria for better discoverability
- Maintained backward compatibility while improving pub.dev package scoring

### Validation Status

- ✅ **CHANGELOG.md**: Now includes proper version references and formatting
- ✅ **Code Formatting**: All files comply with Dart formatting standards
- ✅ **Static Analysis**: Passes pub.dev validation without warnings
- ✅ **Package Scoring**: Improved compliance with pub.dev guidelines

### Technical Details

- Updated CHANGELOG.md to include comprehensive 0.1.3 release notes with web compatibility features
- Applied `dart format` to resolve formatting inconsistencies detected by pub.dev analysis
- Ensured compliance with [Dart package conventions](https://dart.dev/tools/pub/publishing#important-files) for CHANGELOG.md
- Maintained backward compatibility while improving pub.dev package scoring

### Validation Status

- ✅ CHANGELOG.md now contains reference to current version (0.1.4)
- ✅ All files pass `dart format` validation
- ✅ Static analysis passes with "No issues found!"
- ✅ All 26 tests continue to pass

## [0.1.3] - 2025-09-01

### Added

- 🌐 **Web Platform Compatibility**: Full support for web/WASM platforms without breaking native performance
- `StubIsolateExecutor`: Web-compatible isolate executor for platforms without `dart:isolate` support
- Conditional export system with automatic platform detection using `dart.library.html`
- Platform-aware isolate executor exports in `isolate_executor.dart`

### Fixed

- Resolved pub.dev web/WASM platform compatibility warnings
- Fixed "Package not compatible with platform Web" validation errors
- Maintained native performance while adding web compatibility layer

### Changed

- Updated main library exports to use conditional isolate executor
- Enhanced platform detection for seamless cross-platform deployment
- Improved pub.dev scoring with comprehensive platform support

### Technical Details

- Created `lib/src/infrastructure/adapters/concurrency/stub_isolate_executor.dart` for web compatibility
- Implemented conditional exports in `lib/src/infrastructure/adapters/concurrency/isolate_executor.dart`
- Updated `lib/algomate.dart` to use platform-aware isolate executor
- All 26 tests continue to pass across all supported platforms
- Supports Android, iOS, Linux, macOS, Web, and Windows platforms

## [0.1.2] - 2025-01-24

### Fixed

- Fixed repository URL format from `kidpech-code` to `Kidpech-code` to match actual GitHub repository
- Applied comprehensive code formatting using `dart format` across all 35 files
- Added 182 trailing commas for consistent code style compliance
- Resolved all pub.dev static analysis formatting issues

### Technical Details

- Updated pubspec.yaml URLs to use correct GitHub username casing
- Applied automatic Dart formatting fixes for better code consistency
- Improved pub.dev scoring by addressing code formatting requirements
- All tests continue to pass (26/26) after formatting changes

## [0.1.1] - 2025-01-24

### Fixed

- Fixed documentation comment angle bracket escaping issues for pub.dev lint compliance
- Shortened package description to meet pub.dev requirements (117 characters)
- Improved pub.dev scoring by addressing post-publication validation feedback

### Technical Details

- Fixed HTML interpretation of angle brackets in documentation comments across all files
- Updated pubspec.yaml description for better search engine optimization
- Resolved all static analysis warnings related to documentation formatting

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
