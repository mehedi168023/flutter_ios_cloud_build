import 'package:get/get.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/edit_profile/edit_profile_screen.dart';
import '../../features/home/free_fire_screen.dart';
import '../../features/home/ludo_join_screen.dart';
import '../../features/home/ludo_match_list_screen.dart';
import '../../features/home/ludo_screen.dart';
import '../../features/home/upload_evidence_screen.dart';
import '../../features/shop/products_screen.dart';
import '../../features/shop/topup_screen.dart';
import '../../features/matches/join_match_screen.dart';
import '../../features/matches/match_info_screen.dart';
import '../../features/matches/match_list_screen.dart';
import '../../features/matches/match_rules_screen.dart';
import '../../features/misc/info_screens.dart';
import '../../features/my_matches/my_matches_screen.dart';
import '../../features/shell/shell_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/top_players/top_players_screen.dart';
import '../../features/wallet/deposit_screen.dart';
import '../../features/wallet/deposit_webview_screen.dart';
import '../../features/wallet/transactions_screen.dart';
import '../../features/wallet/wallet_screen.dart';
import '../../features/wallet/withdraw_screen.dart';
import 'app_routes.dart';

/// All GetX named routes. Transitions kept consistent (cupertino) app-wide.
class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),
    GetPage(name: AppRoutes.shell, page: () => const ShellScreen()),
    GetPage(name: AppRoutes.freeFire, page: () => const FreeFireScreen()),
    GetPage(name: AppRoutes.ludo, page: () => const LudoScreen()),
    GetPage(
        name: AppRoutes.ludoMatchList, page: () => const LudoMatchListScreen()),
    GetPage(name: AppRoutes.ludoJoin, page: () => const LudoJoinScreen()),
    GetPage(name: AppRoutes.topup, page: () => const TopupScreen()),
    GetPage(name: AppRoutes.products, page: () => const ProductsScreen()),
    GetPage(
        name: AppRoutes.uploadEvidence,
        page: () => const UploadEvidenceScreen()),
    GetPage(name: AppRoutes.matchList, page: () => const MatchListScreen()),
    GetPage(name: AppRoutes.matchInfo, page: () => const MatchInfoScreen()),
    GetPage(name: AppRoutes.joinMatch, page: () => const JoinMatchScreen()),
    GetPage(name: AppRoutes.matchRules, page: () => const MatchRulesScreen()),
    GetPage(name: AppRoutes.myMatches, page: () => const MyMatchesScreen()),
    GetPage(name: AppRoutes.wallet, page: () => const WalletScreen()),
    GetPage(name: AppRoutes.deposit, page: () => const DepositScreen()),
    GetPage(
        name: AppRoutes.depositWebview,
        page: () => const DepositWebviewScreen()),
    GetPage(name: AppRoutes.withdraw, page: () => const WithdrawScreen()),
    GetPage(
        name: AppRoutes.transactions, page: () => const TransactionsScreen()),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileScreen()),
    GetPage(name: AppRoutes.topPlayers, page: () => const TopPlayersScreen()),
    GetPage(name: AppRoutes.terms, page: () => const TermsScreen()),
    GetPage(name: AppRoutes.developer, page: () => const DeveloperScreen()),
  ];
}
