import 'package:get/get.dart';
import '../mock/mock_data.dart';
import '../models/match_model.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';

/// In-memory mock backend. Replace each method body with a real REST call to the
/// Pure-PHP backend (`https://panel.playtourbd.com/api/`) when wiring it up.
class SessionService extends GetxService {
  static SessionService get to => Get.find();

  final Rxn<UserModel> user = Rxn<UserModel>();
  final Rx<WalletModel> wallet = MockData.wallet.obs;
  final RxList<FfMatch> matches = <FfMatch>[].obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  bool get isLoggedIn => user.value != null;

  static const _delay = Duration(milliseconds: 700);

  @override
  void onInit() {
    super.onInit();
    matches.assignAll(MockData.matches);
  }

  Future<bool> login(String phoneOrEmail, String password) async {
    await Future.delayed(_delay);
    user.value = MockData.user;
    wallet.value = MockData.wallet;
    return true;
  }

  Future<bool> register(
      String name, String phoneOrEmail, String password) async {
    await Future.delayed(_delay);
    user.value = MockData.user.copyWith(name: name);
    wallet.value = MockData.wallet;
    return true;
  }

  void logout() {
    user.value = null;
    transactions.clear();
    matches.assignAll(MockData.matches);
  }

  Future<void> refreshMatches() async {
    await Future.delayed(_delay);
    matches.assignAll(MockData.matches);
  }

  List<FfMatch> matchesForMode(String modeKey) =>
      matches.where((m) => m.modeKey == modeKey).toList();

  List<FfMatch> get joinedMatches => matches.where((m) => m.isJoined).toList();

  /// Join a match: deduct entry fee, mark joined, add a transaction row.
  Future<bool> joinMatch(FfMatch match, List<String> playerNames) async {
    await Future.delayed(_delay);
    final idx = matches.indexWhere((m) => m.id == match.id);
    if (idx == -1) return false;
    matches[idx] = matches[idx].copyWith(
      isJoined: true,
      slotsTaken: matches[idx].slotsTaken + 1,
    );
    matches.refresh();
    _addTx(TxType.join, match.entryFee, 'System', 'Joined ${match.title}');
    return true;
  }

  Future<bool> deposit(double amount) async {
    await Future.delayed(_delay);
    wallet.value = wallet.value
        .copyWith(availableBalance: wallet.value.availableBalance + amount);
    _addTx(TxType.deposit, amount, 'Gateway', 'Wallet top-up');
    return true;
  }

  Future<bool> withdraw(double amount, String channel) async {
    await Future.delayed(_delay);
    if (amount > wallet.value.withdrawableBalance) return false;
    _addTx(TxType.withdraw, amount, channel, 'Withdraw to $channel');
    return true;
  }

  Future<void> updateProfile({required String name}) async {
    await Future.delayed(_delay);
    user.value = user.value?.copyWith(name: name);
  }

  Future<bool> changePassword(String current, String next) async {
    await Future.delayed(_delay);
    return current.isNotEmpty && next.isNotEmpty;
  }

  void _addTx(TxType type, double amount, String method, String desc) {
    transactions.insert(
      0,
      TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        type: type,
        amount: amount,
        status: 'success',
        method: method,
        date: DateTime.now(),
        description: desc,
      ),
    );
  }
}
