import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Single source of truth for in-app notifications. Premium animated banners
/// that slide in from the **top** (iOS-style), color-coded by intent with a
/// tinted icon chip on a dark surface. Used everywhere for
/// success / error / warning / info feedback.
class AppToast {
  AppToast._();

  static void success(String message, {String title = 'Success'}) =>
      _show(title, message, AppColors.success, Icons.check_circle_rounded);

  static void error(String message, {String title = 'Oops'}) =>
      _show(title, message, AppColors.danger, Icons.error_rounded);

  static void warning(String message, {String title = 'Warning'}) =>
      _show(title, message, AppColors.gold, Icons.warning_amber_rounded);

  static void info(String message, {String title = 'Notice'}) =>
      _show(title, message, AppColors.primary, Icons.info_rounded);

  static void _show(String title, String message, Color color, IconData icon) {
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
    Get.showSnackbar(
      GetSnackBar(
        titleText: Text(title,
            style: AppTextStyles.title
                .copyWith(color: AppColors.textPrimary, fontSize: 15)),
        messageText: Text(message,
            style:
                AppTextStyles.body1.copyWith(color: AppColors.textSecondary)),
        icon: Container(
          margin: const EdgeInsets.only(left: AppSpacing.md),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        backgroundColor: AppColors.surface,
        borderColor: color.withValues(alpha: 0.45),
        borderWidth: 1,
        borderRadius: AppRadius.lg,
        margin: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.lg),
        snackPosition: SnackPosition.TOP,
        snackStyle: SnackStyle.FLOATING,
        duration: const Duration(seconds: 3),
        isDismissible: true,
        dismissDirection: DismissDirection.up,
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
        ],
        animationDuration: AppDurations.slow,
        forwardAnimationCurve: AppCurves.spring,
        reverseAnimationCurve: AppCurves.standard,
      ),
    );
  }
}
