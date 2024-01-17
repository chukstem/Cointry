import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:easy_load_more/easy_load_more.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toast/toast.dart';
import '../../../constants.dart';
import '../../../helper/networklayer.dart';
import '../../models/post.dart';
import '../../models/reviews.dart';
import '../../models/user_model.dart';
import '../../size_config.dart';
import '../../widgets/material.dart';
import '../profile/user_profile_screen.dart';

class Reviews extends StatefulWidget {
  static String routeName = "/reviews";
  String username;
  bool postReview;
  Reviews({Key? key, required this.username, required this.postReview}) : super(key: key);

  @override
  _Reviews createState() => _Reviews();
}


class _Reviews extends State<Reviews> {
  bool error = false, showprogress = false, wallet_button = false, success = false;
  String name = "", cover="", wallet = "0.0", email = "", username = "", amount = "", avatar="", token = "", content = "", errormsg="";


  List<ReviewsModel> tList = List.empty(growable: true);
  bool loading = true;


  fetchReviews() async {
    setState(() {
      loading = true;
    });
    try {
      List<ReviewsModel> iList = await getReviews(
          http.Client(), widget.username, "0");
      setState(() {
        loading = false;
        tList = iList;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  bool stopRefresh=false;
  addItems() async {
    int length=tList.length+1;
    try {
      List<ReviewsModel> iList = await getReviews(
          http.Client(), widget.username, "$length");
      setState(() {
        loading = false;
        tList.addAll(iList);
        if(iList.isEmpty){
          stopRefresh=true;
        }
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }


  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var fname = prefs.getString("firstname");
      var lname = prefs.getString("lastname");
      name = "$fname $lname";
      email = prefs.getString("email")!;
      username = prefs.getString("username")!;
      token = prefs.getString("token")!;
      avatar = prefs.getString("avatar")!;
      cover = prefs.getString("cover")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getuser();
    Timer(Duration(seconds: 1), () =>
    {
      fetchReviews(),
    });
  }


  @override
  void dispose() {
    super.dispose();
  }

  int counter = 0;


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: kSecondary,
      appBar: AppBar(title: Text(widget.username+"'s Reviews", style: TextStyle(
          color: kPrimaryDarkColor,
          fontWeight: FontWeight.bold,
          fontSize: 22),)),
      body: RefreshIndicator(
        onRefresh: () {
        return fetchReviews();
      },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.only(top: 30),
                color: kSecondary,
                child: Column(
                  children: [
                    TimelineReplies(),
                  ],
                ),
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.postReview==true ? FloatingActionButton.extended(
        onPressed: () {
          _post(context);
        },
        label: Text('Add Review'),
        icon: Icon(Icons.add_comment),
        backgroundColor: kPrimaryVeryLightColor,
      ) : SizedBox(),
    );
  }


  Widget TimelineReplies() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              loading ? Container(
                  height: 300,
                  color: kSecondary,
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                      child: CircularProgressIndicator()))
                  :
              tList!.length <= 0 ?
              Container(
                height: 80,
                color: kSecondary,
                margin: EdgeInsets.all(20),
                child: Center(
                  child: Text("No Reviews Yet!", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: kPrimaryColor),),
                ),
              ) :
              RefreshIndicator(
                onRefresh: _refresh,
                child: EasyLoadMore(
                  isFinished: tList!.length < 30 || tList.length >= 500 || stopRefresh,
                  onLoadMore: _loadMore,
                  runOnEmptyResult: false,
                  child: ListView.builder(
                      controller: _controller,
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 0),
                      itemCount: tList!.length,
                      itemBuilder: (context, index) {
                        return getRepliesItem(
                            tList![index], index, context);
                      })
                ),
              ),
              SizedBox(height: 20,)
            ]
        );
      },
    );
  }

  Future<bool> _loadMore() async {
    await Future.delayed(
      Duration(
        seconds: 0,
        milliseconds: 2000,
      ),
    );

    if(stopRefresh==false){ addItems();}
    return true;
  }

  Future<void> _refresh() async {
    await Future.delayed(
      Duration(
        seconds: 0,
        milliseconds: 2000,
      ),
    );


    fetchReviews();
  }

  Column getRepliesItem(ReviewsModel obj, int index,
      BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 50.0),
              child: Card(
                color: kWhite,
                margin: EdgeInsets.only(left: 10.0, right: 10, bottom: 20),
                child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                        left: 5.0, right: 5, top: 10, bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                alignment: Alignment.topLeft,
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                      if(username!=obj.userModel.first.username){
                                      //  Navigator.pushReplacement(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => UserProfile(user: obj.userModel.first,)));
                                      }
                                      },
                                      child: Text(
                                        obj.userModel.first.first_name + " " +
                                            obj.userModel.first.last_name,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 17.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    obj.userModel.first.rank == "0" ?
                                    Icon(
                                      Icons.verified_user, color: kSecondary,
                                      size: 10,) :
                                    obj.userModel.first.rank == "1" ?
                                    Icon(Icons.verified_user,
                                      color: kPrimaryLightColor, size: 10,) :
                                    Row(mainAxisAlignment: MainAxisAlignment
                                        .start,
                                      children: [
                                        Icon(Icons.star,
                                          color: obj.userModel.first.rank ==
                                              "3"
                                              ? Colors.orangeAccent
                                              : kPrimaryVeryLightColor,
                                          size: 10,),
                                        SizedBox(width: 2,),
                                        Icon(Icons.verified_user,
                                          color: kPrimaryLightColor, size: 10,),
                                      ],),
                                    SizedBox(width: 4,),
                                    Text(
                                      "@" + obj.userModel.first.username,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black45,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                )
                            ),
                            SizedBox(width: 10,),
                            Container(
                              alignment: Alignment.topRight,
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.20,
                              child: Text(
                                obj.date,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black45,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(left: 5, top: 5),
                          child: Text(obj.content,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black45,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 6,
                          ),
                        ),
                      ],
                    )
                ),
              ),
            ),
            Positioned(
              top: 0.0,
              bottom: 0.0,
              left: 35.0,
              child: Container(
                height: double.infinity,
                width: 1.0,
                color: Colors.grey,
              ),
            ),
            Positioned(
              top: 20.0,
              left: 15.0,
              child: InkWell(
                onTap: () {
                  if(username!=obj.userModel.first.username){
                   // Navigator.pushReplacement(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => UserProfile(user: obj.userModel.first,)));
                  }
                },
                child: Container(
                    height: 40,
                    width: 40,
                    child: CircleAvatar(
                      radius: 45,
                      child: Padding(
                        padding: EdgeInsets.all(1), // Border radius
                        child: ClipOval(child: CachedNetworkImage(
                          height: 40,
                          width: 40,
                          imageUrl: obj.userModel.first.avatar,
                          fit: BoxFit.cover,),),
                      ),
                    ),
                    padding: EdgeInsets.all(1),
                    decoration: new BoxDecoration(
                      color: kSecondary, // border color
                      shape: BoxShape.circle,
                    )),
              ),
            )
          ],
        ),
      ],
    );
  }

  final ScrollController _controller = ScrollController();
  void _scrollUp() {
    _controller.animateTo(
      _controller.position.minScrollExtent,
      curve: Curves.easeOut,
      duration: Duration(milliseconds: 200),
    );

  }

  final controller = TextEditingController();
  post() async {
    List<Post> posts = List.empty(growable: true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("username");
    var first_name = prefs.getString("firstname");
    var last_name = prefs.getString("lastname");
    try {
      var old_post = json.decode(prefs.getString("queued_posts")!) as List<dynamic>;
      for (var post in old_post) {
        posts.add(Post(user: post["user"], content: post["content"], url: post["url"], var1: post["var1"], retries: post["retries"], uid: post["uid"]));
      }
    } catch (e) {
      //Snackbar().show(context, ContentType.failure, Language.error, e.toString());
    }

    if (content.isNotEmpty) {
      try {
        posts.add(Post(user: username!, content: content, url: "/trade-review/add", var1: "${widget.username}", retries: 0,
            uid: Uuid().v4()));
        prefs.setString("queued_posts", jsonEncode(posts));
      } catch (e) {
        //Snackbar().show(context, ContentType.failure, "Error!!!!!!!", e.toString());
      }

      try {
        List<UserModel> user = List.empty(growable: true);
        setState(() {
          user.add(new UserModel(id: "4545",
              username: username!,
              first_name: first_name!,
              last_name: last_name!,
              created_on: "",
              isFollowed: "",
              trades: "",
              about: "",
              reviews: "0",
              avatar: avatar,
              cover: cover,
              followers: "",
              following: "",
              rank: "",
              loading: false, isBlocked: ''));
          List<ReviewsModel> iList = List.empty(growable: true);
          iList.add(new ReviewsModel(
              id: '0', content: content, date: "Now", userModel: user));
          tList.insertAll(0, iList);
        });
      } catch (e) {
        //Snackbar().show(context, ContentType.failure, "Error!!!!", e.toString());
      }
    }
    if(posts.isNotEmpty){
      setState(() {
        controller.clear();
        content="";
      });
      //Snackbar().show(context, ContentType.success, Language.success, posts.toString());
    }

    Navigator.of(context).pop();
    setState(() {
       _scrollUp();
    });
  }


    void _post(context) {
      showModalBottomSheet(
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, state) {
                  return SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          padding: EdgeInsets.only(
                              bottom: MediaQuery
                                  .of(context)
                                  .viewInsets
                                  .bottom),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              error ? Container(
                                //show error message here
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(10),
                                child: errmsg(errormsg, success, context),
                                //if error == true then show error message
                                //else set empty container as child
                              ) : Container(),
                              Padding(
                                padding:
                                EdgeInsets.only(
                                    top: 10, right: 20, left: 20),
                                child: TextField(
                                  minLines: 3,
                                  controller: controller,
                                  maxLines: 6,
                                  // and this
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    hintText: "Write something...",
                                    isDense: true,
                                    // now you can customize it here or add padding widget
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    content = value;
                                  },
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 20, right: 20, left: 20, bottom: 25),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: kPrimaryDarkColor,
                                      minimumSize: Size.fromHeight(
                                          40), // fromHeight use double.infinity as width and 40 is the height
                                    ),
                                    child: Text(
                                      'Post',
                                      style: TextStyle(
                                          color: kSecondary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                        post();
                                    },
                                  )),
                            ],
                          )));
                });
          },
          context: context);
    }


}
