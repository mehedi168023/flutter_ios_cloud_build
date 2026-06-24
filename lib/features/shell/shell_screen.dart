import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/core/notice_popup.dart';
import '../../app/data/services/permission_service.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../shop/shop_screen.dart';

class ShellController extends GetxController {
  // Index 1 = Home (the default landing tab, center of the nav bar).
  final index = 1.obs;
  void go(int i) => index.value = i;

  @override
  void onReady() {
    super.onReady();
    // Show the launch notice popup once per app launch (after the first frame).
    WidgetsBinding.instance
        .addPostFrameCallback((_) => NoticePopup.showIfFirstLaunch());
    // Request the permissions the app uses (notification / file-image).
    Future(() => PermissionService.to.requestAll());
  }
}

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  static const _tabs = [ShopScreen(), HomeScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ShellController());
    return Scaffold(
      body: Obx(() => IndexedStack(index: c.index.value, children: _tabs)),
      bottomNavigationBar:
          Obx(() => _NavBar(current: c.index.value, onTap: c.go)),
    );
  }
}

/// Floating, rounded bottom navigation bar with a gradient "glow pill" that
/// slides smoothly to the active tab (professional animated nav).
class _NavBar extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _NavBar({required this.current, required this.onTap});

  static const _items = [
    (Icons.storefront_outlined, Icons.storefront, 'Shop'),
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.person_outline, Icons.person_rounded, 'Profile'),
  ];

  static const _slide = Duration(milliseconds: 360);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border(top: BorderSide(color: context.cBorder)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: SizedBox(
              height: 54,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final slot = constraints.maxWidth / _items.length;
                  return Stack(
                    children: [
                      // Sliding glow pill behind the active tab.
                      AnimatedPositioned(
                        duration: _slide,
                        curve: Curves.easeOutCubic,
                        left: current * slot,
                        top: 0,
                        bottom: 0,
                        width: slot,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF3B7BF0), Color(0xFF16357D)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF6AA1FF)
                                    .withValues(alpha: 0.7),
                                width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                blurRadius: 18,
                                spreadRadius: -3,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(_items.length, (i) {
                          final active = i == current;
                          final item = _items[i];
                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onTap(i),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedScale(
                                    duration: _slide,
                                    curve: Curves.easeOutBack,
                                    scale: active ? 1.0 : 0.9,
                                    child: TweenAnimationBuilder<double>(
                                      duration: _slide,
                                      curve: Curves.easeOut,
                                      tween: Tween(end: active ? 1 : 0),
                                      builder: (_, t, __) => Icon(
                                        active ? item.$2 : item.$1,
                                        size: 23,
                                        color: Color.lerp(
                                            context.cTextDim, Colors.white, t),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  AnimatedDefaultTextStyle(
                                    duration: _slide,
                                    curve: Curves.easeOut,
                                    style: AppTextStyles.label.copyWith(
                                      color: active
                                          ? Colors.white
                                          : context.cTextDim,
                                      fontWeight: active
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                      fontSize: active ? 12.5 : 11.5,
                                    ),
                                    child: Text(item.$3),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
