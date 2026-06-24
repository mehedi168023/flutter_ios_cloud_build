import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'notification_service.dart';

/// Requests only the runtime permissions the app actually uses: notifications
/// and file/image (photos/storage). Every call is wrapped so a denial or an
/// unsupported-on-web platform never crashes the app.
///
/// Location was intentionally removed — no feature uses it, and requesting it
/// is a privacy red flag / App Store rejection risk.
class PermissionService extends GetxService {
  static PermissionService get to => Get.find();

  final RxBool requested = false.obs;

  /// Called once after the user enters the app. Best-effort on every platform.
  Future<void> requestAll() async {
    if (requested.value) return;
    requested.value = true;

    await _safe(() async {
      // OS notification permission (Android 13+, iOS, and browser on web).
      await NotificationService.to.requestOsPermission();
      await Permission.notification.request();
    });

    // File / image permission — Android photos (13+) and legacy storage.
    if (!kIsWeb) {
      await _safe(() => Permission.photos.request());
      await _safe(() => Permission.storage.request());
    }
  }

  Future<void> _safe(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Permission unsupported / denied / unavailable on this platform — ignore.
    }
  }
}
