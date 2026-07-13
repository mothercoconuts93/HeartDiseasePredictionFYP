import 'package:flutter/material.dart';

import '../../widgets/custom_button.dart';
import '../../themes/app_theme.dart';
import '../../widgets/risk_badge.dart';
import '../../widgets/risk_gradient_bar.dart';

class ResultScreen extends StatelessWidget {
  final String riskLevel;
  final double probability;
  final String recommendation;

  const ResultScreen({
    super.key,
    required this.riskLevel,
    required this.probability,
    required this.recommendation,
  });

  Color get riskColor {
    if (riskLevel.contains('High')) return AppTheme.danger;
    if (riskLevel.contains('Moderate')) return AppTheme.warning;
    return AppTheme.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CARDIOGUARD')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AppTheme.lightBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.monitor_heart_outlined,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Analysis Complete',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CALCULATED RISK',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            letterSpacing: 1.1,
                          ),
                        ),
                        RiskBadge(riskLevel: riskLevel),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      riskLevel,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${probability.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RiskGradientBar(probability: probability),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          color: AppTheme.primary,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Medical Recommendation',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(recommendation, style: const TextStyle(height: 1.5)),
                    const SizedBox(height: 14),
                    const Text(
                      'Note: This statistical result should be reviewed by a medical professional.',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            CustomButton(
              text: 'Result Saved to History',
              icon: Icons.check,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This result is already saved to Firestore.'),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('Return to Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
