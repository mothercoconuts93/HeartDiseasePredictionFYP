import 'package:flutter/material.dart';

class CardioGuardLogo extends StatelessWidget {
  final double size;
  final bool includeBackground;

  const CardioGuardLogo({
    super.key,
    this.size = 72,
    this.includeBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/cardioguard_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'CardioGuard heart logo',
      filterQuality: FilterQuality.high,
    );

    if (!includeBackground) return image;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: image,
    );
  }
}
