import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:crypto_app/screens/explore/explore.dart';
import 'package:crypto_app/screens/transactions/transactions.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:crypto_app/screens/home/home_screen.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../constants.dart';
import '../language.dart';
import '../models/post.dart';
import '../screens/chat/conversations_screen.dart';
import '../screens/p2p/p2p.dart';
import '../screens/wallets/wallets_screen.dart';
import '../size_config.dart';
import '../strings.dart';
import 'package:http/http.dart' as http;



class Dashboard extends StatefulWidget {
  static String routeName = "/dashboard";
  @override
  _Dashboard createState() => _Dashboard();

}

class _Dashboard  extends State<Dashboard> {
  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();
  int i=0;
  bool found=false;
  String username="";
  bool refresh=false;
  Timer? _timer;

  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted) setState(() {
      username = prefs.getString("username")!;
    });

  }

  final List<Widget> _tabItems = [
    HomeScreen(),
    //WalletsScreen(),
    P2PScreen(),
    TransactionsScreen(),
    ConversationScreen(),
    //ExploreScreen(),
  ];

    Widget newMsg(){
      return Container(
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            i==0?
            Icon(
              Icons.chat,
              color: kSecondary,
            ) :
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.chat, color: kSecondary, ),
                Positioned(
                  top: -3,
                  right: 0,
                  child: Container(
                    height: getProportionateScreenWidth(16),
                    width: getProportionateScreenWidth(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF4848),
                      shape: BoxShape.circle,
                      border: Border.all(width: 1.5, color: kSecondary),
                    ),
                    child: Center(
                      child: Text(
                        "$i",
                        style: TextStyle(
                          fontSize: getProportionateScreenWidth(10),
                          height: 1,
                          fontWeight: FontWeight.w600,
                          color: kSecondary,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Text("Chat", style: TextStyle(color: kSecondary),),
          ],
        ),
      );
    }




  @override
  void initState() {
    super.initState();
    getuser();
    _refresh();
  }

  @override
  void deactivate() {
    if(mounted) setState(() {
      refresh = false;
    });
    _timer!.cancel();
    super.deactivate();
  }

  @override
  void activate() {
    if(mounted) setState(() {
      refresh = true;
    });
    _refresh();
    super.activate();
  }

  @override
  void dispose() {
    _timer!.cancel();
    if(mounted) setState(() {
      refresh = false;
    });
    super.dispose();
  }

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
      backgroundColor: kPrimaryColor,
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        height: 50.0,
        items: <Widget>[
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.dashboard_rounded,
                  color: kSecondary,
                ),
                Text(Language.home, style: TextStyle(color: kSecondary, fontSize: 12)),
              ],
            ),
          ),
          /*
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.dashboard_rounded,
                  color: kSecondary,
                ),
                Text(Language.wallets, style: TextStyle(color: kSecondary, fontSize: 12),),
              ],
            ),
          ),
          */
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.safety_divider,
                  color: kSecondary,
                ),
                Text(Language.p2p, style: TextStyle(color: kSecondary, fontSize: 12),),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hive,
                  color: kSecondary,
                ),
                Text(Language.history, style: TextStyle(color: kSecondary, fontSize: 12),),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat,
                  color: kSecondary,
                ),
                Text(Language.chats, style: TextStyle(color: kSecondary, fontSize: 12),),
              ],
            ),
          ),
          /*
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  color: kSecondary,
                ),
                Text(Language.explore, style: TextStyle(color: kSecondary, fontSize: 12),),
              ],
            ),
          ),
          */
        ],
        color: kPrimaryColor,
        buttonBackgroundColor: kPrimaryColor,
        backgroundColor: kSecondary,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          // _more(context);
          if(mounted) setState(() {
              _page = index;
            });
        },
      ),
      body: DoubleBackToCloseApp(
          snackBar: SnackBar(
            content: Text(Language.tap_exit),
          ),
          child: _tabItems[_page]),
    );
  }

  _more(BuildContext context){
      return showModalBottomSheet(
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Container(
                        margin: EdgeInsets.only(top: 20, right: 10, left: 10),
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Upcoming Updates", maxLines: 2, style: TextStyle(color: kPrimaryColor, fontSize: 32, fontWeight: FontWeight.bold),),
                              SizedBox(
                                height: 30,
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                        onTap: (){

                                        },
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 50,
                                                width: 50,
                                                padding: EdgeInsets.all(1.0),
                                                decoration: new BoxDecoration(
                                                  color: kPrimaryVeryLightColor, // border color
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.people, size: 30, color: kSecondary,),),
                                              Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                  "P2P",
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    color: kPrimaryColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),)
                                            ],
                                          ),
                                        )
                                    ),
                                    SizedBox(width: 40,),
                                    InkWell(
                                        onTap: (){

                                        },
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 50,
                                                width: 50,
                                                padding: EdgeInsets.all(1.0),
                                                decoration: new BoxDecoration(
                                                  color: kPrimaryVeryLightColor, // border color
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.account_tree_outlined, size: 30, color: kSecondary,),),
                                              Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                  "NFT",
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    color: kPrimaryColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),)
                                            ],
                                          ),
                                        )
                                    ),
                                    SizedBox(width: 40,),
                                    InkWell(
                                        onTap: (){

                                        },
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 50,
                                                width: 50,
                                                padding: EdgeInsets.all(1.0),
                                                decoration: new BoxDecoration(
                                                  color: kPrimaryVeryLightColor, // border color
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.screen_lock_landscape, size: 30, color: kSecondary,),),
                                              Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                  "Loan",
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    color: kPrimaryColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),)
                                            ],
                                          ),
                                        )
                                    ),

                                  ]
                              ),
                              SizedBox(
                                height: 30,
                              ),
                            ],
                          )));
                });
          },
          context: context);
  }


  Future<void> _refresh() async {
    _timer=Timer.periodic(new Duration(seconds: 5), (timer) {
      if(!refresh) process();
    });
  }


  process() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("username");
    var token = prefs.getString("token");
    List<Post> posts=List.empty(growable: true);
    if(mounted) setState(() {
      refresh=true;
    });
    try{
      var old_post = json.decode(prefs.getString("queued_posts")!) as List<dynamic>;
      for(var post in old_post) {
        bool isPosted=false;
        try{
          String apiurl = Strings.url + post["url"].toString();
          var response = null;
          if(post["url"]=="/post_conversation_image"){

            var uri = Uri.parse(apiurl);
            var request = http.MultipartRequest("POST", uri);

            try{
                  var stream = http.ByteStream(DelegatingStream.typed(File(post["var1"]).openRead()));
                  var length = await File(post["var1"]).length();
                  var multipartFile = http.MultipartFile(
                      "image", stream, length,
                      filename: File(post["var1"]).path
                          .split('/')
                          .last);
                request.files.add(multipartFile);
            }catch(e){
              isPosted=true;
            }

            request.headers['Content-Type'] = 'application/json';
            request.headers['Authentication'] = '$token';
            request.fields['username'] = username!;
            request.fields['content'] = post["content"].toString();
            request.fields['user'] = post["user"].toString();
            request.fields['uid'] = post["uid"].toString();

            var respond = await request.send();
              if (respond.statusCode == 200) {
                var responseData = await respond.stream.toBytes();
                var responseString = String.fromCharCodes(responseData);
                var jsondata = json.decode(responseString);
                if (jsondata["status"].toString() == "success") {
                  isPosted=true;
                } else {
                  //Snackbar().show(context, ContentType.failure, "Error", jsondata["response_message"].toString());
                  isPosted=true;
                }
              } else {
                isPosted=false;
              }

          }else{
            Map data = {
              'username': username,
              'user': post["user"].toString(),
              'content': post["content"].toString(),
              'id': post["var1"].toString(),
              'uid': post["uid"].toString(),
            };

            var body = json.encode(data);
            response = await http.post(Uri.parse(apiurl),
                headers: {
                  "Content-Type": "application/json",
                  "Authentication": "$token"},
                body: body
            );

            if (response != null && response.statusCode == 200) {
              var jsondata = json.decode(response.body);
              if (jsondata["status"] != null && jsondata["status"].toString().contains("success")) {
                isPosted=true;
              }else{
                //Snackbar().show(context, ContentType.failure, Language.error, jsondata["response_message"].toString());
                isPosted=true;
              }

            }else{
              isPosted=false;
            }
          }

        }catch(e){
          isPosted=false;
         // Snackbar().show(context, ContentType.failure, "Error!!", e.toString());
        }

        if(!isPosted && post["retries"]<2){
          posts.add(Post(user: post["user"], content: post["content"], url: post["url"], var1: post["var1"], retries: post["retries"]+1, uid: post["uid"]));
        }
      }
      prefs.setString("queued_posts", jsonEncode(posts));

    }catch(e){
      //Snackbar().show(context, ContentType.failure, "Error!!", e.toString());
    }
    if(mounted) setState(() {
      refresh=false;
    });
  }

}
