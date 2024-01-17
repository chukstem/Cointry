import 'network_model.dart';

class CryptoModel {
  String id;
  String balance;
  String usdBalance;
  String type;
  List<NetworkModel> networkModel;

  CryptoModel({
  required this.id, required this.balance, required this.usdBalance, required this.type, required this.networkModel});

  factory CryptoModel.fromJson(Map<String, dynamic> json) {
    var networklist=json["network"] as List;
    List<NetworkModel> networkdata=networklist.map((i) => NetworkModel.fromJson(i)).toList();
    return CryptoModel(
      id: json['id'] as String,
      balance: json['balance'] as String,
      usdBalance: json['usd_balance'] as String,
      type: json['type'] as String,
      networkModel: networkdata,
    );
  }
}
