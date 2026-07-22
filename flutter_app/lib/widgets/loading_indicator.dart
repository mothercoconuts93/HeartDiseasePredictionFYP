// Consistent progress indicator with an optional operation message.

import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

/// Communicates an in-progress asynchronous operation to the user.
class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: AppTheme.primary),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
