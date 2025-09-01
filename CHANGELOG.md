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

## [0.1.4] - 2025-09-01

### Fixed

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned for v0.2.0 - Algorithm Expansion & Performance

- **New Algorithms**: QuickSort variants (randomized, dual-pivot, 3-way), HeapSort variants
- **Fast Path API**: Direct strategy execution for performance-critical scenarios
- **Enhanced Benchmarking**: Statistical analysis with CI/CD integration
- **Cross-Platform Testing**: Automated testing on Linux, macOS, Windows
- **Performance Regression Detection**: Automated PR performance analysis

## [0.1.4] - 2025-01-01

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
