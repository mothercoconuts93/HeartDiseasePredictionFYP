import 'package:flutter/material.dart';

import '../../models/prediction_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_button.dart';
import 'patient_list_screen.dart';
import '../../themes/app_theme.dart';
import '../../widgets/practitioner_bottom_nav.dart';
import 'practitioner_history_screen.dart';
import 'practitioner_profile_screen.dart';

class PractitionerHomeScreen extends StatelessWidget {
  const PractitionerHomeScreen({super.key});

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PredictionModel? _latestPredictionFor(
    String userId,
    List<PredictionModel> predictions,
  ) {
    for (final prediction in predictions) {
      if (prediction.userId == userId) {
        return prediction;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CARDIOGUARD'),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: PractitionerBottomNav(
        currentIndex: 0,
        onHome: () {},
        onHistory: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PractitionerHistoryScreen()),
        ),
        onProfile: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PractitionerProfileScreen()),
        ),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: firestoreService.getPatients(),
        builder: (context, patientSnapshot) {
          if (patientSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (patientSnapshot.hasError) {
            return const Center(
              child: Text('Unable to load patient dashboard.'),
            );
          }

          final patients = patientSnapshot.data ?? [];

          return StreamBuilder<List<PredictionModel>>(
            stream: firestoreService.getAllPredictions(),
            builder: (context, predictionSnapshot) {
              final predictions = predictionSnapshot.data ?? [];
              final latestPredictions = patients
                  .map(
                    (patient) => _latestPredictionFor(patient.uid, predictions),
                  )
                  .whereType<PredictionModel>()
                  .toList();

              final highRiskCount = latestPredictions.where((prediction) {
                return prediction.riskLevel.contains('High');
              }).length;

              final averageRisk = latestPredictions.isEmpty
                  ? 0
                  : latestPredictions
                            .map((prediction) => prediction.probability)
                            .reduce((a, b) => a + b) /
                        latestPredictions.length;

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Dashboard Overview',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your live practice summary based on current patient records.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  _statCard(
                    title: 'Total Patients',
                    value: patients.length.toString(),
                    icon: Icons.people,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 16),
                  _statCard(
                    title: 'High Risk Patients',
                    value: highRiskCount.toString(),
                    icon: Icons.warning,
                    color: AppTheme.danger,
                  ),
                  const SizedBox(height: 16),
                  _statCard(
                    title: 'Average Risk Score',
                    value: '${averageRisk.toStringAsFixed(0)}%',
                    icon: Icons.analytics,
                    color: AppTheme.warning,
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    text: 'Patient List — Search & Manage Records',
                    icon: Icons.manage_search,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PatientListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
