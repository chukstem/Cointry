import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:crypto_app/models/timeline_model.dart';
import 'package:crypto_app/screens/timeline/view_replies_screen.dart';
import 'package:easy_load_more/easy_load_more.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toast/toast.dart';
import '../../../constants.dart';
import '../../../helper/networklayer.dart';
import '../../../models/bills_model.dart';
import '../../../strings.dart';
import 'package:uuid/uuid.dart';
import '../../components/get_products.dart';
import '../../models/post.dart';
import '../../models/user_model.dart';
import '../../size_config.dart';
import '../../widgets/image.dart';
import '../../widgets/snackbar.dart';
import '../chat/chat_screen.dart';
import '../home/ImageView.dart';
import '../profile/user_profile_screen.dart';

class ViewTimelineScreen extends StatefulWidget {
  static String routeName = "/view-timeline";
  TimelineModel model;
  bool isTimeline;
  ViewTimelineScreen({Key? key, required this.model, required this.isTimeline}) : super(key: key);

  @override
  _ViewTimelineScreen createState() => _ViewTimelineScreen();
}


class _ViewTimelineScreen extends State<ViewTimelineScreen> {
  String errormsg="";
  bool error=false, showprogress=false, wallet_button=false, success=false;
  String name="", wallet="0.0", email="";
  String username="", cover="", amount="", token="", avatar="";

  int maxRenderAvatar = 5;
  double size = 30;
  double borderSize = 5;

  List<TimelineModel> tList = List.empty(growable: true);
  bool loading = true, loading2 = true;
  final pageIndexNotifier = ValueNotifier<int>(0);

  Bills? currency;
  List<Bills> currencies=Products().getCurrencies();


  fetchTimeline() async {
    loading2 = true;
    try{
      List<TimelineModel> iList = await getTimelineComments(http.Client(), widget.model.id, "0");
      setState(() {
        loading2 = false;
        tList = iList;
      });

    }catch(e){
      setState(() {
        loading2 = false;
      });
    }
    
  }

  bool stopRefresh=false;
  addItems() async {
    int length=tList.length+1;
    try{
      List<TimelineModel> iList = await getTimelineComments(http.Client(), widget.model.id, "$length");
      setState(() {
        loading2 = false;
        tList.addAll(iList);
        if(iList.isEmpty){
          stopRefresh=true;
        }
      });

    }catch(e){
      setState(() {
        loading2 = false;
      });
    }
    
  }


