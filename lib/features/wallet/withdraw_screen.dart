import 'package:flutter/material.dart';
import '../../app/core/app_toast.dart';
import 'package:get/get.dart';
import '../../app/core/app_constants.dart';
import '../../app/data/mock/mock_data.dart';
import '../../app/data/services/session_service.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/widgets/common_widgets.dart';
import '../../app/widgets/primary_button.dart';
import '../../app/widgets/responsive.dart';

class WithdrawController extends GetxController {
  final channel = 0.obs;
  final number = TextEditingController();
  final amount = TextEditingController();
  final loading = false.obs;

  @override
  void onClose() {
    number.dispose();
    amount.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    final amt = double.tryParse(amount.text.trim());
    if (number.text.trim().isEmpty) {
      AppToast.error('Enter your wallet number');
      return;
    }
    if (amt == null || amt < MockData.minWithdraw) {
      AppToast.error('Minimum withdraw is ${taka(MockData.minWithdraw)}');
      return;
    }
    loading.value = true;
    final label = MockData.withdrawChannels[channel.value].label;
    final ok = await SessionService.to.withdraw(amt, label);
    loading.value = false;
    if (ok) {
      Get.back();
      AppToast.success('Withdraw request submitted');
    } else {
      AppToast.error('Insufficient winning balance.');
    }
  }
}

class WithdrawScreen extends StatelessWidget {
  const WithdrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(WithdrawController());
    const channels = MockData.withdrawChannels;

    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw')),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Center(
                child: Text('CHOOSE YOUR PAYMENT CHANNEL',
                    style: AppTextStyles.caption)),
            const SizedBox(height: 11),
            Obx(() => Row(
                  children: List.generate(channels.length, (i) {
                    final active = c.channel.value == i;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i == 0 ? 12 : 0),
                        child: GestureDetector(
                          onTap: () => c.channel.value = i,
                          child: Container(
                            height: 130,
                            decoration: BoxDecoration(
                              color: context.cSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: active
                                    ? AppColors.success
                                    : context.cBorder,
                                width: active ? 2 : 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: channels[i].color,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: const Icon(
                                            Icons.account_balance_wallet,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(channels[i].label,
                                          style: AppTextStyles.title
                                              .copyWith(fontSize: 16)),
                                    ],
                                  ),
                                ),
                                if (active)
                                  const Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      radius: 11,
                                      backgroundColor: AppColors.success,
                                      child: Icon(Icons.check,
                                          size: 14, color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                )),
            const SizedBox(height: 13),
            TextField(
              controller: c.number,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              style: AppTextStyles.body1,
              decoration: const InputDecoration(
                  labelText: 'Wallet Number',
                  hintText: 'Enter your wallet number'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: c.amount,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => c.submit(),
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
            const SizedBox(height: 8),
            Text(
                'Min: ${taka(MockData.minWithdraw)}  ·  Max: ${taka(MockData.maxWithdraw)}',
                style: AppTextStyles.body2),
            const SizedBox(height: 13),
            Obx(() => PrimaryButton(
                  label: 'WITHDRAW',
                  variant: ButtonVariant.red,
                  loading: c.loading.value,
                  onPressed: c.submit,
                )),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.trending_up,
                        color: AppColors.winningTeal),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                      child: Text('Your Withdrawal Balance is:',
                          style: AppTextStyles.body1)),
                  Obx(() => Text(
                      taka(SessionService.to.wallet.value.withdrawableBalance),
                      style: AppTextStyles.h3
                          .copyWith(color: AppColors.winningTeal))),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Text(MockData.withdrawNotice,
                  style: AppTextStyles.body1.copyWith(height: 1.6)),
            ),
          ],
        ),
      ),
    );
  }
}
