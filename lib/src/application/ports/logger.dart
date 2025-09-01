/// Logger port for AlgoMate operations.
///
/// Provides structured logging with different levels and the ability
/// to disable logging in production for performance.
abstract class Logger {
  /// Log a debug message (lowest priority)
  void debug(String message, [Object? context]);

  /// Log an informational message
  void info(String message, [Object? context]);

  /// Log a warning message
  void warn(String message, [Object? context]);

  /// Log an error message
  void error(String message, [Object? error, StackTrace? stackTrace]);

  /// Check if debug logging is enabled (to avoid expensive string building)
  bool get isDebugEnabled;

  /// Check if info logging is enabled
  bool get isInfoEnabled;
}

/// Log levels for controlling output verbosity
enum LogLevel {
  none, // No logging
  error, // Only errors
  warn, // Warnings and errors
  info, // Info, warnings, and errors
  debug, // All messages
}

/// Factory for creating logger instances
abstract class LoggerFactory {
  /// Create a logger with the specified name and level
  Logger create(String name, [LogLevel level = LogLevel.info]);
}
