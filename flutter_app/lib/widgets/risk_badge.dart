// Color-coded presentation of the model's human-readable risk category.

import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

/// Maps risk labels to an accessible status badge and severity colors.
class RiskBadge extends StatelessWidget {
  final String riskLevel;

  const RiskBadge({super.key, required this.riskLevel});

  /// Selects the foreground severity color from the risk label.
  Color get riskColor {
    if (riskLevel.contains('High') || riskLevel.contains('Critical')) {
      return AppTheme.danger;
    }
    if (riskLevel.contains('Moderate') || riskLevel.contains('Elevated')) {
      return AppTheme.warning;
    }
    return AppTheme.success;
  }

  /// Selects the matching low-contrast badge background.
  Color get backgroundColor {
    if (riskColor == AppTheme.danger) return AppTheme.dangerLight;
    if (riskColor == AppTheme.warning) return AppTheme.warningLight;
    return AppTheme.successLight;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        riskLevel,
        style: TextStyle(
          color: riskColor,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
