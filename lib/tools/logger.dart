import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

abstract class AppLogger {
  static AppLogger instance = kDebugMode ? DebugLogger() : CrashlyticsLogger();

  void log(String message, {Object? error, StackTrace? stackTrace});
  void error(String message, {Object? error, StackTrace? stackTrace});
  void failure(String message, {Object? failure, StackTrace? stackTrace});
  Future<void> setCustomKey(String key, Object value);
  Future<void> setUserIdentifier(String identifier);
}

// Alias for backward compatibility
typedef AppLoggerImpl = AppLogger;

/// Debug implementation: logs directly to local console via debugPrint.
class DebugLogger implements AppLogger {
  @override
  void log(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint('[LOG] $message');
    if (error != null) debugPrint('  Error: $error');
    if (stackTrace != null) debugPrint('  StackTrace: $stackTrace');
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('  Error: $error');
    if (stackTrace != null) debugPrint('  StackTrace: $stackTrace');
  }

  @override
  void failure(String message, {Object? failure, StackTrace? stackTrace}) {
    debugPrint('[FAILURE] $message');
    if (failure != null) debugPrint('  Failure details: $failure');
    if (stackTrace != null) debugPrint('  StackTrace: $stackTrace');
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    debugPrint('[LOGGER KEY] $key: $value');
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    debugPrint('[LOGGER USER] $identifier');
  }
}

/// Production implementation: reports non-fatal errors & breadcrumbs to Firebase Crashlytics.
class CrashlyticsLogger implements AppLogger {
  final FirebaseCrashlytics _crashlytics;

  CrashlyticsLogger([FirebaseCrashlytics? crashlytics])
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  @override
  void log(String message, {Object? error, StackTrace? stackTrace}) {
    _crashlytics.log('[LOG] $message');
    if (error != null) {
      _crashlytics.recordError(error, stackTrace, reason: message);
    }
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _crashlytics.log('[ERROR] $message');
    _crashlytics.recordError(
      error ?? Exception(message),
      stackTrace,
      reason: message,
    );
  }

  @override
  void failure(String message, {Object? failure, StackTrace? stackTrace}) {
    _crashlytics.log(
        '[FAILURE] $message ${failure != null ? "- Details: $failure" : ""}');
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    await _crashlytics.setUserIdentifier(identifier);
  }
}
