import 'package:crypto_app/models/user_model.dart';

class TradingModel {
  String id;
  String amountRate;
  String time;
  String amount;
  String amountCrypto;
  String status;
  String window;
  String endMin;
  String terms;
  String details;
  String currency_symbol;
  String fiat_symbol;
  String currency_decimals;
  String bankname;
  String accountname;
  String accountnumber;
  String type;
  List<UserModel> buyer;
  List<UserModel> seller;

  TradingModel({
    required this.id, required this.amountRate, required this.time, required this.endMin, required this.amountCrypto, required this.amount, required this.status, required this.window, required this.terms, required this.details, required this.currency_symbol,  required this.fiat_symbol, required this.currency_decimals, required this.type, required this.bankname, required this.accountname, required this.accountnumber, required this.buyer, required this.seller});

  factory TradingModel.fromJson(Map<String, dynamic> json) {

    var buyerlist=json["buyer"] as List;
    List<UserModel> buyerdata=buyerlist.map((i) => UserModel.fromJson(i)).toList();

    var sellerlist=json["seller"] as List;
    List<UserModel> sellerdata=sellerlist.map((i) => UserModel.fromJson(i)).toList();

    return TradingModel(
      id: json['id'] as String,
      amountRate: json['rate'] as String,
      time: json['time'] as String,
      endMin: json['endMin'] as String,
      amountCrypto: json['amountCrypto'] as String,
      amount: json['amount'] as String,
      status: json['status'] as String,
      window: json['window'] as String,
      terms: json['terms'] as String,
      details: json['details'] as String,
      currency_symbol: json['currency_symbol'] as String,
      fiat_symbol: json['fiat_symbol'] as String,
      currency_decimals: json['currency_decimals'] as String,
      type: json['type'] as String,
      bankname: json['bank_name'] as String,
      accountname: json['account_name'] as String,
      accountnumber: json['account_number'] as String,
      buyer: buyerdata,
      seller: sellerdata
    );
  }


}
