/// App-wide constants. Brand is white-label: the deployed instance shows
/// "WAR ZONE" in-app while the store/splash identity is "Play Tour".
class AppConstants {
  AppConstants._();

  static const String appName = 'SquadUp';
  static const String brandName = 'SquadUp';
  static const String tagline = 'Tournament';
  static const String appVersion = '1.0.0';

  /// Bangladeshi Taka symbol used throughout the UI.
  static const String currency = '৳'; // ৳

  // Brand assets (extracted from the original APK).
  static const String logo = 'assets/images/logo.png';
  static const String freefireLogo = 'assets/images/freefire_logo.png';
  static const String ludoClassic = 'assets/images/ludo_classic.png';
  static const String ludoAuto = 'assets/images/ludo_auto.webp';
  static const String ffTopup = 'assets/images/ff_topup.webp';
  static const String ludoKingpass = 'assets/images/ludo_kingpass.webp';
  static const String ludoUidGuide = 'assets/images/ludo_uid_guide.webp';
  // Banners.
  static const String shopProductsBanner = 'assets/images/shop_products.jpg';
  static const String shopTopupBanner = 'assets/images/shop_topup.jpg';
  static const String bannerAddMoney = 'assets/images/banner_admoney.webp';
  static const String bannerHowToPlay = 'assets/images/banner_howtoplay.webp';
  static const String bannerJoinGroup = 'assets/images/banner_joingroup.webp';

  /// Demo credentials shown on the login screen (mock auth).
  static const String demoEmail = 'demo@squadup.gg';
  static const String demoPassword = 'play1234';
}

/// Formats an amount with the Taka symbol, e.g. `৳1,250`.
String taka(num value) {
  final s = value.toStringAsFixed(0);
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '${AppConstants.currency}$buf';
}
