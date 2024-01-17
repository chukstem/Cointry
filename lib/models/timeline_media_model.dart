class TimelineMediaModel {
  String url;
  String type;
  int playingstatus;

  TimelineMediaModel({required this.url, required this.type, required this.playingstatus});

  factory TimelineMediaModel.fromJson(Map<String, dynamic> json) {
    return TimelineMediaModel(
      url: json['url'] as String,
      type: json['type'] as String,
      playingstatus: 0,
    );
  }
}