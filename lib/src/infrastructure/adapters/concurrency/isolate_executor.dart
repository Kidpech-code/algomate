// Copyright (c) 2025 Kidpech-code. All rights reserved.
// Use of this source code is governed by a BSD-style license.

/// Platform-aware isolate executor exports.
library algomate.src.infrastructure.adapters.concurrency.isolate_executor;

///
/// This file provides the appropriate isolate executor implementation
/// based on the target platform:
/// - Native platforms: Full isolate support via [DartIsolateExecutor]
/// - Web platform: Stub implementation via [StubIsolateExecutor]

// Export the interface first
export '../../../application/ports/isolate_executor.dart';

// Conditional exports based on platform - only export the implementation classes
export 'dart_isolate_executor.dart'
    if (dart.library.html) 'stub_isolate_executor.dart'
    if (dart.library.js_interop) 'stub_isolate_executor.dart'
    hide IsolateExecutionException, IsolateTimeoutException;
