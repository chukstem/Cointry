class NotificationsModel {
  String title;
  String desc;
  String time;

  NotificationsModel({
  required this.title, required this.desc, required this.time});

  factory NotificationsModel.fromJson(Map<String, dynamic> json) {
    return NotificationsModel(
      title: json['subject'] as String,
      desc: json['body'] as String,
      time: json['date_time'] as String,
    );
  }
}