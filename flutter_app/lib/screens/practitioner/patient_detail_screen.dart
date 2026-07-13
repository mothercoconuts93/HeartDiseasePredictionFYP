import 'package:flutter/material.dart';

import '../../models/prediction_model.dart';
import '../../models/user_model.dart';
import '../../widgets/info_card.dart';
import '../../widgets/risk_badge.dart';
import '../../themes/app_theme.dart';

class PatientDetailScreen extends StatelessWidget {
  final UserModel patient;
  final PredictionModel? latestPrediction;

  const PatientDetailScreen({
    super.key,
    required this.patient,
    required this.latestPrediction,
  });

  Color get riskColor {
    final risk = latestPrediction?.riskLevel;
    if (risk == null) return AppTheme.textSecondary;
    if (risk.contains('High')) return AppTheme.danger;
    if (risk.contains('Moderate')) return AppTheme.warning;
    return AppTheme.success;
  }

  String formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final prediction = latestPrediction;

    return Scaffold(
      appBar: AppBar(title: const Text('CARDIOGUARD')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: riskColor.withValues(alpha: 0.15),
              child: Icon(Icons.person, size: 55, color: riskColor),
            ),
            const SizedBox(height: 16),
            Text(
              patient.fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(patient.email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),
            prediction == null
                ? const Text('No prediction yet')
                : RiskBadge(riskLevel: prediction.riskLevel),
            const SizedBox(height: 25),
            InfoCard(
              icon: Icons.calendar_month,
              title: 'Last Assessment',
              subtitle: prediction == null
                  ? 'No assessment yet'
                  : formatDate(prediction.createdAt),
              color: AppTheme.primary,
            ),
            InfoCard(
              icon: Icons.percent,
              title: 'Latest Probability',
              subtitle: prediction == null
                  ? 'N/A'
                  : '${prediction.probability.toStringAsFixed(2)}%',
              color: AppTheme.warning,
            ),
            InfoCard(
              icon: Icons.medical_services,
              title: 'Recommendation',
              subtitle: prediction == null
                  ? 'Run a prediction to generate a recommendation.'
                  : prediction.recommendation,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
