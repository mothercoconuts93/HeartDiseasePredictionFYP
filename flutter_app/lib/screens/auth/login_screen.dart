import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/cardio_guard_logo.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import '../patient/patient_home_screen.dart';
import '../practitioner/practitioner_home_screen.dart';
import '../../themes/app_theme.dart';
import '../profile/privacy_policy_screen.dart';
import '../profile/terms_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      email: emailController.text,
      password: passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final role = authProvider.currentUserData?.role;
      debugPrint(
        '[Login] Dashboard navigation decision: '
        '${role == 'Practitioner'
            ? 'Practitioner'
            : role == 'Patient'
            ? 'Patient'
            : 'none'} '
        '(loaded role: $role)',
      );

      if (role != 'Practitioner' && role != 'Patient') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your user profile or role could not be loaded.'),
          ),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => role == 'Practitioner'
              ? const PractitionerHomeScreen()
              : const PatientHomeScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Login failed. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: authProvider.isLoading
            ? const Center(child: LoadingIndicator(message: 'Logging in...'))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 30),

                                const CardioGuardLogo(size: 76),

                                const SizedBox(height: 20),

                                const Text(
                                  'CARDIOGUARD',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary,
                                    letterSpacing: 2,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                const Text(
                                  'Clinical Precision. Trusted Care.',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),

                                const SizedBox(height: 35),

                                CustomTextField(
                                  label: 'Email Address',
                                  hintText: 'name@healthcare.com',
                                  controller: emailController,
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                ),

                                const SizedBox(height: 20),

                                CustomTextField(
                                  label: 'Password',
                                  hintText: 'Enter your password',
                                  controller: passwordController,
                                  icon: Icons.lock,
                                  obscureText: obscurePassword,
                                  suffixIcon: IconButton(
                                    tooltip: obscurePassword
                                        ? 'Show password'
                                        : 'Hide password',
                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        obscurePassword = !obscurePassword;
                                      });
                                    },
                                  ),
                                ),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text('Forgot Password?'),
                                  ),
                                ),

                                const SizedBox(height: 15),

                                CustomButton(
                                  text: 'Login to Account',
                                  icon: Icons.login,
                                  onPressed: loginUser,
                                ),

                                const SizedBox(height: 25),

                                const Row(
                                  children: [
                                    Expanded(child: Divider()),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider()),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("New to CardioGuard?"),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const RegisterScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text('Create account'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TermsScreen(),
                                ),
                              ),
                              child: const Text('Terms of Service'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PrivacyPolicyScreen(),
                                ),
                              ),
                              child: const Text('Privacy Policy'),
                            ),
                          ],
                        ),
                        Text(
                          '© ${DateTime.now().year} CardioGuard',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
