import 'dart:math' as math;
import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';

/// Matrix class for web compatibility
class Matrix {
  Matrix(this.rows, this.cols)
      : data = List.generate(rows, (_) => List.filled(cols, 0.0));

  Matrix.fromLists(List<List<num>> lists)
      : rows = lists.length,
        cols = lists.isEmpty ? 0 : lists[0].length,
        data =
            lists.map((row) => row.map((x) => x.toDouble()).toList()).toList();
  final List<List<double>> data;
  final int rows;
  final int cols;

  double get(int row, int col) => data[row][col];
  void set(int row, int col, double value) => data[row][col] = value;

  @override
  String toString() => data.map((row) => row.toString()).join('\n');
}

/// Web-compatible parallel matrix multiplication (falls back to sequential)
///
/// Features:
/// - Falls back to sequential block-based multiplication on web platform
/// - No isolate usage (web limitation)
/// - Uses cache-friendly block algorithm
///
/// Best for: Medium to large matrix multiplication on web platform
///
/// Performance: O(n³) time, sequential execution
/// Space: O(n²) for result matrix
class ParallelMatrixMultiplication extends Strategy<List<Matrix>, Matrix> {
  static const int _blockSize = 64;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'parallel_matrix_multiplication_web',
        timeComplexity: TimeComplexity.oN3,
        spaceComplexity: TimeComplexity.oN2,
        description:
            'Web-compatible block-based matrix multiplication with sequential fallback',
      );

  @override
  bool canApply(List<Matrix> input, SelectorHint hint) {
    if (input.length != 2) return false;
    final a = input[0];
    final b = input[1];
    return a.cols == b.rows && a.rows > 10 && b.cols > 10;
  }

  @override
  Matrix execute(List<Matrix> input) {
    final a = input[0];
    final b = input[1];

    if (a.cols != b.rows) {
      throw ArgumentError(
        'Matrix dimensions incompatible: ${a.rows}x${a.cols} * ${b.rows}x${b.cols}',
      );
    }

    final result = Matrix(a.rows, b.cols);

    // Block-based multiplication for cache efficiency
    for (int i = 0; i < a.rows; i += _blockSize) {
      for (int j = 0; j < b.cols; j += _blockSize) {
        for (int k = 0; k < a.cols; k += _blockSize) {
          _multiplyBlock(
            a,
            b,
            result,
            i,
            j,
            k,
            math.min(i + _blockSize, a.rows),
            math.min(j + _blockSize, b.cols),
            math.min(k + _blockSize, a.cols),
          );
        }
      }
    }

    return result;
  }

  void _multiplyBlock(
    Matrix a,
    Matrix b,
    Matrix result,
    int startI,
    int startJ,
    int startK,
    int endI,
    int endJ,
    int endK,
  ) {
    for (int i = startI; i < endI; i++) {
      for (int j = startJ; j < endJ; j++) {
        double sum = result.get(i, j);
        for (int k = startK; k < endK; k++) {
          sum += a.get(i, k) * b.get(k, j);
        }
        result.set(i, j, sum);
      }
    }
  }
}