  likeTimeline(String tid) async {
    setState(() {
      widget.model.isLiked="1";
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
        widget.model.likes=jsonBody["likes"];
      });
    }
  }

  unlikeTimeline(String tid) async {
    setState(() {
      widget.model.isLiked="0";
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
        widget.model.likes=jsonBody["likes"];
      });
    }
  }


  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var fname = prefs.getString("firstname");
      var lname=prefs.getString("lastname");
      name="$fname $lname";
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
      fetchTimeline(),
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
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Post', style: TextStyle(color: kPrimaryDarkColor, fontWeight: FontWeight.bold, fontSize: 22),)),
      body: RefreshIndicator(
        onRefresh: () {
          return fetchTimeline();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20,),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                       Padding(
                        padding: const EdgeInsets.all(20),
                        child: Card(
                          color: Colors.white,
                          margin: EdgeInsets.only(left: 10.0, right: 10, bottom: 20),
                          child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
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
                                          if(!widget.isTimeline) Navigator.pushReplacement(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => UserProfile(user: widget.model.userModel.first)));
                                        },
                                        child: Container(
                                            height: 40,
                                            width: 40,
                                            child: CircleAvatar(
                                              radius: 45,
                                              child: Padding(
                                                padding: const EdgeInsets.all(1), // Border radius
                                                child: ClipOval(child: CachedNetworkImage(
                                                  height: 40,
                                                  width: 40,
                                                  imageUrl: widget.model.userModel.first.avatar,
                                                  fit: BoxFit.cover,), ),
                                              ),
                                            ),
                                            padding: EdgeInsets.all(1),
                                            decoration: new BoxDecoration(
                                              color: Colors.white, // border color
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
                                                children: [
                                                  InkWell(
                                                    onTap: (){
                                                      if(!widget.isTimeline) Navigator.pushReplacement(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => UserProfile(user: widget.model.userModel.first,)));
                                                    },
                                                    child: Text(
                                                      widget.model.userModel.first.first_name + " "+widget.model.userModel.first.last_name,
                                                      textAlign: TextAlign.start,
                                                      style: const TextStyle(
                                                        fontSize: 17.0,
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  SizedBox(width: 2),
                                                  widget.model.userModel.first.rank=="0" ?
                                                  Icon(Icons.verified_user, color: Colors.white, size: 10,) :
                                                  widget.model.userModel.first.rank=="1" ?
                                                  Icon(Icons.verified_user, color: kPrimaryLightColor, size: 10,) :
                                                  Row(mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Icon(Icons.star, color: widget.model.userModel.first.rank=="3" ? Colors.orangeAccent : kPrimaryVeryLightColor, size: 10,),
                                                      SizedBox(width: 2,),
                                                      Icon(Icons.verified_user, color: kPrimaryLightColor, size: 10,),
                                                    ],),
                                                  SizedBox(width: 4,),
                                                  Text(
                                                    "@"+widget.model.userModel.first.username,
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.black,
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
                                                  widget.model.date,
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black,
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
                                  SizedBox(height: 10,),
                                  widget.model.imagesModel.isNotEmpty?
                                  Center(
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(left: 5, top: 2),
                                      child: widget.model.imagesModel.length>1?
                                      PhotoGrid(
                                        imageUrls: widget.model.imagesModel,
                                        onImageClicked: (i) => ImagePreview().preview(context, widget.model.imagesModel[i].url, setState),
                                        onExpandClicked: () => print('Expand Image was clicked'),
                                        maxImages: 4,
                                      ) : Container(
                                        constraints: BoxConstraints(
                                            maxHeight: 300
                                        ),
                                        child: InkWell(
                                          child: CachedNetworkImage(
                                            imageUrl: widget.model.imagesModel.first.url,
                                            fit: BoxFit.cover,
                                          ),
                                          onTap: () => ImagePreview().preview(context, widget.model.imagesModel.first.url, setState),
                                        ),
                                      ),
                                    ),
                                  ) : SizedBox(),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    margin: EdgeInsets.only(left: 5, top: 5),
                                    child: Text(widget.model.content,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        fontSize: 14.0,
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
                                            widget.model.isLiked=="1" ?
                                            unlikeTimeline(widget.model.id) : likeTimeline(widget.model.id);
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              widget.model.isLiked=="1" ? Icon(Icons.handshake, color: Colors.red, size: 20,) : Icon(Icons.handshake, size: 20,),
                                              SizedBox(width: 5,),
                                              Text(
                                                widget.model.likes,
                                                textAlign: TextAlign.start,
                                                style: const TextStyle(
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
                                              widget.model.comments,
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
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
                                              widget.model.views,
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        PopupMenuButton(
                                          itemBuilder: (context) {
                                            return [
                                              PopupMenuItem<int>(
                                                value: 0,
                                                child: Text("Copy"),
                                              ),
                                              widget.model.userModel.first.username==username || username.toLowerCase()==Strings.app_name.toLowerCase()?
                                              PopupMenuItem<int>(
                                                value: 1,
                                                child: Text("Delete"),
                                              ) :
                                              PopupMenuItem<int>(
                                                value: 2,
                                                child: Text("Chat"),
                                              ),
                                            ];
                                          },
                                          onSelected: (value) {
                                            if (value == 0) {
                                              Clipboard.setData(ClipboardData(text: widget.model.content));
                                              Toast.show("Text Copied to Clipboard!", duration: Toast.lengthLong, gravity: Toast.bottom);
                                            } else if (value == 1) {
                                              delete_timeline(context, widget.model.id);
                                            } else if (value == 2) {
                                              Navigator.of(context).pushReplacement(CupertinoPageRoute(
                                                  builder: (context) => ChatScreen(to: widget.model.userModel.first)));
                                            }
                                          },
                                          child: Icon(Icons.more_vert, color: Colors.black,),
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
              Container(
                padding: EdgeInsets.only(top: 30),
                color: Colors.white,
                child: Column(
                  children: [
                    TimelineComments(),
                  ],
                ),
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _post(context);
        },
        backgroundColor: kPrimaryVeryLightColor,
        child: const Icon(Icons.add_comment, size: 40,),

      ),
    );
  }


  Widget TimelineComments() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 30.0, top: 10.0, bottom: 10),
                child: Text(
                  'Replies',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              loading2 ? Container(
                  height: 300,
                  color: Colors.white,
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                      child: CircularProgressIndicator()))
                  :
              tList!.length <= 0 ?
              Container(
                height: 80,
                color: Colors.white,
                margin: EdgeInsets.all(20),
                child: Center(
                  child: Text("No Replies Yet!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
                ),
              ) :
              RefreshIndicator(
                onRefresh: _refresh,
                child: EasyLoadMore(
                    isFinished: tList.length < 30 || tList.length >= 500 || stopRefresh,
                    onLoadMore: _loadMore,
                    runOnEmptyResult: false,
                    child: ListView.builder(
                        controller: _controller,
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 0),
                        itemCount: tList!.length,
                        itemBuilder: (context, index) {
                          return getTimelineItem(
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
      const Duration(
        seconds: 0,
        milliseconds: 2000,
      ),
    );

    if(stopRefresh==false){ addItems();}
    return true;
  }

  Future<void> _refresh() async {
    await Future.delayed(
      const Duration(
        seconds: 0,
        milliseconds: 2000,
      ),
    );


    fetchTimeline();
  }
  
  
  like(int id, String tid) async {
    setState(() {
      tList[id].isLiked="1";
    });
    String apiurl = Strings.url+"/like_timeline_comment";
    var response = null;
    try {
      Map data = {
        'username': username,
        'cid': tid,
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
    String apiurl = Strings.url+"/unlike_timeline_comment";
    var response = null;
    try {
      Map data = {
        'username': username,
        'cid': tid,
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



  Column getTimelineItem(TimelineModel obj, int index, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              PopupMenuItem<int>(
                value: 0,
                child: Text("Copy"),
              ),
              widget.model.userModel.first.username==username || obj.userModel.first.username==username || username.toLowerCase()==Strings.app_name.toLowerCase()?
              PopupMenuItem<int>(
                value: 1,
                child: Text("Delete"),
              ) :
              PopupMenuItem<int>(
                value: 2,
                child: Text("Chat"),
              ),
              PopupMenuItem<int>(
                value: 3,
                child: Text("View Replies"),
              ),
            ];
          },
          onSelected: (value) {
            if (value == 0) {
              Clipboard.setData(ClipboardData(text: obj.content));
              Toast.show("Text Copied to Clipboard!", duration: Toast.lengthLong, gravity: Toast.bottom);
            } else if (value == 1) {
              delete_timeline_comment(context, obj.id);
            } else if (value == 2) {
              Navigator.of(context).pushReplacement(CupertinoPageRoute(
                  builder: (context) => ChatScreen(to: obj.userModel.first)));
            } else if (value == 3) {
              Navigator.push(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => ViewRepliesScreen(post: widget.model, obj: obj,)));
            }
          },
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 50.0),
                child: Card(
                  margin: EdgeInsets.only(left: 10.0, right: 10, bottom: 20),
                  child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          left: 5.0, right: 5, top: 10, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  alignment: Alignment.topLeft,
                                  width: MediaQuery.of(context).size.width*0.50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: (){
                                         if(obj.userModel.first.username!=username){
                                           Navigator.pushReplacement(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => UserProfile(user: obj.userModel.first,)));
                                         }
                                        },
                                        child: Text(
                                          obj.userModel.first.first_name + " "+obj.userModel.first.last_name,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontSize: 17.0,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      obj.userModel.first.rank=="0" ?
                                      Icon(Icons.verified_user, color: Colors.white, size: 10,) :
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
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black,
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
                                width: MediaQuery.of(context).size.width*0.10,
                                child: Text(
                                  obj.date,
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
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
                            margin: EdgeInsets.only(left: 5, top: 5),
                            child: Text(obj.content,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 14.0,
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
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => ViewRepliesScreen(post: widget.model, obj: obj,)));
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.comment, size: 20,),
                                      SizedBox(width: 5,),
                                      Text(
                                        obj.comments,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
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
                                    Icon(Icons.bar_chart, size: 20,),
                                    SizedBox(width: 5,),
                                    Text(
                                      obj.views,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
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
                  onTap: (){
                    ImagePreview().preview(context, obj.userModel.first.avatar, setState);
                  },
                  child: Container(
                      height: 40,
                      width: 40,
                      child: CircleAvatar(
                        radius: 45,
                        child: Padding(
                          padding: const EdgeInsets.all(1), // Border radius
                          child: ClipOval(child: CachedNetworkImage(
                            height: 40,
                            width: 40,
                            imageUrl: obj.userModel.first.avatar,
                            fit: BoxFit.cover,), ),
                        ),
                      ),
                      padding: EdgeInsets.all(1),
                      decoration: new BoxDecoration(
                        color: Colors.white, // border color
                        shape: BoxShape.circle,
                      )),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }


  final ScrollController _controller = ScrollController();
  void _scrollUp() {
    _controller.animateTo(
      _controller.position.minScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 200),
    );

  }

  String content="", price="";
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
      //Snackbar().show(context, ContentType.failure, "Error!", e.toString());
    }

    if (content.isNotEmpty) {
      try {
        posts.add(Post(user: username!, content: content, url: "/post_comment", var1: "${widget.model.id}", retries: 0,
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
              about: "", reviews: "0",
              avatar: avatar,
              cover: cover,
              followers: "",
              following: "",
              rank: "",
              loading: false, isBlocked: ''));
          List<TimelineModel> iList = List.empty(growable: true);
          iList.add(new TimelineModel(
              id: '0', content: content, date: "Now", userModel: user, likes: '0', comments: '0', views: '0', isLiked: '0', imagesModel: [], mediaModel: [], followersModel: []));
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
      //Snackbar().show(context, ContentType.success, "Success!", posts.toString());
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
                            Padding(
                              padding:
                              const EdgeInsets.only(
                                  top: 10, right: 20, left: 20),
                              child: TextField(
                                minLines: 3,
                                controller: controller,
                                maxLines: 6,
                                keyboardType: TextInputType.multiline,
                                decoration: const InputDecoration(
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
                                padding: const EdgeInsets.only(
                                    top: 20, right: 20, left: 20, bottom: 25),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: kPrimaryDarkColor,
                                    minimumSize: const Size.fromHeight(
                                        40), // fromHeight use double.infinity as width and 40 is the height
                                  ),
                                  child: Text(
                                    'Reply',
                                    style: TextStyle(
                                        color: Colors.white,
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


  String format(String price){
    var value = price;
    if (price.length > 2) {
      //value = value.replaceAll(RegExp(r'\D'), '');
      //value = value.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');
    }
    return value;
  }

  delete_timeline(BuildContext context, String tid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token=prefs.getString("token");
    String? email=prefs.getString("email");
    var response = null;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Deleting',
      text: 'Wait a few secs...',
    );
    try {
      response = await http.post(Uri.parse(Strings.url+"/delete-timeline"),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "Bearer $token"},
          body: json.encode({
            'email': email,
            'tid': tid,
          })
      );
      if (response != null && response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["status"] != null &&
            jsondata["status"].toString().contains("success")) {
          Navigator.pop(context);
          Navigator.pop(context);
        }else{
          Navigator.pop(context);
          Snackbar().show(context, ContentType.failure, "Error!", jsondata["response_message"].toString());
        }

      }else{
        Navigator.pop(context);
        Snackbar().show(context, ContentType.failure, "Error!", "Connection error. Try again");
      }

    } catch (e) {
      Navigator.pop(context);
      Snackbar().show(context, ContentType.failure, "Error!", e.toString());
    }


  }


  delete_timeline_comment(BuildContext context, String cid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token=prefs.getString("token");
    String? email=prefs.getString("email");
    var response = null;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Deleting',
      text: 'Wait a few secs...',
    );
    try {
      response = await http.post(Uri.parse(Strings.url+"/delete-comment"),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "Bearer $token"},
          body: json.encode({
            'email': email,
            'cid': cid,
          })
      );
      if (response != null && response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["status"] != null &&
            jsondata["status"].toString().contains("success")) {
          Navigator.pop(context);
          fetchTimeline();
        }else{
          Navigator.pop(context);
          Snackbar().show(context, ContentType.failure, "Error!", jsondata["response_message"].toString());
        }

      }else{
        Navigator.pop(context);
        Snackbar().show(context, ContentType.failure, "Error!", "Connection error. Try again");
      }

    } catch (e) {
      Navigator.pop(context);
      Snackbar().show(context, ContentType.failure, "Error!", e.toString());
    }


  }

}

