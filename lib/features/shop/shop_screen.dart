import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/data/mock/mock_data.dart';
import '../../app/data/models/misc_models.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/widgets/brand_app_bar.dart';
import '../../app/widgets/common_widgets.dart';
import '../../app/widgets/promo_banner.dart';
import '../../app/widgets/responsive.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandAppBar(),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const PromoBanner(banners: MockData.shopBanners),
            const SizedBox(height: 14),
            const SectionHeader('TOP-UP STORE'),
            const SizedBox(height: 14),
            for (final cat in MockData.topupCategories) ...[
              _TopupCard(category: cat),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 4),
            const SectionHeader('GAMING STORE'),
            const SizedBox(height: 14),
            const _StoreCard(),
            const SizedBox(height: 18),
            const SectionHeader('WHY CHOOSE US?'),
            const SizedBox(height: 14),
            ...MockData.shopFeatures.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _FeatureCard(feature: f),
                )),
          ],
        ),
      ),
    );
  }
}

class _TopupCard extends StatelessWidget {
  final TopupCategory category;
  const _TopupCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.topup, arguments: category),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: category.colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: category.colors.first.withValues(alpha: 0.5),
              blurRadius: 18,
              spreadRadius: -8,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.asset(category.image,
                    width: 78, height: 78, fit: BoxFit.cover, cacheWidth: 220),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(category.title,
                        style: AppTextStyles.h2
                            .copyWith(color: Colors.white, fontSize: 19)),
                    const SizedBox(height: 5),
                    Text(category.subtitle,
                        style: AppTextStyles.body2.copyWith(
                            color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card linking to the gaming-products (e-commerce) screen.
class _StoreCard extends StatelessWidget {
  const _StoreCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.products),
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A0A40), Color(0xFF120A26)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.shopping_bag_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Gaming Products',
                        style: AppTextStyles.h2
                            .copyWith(color: Colors.white, fontSize: 19)),
                    const SizedBox(height: 4),
                    Text('Headsets · Keyboards · Chairs & more',
                        style: AppTextStyles.body2.copyWith(
                            color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final ShopFeature feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(feature.icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature.title,
                    style: AppTextStyles.title.copyWith(fontSize: 17)),
                const SizedBox(height: 4),
                Text(feature.subtitle, style: AppTextStyles.body2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
