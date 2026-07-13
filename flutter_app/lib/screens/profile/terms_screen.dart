import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CARDIOGUARD')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              'Purpose of the App',
              'CardioGuard is designed as a heart disease risk assessment and preventive healthcare support tool.',
            ),
            _section(
              'Not a Medical Diagnosis',
              'The prediction result does not replace consultation with a qualified healthcare professional.',
            ),
            _section(
              'User Responsibility',
              'Users are responsible for entering accurate health information. Incorrect data may affect prediction results.',
            ),
            _section(
              'Practitioner Use',
              'Practitioners may use the system to review patient risk information, but clinical decisions should be based on professional judgement.',
            ),
            _section(
              'System Limitations',
              'CardioGuard is developed for academic and decision-support purposes and may not cover all clinical risk factors.',
            ),
          ],
        ),
      ),
    );
  }
}
