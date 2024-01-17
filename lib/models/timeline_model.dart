import 'package:crypto_app/models/timeline_images_model.dart';
import 'package:crypto_app/models/timeline_media_model.dart';
import 'package:crypto_app/models/user_model.dart';

class TimelineModel {
  String id;
  String content;
  String date;
  String likes;
  String comments;
  String views;
  String isLiked;
  List<TimelineImagesModel> imagesModel;
  List<TimelineMediaModel> mediaModel;
  List<UserModel> followersModel;
  List<UserModel> userModel;

  TimelineModel({
  required this.id, required this.content, required this.date, required this.likes, required this.comments, required this.views, required this.isLiked, required this.imagesModel, required this.mediaModel, required this.followersModel, required this.userModel});

  factory TimelineModel.fromJson(Map<String, dynamic> json) {
    var imageslist=json["images"] as List;
    List<TimelineImagesModel> imagesdata=imageslist.map((i) => TimelineImagesModel.fromJson(i)).toList();

    var medialist=json["media"] as List;
    List<TimelineMediaModel> mediadata=medialist.map((i) => TimelineMediaModel.fromJson(i)).toList();

    var followerslist=json["recommendations"] as List;
    List<UserModel> followersdata=followerslist.map((i) => UserModel.fromJson(i)).toList();

    var user=json["user"] as List;
    List<UserModel> userdata=user.map((i) => UserModel.fromJson(i)).toList();

    return TimelineModel(
      id: json['id'] as String,
      content: json['content'] as String,
      date: json['date'] as String,
      likes: json['likes'] as String,
      comments: json['comments'] as String,
      views: json['views'] as String,
      isLiked: json['isLiked'] as String,
      imagesModel: imagesdata,
      mediaModel: mediadata,
      followersModel: followersdata,
      userModel: userdata,
    );
  }
}
