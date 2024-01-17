import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_app/helper/networklayer.dart';
import 'package:crypto_app/models/conversations_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_pusher/pusher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../size_config.dart';
import '../../strings.dart';
import '../../widgets/image.dart';
import 'chat_screen.dart';

class ConversationScreen extends StatefulWidget {

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<ConversationScreen> {
  String username="", statusFrom="";
  bool loading=true, refresh=true, statusMode=false;
  List<ConversationsModel> list = List.empty(growable: true);
  List<ConversationsModel> olist = List.empty(growable: true);
  Channel? channel;

  cachedList() async {
    List<ConversationsModel> iList = await getConversationsCached();
    if (iList.isNotEmpty) {
      setState(() {
        loading = false;
        list = iList;
        olist = iList;
      });
    }
  }

  fetch() async {
    setState(() {
      refresh=true;
    });
    try{
      List<ConversationsModel> iList = await getConversations(http.Client());
      setState(() {
        list = iList;
        olist = iList;
      });

    }catch(e){
    }
    setState(() {
      loading = false;
      refresh=false;
    });

  }


  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username")!;
    });
  }

  Future<void> initPusher() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("token");
      await Pusher.init(
        "qwerty",
        PusherOptions(
          host: Strings.domain,
          port: 6001,
          encrypted: true,
          cluster: "mt1",
          auth: PusherAuth(
            Strings.home+"/broadcasting/auth",
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'auth-token': '$token',
              'Access-Control-Allow-Origin': '*'
            },),
        ),
        enableLogging: true,
      );
    } on PlatformException catch (e) {}
    Pusher.connect(onConnectionStateChange: (x) async {
      // Snackbar().show(context, ContentType.help, "State", "Last: ${x!.previousState}  Current: ${x!.currentState}");
    }, onError: (x) {
      // Snackbar().show(context, ContentType.warning, Language.error, "${x!.message}");
    });


    channel = await Pusher.subscribe("private-chat.$username");
    channel!.bind("client-conversations", (data) {
      fetch();
    });
    try{
      channel!.bind("client-status", (data) {
        var js = data!.toJson();
        var object = jsonDecode(js["data"]);
        if(object["action"]=="ping"){
          if(!refresh){
            fetch();
          }
        }else if(object["action"]=="typing" && int.parse(object["date"]) > DateTime.now().millisecondsSinceEpoch-10000){
          setState(() {
            if(mounted){
              statusMode=true;
              statusFrom=object["from"];
            }
          });
        }else{
          setState(() {
            statusMode=false;
            statusFrom=object["from"];
          });
        }
      });

    }catch (e) {}
  }



  @override
  void initState() {
    getuser();
    cachedList();
    Timer(Duration(seconds: 1), () =>
    {
      fetch(),
      initPusher(),
    });
    super.initState();
  }



  @override
  void deactivate() {
    Pusher.disconnect();
    super.deactivate();
  }

  @override
  void activate() {
    Pusher.connect();
    super.activate();
  }

  @override
  void dispose() {
    Pusher.disconnect();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: kSecondary,
      body: RefreshIndicator(
        onRefresh: () {
          return fetch();
        },
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0)),
                ),
                padding: EdgeInsets.only(top: 20),
                child: Padding(
                  padding: EdgeInsets.only(top: 20.0, bottom: 10),
                  child: Center(child: Text(
                    'Chats',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: kSecondary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              loading? Container(
                  margin: EdgeInsets.all(50),
                  child: Center(
                      child: CircularProgressIndicator()))
                  :
              list.length <= 0 ?
              Container(
                height: 200,
                margin: EdgeInsets.all(20),
                child: Center(
                  child: Text("You have not started any conversation Yet!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
                ),
              )
                  :
              Column(
                children: <Widget>[
                  ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 0),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return getListItem(
                            list[index], index, context);
                      })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Container getListItem(ConversationsModel obj, int index, BuildContext context){
    var messageSender = obj.from.first.username;
    final currentUser = messageSender.toLowerCase() == username.toLowerCase()
        ? "${obj.to.first.first_name} ${obj.to.first.last_name}"
        : "${obj.from.first.first_name} ${obj.from.first.last_name}";
    var messageText = obj.content;
    var time = obj.date;
    final avatar = messageSender.toLowerCase() == username.toLowerCase()
        ? obj.to.first.avatar
        : obj.from.first.avatar;
    return Container(
      child: Card(
        color: kWhite,
        margin: EdgeInsets.only(
          bottom: 5,
          top: 5,
          left: 10,
          right: 10,
        ),
        child: InkWell(
          onTap: () async {
            final result = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatScreen(to: messageSender.toLowerCase() == username.toLowerCase() ? obj.to.first : obj.from.first)));
            setState(() {
              fetch();
              initPusher();
            });
          },
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Container(
                margin: EdgeInsets.only(left: 15, right: 10),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.15,
                      child: InkWell(
                        onTap: (){
                          ImagePreview().preview(context, avatar, setState);
                        },
                        child: Container(
                            height: 60,
                            width: 60,
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: kSecondary,
                              child: Padding(
                                padding: EdgeInsets.all(1), // Border radius
                                child: ClipOval(child: CachedNetworkImage(
                                  height: 60,
                                  width: 60,
                                  imageUrl: avatar,
                                  fit: BoxFit.cover, ), ),
                              ),
                            ),
                            padding: EdgeInsets.all(1),
                            decoration: new BoxDecoration(
                              color: kSecondary, // border color
                              shape: BoxShape.circle,
                            )),
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      padding: EdgeInsets.only(top: 10, right: 10),
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(width: MediaQuery.of(context).size.width*0.57,
                                child: Text(
                                  '$currentUser',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18),
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(width: 5,),
                              Container(width: MediaQuery.of(context).size.width*0.13,
                                child: Text(
                                  getDate("$time"),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16),
                                  maxLines: 1,
                                ),),
                              SizedBox(width: 5,),
                            ],
                          ),
                          SizedBox(height: 5),
                          statusMode==true && statusFrom!=username && statusFrom==messageSender?
                          Text(
                            'is typing...',
                            style: TextStyle(
                                color: Colors.black54, fontSize: 16),
                            maxLines: 1,
                          ) :
                          messageText.contains("deleted->") ?
                          Text(
                            'deleted!',
                            style: TextStyle(
                                color: Colors.black54, fontSize: 16),
                            maxLines: 1,
                          ) : messageSender!=username && obj.read=="false"?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.57,
                                child: Text(
                                  '$messageText',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              obj.unread=="0" ? SizedBox() :
                              Container(
                                height: getProportionateScreenWidth(16),
                                width: MediaQuery.of(context).size.width*0.13,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFF4848),
                                  shape: BoxShape.circle,
                                  border: Border.all(width: 1.5, color: kSecondary),
                                ),
                                child: Center(
                                  child: Text(
                                    "${obj.unread}",
                                    style: TextStyle(
                                      fontSize: getProportionateScreenWidth(10),
                                      height: 1,
                                      fontWeight: FontWeight.w600,
                                      color: kSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ) : messageSender==username && obj.read=="false" ?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.done_all_outlined, size: 15,),
                              SizedBox(width: 5,),
                              Container(
                                width: MediaQuery.of(context).size.width*0.57,
                                child: Text(
                                  '$messageText',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ) : messageSender==username && obj.read=="true" ?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.done_all, size: 15, color: Colors.green,),
                              SizedBox(width: 5,),
                              Container(
                                width: MediaQuery.of(context).size.width*0.57,
                                child: Text(
                                  '$messageText',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ) : Container(
                            width: MediaQuery.of(context).size.width*0.57,
                            child: Text(
                              '$messageText',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }


  String getDate(String date) {
    String timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(date)*1000).toString();
    final year = int.parse(timestamp.substring(0, 4));
    final month = int.parse(timestamp.substring(5, 7));
    final day = int.parse(timestamp.substring(8, 10));
    final hour = int.parse(timestamp.substring(11, 13));
    final minute = int.parse(timestamp.substring(14, 16));

    final DateTime videoDate = DateTime(year, month, day, hour, minute);
    final int diffInHours = DateTime.now().difference(videoDate).inHours;

    String timeAgo = '';
    String timeUnit = '';
    int timeValue = 0;

    if (diffInHours < 1) {
      final diffInMinutes = DateTime.now().difference(videoDate).inMinutes;
      timeValue = diffInMinutes;
      timeUnit = 'min';
    } else if (diffInHours < 24) {
      timeValue = diffInHours;
      timeUnit = 'hr';
    } else if (diffInHours >= 24 && diffInHours < 24 * 7) {
      timeValue = (diffInHours / 24).floor();
      timeUnit = 'day';
    } else if (diffInHours >= 24 * 7 && diffInHours < 24 * 30) {
      timeValue = (diffInHours / (24 * 7)).floor();
      timeUnit = 'wk';
    } else if (diffInHours >= 24 * 30 && diffInHours < 24 * 12 * 30) {
      timeValue = (diffInHours / (24 * 30)).floor();
      timeUnit = 'mth';
    } else {
      timeValue = (diffInHours / (24 * 365)).floor();
      timeUnit = 'yr';
    }

    timeAgo = timeValue.toString() + ' ' + timeUnit;
    timeAgo += timeValue > 1 ? 's' : '';

    return timeAgo;
  }

}