/// Web-compatible parallel Strassen multiplication (falls back to sequential)
///
/// Features:
/// - Falls back to sequential Strassen algorithm on web platform
/// - No isolate usage (web limitation)
/// - Uses divide-and-conquer approach
///
/// Best for: Large square matrix multiplication on web platform
///
/// Performance: O(n^2.807) time, sequential execution
/// Space: O(n²) for temporary matrices
class ParallelStrassenMultiplication extends Strategy<List<Matrix>, Matrix> {
  static const int _sequentialThreshold = 64;

  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'parallel_strassen_multiplication_web',
        timeComplexity:
            TimeComplexity.oNLogN, // Using closest available enum value
        spaceComplexity: TimeComplexity.oN2,
        description:
            'Web-compatible Strassen matrix multiplication with sequential fallback',
      );

  @override
  bool canApply(List<Matrix> input, SelectorHint hint) {
    if (input.length != 2) return false;
    final a = input[0];
    final b = input[1];
    // Strassen works best for square matrices and large sizes
    return a.rows == a.cols &&
        b.rows == b.cols &&
        a.rows == b.rows &&
        a.rows >= 128;
  }

  @override
  Matrix execute(List<Matrix> input) {
    final a = input[0];
    final b = input[1];

    if (a.cols != b.rows) {
      throw ArgumentError(
        'Matrix dimensions incompatible: ${a.rows}x${a.cols} * ${b.rows}x${b.cols}',
      );
    }

    return _strassenMultiply(a, b);
  }

  Matrix _strassenMultiply(Matrix a, Matrix b) {
    final n = a.rows;

    if (n <= _sequentialThreshold) {
      return _standardMultiply(a, b);
    }

    final mid = n ~/ 2;

    // Divide matrices into quadrants
    final a11 = _subMatrix(a, 0, 0, mid, mid);
    final a12 = _subMatrix(a, 0, mid, mid, n);
    final a21 = _subMatrix(a, mid, 0, n, mid);
    final a22 = _subMatrix(a, mid, mid, n, n);

    final b11 = _subMatrix(b, 0, 0, mid, mid);
    final b12 = _subMatrix(b, 0, mid, mid, n);
    final b21 = _subMatrix(b, mid, 0, n, mid);
    final b22 = _subMatrix(b, mid, mid, n, n);

    // Calculate the 7 products
    final m1 = _strassenMultiply(_add(a11, a22), _add(b11, b22));
    final m2 = _strassenMultiply(_add(a21, a22), b11);
    final m3 = _strassenMultiply(a11, _subtract(b12, b22));
    final m4 = _strassenMultiply(a22, _subtract(b21, b11));
    final m5 = _strassenMultiply(_add(a11, a12), b22);
    final m6 = _strassenMultiply(_subtract(a21, a11), _add(b11, b12));
    final m7 = _strassenMultiply(_subtract(a12, a22), _add(b21, b22));

    // Calculate result quadrants
    final c11 = _add(_subtract(_add(m1, m4), m5), m7);
    final c12 = _add(m3, m5);
    final c21 = _add(m2, m4);
    final c22 = _add(_subtract(_add(m1, m3), m2), m6);

    // Combine result
    return _combineMatrices(c11, c12, c21, c22);
  }

  Matrix _standardMultiply(Matrix a, Matrix b) {
    final result = Matrix(a.rows, b.cols);
    for (int i = 0; i < a.rows; i++) {
      for (int j = 0; j < b.cols; j++) {
        double sum = 0.0;
        for (int k = 0; k < a.cols; k++) {
          sum += a.get(i, k) * b.get(k, j);
        }
        result.set(i, j, sum);
      }
    }
    return result;
  }

  Matrix _subMatrix(
    Matrix matrix,
    int startRow,
    int startCol,
    int endRow,
    int endCol,
  ) {
    final result = Matrix(endRow - startRow, endCol - startCol);
    for (int i = 0; i < result.rows; i++) {
      for (int j = 0; j < result.cols; j++) {
        result.set(i, j, matrix.get(startRow + i, startCol + j));
      }
    }
    return result;
  }

  Matrix _add(Matrix a, Matrix b) {
    final result = Matrix(a.rows, a.cols);
    for (int i = 0; i < a.rows; i++) {
      for (int j = 0; j < a.cols; j++) {
        result.set(i, j, a.get(i, j) + b.get(i, j));
      }
    }
    return result;
  }

  Matrix _subtract(Matrix a, Matrix b) {
    final result = Matrix(a.rows, a.cols);
    for (int i = 0; i < a.rows; i++) {
      for (int j = 0; j < a.cols; j++) {
        result.set(i, j, a.get(i, j) - b.get(i, j));
      }
    }
    return result;
  }

  Matrix _combineMatrices(Matrix c11, Matrix c12, Matrix c21, Matrix c22) {
    final result = Matrix(c11.rows + c21.rows, c11.cols + c12.cols);

    // Copy c11
    for (int i = 0; i < c11.rows; i++) {
      for (int j = 0; j < c11.cols; j++) {
        result.set(i, j, c11.get(i, j));
      }
    }

    // Copy c12
    for (int i = 0; i < c12.rows; i++) {
      for (int j = 0; j < c12.cols; j++) {
        result.set(i, c11.cols + j, c12.get(i, j));
      }
    }

    // Copy c21
    for (int i = 0; i < c21.rows; i++) {
      for (int j = 0; j < c21.cols; j++) {
        result.set(c11.rows + i, j, c21.get(i, j));
      }
    }

    // Copy c22
    for (int i = 0; i < c22.rows; i++) {
      for (int j = 0; j < c22.cols; j++) {
        result.set(c11.rows + i, c11.cols + j, c22.get(i, j));
      }
    }

    return result;
  }
}
