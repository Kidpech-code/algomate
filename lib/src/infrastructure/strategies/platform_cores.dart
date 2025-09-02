// platform_cores.dart
// Provides numberOfProcessors for native and web environments using conditional imports.

// Export the correct implementation based on platform.
export 'platform_cores_native.dart'
    if (dart.library.html) 'platform_cores_web.dart';
