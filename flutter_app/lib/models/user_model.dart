// Firestore-backed account profile shared by Patient and Practitioner roles.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents one document in the `users` collection.
class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  /// Serializes profile data for a Firestore write.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Parses a profile while rejecting unsupported privilege roles.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    final role = map['role'];

    if (role != 'Patient' && role != 'Practitioner') {
      throw const FormatException('Invalid or missing user role');
    }

    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: role as String,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  /// Reads both current ISO strings and legacy/manual Firestore date values.
  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }
}
