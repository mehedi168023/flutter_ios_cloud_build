import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Mobile implementation backed by flutter_local_notifications.
class LocalNotifier {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@drawable/ic_notification');
    const ios = DarwinInitializationSettings();
    await _plugin
        .initialize(const InitializationSettings(android: android, iOS: ios));
    _ready = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return granted ?? true;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'squadup_demo',
        'SquadUp',
        channelDescription: 'SquadUp tournament notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details);
  }
}
