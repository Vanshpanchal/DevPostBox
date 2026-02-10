import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            SizedBox(
              width: 250,
              height: 250,
              child: Lottie.asset(
                'assets/email_animation.json',
                fit: BoxFit.contain,
              ),
            ),
            // const SizedBox(height: 24),
            // // App Title
            // Text(
            //   'DevPostBox',
            //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            //         fontWeight: FontWeight.bold,
            //         letterSpacing: 1.2,
            //       ),
            // ),
          ],
        ),
      ),
    );
  }
}
