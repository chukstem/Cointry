class MarketsModel {
  String img;
  String pair;
  String price;
  String low;
  String high;
  String percentage_change;
  String prefix_currency_id;
  String suffix_currency_id;

  MarketsModel({required this.img, required this.pair, required this.price, required this.low, required this.high, required this.percentage_change, required this.prefix_currency_id, required this.suffix_currency_id});

  factory MarketsModel.fromJson(Map<String, dynamic> json) {
    return MarketsModel(
      img: json['img'] as String,
      pair: json['pair'] as String,
      price: json['price'] as String,
      low: json['low'] as String,
      high: json['high'] as String,
      percentage_change: json['percentage_change'] as String,
      prefix_currency_id: json['prefix_currency_id'] as String,
      suffix_currency_id: json['suffix_currency_id'] as String,
    );
  }


}