import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../themes/app_theme.dart';
import '../../widgets/dashboard_card.dart';
import 'prediction_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'health_recommendations_screen.dart';
import '../../widgets/app_bottom_nav.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUserData;
    return Scaffold(
      appBar: AppBar(
        title: const Text('CARDIOGUARD'),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onHome: () {},
        onHistory: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoryScreen()),
        ),
        onProfile: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Hello, ${user?.fullName ?? 'Patient'}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              const Text(
                'Your heart health summary starts here.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 30),

              DashboardCard(
                icon: Icons.health_and_safety,
                title: 'New Risk Assessment',
                subtitle: 'Start a heart disease prediction',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PredictionScreen()),
                  );
                },
              ),

              DashboardCard(
                icon: Icons.history,
                title: 'Prediction History',
                subtitle: 'Review previous assessment results',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
              ),

              DashboardCard(
                icon: Icons.favorite,
                title: 'Health Recommendations',
                subtitle: 'View preventive heart health guidance',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HealthRecommendationsScreen(),
                    ),
                  );
                },
              ),

              DashboardCard(
                icon: Icons.person,
                title: 'Profile',
                subtitle: 'Manage your account details',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
