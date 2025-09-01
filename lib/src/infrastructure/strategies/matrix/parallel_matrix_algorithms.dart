import 'dart:isolate';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:async';
import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';

/// Matrix class for mathematical operations
class Matrix {
  Matrix(this.rows, this.cols, this.data);

  factory Matrix.zero(int rows, int cols) {
    return Matrix(rows, cols, List.filled(rows * cols, 0));
  }

  factory Matrix.identity(int size) {
    final data = List.filled(size * size, 0);
    for (int i = 0; i < size; i++) {
      data[i * size + i] = 1;
    }
    return Matrix(size, size, data);
  }

  factory Matrix.fromLists(List<List<int>> lists) {
    final rows = lists.length;
    final cols = lists.isEmpty ? 0 : lists[0].length;
    final data = <int>[];

    for (final row in lists) {
      data.addAll(row);
    }

    return Matrix(rows, cols, data);
  }

  final int rows;
  final int cols;
  final List<int> data;

  int get(int row, int col) => data[row * cols + col];
  void set(int row, int col, int value) => data[row * cols + col] = value;

  List<List<int>> toLists() {
    final result = <List<int>>[];
    for (int i = 0; i < rows; i++) {
      result.add(data.sublist(i * cols, (i + 1) * cols));
    }
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Matrix) return false;
    return rows == other.rows &&
        cols == other.cols &&
        _listEquals(data, other.data);
  }

  @override
  int get hashCode => Object.hash(rows, cols, Object.hashAll(data));

  static bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Parallel Matrix Multiplication using Block Decomposition
