import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/prediction_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/patient/patient_home_screen.dart';
import 'screens/practitioner/practitioner_home_screen.dart';
import 'widgets/loading_indicator.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const CardioGuard());
}

class CardioGuard extends StatelessWidget {
  const CardioGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PredictionProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CardioGuard',
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: LoadingIndicator(message: 'Loading...')),
          );
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        return FutureBuilder<void>(
          future: authProvider.loadCurrentUserData(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: LoadingIndicator(message: 'Loading...')),
              );
            }

            if (userSnapshot.hasError) {
              debugPrint(
                '[AuthGate] Failed to load Firestore user data: '
                '${userSnapshot.error}',
              );
              return const Scaffold(
                body: Center(child: Text('Unable to load your user profile.')),
              );
            }

            final role = authProvider.currentUserData?.role;
            debugPrint(
              '[AuthGate] Dashboard navigation decision: '
              '${role == 'Practitioner'
                  ? 'Practitioner'
                  : role == 'Patient'
                  ? 'Patient'
                  : 'none'} '
              '(loaded role: $role)',
            );

            if (role == 'Practitioner') {
              return const PractitionerHomeScreen();
            }

            if (role == 'Patient') {
              return const PatientHomeScreen();
            }

            return const Scaffold(
              body: Center(child: Text('User profile or role not found.')),
            );
          },
        );
      },
    );
  }
}
