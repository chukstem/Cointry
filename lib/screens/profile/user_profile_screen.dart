import 'dart:async';
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_app/models/user_model.dart';
import 'package:crypto_app/screens/profile/reviews.dart';
import 'package:crypto_app/screens/timeline/followers.dart';
import 'package:crypto_app/screens/timeline/following.dart';
import 'package:easy_load_more/easy_load_more.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto_app/constants.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import '../../helper/networklayer.dart';
import '../../language.dart';
import '../../models/crypto_model.dart';
import '../../models/timeline_model.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import '../../widgets/image.dart';
import '../../widgets/snackbar.dart';
import '../chat/chat_screen.dart';
import '../home/ImageView.dart';
import '../timeline/view_timeline_screen.dart';
import '../wallets/view_fiat_page.dart';
import '../wallets/view_page.dart';


class UserProfile extends StatefulWidget {
  UserModel user;
  bool? fromChat;
  bool? fromTimeline;
  UserProfile({Key? key, required this.user, this.fromChat, this.fromTimeline}) : super(key: key);

  @override
  _UserProfile createState() => _UserProfile();
}

class _UserProfile extends State<UserProfile> {
  String token="", username="", errormsg="";
  bool error=false, showprogress=false, loading=true,  loading2=false, success=false;
  List<TimelineModel> tList = List.empty(growable: true);

  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString("token")!;
      username = prefs.getString("username")!;
    });
  }

  String? selectedValue;

  fetchTimeline() async {
    setState(() {
      loading = true;
    });
    try{
      List<TimelineModel> iList = await getTimeline(http.Client(), widget.user.username, "0");
      setState(() {
        loading = false;
        tList = iList;
      });
      if(tList.isNotEmpty){
        setState(() {
          widget.user=tList.first.userModel.first;
        });
      }

    }catch(e){
      setState(() {
        loading = false;
      });
    }

  }

  bool stopRefresh=false;
  addItems() async {
    int length=tList.length+1;
    try{
      List<TimelineModel> iList = await getTimeline(http.Client(), widget.user.username, "$length");
      setState(() {
        loading = false;
        tList.addAll(iList);
        if(iList.isEmpty){
          stopRefresh=true;
        }
      });
      if(tList.isNotEmpty){
        setState(() {
          widget.user=tList.first.userModel.first;
        });
      }

    }catch(e){
      setState(() {
        loading = false;
      });
    }

  }

  @override
  void initState() {
    super.initState();
    getuser();
    Timer(Duration(seconds: 1), () =>
    {
      fetchTimeline(),
      cachedList(),
    });
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
        body: RefreshIndicator(onRefresh: () {
          return fetchTimeline();
        },
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                backAppbar(context, widget.user.first_name + " "+widget.user.last_name),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  width: MediaQuery.of(context).size.width*0.90,
                  child: Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      InkWell(
                        onTap: () async {
                          ImagePreview().preview(context, widget.user.cover, setState);
                        },
                        child: Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40.0),
                            child: Padding(
                              padding: EdgeInsets.all(1), // Border radius
                              child: CachedNetworkImage(
                                height: 200,
                                width: 200,
                                imageUrl: widget.user.cover,
                                fit: BoxFit.cover, ), ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -6,
                        bottom: -6,
                        child: SizedBox(
                          height: 120,
                          width: 120,
                          child: InkWell(
                            onTap: () async {
                              ImagePreview().preview(context, widget.user.avatar, setState);
                            },
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: kSecondary,
                              child: Padding(
                                padding: EdgeInsets.all(2), // Border radius
                                child: ClipOval(child: CachedNetworkImage(
                                  height: 120,
                                  width: 120,
                                  imageUrl: widget.user.avatar,
                                  fit: BoxFit.cover, ), ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                widget.user.username==username ?
                SizedBox() :
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget.user.isFollowed=="0" ?
                    InkWell(
                      onTap: (){
                        if(!loading2) {
                          follow(widget.user.username);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: 95,
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kPrimaryDarkColor,
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        child: Center(
                          child: loading2?
                          SizedBox(
                            height:20, width:20,
                            child: CircularProgressIndicator(
                              backgroundColor: kSecondary,
                              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryDarkColor),
                            ),
                          ) : Text(
                            Language.follow,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: kSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ) : widget.user.isFollowed=="1" ?
                    InkWell(
                      onTap: (){
                        if(!loading2) {
                          unfollow(widget.user.username);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(10),
                        width: 95,
                        decoration: BoxDecoration(
                          color: kPrimaryDarkColor,
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        child: Center(
                          child: loading2?
                          SizedBox(
                            height:20, width:20,
                            child: CircularProgressIndicator(
                              backgroundColor: kSecondary,
                              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryDarkColor),
                            ),
                          ) : Text(
                            Language.unfollow,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: kSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    )  :  Positioned(
                        right: -16,
                        bottom: 0,
                        child: Container()),
                    widget!.fromChat == true? SizedBox() :
                    InkWell(
                      onTap: (){
                        Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) => ChatScreen(to: widget.user)));
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(10),
                        width: 95,
                        decoration: BoxDecoration(
                          color: kPrimaryDarkColor,
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        child: Center(
                          child: Text(
                            Language.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: kSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      width: 95,
                      decoration: BoxDecoration(
                        color: kPrimaryDarkColor,
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: PopupMenuButton(
                          child: Center(
                            child: Text(
                              Language.more,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: kSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem<int>(
                                value: 0,
                                child: Text(Language.send_coin),
                              ),
                              widget.user.isBlocked=="1" ?
                              PopupMenuItem<int>(
                                value: 2,
                                child: Text('Unblock'),
                              ) :
                              PopupMenuItem<int>(
                                value: 1,
                                child: Text(Language.block_user),
                              ),
                            ];
                          },
                          onSelected: (value) {
                            if (value == 0) {
                              _sendCoin("Select Wallet");
                            }else if (value == 1) {
                              block(context, widget.user.username);
                            }else if (value == 2) {
                              unblock(context, widget.user.username);
                            }
                          }
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Padding(padding: EdgeInsets.only(left: 20, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: (){
                            },
                            child: Text(
                              widget.user.first_name + " "+widget.user.last_name,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 2),
                          widget.user.rank=="0" ?
                          Icon(Icons.verified_user, color: kSecondary, size: 10,) :
                          widget.user.rank=="1" ?
                          Icon(Icons.verified_user, color: kPrimaryLightColor, size: 10,) :
                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.star, color: widget.user.rank=="3" ? Colors.orangeAccent : kPrimaryVeryLightColor, size: 10,),
                              SizedBox(width: 2,),
                              Icon(Icons.verified_user, color: kPrimaryLightColor, size: 10,),
                            ],),
                        ],
                      ),
                      SizedBox(height: 4,),
                      Text(
                        "@"+widget.user.username,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 10,),
                      Text(
                        widget.user.about,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black45,
                            fontWeight: FontWeight.bold
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 10,
                      ),
                      SizedBox(height: 10,),
                      Text(
                        "Joined "+widget.user.created_on,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black45,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 20,),
                    InkWell(
                      onTap: (){
                        Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => Following(username: widget.user.username)));
                      },
                      child: Text(
                        "${widget.user.following} ${Language.following}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 10,),
                    InkWell(
                      onTap: (){
                        Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => Followers(username: widget.user.username)));
                      },
                      child: Text(
                        "${widget.user.followers} ${Language.followers}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 10,),
                    Text(
                      "${widget.user.trades} Trades",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(width: 10,),
                    InkWell(
                      onTap: (){
                        Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => Reviews(username: widget.user.username, postReview: false,)));
                      },
                      child: Text(
                        "${widget.user.reviews} Reviews",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 20,),
                  ],
                ),
                SizedBox(height: 10,),
                Divider(),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  color: kSecondary,
                  child: Column(
                    children: [
                      Timeline(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }


  Widget Timeline() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 30.0, top: 10.0, bottom: 10),
                child: Text(
                  Language.timeline,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
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
                  child: Text(Language.empty, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
                ),
              )
                  :
              RefreshIndicator(
                onRefresh: _refresh,
                child: EasyLoadMore(
                  isFinished: tList.length < 30 || tList.length >= 500 || stopRefresh,
                  onLoadMore: _loadMore,
                  runOnEmptyResult: false,
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 0),
                      itemCount: tList.length,
                      itemBuilder: (context, index) {
                        return getTimelineItem(
                            tList![index], index, context);
                      }),
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


    fetchTimeline();
  }

  Column getTimelineItem(TimelineModel obj, int index, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
            onTap: (){
              if(!widget.fromTimeline!) Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => ViewTimelineScreen(model: obj, isTimeline: true)));
            },
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Card(
                color: kWhite,
                margin: EdgeInsets.only(left: 10.0, right: 10, bottom: 20),
                child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                        left: 5.0, right: 5, top: 10, bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: (){
                                ImagePreview().preview(context, obj.userModel.first.avatar, setState);
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
                                        fit: BoxFit.cover,), ),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(1),
                                  decoration: new BoxDecoration(
                                    color: kSecondary, // border color
                                    shape: BoxShape.circle,
                                  )),
                            ),
                            SizedBox(width: 10,),
                            Container(
                                alignment: Alignment.topLeft,
                                width: MediaQuery.of(context).size.width*0.50,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: (){
                                          },
                                          child: Text(
                                            obj.userModel.first.first_name + " "+obj.userModel.first.last_name,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        obj.userModel.first.rank=="0" ?
                                        Icon(Icons.verified_user, color: kSecondary, size: 10,) :
                                        obj.userModel.first.rank=="1" ?
                                        Icon(Icons.verified_user, color: kPrimaryLightColor, size: 10,) :
                                        Row(mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.star, color: obj.userModel.first.rank=="3" ? Colors.orangeAccent : kPrimaryVeryLightColor, size: 10,),
                                            SizedBox(width: 2,),
                                            Icon(Icons.verified_user, color: kPrimaryLightColor, size: 10,),
                                          ],
                                        ),
                                        SizedBox(width: 4,),
                                        Text(
                                          "@"+obj.userModel.first.username,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black45,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.topLeft,
                                      width: MediaQuery.of(context).size.width*0.10,
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
                                )
                            ),
                          ],
                        ),
                        obj.imagesModel.isNotEmpty?
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(left: 5, top: 2),
                            child: obj.imagesModel.length>1?
                            PhotoGrid(
                              imageUrls: obj.imagesModel,
                              onImageClicked: (i) => ImagePreview().preview(context, obj.imagesModel[i].url, setState),
                              onExpandClicked: () => print('Expand Image was clicked'),
                              maxImages: 4,
                            ) : Container(
                              constraints: BoxConstraints(
                                  maxHeight: 300
                              ),
                              child: InkWell(
                                child: CachedNetworkImage(
                                  imageUrl: obj.imagesModel.first.url,
                                  fit: BoxFit.cover,
                                ),
                                onTap: () => ImagePreview().preview(context, obj.imagesModel.first.url, setState),
                              ),
                            ),
                          ),
                        ) : SizedBox(),
                        Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(left: 5, top: 10, bottom: 10),
                          child: Text(obj.content,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 6,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(left: 10, top: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: (){
                                  obj.isLiked=="1" ?
                                  unlike(index, obj.id) : like(index, obj.id);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    obj.isLiked=="1" ? Icon(Icons.handshake, color: Colors.red, size: 20,) : Icon(Icons.handshake, size: 20,),
                                    SizedBox(width: 5,),
                                    Text(
                                      obj.likes,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.comment, size: 20,),
                                  SizedBox(width: 5,),
                                  Text(
                                    obj.comments,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.bar_chart, size: 20,),
                                  SizedBox(width: 5,),
                                  Text(
                                    obj.views,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                ),
              ),
            )
        ),
        //index==0 ?
        // getFollow() : SizedBox(),
      ],
    );
  }



  like(int id, String tid) async {
    setState(() {
      tList[id].isLiked="1";
    });
    String apiurl = Strings.url+"/like_timeline";
    var response = null;
    try {
      Map data = {
        'username': username,
        'tid': tid,
      };
      var body = json.encode(data);
      response = await http.post(Uri.parse(apiurl),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "$token"},
          body: body
      );
    } catch (e) {
    }
    if (response.statusCode == 200) {
      var jsonBody = json.decode(response.body);
      setState(() {
        tList[id].likes=jsonBody["likes"];
      });
    }
  }

  unlike(int id, String tid) async {
    setState(() {
      tList[id].isLiked="0";
    });
    String apiurl = Strings.url+"/unlike_timeline";
    var response = null;
    try {
      Map data = {
        'username': username,
        'tid': tid,
      };
      var body = json.encode(data);
      response = await http.post(Uri.parse(apiurl),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "$token"},
          body: body
      );
    } catch (e) {
    }
    if (response.statusCode == 200) {
      var jsonBody = json.decode(response.body);
      setState(() {
        tList[id].likes=jsonBody["likes"];
      });
    }
  }


  follow(String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username")!;
    String token = prefs.getString("token")!;
    setState(() {
      loading2=true;
    });
    String apiurl = Strings.url+"/follow_user";
    var response = null;
    try {
      Map data = {
        'username': username,
        'user': user,
      };
      var body = json.encode(data);
      response = await http.post(Uri.parse(apiurl),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "$token"},
          body: body
      );
      if (response.statusCode == 200) {
        var jsonBody = json.decode(response.body);
        if(jsonBody["status"]=="success"){
          setState(() {
            widget.user.isFollowed="1";
          });
          Toast.show("You have followed @"+user, duration: Toast.lengthLong, gravity: Toast.bottom);
        }
      }
    } catch (e) {
      Toast.show(Language.network_error, duration: Toast.lengthLong, gravity: Toast.bottom);
    }

    setState(() {
      loading2=false;
    });
  }


  unfollow(String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username")!;
    String token = prefs.getString("token")!;
    setState(() {
      loading2=true;
    });
    String apiurl = Strings.url+"/unfollow_user";
    var response = null;
    try {
      Map data = {
        'username': username,
        'user': user,
      };
      var body = json.encode(data);
      response = await http.post(Uri.parse(apiurl),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "$token"},
          body: body
      );
      if (response.statusCode == 200) {
        var jsonBody = json.decode(response.body);
        if(jsonBody["status"]=="success"){
          setState(() {
            widget.user.isFollowed="0";
          });
          Toast.show("You have unfollowed @"+user, duration: Toast.lengthLong, gravity: Toast.bottom);
        }
      }
    } catch (e) {
      Toast.show(Language.network_error, duration: Toast.lengthLong, gravity: Toast.bottom);
    }

    setState(() {
      loading2=false;
    });
  }


  block(BuildContext context, String user) async{
    QuickAlert.show(
        context: context,
        backgroundColor: kPrimaryDarkColor,
        type: QuickAlertType.confirm,
        title: 'Block User',
        titleColor: kSecondary,
        textColor: kSecondary,
        text: 'Are you sure you want to block @$user?',
        confirmBtnText: 'Block',
        cancelBtnText: 'Discard',
        confirmBtnColor: Colors.red,
        onConfirmBtnTap: () async {
          Navigator.pop(context);
          block_account(context, user);
          return;
        },
        onCancelBtnTap: (){
          Navigator.pop(context);
          return;
        }
    );
  }
  unblock(BuildContext context, String user) async{
    QuickAlert.show(
        context: context,
        backgroundColor: kPrimaryDarkColor,
        type: QuickAlertType.confirm,
        title: 'Unblock User',
        titleColor: kSecondary,
        textColor: kSecondary,
        text: 'Are you sure you want to unblock @$user?',
        confirmBtnText: 'Unblock',
        cancelBtnText: 'Discard',
        confirmBtnColor: Colors.red,
        onConfirmBtnTap: () async {
          Navigator.pop(context);
          unblock_account(context, user);
          return;
        },
        onCancelBtnTap: (){
          Navigator.pop(context);
          return;
        }
    );
  }

  block_account(BuildContext context, String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token=prefs.getString("token");
    String? email=prefs.getString("email");
    var response = null;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Blocking',
      text: 'Wait a few secs...',
    );
    try {
      response = await http.post(Uri.parse(Strings.url+"/block-user"),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "Bearer $token"},
          body: json.encode({
            'email': email,
            'user': user,
          })
      );
      if (response != null && response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["status"] != null &&
            jsondata["status"].toString().contains("success")) {
          Navigator.pop(context);
          setState(() {
            widget.user.isBlocked="1";
          });
          Snackbar().show(context, ContentType.success, Language.error, jsondata["response_message"].toString());
        }else{
          Navigator.pop(context);
          Snackbar().show(context, ContentType.failure, Language.error, jsondata["response_message"].toString());
        }

      } else {
        Navigator.pop(context);
        Snackbar().show(context, ContentType.failure, Language.error, Language.network_error);
      }

    } catch (e) {
      Navigator.pop(context);
      Snackbar().show(context, ContentType.failure, Language.error, e.toString());
    }

  }

  unblock_account(BuildContext context, String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token=prefs.getString("token");
    String? email=prefs.getString("email");
    var response = null;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Blocking',
      text: 'Wait a few secs...',
    );
    try {
      response = await http.post(Uri.parse(Strings.url+"/unblock-user"),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "Bearer $token"},
          body: json.encode({
            'email': email,
            'user': user,
          })
      );
      if (response != null && response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["status"] != null &&
            jsondata["status"].toString().contains("success")) {
          Navigator.pop(context);
          setState(() {
            widget.user.isBlocked="0";
          });
          Snackbar().show(context, ContentType.success, Language.error, jsondata["response_message"].toString());
        }else{
          Navigator.pop(context);
          Snackbar().show(context, ContentType.failure, Language.error, jsondata["response_message"].toString());
        }

      } else {
        Navigator.pop(context);
        Snackbar().show(context, ContentType.failure, Language.error, Language.network_error);
      }

    } catch (e) {
      Navigator.pop(context);
      Snackbar().show(context, ContentType.failure, Language.error, e.toString());
    }

  }


  List<CryptoModel> wList = List.empty(growable: true);
  cachedList() async {
    List<CryptoModel> iList = await getCryptosCached();
    setState(() {
      wList = iList;
    });
  }

  Widget getSingleChildScrollView(String title) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 30.0, top: 30.0, bottom: 10),
                    child: Text(
                      '$title',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              wList!.length <= 0 ?
              Container(
                height: 80,
                margin: EdgeInsets.all(20),
                child: Center(
                  child: Text("No Wallet Yet!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
                ),
              )
                  :
              Column(
                children: <Widget>[
                  ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 0),
                      itemCount: wList!.length,
                      itemBuilder: (context, index) {
                        return getWalletItem(
                            wList![index], index, context, title);
                      })
                ],
              ),
              SizedBox(height: 20,)
            ]
        );
      },
    );
  }

  _sendCoin(String title) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        builder: (BuildContext context) {
          return  SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Container(
              padding: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: kSecondary,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    getSingleChildScrollView("$title"),
                  ]),
            ),
          );
        });
  }


  Container getWalletItem(CryptoModel obj, int index, BuildContext context, String title) {
    return Container(
      child: Card(
        color: kWhite,
        margin: EdgeInsets.only(bottom: 5, top: 5, left: 10, right: 10),
        child: InkWell(
          onTap: (){
            Navigator.of(context).pop();
            if(obj.type=="coin"){
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ViewCrypto(obj: obj, action: "@"+widget.user.username)));
            }else if(obj.type=="fiat"){
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ViewFiat(obj: obj, action: "@"+widget.user.username)));
            }
          },
          child: Container(
            padding: EdgeInsets.only(
                left: 5.0, right: 5, top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.20,
                    child: CircleAvatar(
                        maxRadius: 23,
                        minRadius: 23,
                        child: CachedNetworkImage(
                          imageUrl: obj.networkModel[0].img,
                          height: 45.0,
                          width: 45.0,
                        ),
                        backgroundColor: kSecondary),
                    padding: EdgeInsets.all(1.0),
                    decoration: BoxDecoration(
                      color: kSecondary, // border color
                      shape: BoxShape.circle,
                    )),
                Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.23,
                            child: Text(
                              obj.networkModel[0].currency,
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
                          SizedBox(height: 5,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.23,
                            child: Text(
                              "\$" + obj.networkModel[0].price,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        width: 95,
                        decoration: BoxDecoration(
                          color: obj.networkModel[0].percentage_change.contains("-") ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        child: Text(
                          obj.networkModel[0].percentage_change.contains("-") ? ""+obj.networkModel[0].percentage_change+"%" : "+"+obj.networkModel[0].percentage_change+"%",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: kSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