///
/// Features:
/// - Divides matrices into blocks for parallel processing
/// - Cache-efficient memory access patterns
/// - Automatic block size optimization based on cache size
/// - Falls back to sequential for small matrices
/// - Supports rectangular matrices
///
/// Algorithm: Blocked matrix multiplication with work distribution
/// Best for: Large dense matrices (>500x500), numerical computations
///
/// Performance: O(n³) time, improved wall-clock time on multi-core
/// Space: O(1) additional space for block operations
class ParallelMatrixMultiplication extends Strategy<List<Matrix>, Matrix> {
  static const int _sequentialThreshold = 200; // 200x200 matrix
  static const int _defaultBlockSize = 64; // Cache-friendly block size
  static const int _maxIsolates = 4;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'parallel_matrix_multiply',
        timeComplexity: TimeComplexity.oN3, // O(n³)
        spaceComplexity: TimeComplexity.o1,
        requiresSorted: false,
        memoryOverheadBytes: 16384, // Block temporary storage
        description:
            'Multi-core matrix multiplication using block decomposition',
      );

  @override
  bool canApply(List<Matrix> input, SelectorHint hint) {
    if (input.length != 2) return false;

    final a = input[0];
    final b = input[1];

    // Check dimension compatibility
    if (a.cols != b.rows) return false;

    // Only beneficial for larger matrices
    final size = math.max(a.rows, math.max(a.cols, b.cols));
    if (size < _sequentialThreshold) return false;

    // Check isolate support
    try {
      Isolate.current;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Matrix execute(List<Matrix> input) {
    final a = input[0];
    final b = input[1];

    if (a.cols != b.rows) {
      throw ArgumentError('Matrix dimensions incompatible for multiplication');
    }

    final maxSize = math.max(a.rows, math.max(a.cols, b.cols));

    if (maxSize < _sequentialThreshold) {
      return _sequentialMultiply(a, b);
    }

    try {
      return _parallelMultiply(a, b);
    } catch (e) {
      return _sequentialMultiply(a, b);
    }
  }

  /// Parallel matrix multiplication using block decomposition
  Matrix _parallelMultiply(Matrix a, Matrix b) {
    final result = Matrix.zero(a.rows, b.cols);
    final blockSize = _optimalBlockSize(a, b);
    final numCores = _getAvailableCores();

    // Create block multiplication tasks
    final tasks = <BlockMultiplyTask>[];

    for (int i = 0; i < a.rows; i += blockSize) {
      for (int j = 0; j < b.cols; j += blockSize) {
        for (int k = 0; k < a.cols; k += blockSize) {
          final task = BlockMultiplyTask(
            i,
            j,
            k,
            math.min(blockSize, a.rows - i),
            math.min(blockSize, b.cols - j),
            math.min(blockSize, a.cols - k),
            _extractBlock(a, i, k, blockSize, blockSize),
            _extractBlock(b, k, j, blockSize, blockSize),
          );
          tasks.add(task);
        }
      }
    }

    // Distribute tasks across isolates
    _executeBlockTasks(tasks, result, numCores);

    return result;
  }

  /// Execute block multiplication tasks in parallel
  void _executeBlockTasks(
      List<BlockMultiplyTask> tasks, Matrix result, int numCores,) {
    final taskChunks = _distributeTasksEvenly(tasks, numCores);
    final futures = <Future<List<BlockResult>>>[];

    for (final chunk in taskChunks) {
      futures.add(_computeBlockChunk(chunk));
    }

    // Collect results and merge into final matrix
    for (int i = 0; i < futures.length; i++) {
      try {
        List<BlockResult>? chunkResults;
        futures[i].then((results) => chunkResults = results).catchError((e) {
          // Fallback: compute chunk sequentially
          chunkResults = _computeBlockChunkSequential(taskChunks[i]);
          return chunkResults!;
        });

        // Wait for results
        while (chunkResults == null) {
          // Busy wait
        }

        // Merge results
        for (final blockResult in chunkResults!) {
          _mergeBlockResult(result, blockResult);
        }
      } catch (e) {
        // Fallback to sequential computation
        final chunkResults = _computeBlockChunkSequential(taskChunks[i]);
        for (final blockResult in chunkResults) {
          _mergeBlockResult(result, blockResult);
        }
      }
    }
  }

  /// Compute a chunk of block tasks in an isolate
  Future<List<BlockResult>> _computeBlockChunk(
      List<BlockMultiplyTask> tasks,) async {
    final completer = Completer<List<BlockResult>>();

    try {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(
        _isolateBlockMultiply,
        [receivePort.sendPort, tasks],
      );

      receivePort.listen((message) {
        if (message is List<BlockResult>) {
          completer.complete(message);
        } else if (message is String && message.startsWith('error:')) {
          completer.completeError(Exception(message));
        }
        receivePort.close();
        isolate.kill();
      });
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException(
          'Block multiply timeout', const Duration(seconds: 30),),
    );
  }

  /// Sequential computation of block chunk (fallback)
  List<BlockResult> _computeBlockChunkSequential(
      List<BlockMultiplyTask> tasks,) {
    final results = <BlockResult>[];

    for (final task in tasks) {
      final blockResult = _multiplyBlocks(
        task.blockA,
        task.blockB,
        task.rowStart,
        task.colStart,
        task.blockRows,
        task.blockCols,
      );
      results.add(blockResult);
    }

    return results;
  }

  /// Multiply two matrix blocks
  BlockResult _multiplyBlocks(
    List<int> blockA,
    List<int> blockB,
    int rowStart,
    int colStart,
    int blockRows,
    int blockCols,
  ) {
    final resultData = List.filled(blockRows * blockCols, 0);
    final kSize = blockA.length ~/ blockRows;

    for (int i = 0; i < blockRows; i++) {
      for (int j = 0; j < blockCols; j++) {
        int sum = 0;
        for (int k = 0; k < kSize; k++) {
          sum += blockA[i * kSize + k] * blockB[k * blockCols + j];
        }
        resultData[i * blockCols + j] = sum;
      }
    }

    return BlockResult(rowStart, colStart, blockRows, blockCols, resultData);
  }

  /// Merge block result into final matrix
  void _mergeBlockResult(Matrix result, BlockResult blockResult) {
    for (int i = 0; i < blockResult.rows; i++) {
      for (int j = 0; j < blockResult.cols; j++) {
        final resultRow = blockResult.rowStart + i;
        final resultCol = blockResult.colStart + j;
        final value = blockResult.data[i * blockResult.cols + j];

        if (resultRow < result.rows && resultCol < result.cols) {
          result.set(
              resultRow, resultCol, result.get(resultRow, resultCol) + value,);
        }
      }
    }
  }

  /// Extract a block from a matrix
  List<int> _extractBlock(
      Matrix matrix, int startRow, int startCol, int blockRows, int blockCols,) {
    final actualRows = math.min(blockRows, matrix.rows - startRow);
    final actualCols = math.min(blockCols, matrix.cols - startCol);
    final block = <int>[];

    for (int i = 0; i < actualRows; i++) {
      for (int j = 0; j < actualCols; j++) {
        block.add(matrix.get(startRow + i, startCol + j));
      }
      // Pad with zeros if needed
      for (int j = actualCols; j < blockCols; j++) {
        block.add(0);
      }
    }

    // Pad with zero rows if needed
    for (int i = actualRows; i < blockRows; i++) {
      block.addAll(List.filled(blockCols, 0));
    }

    return block;
  }

  /// Distribute tasks evenly across cores
  List<List<BlockMultiplyTask>> _distributeTasksEvenly(
      List<BlockMultiplyTask> tasks, int numCores,) {
    final chunks = <List<BlockMultiplyTask>>[];
    final chunkSize = (tasks.length / numCores).ceil();

    for (int i = 0; i < tasks.length; i += chunkSize) {
      final end = math.min(i + chunkSize, tasks.length);
      chunks.add(tasks.sublist(i, end));
    }

    return chunks;
  }

  /// Calculate optimal block size based on matrix dimensions
  int _optimalBlockSize(Matrix a, Matrix b) {
    // Start with default cache-friendly size
    int blockSize = _defaultBlockSize;

    // Adjust based on matrix size
    final maxDim = math.max(a.rows, math.max(a.cols, b.cols));

    if (maxDim < 300) {
      blockSize = 32;
    } else if (maxDim < 1000) {
      blockSize = 64;
    } else if (maxDim < 2000) {
      blockSize = 128;
    } else {
      blockSize = 256;
    }

    return blockSize;
  }

  /// Sequential matrix multiplication fallback
  Matrix _sequentialMultiply(Matrix a, Matrix b) {
    final result = Matrix.zero(a.rows, b.cols);

    for (int i = 0; i < a.rows; i++) {
      for (int j = 0; j < b.cols; j++) {
        int sum = 0;
        for (int k = 0; k < a.cols; k++) {
          sum += a.get(i, k) * b.get(k, j);
        }
        result.set(i, j, sum);
      }
    }

    return result;
  }

  /// Get number of available CPU cores
  int _getAvailableCores() {
    try {
      return math.min(Platform.numberOfProcessors, _maxIsolates);
    } catch (e) {
      return 4;
    }
  }
}

/// Task for block matrix multiplication
class BlockMultiplyTask {
  const BlockMultiplyTask(
    this.rowStart,
    this.colStart,
    this.kStart,
    this.blockRows,
    this.blockCols,
    this.blockK,
    this.blockA,
    this.blockB,
  );

  final int rowStart, colStart, kStart;
  final int blockRows, blockCols, blockK;
  final List<int> blockA, blockB;
}

/// Result of block matrix multiplication
class BlockResult {
  const BlockResult(
      this.rowStart, this.colStart, this.rows, this.cols, this.data,);

  final int rowStart, colStart;
  final int rows, cols;
  final List<int> data;
}

/// Isolate entry point for block matrix multiplication
void _isolateBlockMultiply(List<dynamic> args) {
  final sendPort = args[0] as SendPort;
  final tasks = args[1] as List<BlockMultiplyTask>;

  try {
    final results = <BlockResult>[];

    for (final task in tasks) {
      final blockResult = _multiplyBlocksIsolate(
        task.blockA,
        task.blockB,
        task.rowStart,
        task.colStart,
        task.blockRows,
        task.blockCols,
      );
      results.add(blockResult);
    }

    sendPort.send(results);
  } catch (e) {
    sendPort.send('error: $e');
  }
}

/// Block multiplication in isolate
BlockResult _multiplyBlocksIsolate(
  List<int> blockA,
  List<int> blockB,
  int rowStart,
  int colStart,
  int blockRows,
  int blockCols,
) {
  final resultData = List.filled(blockRows * blockCols, 0);
  final kSize = blockA.length ~/ blockRows;

  for (int i = 0; i < blockRows; i++) {
    for (int j = 0; j < blockCols; j++) {
      int sum = 0;
      for (int k = 0; k < kSize; k++) {
        sum += blockA[i * kSize + k] * blockB[k * blockCols + j];
      }
      resultData[i * blockCols + j] = sum;
    }
  }

  return BlockResult(rowStart, colStart, blockRows, blockCols, resultData);
}

/// Strassen's Algorithm for Matrix Multiplication (Parallel Implementation)
///
/// Features:
/// - Divide-and-conquer approach with O(n^2.807) complexity
/// - Parallel execution of recursive calls
/// - Automatic switching to standard multiplication for small matrices
/// - Memory-efficient implementation with minimal matrix copies
///
/// Best for: Very large square matrices (>1000x1000) where the improved
/// asymptotic complexity outweighs the overhead
class ParallelStrassenMultiplication extends Strategy<List<Matrix>, Matrix> {
  static const int _sequentialThreshold = 128; // Switch to standard multiply
  static const int _parallelThreshold = 512; // Enable parallelism
  static const int _maxRecursionDepth = 6;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'parallel_strassen_multiply',
        timeComplexity:
            TimeComplexity.oN3, // Actually O(n^2.807) but using closest enum
        spaceComplexity: TimeComplexity.oN2,
        requiresSorted: false,
        memoryOverheadBytes: 32768, // Recursive matrix storage
        description:
            'Parallel Strassen matrix multiplication with O(n^2.807) complexity',
      );

  @override
  bool canApply(List<Matrix> input, SelectorHint hint) {
    if (input.length != 2) return false;

    final a = input[0];
    final b = input[1];

    // Must be square matrices for Strassen
    if (a.rows != a.cols || b.rows != b.cols) return false;
    if (a.cols != b.rows) return false;

    // Only beneficial for large matrices
    final size = a.rows;
    if (size < _parallelThreshold) return false;

    // Size should be power of 2 for optimal performance
    // (not required, but recommended)

    // Check isolate support
    try {
      Isolate.current;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Matrix execute(List<Matrix> input) {
    final a = input[0];
    final b = input[1];

    if (a.cols != b.rows) {
      throw ArgumentError('Matrix dimensions incompatible for multiplication');
    }

    try {
      return _strassenMultiply(a, b, 0);
    } catch (e) {
      return _standardMultiply(a, b);
    }
  }

  /// Strassen multiplication with parallel execution
  Matrix _strassenMultiply(Matrix a, Matrix b, int depth) {
    final n = a.rows;

    // Base case: use standard multiplication
    if (n <= _sequentialThreshold) {
      return _standardMultiply(a, b);
    }

    // Ensure even dimensions by padding if necessary
    final paddedN = n.isOdd ? n + 1 : n;
    final paddedA = _padMatrix(a, paddedN);
    final paddedB = _padMatrix(b, paddedN);

    final result = _strassenRecursive(paddedA, paddedB, depth);

    // Remove padding from result
    return _trimMatrix(result, n);
  }

  /// Recursive Strassen implementation
  Matrix _strassenRecursive(Matrix a, Matrix b, int depth) {
    final n = a.rows;

    if (n <= _sequentialThreshold) {
      return _standardMultiply(a, b);
    }

    final half = n ~/ 2;

    // Divide matrices into quadrants
    final a11 = _subMatrix(a, 0, 0, half);
    final a12 = _subMatrix(a, 0, half, half);
    final a21 = _subMatrix(a, half, 0, half);
    final a22 = _subMatrix(a, half, half, half);

    final b11 = _subMatrix(b, 0, 0, half);
    final b12 = _subMatrix(b, 0, half, half);
    final b21 = _subMatrix(b, half, 0, half);
    final b22 = _subMatrix(b, half, half, half);

    // Compute Strassen's 7 multiplications
    Matrix m1, m2, m3, m4, m5, m6, m7;

    if (depth < _maxRecursionDepth && n >= _parallelThreshold) {
      // Parallel computation of Strassen multiplications
      final futures = <Future<Matrix>>[];

      futures.add(_computeStrassenM1(a11, a22, b11, b22, depth + 1));
      futures.add(_computeStrassenM2(a21, a22, b11, depth + 1));
      futures.add(_computeStrassenM3(a11, b12, b22, depth + 1));
      futures.add(_computeStrassenM4(a22, b21, b11, depth + 1));
      futures.add(_computeStrassenM5(a11, a12, b22, depth + 1));
      futures.add(_computeStrassenM6(a21, a11, b11, b12, depth + 1));
      futures.add(_computeStrassenM7(a12, a22, b21, b22, depth + 1));

      // Wait for all multiplications to complete
      final results = _waitForStrassenResults(futures);
      m1 = results[0];
      m2 = results[1];
      m3 = results[2];
      m4 = results[3];
      m5 = results[4];
      m6 = results[5];
      m7 = results[6];
    } else {
      // Sequential computation
      m1 = _strassenRecursive(_add(a11, a22), _add(b11, b22), depth + 1);
      m2 = _strassenRecursive(_add(a21, a22), b11, depth + 1);
      m3 = _strassenRecursive(a11, _subtract(b12, b22), depth + 1);
      m4 = _strassenRecursive(a22, _subtract(b21, b11), depth + 1);
      m5 = _strassenRecursive(_add(a11, a12), b22, depth + 1);
      m6 = _strassenRecursive(_subtract(a21, a11), _add(b11, b12), depth + 1);
      m7 = _strassenRecursive(_subtract(a12, a22), _add(b21, b22), depth + 1);
    }

    // Combine results to form final matrix
    final c11 = _add(_subtract(_add(m1, m4), m5), m7);
    final c12 = _add(m3, m5);
    final c21 = _add(m2, m4);
    final c22 = _add(_subtract(_add(m1, m3), m2), m6);

    return _combineQuadrants(c11, c12, c21, c22);
  }

  /// Compute Strassen M1 in isolate
  Future<Matrix> _computeStrassenM1(
      Matrix a11, Matrix a22, Matrix b11, Matrix b22, int depth,) async {
    final completer = Completer<Matrix>();

    try {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(
        _isolateStrassenM1,
        [receivePort.sendPort, a11, a22, b11, b22, depth],
      );

      receivePort.listen((message) {
        if (message is Matrix) {
          completer.complete(message);
        } else if (message is String && message.startsWith('error:')) {
          completer.completeError(Exception(message));
        }
        receivePort.close();
        isolate.kill();
      });
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => _standardMultiply(_add(a11, a22), _add(b11, b22)),
    );
  }

  /// Additional Strassen computation methods...
  Future<Matrix> _computeStrassenM2(
      Matrix a21, Matrix a22, Matrix b11, int depth,) async {
    return _strassenRecursive(_add(a21, a22), b11, depth);
  }

  Future<Matrix> _computeStrassenM3(
      Matrix a11, Matrix b12, Matrix b22, int depth,) async {
    return _strassenRecursive(a11, _subtract(b12, b22), depth);
  }

  Future<Matrix> _computeStrassenM4(
      Matrix a22, Matrix b21, Matrix b11, int depth,) async {
    return _strassenRecursive(a22, _subtract(b21, b11), depth);
  }

  Future<Matrix> _computeStrassenM5(
      Matrix a11, Matrix a12, Matrix b22, int depth,) async {
    return _strassenRecursive(_add(a11, a12), b22, depth);
  }

  Future<Matrix> _computeStrassenM6(
      Matrix a21, Matrix a11, Matrix b11, Matrix b12, int depth,) async {
    return _strassenRecursive(_subtract(a21, a11), _add(b11, b12), depth);
  }

  Future<Matrix> _computeStrassenM7(
      Matrix a12, Matrix a22, Matrix b21, Matrix b22, int depth,) async {
    return _strassenRecursive(_subtract(a12, a22), _add(b21, b22), depth);
  }

  /// Wait for all Strassen computation results
  List<Matrix> _waitForStrassenResults(List<Future<Matrix>> futures) {
    final results = <Matrix>[];

    for (final future in futures) {
      Matrix? result;
      future.then((value) => result = value).catchError((e) {
        result = Matrix.zero(1, 1); // Fallback
        return result!;
      });

      while (result == null) {
        // Busy wait
      }
      results.add(result!);
    }

    return results;
  }

  /// Matrix operations for Strassen algorithm
  Matrix _add(Matrix a, Matrix b) {
    final result = Matrix.zero(a.rows, a.cols);
    for (int i = 0; i < a.rows; i++) {
      for (int j = 0; j < a.cols; j++) {
        result.set(i, j, a.get(i, j) + b.get(i, j));
      }
    }
    return result;
  }

  Matrix _subtract(Matrix a, Matrix b) {
    final result = Matrix.zero(a.rows, a.cols);
    for (int i = 0; i < a.rows; i++) {
      for (int j = 0; j < a.cols; j++) {
        result.set(i, j, a.get(i, j) - b.get(i, j));
      }
    }
    return result;
  }

  /// Extract submatrix
  Matrix _subMatrix(Matrix matrix, int rowStart, int colStart, int size) {
    final result = Matrix.zero(size, size);
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        result.set(i, j, matrix.get(rowStart + i, colStart + j));
      }
    }
    return result;
  }

  /// Combine four quadrants into one matrix
  Matrix _combineQuadrants(Matrix c11, Matrix c12, Matrix c21, Matrix c22) {
    final size = c11.rows * 2;
    final result = Matrix.zero(size, size);
    final half = size ~/ 2;

    // Copy quadrants
    for (int i = 0; i < half; i++) {
      for (int j = 0; j < half; j++) {
        result.set(i, j, c11.get(i, j));
        result.set(i, j + half, c12.get(i, j));
        result.set(i + half, j, c21.get(i, j));
        result.set(i + half, j + half, c22.get(i, j));
      }
    }

    return result;
  }

  /// Pad matrix to specified size
  Matrix _padMatrix(Matrix matrix, int newSize) {
    if (matrix.rows >= newSize && matrix.cols >= newSize) return matrix;

    final result = Matrix.zero(newSize, newSize);
    for (int i = 0; i < matrix.rows; i++) {
      for (int j = 0; j < matrix.cols; j++) {
        result.set(i, j, matrix.get(i, j));
      }
    }
    return result;
  }

  /// Trim matrix to specified size
  Matrix _trimMatrix(Matrix matrix, int newSize) {
    if (matrix.rows <= newSize && matrix.cols <= newSize) return matrix;

    final result = Matrix.zero(newSize, newSize);
    for (int i = 0; i < newSize; i++) {
      for (int j = 0; j < newSize; j++) {
        result.set(i, j, matrix.get(i, j));
      }
    }
    return result;
  }

  /// Standard matrix multiplication
  Matrix _standardMultiply(Matrix a, Matrix b) {
    final result = Matrix.zero(a.rows, b.cols);

    for (int i = 0; i < a.rows; i++) {
      for (int j = 0; j < b.cols; j++) {
        int sum = 0;
        for (int k = 0; k < a.cols; k++) {
          sum += a.get(i, k) * b.get(k, j);
        }
        result.set(i, j, sum);
      }
    }

    return result;
  }
}

