import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../themes/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/info_card.dart';
import '../../widgets/practitioner_bottom_nav.dart';
import '../auth/login_screen.dart';
import '../profile/privacy_policy_screen.dart';
import '../profile/terms_screen.dart';
import 'practitioner_history_screen.dart';
import 'practitioner_home_screen.dart';

class PractitionerProfileScreen extends StatelessWidget {
  const PractitionerProfileScreen({super.key});

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

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You will need to sign in again to access practitioner records.',
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

    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUserData;
    final email = user?.email ?? auth.firebaseUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('CARDIOGUARD')),
      bottomNavigationBar: PractitionerBottomNav(
        currentIndex: 2,
        onHome: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PractitionerHomeScreen()),
        ),
        onHistory: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PractitionerHistoryScreen()),
        ),
        onProfile: () {},
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: AppTheme.lightBlue,
            child: Icon(
              Icons.medical_services_outlined,
              size: 43,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user?.fullName ?? 'Practitioner',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 5),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          InfoCard(
            icon: Icons.badge_outlined,
            title: 'Role',
            subtitle: user?.role ?? 'Practitioner',
          ),
          InfoCard(
            icon: Icons.calendar_month_outlined,
            title: 'Member Since',
            subtitle: user == null
                ? 'Unavailable'
                : _formatJoinedDate(user.createdAt),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: const Icon(
                Icons.privacy_tip_outlined,
                color: AppTheme.primary,
              ),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: const Icon(
                Icons.description_outlined,
                color: AppTheme.primary,
              ),
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              ),
            ),
          ),
          const SizedBox(height: 18),
          CustomButton(
            text: 'Logout',
            icon: Icons.logout,
            onPressed: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
