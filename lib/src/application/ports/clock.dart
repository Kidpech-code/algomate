/// Clock port for time-related operations.
///
/// Abstraction over time measurement to enable testing and
/// consistent timing across different platforms.
abstract class Clock {
  /// Get the current timestamp in milliseconds since epoch
  int get currentTimeMillis;

  /// Get the current timestamp in microseconds since epoch
  int get currentTimeMicros;

  /// Create a stopwatch for measuring elapsed time
  Stopwatch createStopwatch();
}

/// Default system clock implementation
class SystemClock implements Clock {
  const SystemClock();

  @override
  int get currentTimeMillis => DateTime.now().millisecondsSinceEpoch;

  @override
  int get currentTimeMicros => DateTime.now().microsecondsSinceEpoch;

  @override
  Stopwatch createStopwatch() => Stopwatch();
}

/// Mock clock for testing (allows time control)
class MockClock implements Clock {
  MockClock([int? initialTimeMicros])
      : _currentTimeMicros = initialTimeMicros ?? 0;

  int _currentTimeMicros;

  @override
  int get currentTimeMillis => _currentTimeMicros ~/ 1000;

  @override
  int get currentTimeMicros => _currentTimeMicros;

  @override
  Stopwatch createStopwatch() => MockStopwatch(this);

  /// Advance the clock by the specified duration
  void advance(Duration duration) {
    _currentTimeMicros += duration.inMicroseconds;
  }

  /// Set the clock to a specific time
  void setTime(int timeMicros) {
    _currentTimeMicros = timeMicros;
  }
}

/// Mock stopwatch that works with MockClock
class MockStopwatch implements Stopwatch {
  MockStopwatch(this._clock);

  final MockClock _clock;
  int? _startTime;
  int _elapsedMicros = 0;
  bool _isRunning = false;

  @override
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _startTime = _clock.currentTimeMicros;
  }

  @override
  void stop() {
    if (!_isRunning) return;
    _isRunning = false;
    _elapsedMicros += _clock.currentTimeMicros - _startTime!;
    _startTime = null;
  }

  @override
  void reset() {
    _elapsedMicros = 0;
    _isRunning = false;
    _startTime = null;
  }

  @override
  bool get isRunning => _isRunning;

  @override
  int get elapsedMicroseconds {
    var elapsed = _elapsedMicros;
    if (_isRunning && _startTime != null) {
      elapsed += _clock.currentTimeMicros - _startTime!;
    }
    return elapsed;
  }

  @override
  int get elapsedMilliseconds => elapsedMicroseconds ~/ 1000;

  @override
  int get elapsedTicks => elapsedMicroseconds;

  @override
  Duration get elapsed => Duration(microseconds: elapsedMicroseconds);

  @override
  int get frequency => 1000000; // 1MHz (microsecond resolution)
}
