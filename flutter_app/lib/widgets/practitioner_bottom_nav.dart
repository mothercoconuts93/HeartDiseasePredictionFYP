// Reusable Practitioner navigation bar for the role-specific workflow.

import 'package:flutter/material.dart';

/// Displays Practitioner Home, History, and Profile destinations.
class PractitionerBottomNav extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onHome;
  final VoidCallback onHistory;
  final VoidCallback onProfile;

  const PractitionerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onHome,
    required this.onHistory,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index == currentIndex) return;
        switch (index) {
          case 0:
            onHome();
            return;
          case 1:
            onHistory();
            return;
          case 2:
            onProfile();
            return;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'History',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
