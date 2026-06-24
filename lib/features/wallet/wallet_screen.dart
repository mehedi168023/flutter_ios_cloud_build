import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/core/app_sheets.dart';
import '../../app/core/app_constants.dart';
import '../../app/data/services/session_service.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/widgets/common_widgets.dart';
import '../../app/widgets/primary_button.dart';
import '../../app/widgets/responsive.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionService.to;
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            AppCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF14253F), Color(0xFF0E1A2C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              padding: const EdgeInsets.all(14),
              child: Obx(() {
                final w = session.wallet.value;
                return Column(
                  children: [
                    Text('Available Balance',
                        style: AppTextStyles.body1
                            .copyWith(color: context.cTextDim)),
                    const SizedBox(height: 6),
                    Text(taka(w.availableBalance),
                        style: AppTextStyles.h1.copyWith(fontSize: 32)),
                    const SizedBox(height: 11),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: context.cBgAlt.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: const Border(
                            left: BorderSide(
                                color: AppColors.winningTeal, width: 3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.trending_up,
                              color: AppColors.winningTeal, size: 18),
                          const SizedBox(width: 8),
                          Text('Winning Balance',
                              style: AppTextStyles.body1
                                  .copyWith(color: context.cTextDim)),
                          const SizedBox(width: 12),
                          Container(
                              width: 1, height: 16, color: context.cBorder),
                          const SizedBox(width: 12),
                          Text(taka(w.winningBalance),
                              style: AppTextStyles.title
                                  .copyWith(color: AppColors.winningTeal)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Add Money',
                            icon: Icons.add,
                            variant: ButtonVariant.green,
                            height: 46,
                            onPressed: () => Get.toNamed(AppRoutes.deposit),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Withdraw',
                            icon: Icons.arrow_upward,
                            variant: ButtonVariant.red,
                            height: 46,
                            onPressed: () => Get.toNamed(AppRoutes.withdraw),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 15),
            const SectionHeader('QUICK ACTIONS'),
            const SizedBox(height: 12),
            ListNavTile(
              icon: Icons.receipt_long_outlined,
              label: 'Transaction History',
              subtitle: 'View all your transactions',
              onTap: () => Get.toNamed(AppRoutes.transactions),
            ),
            const SizedBox(height: 15),
            const SectionHeader('HOW TO GUIDE'),
            const SizedBox(height: 12),
            _guide(context, Icons.add_card, 'How to Add Money?', const [
              'Open the Wallet and tap “Add Money”.',
              'Enter the amount you want to deposit.',
              'Tap “Proceed to Payment” and complete it on the secure gateway.',
              'Your balance is credited instantly after a successful payment.',
            ]),
            const SizedBox(height: 12),
            _guide(context, Icons.sports_esports_outlined,
                'How to Join a Match?', const [
              'Pick a game mode from the Home screen.',
              'Open a match to review the rules and prize pool.',
              'Tap “Join Match”, choose your slot type and enter player names.',
              'The entry fee is deducted and your slot is confirmed.',
            ]),
            const SizedBox(height: 12),
            _guide(context, Icons.account_balance_outlined,
                'How to Withdraw?', const [
              'Open the Wallet and tap “Withdraw”.',
              'Choose bKash or Nagad and enter your wallet number.',
              'Enter an amount between ৳105 and ৳10000.',
              'Submit — your request is processed to the selected channel.',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _guide(
      BuildContext context, IconData icon, String title, List<String> steps) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () => _openGuide(icon, title, steps),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.cSurfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: context.cTextDim, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Text(title,
                  style: AppTextStyles.title.copyWith(fontSize: 15))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book_rounded,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('Guide',
                    style:
                        AppTextStyles.label.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openGuide(IconData icon, String title, List<String> steps) {
    AppSheet.show(
      title: title,
      subtitle: 'Follow these steps:',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Text('${i + 1}',
                        style: AppTextStyles.title
                            .copyWith(color: AppColors.primary, fontSize: 13)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(steps[i],
                        style: AppTextStyles.body1.copyWith(height: 1.5)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
