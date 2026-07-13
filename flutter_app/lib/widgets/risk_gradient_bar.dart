import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class RiskGradientBar extends StatelessWidget {
  final double probability;
  final bool showPercentage;

  const RiskGradientBar({
    super.key,
    required this.probability,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = probability.clamp(0, 100) / 100;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const markerWidth = 18.0;
            final markerLeft =
                (constraints.maxWidth - markerWidth) * normalized;

            return SizedBox(
              height: showPercentage ? 52 : 30,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 9,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 13,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primary,
                            Color(0xFF8E44AD),
                            AppTheme.danger,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    left: markerLeft,
                    child: Container(
                      width: markerWidth,
                      height: 27,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.textPrimary,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (showPercentage)
                    Positioned(
                      top: 34,
                      left: markerLeft - 13,
                      child: SizedBox(
                        width: 44,
                        child: Text(
                          '${probability.clamp(0, 100).toStringAsFixed(0)}%',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LOW',
              style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
            ),
            Text(
              'MODERATE',
              style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
            ),
            Text(
              'HIGH',
              style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
