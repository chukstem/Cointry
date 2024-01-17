import 'package:crypto_app/models/timeline_hashtags_model.dart';
import 'package:crypto_app/models/timeline_model.dart';
import 'package:crypto_app/models/user_model.dart';

class ExploreModel {
  List<TimelineModel> timeline;
  List<UserModel> followers;
  List<UserModel> following;
  List<UserModel> findpeople;
  List<HashtagsModel> hashtags;

  ExploreModel({
  required this.timeline, required this.followers, required this.following, required this.findpeople, required this.hashtags});

  factory ExploreModel.fromJson(Map<String, dynamic> json) {
    var timelinelist=json["timeline"] as List;
    List<TimelineModel> timelinedata=timelinelist.map((i) => TimelineModel.fromJson(i)).toList();

    var followerslist=json["followers"] as List;
    List<UserModel> followersdata=followerslist.map((i) => UserModel.fromJson(i)).toList();

    var followinglist=json["following"] as List;
    List<UserModel> followingdata=followinglist.map((i) => UserModel.fromJson(i)).toList();

    var findpeople=json["people"] as List;
    List<UserModel> findpeopledata=findpeople.map((i) => UserModel.fromJson(i)).toList();

    var hashtag=json["hashtags"] as List;
    List<HashtagsModel> hashtagdata=hashtag.map((i) => HashtagsModel.fromJson(i)).toList();

    return ExploreModel(
      timeline: timelinedata,
      followers: followersdata,
      following: followingdata,
      findpeople: findpeopledata,
      hashtags: hashtagdata,
    );
  }
}
