import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/core/app_constants.dart';
import '../../app/data/services/session_service.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Boot screen — shows the brand, then routes to the shell (if logged in) or login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2200), () {
      final next =
          SessionService.to.isLoggedIn ? AppRoutes.shell : AppRoutes.login;
      Get.offAllNamed(next);
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgAlt,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.winningTeal.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Hero(
                tag: 'brand-logo',
                child: Image.asset(AppConstants.logo,
                    width: 150, height: 150, cacheWidth: 400),
              ),
            ),
            const SizedBox(height: 30),
            const Text(AppConstants.appName, style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text(AppConstants.tagline,
                style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary, letterSpacing: 4)),
            const SizedBox(height: 50),
            ScaleTransition(
              scale: Tween(begin: 0.7, end: 1.1).animate(
                CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
              ),
              child: Transform.rotate(
                angle: 0.785398, // 45° → diamond
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.winningTeal,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.winningTeal.withValues(alpha: 0.6),
                          blurRadius: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
