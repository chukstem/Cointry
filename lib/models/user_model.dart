class UserModel {
  String id;
  String username;
  String first_name;
  String last_name;
  String created_on;
  String isFollowed;
  String isBlocked;
  String trades;
  String about;
  String avatar;
  String cover;
  String followers;
  String following;
  String rank;
  String reviews;
  bool loading;

  UserModel({required this.id, required this.username, required this.first_name,  required this.last_name, required this.created_on, required this.isFollowed, required this.isBlocked, required this.trades, required this.about, required this.avatar, required this.cover, required this.followers, required this.following, required this.rank, required this.reviews, required this.loading});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      first_name: json['first_name'] as String,
      last_name: json['last_name'] as String,
      created_on: json['created_on'] as String,
      isFollowed: json['isFollowed'] as String,
      isBlocked: json['isBlocked'] as String,
      trades: json['trades'] as String,
      about: json['about'] as String,
      avatar: json['avatar'] as String,
      cover: json['cover'] as String,
      followers: json['followers'] as String,
      following: json['following'] as String,
      rank: json['rank'] as String,
      reviews: json['reviews'] as String,
      loading: false,
    );
  }
}