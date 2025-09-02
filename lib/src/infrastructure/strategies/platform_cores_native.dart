// platform_cores_native.dart
// Native implementation for numberOfProcessors
import 'dart:io' show Platform;

int getNumberOfProcessors() => Platform.numberOfProcessors;
