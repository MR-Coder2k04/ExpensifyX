import 'package:uuid/uuid.dart';

enum walletType { private, public }

class Walletmodel {
  Walletmodel({
    required this.WalletName,
    required this.Amount,
    String? givenuserID,
    String? Wallet,
    String? pass,
    required this.type,
  }) : userID = givenuserID ?? "Default",
       walletId = Wallet ?? Uuid().v4(),
       password = pass;

  final String WalletName;
  final int Amount;
  final walletType type;
  final String walletId;
  final String userID;
  final String? password;
}
