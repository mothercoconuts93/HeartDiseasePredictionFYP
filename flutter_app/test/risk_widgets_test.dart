// Widget tests for risk labels, colors, and probability visualization.

import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/risk_badge.dart';
import 'package:flutter_app/widgets/risk_gradient_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('risk badge displays the supplied live risk label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: RiskBadge(riskLevel: 'Moderate Risk')),
      ),
    );

    expect(find.text('Moderate Risk'), findsOneWidget);
  });

  testWidgets('gradient bar displays accessible scale labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 300, child: RiskGradientBar(probability: 65)),
        ),
      ),
    );

    expect(find.text('LOW'), findsOneWidget);
    expect(find.text('MODERATE'), findsOneWidget);
    expect(find.text('HIGH'), findsOneWidget);
  });
}
