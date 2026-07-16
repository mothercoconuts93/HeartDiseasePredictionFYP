import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/info_card.dart';
import '../auth/login_screen.dart';
import '../profile/settings_screen.dart';
import '../../themes/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import 'history_screen.dart';
import 'patient_home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You will need to sign in again to view your assessments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  String _formatJoinedDate(DateTime date) {
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

    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUserData;

    return Scaffold(
      appBar: AppBar(title: const Text('CARDIOGUARD')),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onHome: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
        ),
        onHistory: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HistoryScreen()),
        ),
        onProfile: () {},
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.lightBlue,
            child: Icon(Icons.person, size: 60, color: AppTheme.primary),
          ),
          const SizedBox(height: 15),
          Text(
            user?.fullName ?? 'Patient User',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? authProvider.firebaseUser?.email ?? '',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          InfoCard(
            icon: Icons.email,
            title: 'Email',
            subtitle: user?.email ?? authProvider.firebaseUser?.email ?? '',
          ),
          InfoCard(
            icon: Icons.badge,
            title: 'Role',
            subtitle: user?.role ?? 'Patient',
          ),
          InfoCard(
            icon: Icons.calendar_month,
            title: 'Joined',
            subtitle: user == null
                ? 'Unknown'
                : _formatJoinedDate(user.createdAt),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              leading: const Icon(
                Icons.settings_outlined,
                color: AppTheme.primary,
              ),
              title: const Text('Settings'),
              subtitle: const Text('Privacy, terms, and app preferences'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          CustomButton(
            text: 'Logout',
            icon: Icons.logout,
            onPressed: () => logout(context),
          ),
        ],
      ),
    );
  }
}
