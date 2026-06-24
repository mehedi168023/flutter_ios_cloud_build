/// Wallet balances — mirrors `/api/wallet`.
class WalletModel {
  final double availableBalance;
  final double winningBalance;
  final double withdrawableBalance;
  final double wonAmount;

  const WalletModel({
    this.availableBalance = 0,
    this.winningBalance = 0,
    this.withdrawableBalance = 0,
    this.wonAmount = 0,
  });

  factory WalletModel.fromJson(Map<String, dynamic> j) => WalletModel(
        availableBalance: (j['available_balance'] ?? 0).toDouble(),
        winningBalance: (j['winning_balance'] ?? 0).toDouble(),
        withdrawableBalance: (j['withdrawable_balance'] ?? 0).toDouble(),
        wonAmount: (j['won_amount'] ?? 0).toDouble(),
      );

  WalletModel copyWith({double? availableBalance, double? winningBalance}) =>
      WalletModel(
        availableBalance: availableBalance ?? this.availableBalance,
        winningBalance: winningBalance ?? this.winningBalance,
        withdrawableBalance: withdrawableBalance,
        wonAmount: wonAmount,
      );
}

enum TxType { deposit, withdraw, join, prize, refund }

/// A wallet transaction row.
class TransactionModel {
  final int id;
  final TxType type;
  final double amount;
  final String status; // success | pending | failed
  final String method; // bKash | Nagad | Gateway | System
  final DateTime date;
  final String description;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.method,
    required this.date,
    this.description = '',
  });

  bool get isCredit =>
      type == TxType.deposit || type == TxType.prize || type == TxType.refund;
}
