import 'network_model.dart';

class CryptoTransactionsModel {
  String hash;
  String title;
  String time;
  String amount;
  String charge;
  String final_amount;
  String status;
  String to;
  String total;
  String img;

  CryptoTransactionsModel({
  required this.hash, required this.title, required this.time, required this.amount, required this.final_amount, required this.charge , required this.status, required this.to, required this.total, required this.img});

  factory CryptoTransactionsModel.fromJson(Map<String, dynamic> json) {
    return CryptoTransactionsModel(
      hash: json['hash'] as String,
      title: json['title'] as String,
      time: json['time'] as String,
      amount: json['amount'] as String,
      final_amount: json['final_amount'] as String,
      charge: json['charge'] as String,
      status: json['status'] as String,
      to: json['to'] as String,
      total: json['total'] as String,
      img: json['imgUrl'] as String,
    );
  }
}
