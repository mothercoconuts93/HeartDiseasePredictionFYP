import 'package:flutter/material.dart';

import '../../widgets/info_card.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';
import '../../themes/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppTheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: enabled ? (_) {} : null,
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
          _switchTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle:
                'Coming soon — the current release uses the clinical light theme',
            value: false,
            enabled: false,
          ),

          _settingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Read how your data is handled',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
          ),

          _settingsTile(
            icon: Icons.article,
            title: 'Terms of Service',
            subtitle: 'View app usage terms',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              );
            },
          ),

          InfoCard(
            icon: Icons.info,
            title: 'About CardioGuard',
            subtitle:
                'A Flutter-based heart disease prediction system developed for early cardiovascular risk assessment.',
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
