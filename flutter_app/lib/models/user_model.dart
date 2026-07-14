import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

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
