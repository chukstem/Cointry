import 'package:crypto_app/models/user_model.dart';

class ReviewsModel {
  String id;
  String content;
  String date;
  List<UserModel> userModel;

  ReviewsModel({
  required this.id, required this.content, required this.date, required this.userModel});

  factory ReviewsModel.fromJson(Map<String, dynamic> json) {

    var user=json["user"] as List;
    List<UserModel> userdata=user.map((i) => UserModel.fromJson(i)).toList();

    return ReviewsModel(
      id: json['id'] as String,
      content: json['content'] as String,
      date: json['date'] as String,
      userModel: userdata,
    );
  }
}
