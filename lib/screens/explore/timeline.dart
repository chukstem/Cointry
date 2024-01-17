import 'dart:async';
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_app/models/timeline_hashtags_model.dart';
import 'package:crypto_app/screens/explore/post_timeline.dart';
import 'package:crypto_app/screens/explore/timeline_hashtags.dart';
import 'package:easy_load_more/easy_load_more.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crypto_app/constants.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import '../../helper/networklayer.dart';
import '../../language.dart';
import '../../models/timeline_model.dart';
import '../../strings.dart';
import '../../widgets/image.dart';
import '../../widgets/snackbar.dart';
import '../home/ImageView.dart';
import '../profile/user_profile_screen.dart';
import '../timeline/view_timeline_screen.dart'; 


class Timeline extends StatefulWidget {
  bool loading;
  List<TimelineModel> tList;
  List<HashtagsModel> hList;
  Timeline({Key? key, required this.loading, required this.tList, required this.hList}) : super(key: key);

  @override
  _Timeline createState() => _Timeline();
}

class _Timeline extends State<Timeline> {
  String token="", username="", errormsg="";
  bool error=false, showprogress=false, success=false;

  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString("token")!;
      username = prefs.getString("username")!;
    });
  }
  final List<String> items = [
    'Send Coin',
    'Block User',
  ];
  String? selectedValue;

  fetchTimeline() async {
    try{
      List<TimelineModel> iList = await getTimeline(http.Client(), "ALL", "0");
      setState(() {
        widget.loading = false;
        widget.tList = iList;
      });

    }catch(e){
      setState(() {
        widget.loading = false;
      });
    }

  }

  bool stopRefresh=false;
  addItems() async {
    int length=widget.tList.length+1;
    try{
      List<TimelineModel> iList = await getTimeline(http.Client(), "ALL", "$length");
      setState(() {
        widget.loading = false;
        widget.tList.addAll(iList);
        if(iList.isEmpty){
          stopRefresh=true;
        }
      });

    }catch(e){
      setState(() {
        widget.loading = false;
      });
    }

  }

  fetchdelay(){
    Timer(Duration(seconds: 120), () =>
    {
      fetchTimeline(),
    });
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

  @override
  void initState() {
    super.initState();
    getuser();
  }


  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      body: RefreshIndicator(
          onRefresh: () {
            return fetchTimeline();
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(0),
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  widget.loading ? Container(
                      height: 300,
                      color: kSecondary,
                      margin: EdgeInsets.only(top: 20),
                      child: Center(
                          child: CircularProgressIndicator()))
                      :
                  widget.hList!.length <= 0 ?
                  SizedBox() :
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                      "Trending Hashtags",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 20.0,
                          color: kPrimaryDarkColor,
                          fontWeight: FontWeight.bold
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Column(
                    children: [
                      widget.hList!.length <= 0 ?
                      SizedBox() :
                      widget.loading? SizedBox() :
                      ListView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 0),
                          itemCount: widget.hList!.length,
                          itemBuilder: (context, index) {
                            return getHashtagItem(
                                widget.hList![index], index, context);
                          }),

                      !widget.loading && widget.tList!.length <= 0 ?
                      Container(
                        height: 80,
                        color: kSecondary,
                        margin: EdgeInsets.all(20),
                        child: Center(
                          child: Text(Language.empty, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
                        ),
                      )
                          :
                      widget.loading? SizedBox() :
                      EasyLoadMore(
                        isFinished: widget.tList!.length < 30 || widget.tList!.length >= 500 || stopRefresh,
                        onLoadMore: _loadMore,
                        runOnEmptyResult: false,
                        child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.only(top: 0),
                            itemCount: widget.tList!.length,
                            itemBuilder: (context, index) {
                              return getTimelineItem(
                                  widget.tList![index], index, context);
                            }),
                      ),
                    ],
                  )
                ]),)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) => NewPost())).whenComplete(() => fetchdelay());
        },
        backgroundColor: kPrimaryLightColor,
        child: Icon(Icons.add, size: 40,),
      ),
    );
  }




  InkWell getTimelineItem(TimelineModel obj, int index, BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => ViewTimelineScreen(model: obj, isTimeline: false)));
      },
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: Card(
              color: kWhite,
              margin: EdgeInsets.only(left: 10.0, right: 10, bottom: 10, top: 5),
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
                          Container(
                            margin: EdgeInsets.only(left: 10),
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
                                          Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => UserProfile(user: obj.userModel.first,)));
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
                                        ],),
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
                      ): SizedBox(),
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
          ),
        ],
      ),
    );
  }



  like(int id, String tid) async {
    setState(() {
      widget.tList[id].isLiked="1";
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
        widget.tList[id].likes=jsonBody["likes"];
      });
    }
  }

  unlike(int id, String tid) async {
    setState(() {
      widget.tList[id].isLiked="0";
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
        widget.tList[id].likes=jsonBody["likes"];
      });
    }
  }

  block(BuildContext context, String user) async{
    QuickAlert.show(
        context: context,
        backgroundColor: kPrimaryDarkColor,
        type: QuickAlertType.confirm,
        title: Language.block_user,
        titleColor: kSecondary,
        textColor: kSecondary,
        text: Language.proceed_block+' @$user?',
        confirmBtnText: Language.proceed,
        cancelBtnText: Language.cancel,
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

  block_account(BuildContext context, String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token=prefs.getString("token");
    String? email=prefs.getString("email");
    var response = null;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: Language.loading,
      text: Language.processing,
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
        }else{
          Navigator.pop(context);
          Snackbar().show(context, ContentType.failure, Language.error, jsondata["response_message"].toString());
        }

      }else{
        Navigator.pop(context);
        Snackbar().show(context, ContentType.failure, Language.error, Language.network_error);
      }

    } catch (e) {
      Navigator.pop(context);
      Snackbar().show(context, ContentType.failure, Language.error, e.toString());
    }

  }

  Widget getHashtagItem(HashtagsModel hashtagsModel, int index, BuildContext context) {
    return InkWell(
        onTap: (){
          Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => TimelineHashtags(subject: hashtagsModel.subject,)));
    },
    child: Card(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      color: kSecondary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
            child: Text(
              widget.hList![index].subject,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 17.0,
                color: kPrimaryDarkColor,
                fontWeight: FontWeight.bold
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 10),
            child: Text(
              widget.hList![index].total,
              textAlign: TextAlign.start,
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
      ),
    );
  }
}
