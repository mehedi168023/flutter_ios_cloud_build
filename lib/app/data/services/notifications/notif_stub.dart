/// Web / no-op implementation. Used when `dart:io` is unavailable (web),
/// where flutter_local_notifications has no platform support.
class LocalNotifier {
  Future<void> init() async {}

  Future<bool> requestPermission() async => true;

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    // No OS notification on web; the in-app list still records it.
  }
}