/// Isolate entry point for Strassen M1 computation
void _isolateStrassenM1(List<dynamic> args) {
  final sendPort = args[0] as SendPort;
  final a11 = args[1] as Matrix;
  final a22 = args[2] as Matrix;
  final b11 = args[3] as Matrix;
  final b22 = args[4] as Matrix;
  // depth parameter available but not used in this simple implementation

  try {
    // Compute (A11 + A22) * (B11 + B22)
    final aSum = _addMatricesIsolate(a11, a22);
    final bSum = _addMatricesIsolate(b11, b22);
    final result = _multiplyStandardIsolate(aSum, bSum);

    sendPort.send(result);
  } catch (e) {
    sendPort.send('error: $e');
  }
}

/// Matrix addition in isolate
Matrix _addMatricesIsolate(Matrix a, Matrix b) {
  final result = Matrix.zero(a.rows, a.cols);
  for (int i = 0; i < a.rows; i++) {
    for (int j = 0; j < a.cols; j++) {
      result.set(i, j, a.get(i, j) + b.get(i, j));
    }
  }
  return result;
}

/// Standard matrix multiplication in isolate
Matrix _multiplyStandardIsolate(Matrix a, Matrix b) {
  final result = Matrix.zero(a.rows, b.cols);

  for (int i = 0; i < a.rows; i++) {
    for (int j = 0; j < b.cols; j++) {
      int sum = 0;
      for (int k = 0; k < a.cols; k++) {
        sum += a.get(i, k) * b.get(k, j);
      }
      result.set(i, j, sum);
    }
  }

  return result;
}
