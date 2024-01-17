import 'package:crypto_app/models/user_model.dart';

class P2PModel {
  String id;
  String amountRate;
  String time;
  String amountCrypto;
  String amountMin;
  String amountMax;
  String paymentMethod;
  String window;
  String rate_attribute;
  String avg_speed;
  String bank_image;
  String terms;
  String details;
  String currency_symbol;
  String fiat_symbol;
  String status;
  String currency_decimals;
  List<UserModel> user;

  P2PModel({
  required this.id, required this.amountRate, required this.time, required this.amountCrypto, required this.amountMin, required this.amountMax, required this.paymentMethod, required this.window, required this.rate_attribute, required this.avg_speed, required this.bank_image, required this.terms, required this.details, required this.currency_symbol,  required this.fiat_symbol, required this.currency_decimals, required this.status, required this.user});

  factory P2PModel.fromJson(Map<String, dynamic> json) {

    var userlist=json["user"] as List;
    List<UserModel> userdata=userlist.map((i) => UserModel.fromJson(i)).toList();

    return P2PModel(
      id: json['id'] as String,
      amountRate: json['rate'] as String,
      time: json['time'] as String,
      amountCrypto: json['amountCrypto'] as String,
      amountMin: json['amountMin'] as String,
      amountMax: json['amountMax'] as String,
      paymentMethod: json['paymentMethod'] as String,
      window: json['window'] as String,
      rate_attribute: json['rate_attribute'] as String,
      avg_speed: json['avg_speed'] as String,
      bank_image: json['bank_image'] as String,
      terms: json['terms'] as String,
      details: json['details'] as String,
      currency_symbol: json['currency_symbol'] as String,
      fiat_symbol: json['fiat_symbol'] as String,
      currency_decimals: json['currency_decimals'] as String,
      status: json['status'] as String,
      user: userdata,
    );
  }


}
