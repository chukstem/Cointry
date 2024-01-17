import 'package:crypto_app/models/timeline_images_model.dart';
import 'package:crypto_app/models/timeline_media_model.dart';
import 'package:crypto_app/models/user_model.dart';

class TimelineCommentRepliesModel {
  String id;
  String content;
  String date;
  List<UserModel> userModel;

  TimelineCommentRepliesModel({
  required this.id, required this.content, required this.date, required this.userModel});

  factory TimelineCommentRepliesModel.fromJson(Map<String, dynamic> json) {

    var user=json["user"] as List;
    List<UserModel> userdata=user.map((i) => UserModel.fromJson(i)).toList();

    return TimelineCommentRepliesModel(
      id: json['id'] as String,
      content: json['content'] as String,
      date: json['date'] as String,
      userModel: userdata,
    );
  }
}
