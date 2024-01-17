import 'package:crypto_app/models/crypto_transactions_model.dart';
import 'package:crypto_app/models/fiat_transaction_model.dart';

class TransactionsModel {
  List<CryptoTransactionsModel> deposit;
  List<CryptoTransactionsModel> withdraw;
  List<CryptoTransactionsModel> fiat_deposit;
  List<CryptoTransactionsModel> fiat_withdraw;
  List<CryptoTransactionsModel> swap;
  List<FiatTransactionModel> bills;

  TransactionsModel({
    required this.deposit, required this.withdraw, required this.fiat_deposit, required this.fiat_withdraw, required this.swap, required this.bills});

  factory TransactionsModel.fromJson(Map<String, dynamic> json) {
    var depositlist=json["deposit"] as List;
    List<CryptoTransactionsModel> depositdata=depositlist.map((i) => CryptoTransactionsModel.fromJson(i)).toList();

    var withdrawlist=json["withdraw"] as List;
    List<CryptoTransactionsModel> withdrawdata=withdrawlist.map((i) => CryptoTransactionsModel.fromJson(i)).toList();

    var fiatdepositlist=json["fiat_deposit"] as List;
    List<CryptoTransactionsModel> fiatdepositdata=fiatdepositlist.map((i) => CryptoTransactionsModel.fromJson(i)).toList();

    var fiatwithdrawlist=json["fiat_withdraw"] as List;
    List<CryptoTransactionsModel> fiatwithdrawdata=fiatwithdrawlist.map((i) => CryptoTransactionsModel.fromJson(i)).toList();

    var swaplist=json["swap"] as List;
    List<CryptoTransactionsModel> swapdata=swaplist.map((i) => CryptoTransactionsModel.fromJson(i)).toList();

    var billslist=json["bills"] as List;
    List<FiatTransactionModel> billsdata=billslist.map((i) => FiatTransactionModel.fromJson(i)).toList();


    return TransactionsModel(
      deposit: depositdata,
      withdraw: withdrawdata,
      fiat_deposit: fiatdepositdata,
      fiat_withdraw: fiatwithdrawdata,
      swap: swapdata,
      bills: billsdata,
    );
  }
}

