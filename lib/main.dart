import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/core/app_constants.dart';
import 'app/core/initial_binding.dart';
import 'app/core/theme_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_colors.dart';
import 'app/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const SquadUpApp());
}

class SquadUpApp extends StatelessWidget {
  const SquadUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Register core services before the first frame so `.to` accessors resolve.
    InitialBinding().dependencies();
    return Obx(() => GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeController.to.mode.value,
          initialRoute: AppRoutes.splash,
          getPages: AppPages.routes,
          defaultTransition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 300),
          opaqueRoute: true,
          builder: (context, child) {
            // Cap text scaling so layouts stay pixel-stable on every device.
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: media.textScaler.clamp(maxScaleFactor: 1.1),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        ));
  }
}
