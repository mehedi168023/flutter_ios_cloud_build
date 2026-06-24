import 'package:flutter/material.dart';
import '../../app/core/app_loader.dart';
import '../../app/core/app_toast.dart';
import 'package:get/get.dart';
import '../../app/core/app_constants.dart';
import '../../app/data/services/session_service.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/widgets/common_widgets.dart';
import '../../app/widgets/primary_button.dart';

/// Stands in for the real payment-gateway WebView (`deposit_gateway_url`).
/// In demo mode it simulates a successful payment and credits the wallet.
class DepositWebviewScreen extends StatelessWidget {
  const DepositWebviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final amount = Get.arguments as double;

    return Scaffold(
      appBar: AppBar(title: const Text('Secure Payment')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const AppCard(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.lock, color: AppColors.winningTeal, size: 16),
                  SizedBox(width: 8),
                  Text('secure.squadup.gg/pay', style: AppTextStyles.body2),
                ],
              ),
            ),
            const Spacer(),
            const Icon(Icons.shield_outlined,
                size: 72, color: AppColors.primary),
            const SizedBox(height: 11),
            Text('Pay ${taka(amount)}', style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text('Demo gateway — no real charge',
                style: AppTextStyles.body2.copyWith(color: context.cTextMuted)),
            const Spacer(),
            PrimaryButton(
              label: 'Confirm Payment',
              variant: ButtonVariant.green,
              onPressed: () async {
                AppLoader.show('Processing...');
                await SessionService.to.deposit(amount);
                AppLoader.dismiss();
                Get.back();
                Get.back();
                AppToast.success('${taka(amount)} added to wallet');
              },
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Cancel',
              variant: ButtonVariant.red,
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
