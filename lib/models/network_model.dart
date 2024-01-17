class NetworkModel {
  String address;
  String network_id;
  String network;
  String currency;
  String currency_symbol;
  String price;
  String buy_price;
  String sell_price;
  String low;
  String high;
  String percentage_change;
  String img;
  String deposit_fee;
  String withdraw_fee;
  String cashout_fee;
  String cashout_rate;
  String deposit_fee_fixed;
  String withdraw_fee_fixed;
  String cashout_fee_fixed;
  String user_user_fixed;
  String buy_fee_fixed;
  String buy_fee;
  String sell_fee_fixed;
  String sell_fee;
  String buy_rate;
  String sell_rate;
  String currency_id;
  String decimals;
  String network_symbol;
  String deposit_status;
  String withdraw_status;

  NetworkModel({required this.address, required this.network,  required this.network_id, required this.currency,  required this.currency_symbol, required this.price, required this.buy_price, required this.sell_price, required this.low, required this.high, required this.percentage_change, required this.img, required this.deposit_fee, required this.withdraw_fee, required this.cashout_fee, required this.deposit_fee_fixed, required this.buy_fee_fixed, required this.withdraw_fee_fixed, required this.user_user_fixed, required this.cashout_fee_fixed, required this.sell_fee_fixed, required this.cashout_rate, required this.buy_fee, required this.buy_rate, required this.sell_fee, required this.sell_rate, required this.currency_id, required this.decimals, required this.network_symbol, required this.deposit_status, required this.withdraw_status});

  factory NetworkModel.fromJson(Map<String, dynamic> json) {
    return NetworkModel(
      address: json['address'] as String,
      network: json['network_name'] as String,
      network_id: json['network_id'] as String,
      currency: json['currency_name'] as String,
      currency_symbol: json['currency_symbol'] as String,
      price: json['price'] as String,
      buy_price: json['buy_price'] as String,
      sell_price: json['sell_price'] as String,
      low: json['low'] as String,
      high: json['high'] as String,
      percentage_change: json['percentage_change'] as String,
      img: json['img'] as String,
      deposit_fee: json['deposit_fee'] as String,
      withdraw_fee: json['withdraw_fee'] as String,
      cashout_fee: json['cashout_fee'] as String,
      deposit_fee_fixed: json['deposit_fee_fixed'] as String,
      withdraw_fee_fixed: json['withdraw_fee_fixed'] as String,
      user_user_fixed: json['user_user_fixed'] as String,
      cashout_fee_fixed: json['cashout_fee_fixed'] as String,
      buy_fee_fixed: json['buy_fee_fixed'] as String,
      sell_fee_fixed: json['sell_fee_fixed'] as String,
      cashout_rate: json['cashout_rate'] as String,
      buy_fee: json['buy_fee'] as String,
      sell_fee: json['sell_fee'] as String,
      buy_rate: json['buy_rate'] as String,
      sell_rate: json['sell_rate'] as String,
      currency_id: json['currency_id'] as String,
      decimals: json['decimals'] as String,
      network_symbol: json['network_symbol'] as String,
      deposit_status: json['deposit_status'] as String,
      withdraw_status: json['withdraw_status'] as String,
    );
  }
}