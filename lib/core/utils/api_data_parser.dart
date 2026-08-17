import 'package:intl/intl.dart';

/// Helper for parsing date, time, and numeric values from external APIs.
///
/// Enforces the 'en_US' locale and standard ISO-8601 formats for API data
/// serialization and deserialization, guaranteeing deterministic behavior
/// regardless of the user's active UI locale setting.
class ApiDataParser {
  static const String apiLocale = 'en_US';

  /// Parses ISO-8601 or EN-US formatted date strings from API payloads.
  static DateTime parseDateTime(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      return DateFormat('yyyy-MM-dd HH:mm:ss', apiLocale).parse(dateString);
    }
  }

  /// Safely parses string representations of double/number values using EN-US standards.
  static double parseDouble(String value) {
    try {
      final format = NumberFormat.decimalPattern(apiLocale);
      return format.parse(value).toDouble();
    } catch (_) {
      return double.parse(value);
    }
  }

  /// Formats a DateTime object into an ISO-8601 string for API requests.
  static String toIsoString(DateTime date) {
    return date.toIso8601String();
  }
}
