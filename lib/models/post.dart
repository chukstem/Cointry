class Post{
  final String user;
  final String content;
  final String url;
  final String var1;
  final int retries;
  final String uid;
  Post({required this.user, required this.content, required this.url, required this.var1, required this.retries, required this.uid});
  Map toJson() => {
    'user': user,
    'content': content,
    'url': url,
    'var1': var1,
    'retries': retries,
    'uid': uid,
  };
}