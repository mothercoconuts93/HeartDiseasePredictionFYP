import 'package:flutter/material.dart';

import '../../models/prediction_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../themes/app_theme.dart';
import '../../widgets/practitioner_bottom_nav.dart';
import '../../widgets/risk_badge.dart';
import 'patient_detail_screen.dart';
import 'practitioner_home_screen.dart';
import 'practitioner_profile_screen.dart';

class PractitionerHistoryScreen extends StatelessWidget {
  const PractitionerHistoryScreen({super.key});

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month}/${local.year} ${local.hour}:$minute';
  }

  Color _riskColor(String risk) {
    if (risk.contains('High')) return AppTheme.danger;
    if (risk.contains('Moderate')) return AppTheme.warning;
    return AppTheme.success;
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('CARDIOGUARD')),
      bottomNavigationBar: PractitionerBottomNav(
        currentIndex: 1,
        onHome: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PractitionerHomeScreen()),
        ),
        onHistory: () {},
        onProfile: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PractitionerProfileScreen()),
        ),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: firestore.getPatients(),
        builder: (context, patientSnapshot) {
          if (patientSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (patientSnapshot.hasError) {
            return const Center(child: Text('Unable to load patients.'));
          }
          final patients = patientSnapshot.data ?? [];
          final byId = {for (final patient in patients) patient.uid: patient};

          return StreamBuilder<List<PredictionModel>>(
            stream: firestore.getAllPredictions(),
            builder: (context, predictionSnapshot) {
              if (predictionSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (predictionSnapshot.hasError) {
                return const Center(
                  child: Text('Unable to load assessment history.'),
                );
              }
              final predictions = predictionSnapshot.data ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assessment History',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${predictions.length} recorded assessment${predictions.length == 1 ? '' : 's'}',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: predictions.isEmpty
                        ? const Center(
                            child: Text('No patient assessments found.'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                            itemCount: predictions.length,
                            itemBuilder: (context, index) {
                              final prediction = predictions[index];
                              final patient = byId[prediction.userId];
                              final color = _riskColor(prediction.riskLevel);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: color.withValues(
                                      alpha: 0.1,
                                    ),
                                    child: Icon(
                                      Icons.monitor_heart_outlined,
                                      color: color,
                                    ),
                                  ),
                                  title: Text(
                                    patient?.fullName ?? 'Unknown patient',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RiskBadge(
                                          riskLevel: prediction.riskLevel,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(_formatDate(prediction.createdAt)),
                                      ],
                                    ),
                                  ),
                                  trailing: Text(
                                    '${prediction.probability.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: color,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  onTap: patient == null
                                      ? null
                                      : () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PatientDetailScreen(
                                              patient: patient,
                                              latestPrediction: prediction,
                                            ),
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
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
