import 'package:flutter/material.dart';
import '../../app/core/app_toast.dart';
import 'package:get/get.dart';
import '../../app/core/app_constants.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/widgets/common_widgets.dart';
import '../../app/widgets/primary_button.dart';
import '../../app/widgets/responsive.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final amount = TextEditingController();

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Money')),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            AppCard(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.25),
                  context.cSurface
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.account_balance_wallet,
                        color: AppColors.winningTeal),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add Money',
                            style: AppTextStyles.title.copyWith(fontSize: 18)),
                        const SizedBox(height: 2),
                        const Text('Secure payment via gateway',
                            style: AppTextStyles.body2),
                      ],
                    ),
                  ),
                  const StatusPill(
                      text: 'Active',
                      color: AppColors.winningTeal,
                      showDot: false),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const SectionHeader('ENTER AMOUNT'),
            const SizedBox(height: 12),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              style: AppTextStyles.body1,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: Text(AppConstants.currency,
                      style: TextStyle(
                          fontSize: 20, color: AppColors.textSecondary)),
                ),
                prefixIconConstraints: BoxConstraints(minWidth: 0),
              ),
            ),
            const SizedBox(height: 15),
            PrimaryButton(
              label: 'PROCEED TO PAYMENT',
              icon: Icons.lock_outline,
              variant: ButtonVariant.green,
              onPressed: () {
                final v = double.tryParse(amount.text.trim());
                if (v == null || v <= 0) {
                  AppToast.error('Enter a valid amount');
                  return;
                }
                Get.toNamed(AppRoutes.depositWebview, arguments: v);
              },
            ),
            const SizedBox(height: 15),
            AppCard(
              child: Column(
                children: [
                  _info(Icons.verified, AppColors.primary,
                      'Secure payment powered by our gateway'),
                  const SizedBox(height: 14),
                  _info(Icons.bolt, AppColors.gold,
                      'Balance is credited instantly after payment'),
                  const SizedBox(height: 14),
                  _info(Icons.headset_mic, AppColors.winningTeal,
                      'Contact support if payment is not reflected'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
            child: Text(text,
                style: AppTextStyles.body1.copyWith(color: context.cTextDim))),
      ],
    );
  }
}
