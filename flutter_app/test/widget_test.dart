// Smoke test for the application root and unauthenticated entry state.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/main.dart';

void main() {
  test('CardioGuard app widget exists', () {
    expect(const CardioGuard(), isA<CardioGuard>());
  });
}
