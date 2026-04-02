import 'package:cloud_firestore/cloud_firestore.dart';

extension TimestampExtension on Timestamp {
  DateTime toDateTime() => toDate();
}

extension DateTimeExtension on DateTime {
  Timestamp toTimestamp() => Timestamp.fromDate(this);
}

class FirestoreUtils {
  FirestoreUtils._();

  /// Safely convert a Firestore dynamic value to DateTime.
  /// Accepts Timestamp, String (ISO 8601), or int (milliseconds since epoch).
  static DateTime? toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  /// Convert DateTime to Firestore Timestamp.
  static Timestamp? fromDateTime(DateTime? value) {
    if (value == null) return null;
    return Timestamp.fromDate(value);
  }

  /// Safely get a string from a map, returning empty string if null.
  static String getString(Map<String, dynamic> map, String key,
      {String defaultValue = ''}) {
    final value = map[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Safely get a double from a map, returning 0.0 if null or invalid.
  static double getDouble(Map<String, dynamic> map, String key,
      {double defaultValue = 0.0}) {
    final value = map[key];
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safely get an int from a map, returning 0 if null or invalid.
  static int getInt(Map<String, dynamic> map, String key,
      {int defaultValue = 0}) {
    final value = map[key];
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safely get a bool from a map.
  static bool getBool(Map<String, dynamic> map, String key,
      {bool defaultValue = false}) {
    final value = map[key];
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return defaultValue;
  }

  /// Safely get a list of strings from a map.
  static List<String> getStringList(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Generate a short readable document ID from Firestore.
  static String generateId(CollectionReference collection) {
    return collection.doc().id;
  }
}
