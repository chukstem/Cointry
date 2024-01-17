class TimelineImagesModel {
  String url;

  TimelineImagesModel({required this.url});

  factory TimelineImagesModel.fromJson(Map<String, dynamic> json) {
    return TimelineImagesModel(
      url: json['url'] as String,
    );
  }
}