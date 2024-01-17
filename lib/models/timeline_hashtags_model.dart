
class HashtagsModel {
  String subject;
  String total;

  HashtagsModel({
    required this.subject, required this.total});

  factory HashtagsModel.fromJson(Map<String, dynamic> json) {

    return HashtagsModel(
      subject: json['subject'] as String,
        total: json['total'] as String
    );
  }
}
