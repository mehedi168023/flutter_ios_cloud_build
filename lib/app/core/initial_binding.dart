import 'package:get/get.dart';
import '../data/services/notification_service.dart';
import '../data/services/permission_service.dart';
import '../data/services/session_service.dart';
import 'theme_controller.dart';

/// Registers the always-on services before the first screen builds.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);
    Get.put(SessionService(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    Get.put(PermissionService(), permanent: true);
  }
}
