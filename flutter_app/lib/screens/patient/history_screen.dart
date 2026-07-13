import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/prediction_model.dart';
import '../../providers/prediction_provider.dart';
import '../../widgets/risk_badge.dart';
import '../../themes/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import 'patient_home_screen.dart';
import 'profile_screen.dart';
import 'prediction_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _visibleCount = 10;

  Color getRiskColor(String risk) {
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

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final predictionProvider = Provider.of<PredictionProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('CARDIOGUARD')),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onHome: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
        ),
        onHistory: () {},
        onProfile: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
      ),
      body: user == null
          ? _emptyState('You must be logged in to view prediction history.')
          : StreamBuilder<List<PredictionModel>>(
              stream: predictionProvider.getPredictionHistory(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _emptyState(
                    'Unable to load prediction history. Please try again later.',
                  );
                }

                final history = snapshot.data ?? [];

                if (history.isEmpty) {
                  return _emptyState('No prediction history found.');
                }

                final visibleHistory = history.take(_visibleCount).toList();
                final hasMore = history.length > visibleHistory.length;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: visibleHistory.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == visibleHistory.length) {
                      return OutlinedButton(
                        onPressed: () => setState(() => _visibleCount += 10),
                        child: Text(
                          'Load More (${history.length - visibleHistory.length} remaining)',
                        ),
                      );
                    }
                    final item = visibleHistory[index];
                    final color = getRiskColor(item.riskLevel);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PredictionDetailScreen(prediction: item),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: color.withValues(alpha: 0.1),
                                child: Icon(Icons.monitor_heart, color: color),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatDate(item.createdAt),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    RiskBadge(riskLevel: item.riskLevel),
                                    const SizedBox(height: 8),
                                    Text(
                                      item.recommendation,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${item.probability.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: AppTheme.primary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
