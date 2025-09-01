import '../../../application/ports/logger.dart';

/// Console logger implementation for development and debugging.
///
/// Provides structured logging with configurable levels and the ability
/// to disable logging in production builds.
class ConsoleLogger implements Logger {
  ConsoleLogger(this.name, [this.level = LogLevel.info]);

  final String name;
  final LogLevel level;

  @override
  void debug(String message, [Object? context]) {
    if (!isDebugEnabled) return;
    _log('DEBUG', message, context);
  }

  @override
  void info(String message, [Object? context]) {
    if (!isInfoEnabled) return;
    _log('INFO', message, context);
  }

  @override
  void warn(String message, [Object? context]) {
    if (_shouldLog(LogLevel.warn)) {
      _log('WARN', message, context);
    }
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_shouldLog(LogLevel.error)) {
      _log('ERROR', message, error);
      if (stackTrace != null) {
        print('  Stack trace: $stackTrace');
      }
    }
  }

  @override
  bool get isDebugEnabled => _shouldLog(LogLevel.debug);

  @override
  bool get isInfoEnabled => _shouldLog(LogLevel.info);

  bool _shouldLog(LogLevel messageLevel) {
    return level.index >= messageLevel.index && level != LogLevel.none;
  }

  void _log(String levelName, String message, [Object? context]) {
    final timestamp = DateTime.now().toIso8601String();
    final contextPart = context != null ? ' | $context' : '';
    print('$timestamp [$levelName] $name: $message$contextPart');
  }
}

/// Silent logger that discards all messages (for production).
class SilentLogger implements Logger {
  const SilentLogger();

  @override
  void debug(String message, [Object? context]) {}

  @override
  void info(String message, [Object? context]) {}

  @override
  void warn(String message, [Object? context]) {}

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  bool get isDebugEnabled => false;

  @override
  bool get isInfoEnabled => false;
}

/// Console logger factory for creating loggers with consistent configuration.
class ConsoleLoggerFactory implements LoggerFactory {
  const ConsoleLoggerFactory([this.defaultLevel = LogLevel.info]);

  /// Create a factory for debug builds with verbose logging.
  factory ConsoleLoggerFactory.debug() {
    return const ConsoleLoggerFactory(LogLevel.debug);
  }

  final LogLevel defaultLevel;

  @override
  Logger create(String name, [LogLevel? level]) {
    return ConsoleLogger(name, level ?? defaultLevel);
  }

  /// Create a factory that produces silent loggers (for production).
  static LoggerFactory silent() => const _SilentLoggerFactory();
}

class _SilentLoggerFactory implements LoggerFactory {
  const _SilentLoggerFactory();

  @override
  Logger create(String name, [LogLevel? level]) {
    return const SilentLogger();
  }
}

/// Buffered logger that collects messages for testing or delayed output.
class BufferedLogger implements Logger {
  BufferedLogger(this.name, [this.level = LogLevel.info]);

  final String name;
  final LogLevel level;
  final List<LogEntry> _buffer = [];

  /// Get all logged messages
  List<LogEntry> get messages => List.unmodifiable(_buffer);

  /// Clear the message buffer
  void clear() => _buffer.clear();

  @override
  void debug(String message, [Object? context]) {
    if (isDebugEnabled) {
      _buffer.add(LogEntry('DEBUG', message, context: context));
    }
  }

  @override
  void info(String message, [Object? context]) {
    if (isInfoEnabled) {
      _buffer.add(LogEntry('INFO', message, context: context));
    }
  }

  @override
  void warn(String message, [Object? context]) {
    if (_shouldLog(LogLevel.warn)) {
      _buffer.add(LogEntry('WARN', message, context: context));
    }
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_shouldLog(LogLevel.error)) {
      _buffer.add(LogEntry('ERROR', message, error: error, stackTrace: stackTrace));
    }
  }

  @override
  bool get isDebugEnabled => _shouldLog(LogLevel.debug);

  @override
  bool get isInfoEnabled => _shouldLog(LogLevel.info);

  bool _shouldLog(LogLevel messageLevel) {
    return level.index >= messageLevel.index && level != LogLevel.none;
  }
}

/// A single log entry in the buffered logger.
class LogEntry {
  const LogEntry(this.level, this.message, {this.context, this.error, this.stackTrace, DateTime? timestamp})
    : timestamp = timestamp ?? const _CurrentTime();

  final String level;
  final String message;
  final Object? context;
  final Object? error;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  @override
  String toString() {
    final contextPart = context != null ? ' | $context' : '';
    final errorPart = error != null ? ' | Error: $error' : '';
    return '${timestamp.toIso8601String()} [$level] $message$contextPart$errorPart';
  }
}

class _CurrentTime implements DateTime {
  const _CurrentTime();

  DateTime get _now => DateTime.now();

  @override
  String toIso8601String() => _now.toIso8601String();

  // Implement other DateTime methods by delegating to _now
  @override
  DateTime add(Duration duration) => _now.add(duration);

  @override
  int compareTo(DateTime other) => _now.compareTo(other);

  @override
  DateTime subtract(Duration duration) => _now.subtract(duration);

  @override
  int get day => _now.day;

  @override
  int get weekday => _now.weekday;

  @override
  int get hour => _now.hour;

  @override
  bool isAfter(DateTime other) => _now.isAfter(other);

  @override
  bool isAtSameMomentAs(DateTime other) => _now.isAtSameMomentAs(other);

  @override
  bool isBefore(DateTime other) => _now.isBefore(other);

  @override
  bool get isUtc => _now.isUtc;

  @override
  int get microsecond => _now.microsecond;

  @override
  int get microsecondsSinceEpoch => _now.microsecondsSinceEpoch;

  @override
  int get millisecond => _now.millisecond;

  @override
  int get millisecondsSinceEpoch => _now.millisecondsSinceEpoch;

  @override
  int get minute => _now.minute;

  @override
  int get month => _now.month;

  @override
  int get second => _now.second;

  @override
  String get timeZoneName => _now.timeZoneName;

  @override
  Duration get timeZoneOffset => _now.timeZoneOffset;

  @override
  DateTime toLocal() => _now.toLocal();

  @override
  DateTime toUtc() => _now.toUtc();

  @override
  int get year => _now.year;

  @override
  String toString() => _now.toString();

  @override
  bool operator ==(Object other) => other is DateTime && _now.isAtSameMomentAs(other);

  @override
  int get hashCode => _now.hashCode;

  @override
  Duration difference(DateTime other) => _now.difference(other);
}
