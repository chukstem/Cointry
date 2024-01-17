
class AirdropsModel {
  String img;
  String title;
  String amount;
  String content;

  AirdropsModel({required this.img, required this.title, required this.amount, required this.content});

  factory AirdropsModel.fromJson(Map<String, dynamic> json) {
    return AirdropsModel(
      img: json['img'] as String,
      title: json['title'] as String,
      amount: json['amount'] as String,
      content: json['content'] as String,
    );
  }
}
