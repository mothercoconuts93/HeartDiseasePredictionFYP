// Branded launch screen that transitions to authentication.

import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import '../../themes/app_theme.dart';
import '../../widgets/cardio_guard_logo.dart';

/// Briefly presents CardioGuard branding before opening the login screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _goToLogin();
  }

  /// Waits for the splash interval and replaces it with Login.
  Future<void> _goToLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CardioGuardLogo(size: 108),
              SizedBox(height: 20),
              Text(
                'CARDIOGUARD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Heart Disease Prediction System',
                style: TextStyle(color: Colors.white70, fontSize: 17),
              ),
              SizedBox(height: 45),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
