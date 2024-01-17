import 'package:crypto_app/models/user_model.dart';

class ConversationsModel {
  String id;
  String content;
  String date;
  String read;
  String unread;
  String imgUrl;
  List<UserModel> to;
  List<UserModel> from;
  bool loading;

  ConversationsModel({
  required this.id, required this.content, required this.date, required this.read, required this.unread,  required this.imgUrl, required this.to, required this.from, required this.loading});

  factory ConversationsModel.fromJson(Map<String, dynamic> json) {

    var tolist=json["to"] as List;
    var fromlist=json["from"] as List;
    List<UserModel> todata=tolist.map((i) => UserModel.fromJson(i)).toList();
    List<UserModel> fromdata=fromlist.map((i) => UserModel.fromJson(i)).toList();

    return ConversationsModel(
      id: json['id'] as String,
      content: json['text'] as String,
      date: json['timestamp'] as String,
      read: json['read'] as String,
      unread: json['unread'] as String,
      imgUrl: json['imgUrl'] as String,
      to: todata,
      from: fromdata,
      loading: false,
    );
  }
}
