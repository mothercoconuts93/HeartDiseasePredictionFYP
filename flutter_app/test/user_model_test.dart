// Verifies Firestore user parsing, including role and timestamp compatibility.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/models/user_model.dart';

void main() {
  test('parses a Firestore Timestamp and practitioner role', () {
    final createdAt = DateTime.utc(2026, 7, 15, 12, 30);

    final user = UserModel.fromMap({
      'uid': 'practitioner-uid',
      'fullName': 'Dr. Amir Hassan',
      'email': 'dr.amir.hassan@cardioguard.test',
      'role': 'Practitioner',
      'createdAt': Timestamp.fromDate(createdAt),
    });

    expect(user.role, 'Practitioner');
    expect(
      user.createdAt.millisecondsSinceEpoch,
      createdAt.millisecondsSinceEpoch,
    );
  });

  test('rejects a missing role', () {
    expect(
      () => UserModel.fromMap({
        'uid': 'missing-role-uid',
        'createdAt': Timestamp.now(),
      }),
      throwsFormatException,
    );
  });

  test('rejects an unsupported role', () {
    expect(
      () => UserModel.fromMap({
        'uid': 'unsupported-role-uid',
        'role': 'Admin',
        'createdAt': Timestamp.now(),
      }),
      throwsFormatException,
    );
  });
}
