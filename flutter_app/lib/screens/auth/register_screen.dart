import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loading_indicator.dart';
import '../patient/patient_home_screen.dart';
import '../practitioner/practitioner_home_screen.dart';
import '../../themes/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String selectedRole = 'Patient';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    FocusScope.of(context).unfocus();

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      fullName: name,
      email: email,
      password: password,
      role: selectedRole,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => selectedRole == 'Practitioner'
              ? const PractitionerHomeScreen()
              : const PatientHomeScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registration failed.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('CARDIOGUARD')),
      body: authProvider.isLoading
          ? const Center(
              child: LoadingIndicator(message: 'Creating account...'),
            )
          : SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 40),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppTheme.lightBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 34,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 22),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'I am a...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'Patient',
                          label: Text('Patient'),
                          icon: Icon(Icons.person_outline),
                        ),
                        ButtonSegment(
                          value: 'Practitioner',
                          label: Text('Practitioner'),
                          icon: Icon(Icons.medical_services_outlined),
                        ),
                      ],
                      selected: {selectedRole},
                      showSelectedIcon: false,
                      onSelectionChanged: (values) =>
                          setState(() => selectedRole = values.first),
                      style: const ButtonStyle(
                        visualDensity: VisualDensity(vertical: 2),
                      ),
                    ),

                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Full Name',
                      controller: nameController,
                      icon: Icons.person,
                    ),

                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Email Address',
                      controller: emailController,
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Password',
                      controller: passwordController,
                      icon: Icons.lock,
                      obscureText: true,
                    ),

                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Confirm Password',
                      controller: confirmPasswordController,
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),

                    const SizedBox(height: 24),

                    CustomButton(
                      text: 'Register',
                      icon: Icons.person_add,
                      onPressed: registerUser,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
