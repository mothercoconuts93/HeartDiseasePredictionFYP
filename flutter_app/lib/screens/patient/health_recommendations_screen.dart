import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class HealthRecommendationsScreen extends StatelessWidget {
  const HealthRecommendationsScreen({super.key});

  Widget _recommendationCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(description),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CARDIOGUARD')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _recommendationCard(
            icon: Icons.directions_walk,
            title: 'Stay Physically Active',
            description:
                'Aim for regular moderate exercise such as walking, cycling, or swimming based on your health condition.',
            color: AppTheme.success,
          ),
          _recommendationCard(
            icon: Icons.restaurant,
            title: 'Maintain a Heart-Healthy Diet',
            description:
                'Reduce saturated fats, processed foods, and excessive salt. Include more fruits, vegetables, and whole grains.',
            color: AppTheme.warning,
          ),
          _recommendationCard(
            icon: Icons.smoke_free,
            title: 'Avoid Smoking',
            description:
                'Smoking increases cardiovascular risk. Quitting smoking can significantly improve heart health.',
            color: AppTheme.danger,
          ),
          _recommendationCard(
            icon: Icons.monitor_heart,
            title: 'Monitor Blood Pressure',
            description:
                'Regularly monitor blood pressure and cholesterol levels, especially if you have family history or diabetes.',
            color: AppTheme.primary,
          ),
          _recommendationCard(
            icon: Icons.medical_services,
            title: 'Consult a Healthcare Professional',
            description:
                'If you receive a high-risk result, schedule a consultation with a qualified medical practitioner.',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}
