import 'package:get/get.dart';
import '../models/notification_model.dart';
import 'notifications/notif_platform.dart';

/// Manages the in-app notification feed and fires OS notifications (mobile).
class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final LocalNotifier _notifier = LocalNotifier();
  final RxList<AppNotification> items = <AppNotification>[].obs;

  int get unreadCount => items.where((n) => !n.read).length;

  @override
  void onInit() {
    super.onInit();
    _notifier.init();
    _seedDemo();
  }

  Future<bool> requestOsPermission() => _notifier.requestPermission();

  /// Adds a notification to the in-app feed AND pops an OS notification.
  Future<void> push({
    required NotifType type,
    required String title,
    required String body,
    bool osNotify = true,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    items.insert(
        0,
        AppNotification(
            id: id,
            type: type,
            title: title,
            body: body,
            time: DateTime.now()));
    if (osNotify) {
      await _notifier.show(id: id % 100000, title: title, body: body);
    }
  }

  void markAllRead() {
    for (final n in items) {
      n.read = true;
    }
    items.refresh();
  }

  void clearAll() => items.clear();

  /// A test notification triggered from the Notifications screen.
  Future<void> sendTest() => push(
        type: NotifType.system,
        title: 'Test Notification 🔔',
        body: 'This is a demo notification from SquadUp.',
      );

  void _seedDemo() {
    items.assignAll([
      AppNotification(
        id: 1,
        type: NotifType.promo,
        title: 'Weekly Mega Tournament 🔥',
        body: 'Join the BR Solo Time match and win up to ৳160!',
        time: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      AppNotification(
        id: 2,
        type: NotifType.wallet,
        title: 'Wallet Ready',
        body: 'Add money via bKash or Nagad to join paid matches.',
        time: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 3,
        type: NotifType.system,
        title: 'Welcome to SquadUp 🏆',
        body: 'Compete in Free Fire tournaments and earn rewards.',
        time: DateTime.now().subtract(const Duration(days: 1)),
        read: true,
      ),
    ]);
  }
}
