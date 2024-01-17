import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' as foundation;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_app/helper/networklayer.dart';
import 'package:crypto_app/models/user_model.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_pusher/pusher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../language.dart';
import '../../models/conversations_model.dart';
import '../../models/crypto_model.dart';
import '../../models/post.dart';
import '../../strings.dart';
import '../../widgets/image.dart';
import '../profile/user_profile_screen.dart';
import 'package:uuid/uuid.dart';

import '../wallets/view_fiat_page.dart';
import '../wallets/view_page.dart';
 
final focusNode = FocusNode();



class ChatScreen extends StatefulWidget { 
  final UserModel to;
  ChatScreen({required this.to});
  
  @override
  _ChatScreenState createState() => _ChatScreenState();
}




class _ChatScreenState extends State<ChatScreen> {
  var messageText;
  bool loading = true;
  String errormsg = "",
      content = "";
  bool error = false,
      showprogress = false,
      success = false;
  List<ConversationsModel> list = List.empty(growable: true);
  List<ConversationsModel> olist = List.empty(growable: true);
  String username = "";
  final ScrollController _controller = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  bool emojiShowing = false;
  String valueStatus="";
  Channel? channel;
  Channel? status;

  Widget typing() {
    return Text(valueStatus, style: TextStyle(
        color: kSecondary, fontSize: 14, fontWeight: FontWeight.bold),);
  }


  onBackspacePressed() {
    _textEditingController
      ..text = _textEditingController.text.characters.toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _textEditingController.text.length));
  }


  void _scrollUp() {
    _controller.animateTo(
      _controller.position.minScrollExtent,
      curve: Curves.easeOut,
      duration: Duration(milliseconds: 200),
    );
  }

  fetchCached() async {
    try {
      List<ConversationsModel> iList = await getUserConversationsCached(
          username, widget.to.username);
      if (iList.isNotEmpty) {
        setState(() {
          loading = false;
          list = iList;
          olist = iList;
        });
      }
    } catch (e) {}
    setState(() {
      _scrollUp();
    });
  }

  fetchCached2() async {
    try {
      List<ConversationsModel> iList = await getUserConversationsCached(
          widget.to.username, username);
      if (iList.isNotEmpty) {
        setState(() {
          loading = false;
          list = iList;
          olist = iList;
        });
      }
    } catch (e) {}
    setState(() {
      _scrollUp();
    });
  }

  fetch() async {
    try {
      List<ConversationsModel> iList = await getUserConversations(
          http.Client(), username, widget.to.username, "0");
      setState(() {
        loading = false;
        list = iList;
        olist = iList;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
    setState(() {
      _scrollUp();
    });
  }

  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username")!;
      valueStatus="@${widget.to.username}";
    });
  }

  @override
  void initState() {
    super.initState();
    getuser();
    fetchCached();
    fetchCached2();
    Timer(Duration(seconds: 1), () =>
    {
      cachedList(),
      fetch(),
      initPusher(),
    });
  }


  @override
  void deactivate() {
    setTyping("null");
    //Pusher.disconnect();
    super.deactivate();
  }

  @override
  void activate() {
    //Pusher.connect();
    super.activate();
  }

  @override
  void dispose() {
    setTyping("null");
    //Pusher.disconnect();
    super.dispose();
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
    Pusher.connect();
    channel = await Pusher.subscribe("private-chat.$username");
    channel!.bind("client-conversations", (data) {
      if(widget.to.isBlocked=="0") {
        try {
          var js = data!.toJson();
          var object = jsonDecode(js["data"]);
          if (mounted && object["sender"] == "${widget.to.username}" &&
              object["isChat"] != "false") {
            setState(() {
              String sender = object["sender"];
              String receiver = object["receiver"];
              content = object["message"];
              var imageUrl = object["imageUrl"];
              int seconds = int.parse(object["date"]);
              List<UserModel> to = List.empty(growable: true);
              List<UserModel> from = List.empty(growable: true);
              to.add(new UserModel(id: "547564565",
                  username: receiver,
                  first_name: "",
                  last_name: "",
                  created_on: "",
                  isFollowed: "",
                  reviews: "0",
                  trades: "",
                  about: "",
                  avatar: "",
                  cover: "",
                  followers: "",
                  following: "",
                  rank: "",
                  loading: false,
                  isBlocked: ''));
              from.add(new UserModel(id: "547564565",
                  username: sender,
                  first_name: "",
                  last_name: "",
                  created_on: "",
                  isFollowed: "",
                  trades: "",
                  about: "",
                  reviews: "0",
                  avatar: "",
                  cover: "",
                  followers: "",
                  following: "",
                  rank: "",
                  loading: false,
                  isBlocked: ''));
              List<ConversationsModel> iList = List.empty(growable: true);
              iList.add(new ConversationsModel(id: "546574651",
                  content: content,
                  date: "$seconds",
                  read: "false",
                  unread: "1",
                  to: to,
                  from: from,
                  imgUrl: '$imageUrl',
                  loading: false));
              list.insertAll(0, iList);
            });
          } else if (mounted && object["sender"] == "${widget.to.username}") {
            fetch();
          } else if (mounted && object["receiver"] == "${widget.to.username}") {
            for (int i = 0; i < list
                .where((o) => o.id == "546574654")
                .toList()
                .length; i++) {
              setState(() {
                list[i].id = "546574651";
              });
            }
            fetch();
          }
          _scrollUp();
        } catch (e) {
          // Snackbar().show(context, ContentType.warning, "Error!!!!", e.toString());
        }
      }
    });

    channel!.bind("client-status", (data){
      if(widget.to.isBlocked=="0") {
        try {
          var js = data!.toJson();
          var object = jsonDecode(js["data"]);
          if (object["action"] == "ping" &&
              object["from"] == "${widget.to.username}") {
            if (mounted) fetch();
          } else if (object["action"] == "typing" &&
              object["from"] == "${widget.to.username}" &&
              int.parse(object["date"]) > DateTime
                  .now()
                  .millisecondsSinceEpoch - 10000) {
            setState(() {
              if (mounted) valueStatus = "is typing...";
            });
          } else if (int.parse(object["date"]) > DateTime
              .now()
              .millisecondsSinceEpoch - 50000) {
            setState(() {
              if (mounted) valueStatus = "online";
            });
          } else {
            setState(() {
              if (mounted) valueStatus = "last seen " + getDate(object["date"]);
            });
          }
          for (int i = 0; i < list.length; i++) {
            setState(() {
              list[i].read = "true";
            });
          }
        } catch (e) {}
      }
    });

    status = await Pusher.subscribe("private-chat.${widget.to.username}");
    setTyping("null");
  }

  setTyping(String val) async {
      int date=DateTime.now().millisecondsSinceEpoch;
      await status!.trigger("client-status", data: '{"action": "$val", "date": "$date", "from": "$username"}');
  }


  post() async {
    List<Post> posts = List.empty(growable: true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("username");
    var first_name = prefs.getString("firstname");
    var last_name = prefs.getString("lastname");
    try {
      var old_post = json.decode(prefs.getString("queued_posts")!) as List<
          dynamic>;
      for (var post in old_post) {
        posts.add(Post(user: post["user"],
            content: post["content"],
            url: post["url"],
            var1: post["var1"],
            retries: post["retries"],
            uid: post["uid"]));
      }
    } catch (e) {
      //Snackbar().show(context, ContentType.failure, Language.error, e.toString());
    }

    if (_textEditingController.text.isNotEmpty) {

      try {
        posts.add(Post(user: widget.to.username,
            content: _textEditingController.text,
            url: "/post_conversation",
            var1: "",
            retries: 0,
            uid: Uuid().v4()));
        prefs.setString("queued_posts", jsonEncode(posts));
      } catch (e) {
        //Snackbar().show(context, ContentType.failure, "Error!!!!!!!", e.toString());
      }

      try {
        List<UserModel> to = List.empty(growable: true);
        to.add(widget.to);
        List<UserModel> from = List.empty(growable: true);
        setState(() {
          int seconds = DateTime
              .now()
              .millisecondsSinceEpoch;
          from.add(new UserModel(id: "547564565",
              username: username!,
              first_name: first_name!,
              last_name: last_name!,
              created_on: "",
              isFollowed: "",
              trades: "",
              about: "",
              reviews: "0",
              avatar: "",
              cover: "",
              followers: "",
              following: "",
              rank: "",
              loading: false, isBlocked: ''));
          List<ConversationsModel> iList = List.empty(growable: true);
          iList.add(new ConversationsModel(id: "546574654",
              content: _textEditingController.text,
              date: "$seconds",
              read: "false",
              unread: "1",
              to: to,
              from: from,
              imgUrl: '',
              loading: false));
          list.insertAll(0, iList);
        });
      } catch (e) {
        //Snackbar().show(context, ContentType.failure, "Error!!!!", e.toString());
      }
    }


    if (posts.isNotEmpty) {
      String val=_textEditingController.text;
      setState(() {
        _textEditingController.clear();
      });
      setTyping("null");
      try {
        int date=DateTime.now().millisecondsSinceEpoch;
        await status!.trigger("client-conversations", data: '{"sender": "$username", "date": "$date", "receiver": "${widget.to.username}", "message": "$val", "imageUrl": "", "isChat": "true"}');
        await channel!.trigger("client-conversations", data: '{"sender": "$username", "date": "$date", "receiver": "${widget.to.username}", "message": "$val", "imageUrl": "", "isChat": "true"}');
      } catch (e) {
       // Snackbar().show(context, ContentType.failure, Language.error, e.toString());
      }
      //Snackbar().show(context, ContentType.success, Language.success, posts.toString());
    }

    setState(() {
      _scrollUp();
    });
  }


  postImage(String imagePath) async {
    List<Post> posts = List.empty(growable: true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("username");
    var first_name = prefs.getString("firstname");
    var last_name = prefs.getString("lastname");
    try {
      var old_post = json.decode(prefs.getString("queued_posts")!) as List<
          dynamic>;
      for (var post in old_post) {
        posts.add(Post(user: post["user"],
            content: post["content"],
            url: post["url"],
            var1: post["var1"],
            retries: post["retries"],
            uid: post["uid"]));
      }
    } catch (e) {}

    try {
      posts.add(Post(user: widget.to.username,
          content: "image",
          url: "/post_conversation_image",
          var1: "$imagePath",
          retries: 0,
          uid: Uuid().v4()));
      prefs.setString("queued_posts", jsonEncode(posts));
    } catch (e) {}

    try {
      List<UserModel> to = List.empty(growable: true);
      to.add(widget.to);
      List<UserModel> from = List.empty(growable: true);
      setState(() {
        int seconds = DateTime
            .now()
            .millisecondsSinceEpoch;
        from.add(new UserModel(id: "local->image",
            username: username!,
            first_name: first_name!,
            last_name: last_name!,
            created_on: "",
            isFollowed: "",
            trades: "",
            about: "",
            reviews: "0",
            avatar: "",
            cover: "",
            followers: "",
            following: "",
            rank: "",
            loading: false, isBlocked: ''));
        List<ConversationsModel> iList = List.empty(growable: true);
        iList.add(new ConversationsModel(id: "local->image",
            content: "image",
            date: "$seconds",
            read: "false",
            unread: "1",
            to: to,
            from: from,
            imgUrl: '$imagePath',
            loading: false));
        list.insertAll(0, iList);
      });
    } catch (e) {}
    setTyping("null");
    setState(() {
      _scrollUp();
    });
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: kSecondary,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
              ),
              padding: EdgeInsets.only(top: 10),
              child: Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: kPrimaryLightColor,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                              topLeft: Radius.circular(10.0)),
                        ),
                        margin: EdgeInsets.only(left: 15,),
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        child: InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            color: kSecondary,
                            size: 22,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        )
                    ),
                    InkWell(
                      onTap: () {
                        if (widget.to.username != Strings.agent_name) {
                          Navigator.push(context, MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) =>
                                  UserProfile(user: widget.to!, fromChat: true,)));
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${widget.to.first_name} ${widget.to
                              .last_name}", maxLines: 2,
                            style: TextStyle(color: kSecondary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),),
                          typing(),
                        ],
                      ),
                    ),
                    Container(margin: EdgeInsets.only(right: 28),
                      child: widget.to.username == Strings.agent_name
                          ? SizedBox()
                          :
                      PopupMenuButton(
                          child: Icon(Icons.more_vert, color: kSecondary,),
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem<int>(
                                value: 0,
                                child: Text(Language.profile),
                              ),
                              PopupMenuItem<int>(
                                value: 1,
                                child: Text(Language.send_coin),
                              ),
                            ];
                          },
                          onSelected: (value) {
                            if (value == 0) {
                              Navigator.push(context,
                                  MaterialPageRoute<dynamic>(
                                      builder: (BuildContext context) =>
                                          UserProfile(user: widget.to!, fromChat: true,)));
                            }else if (value == 1) {
                              _sendCoin("Select Wallet");
                            }
                          }
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            loading ? Container(
                margin: EdgeInsets.all(50),
                child: Center(
                    child: CircularProgressIndicator()))
                :
            list.length <= 0 ?
            Container(
              height: 200,
              margin: EdgeInsets.all(20),
              child: Center(
                child: Text("You have not started any conversation Yet!",
                  style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: kPrimaryColor),),
              ),
            )
                :
            Expanded(
                child: ListView.builder(
                    controller: _controller,
                    physics: AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    reverse: true,
                    padding: EdgeInsets.only(top: 0),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return getListItem(
                          list[index], index, context);
                    })
            ),
            Offstage(
              offstage: !emojiShowing,
              child: SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    textEditingController: _textEditingController,
                    onBackspacePressed: onBackspacePressed,
                    config: Config(
                      columns: 7,
                      emojiSizeMax: 32 *
                          (foundation.defaultTargetPlatform ==
                              TargetPlatform.iOS
                              ? 1.30
                              : 1.0),
                      verticalSpacing: 0,
                      horizontalSpacing: 0,
                      gridPadding: EdgeInsets.zero,
                      initCategory: Category.RECENT,
                      bgColor: Color(0xFFF2F2F2),
                      indicatorColor: Colors.blue,
                      iconColor: Colors.grey,
                      iconColorSelected: Colors.blue,
                      backspaceColor: Colors.blue,
                      skinToneDialogBgColor: kSecondary,
                      skinToneIndicatorColor: Colors.grey,
                      enableSkinTones: true,
                      recentTabBehavior: RecentTabBehavior.RECENT,
                      recentsLimit: 28,
                      replaceEmojiOnLimitExceed: false,
                      noRecents: Text(
                        'No Recent',
                        style: TextStyle(fontSize: 20, color: Colors.black26),
                        textAlign: TextAlign.center,
                      ),
                      loadingIndicator: SizedBox.shrink(),
                      tabIndicatorAnimDuration: kTabScrollDuration,
                      categoryIcons: CategoryIcons(),
                      buttonMode: ButtonMode.MATERIAL,
                      checkPlatformCompatibility: true,
                    ),
                  )),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          width: double.infinity,
          decoration: new BoxDecoration(
              border: new Border(
                  top: new BorderSide(color: Colors.blueGrey, width: 0.5)),
              color: Colors.white),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      emojiShowing = !emojiShowing;
                    });
                  },
                  icon: Icon(
                    Icons.emoji_emotions,
                    color: Colors.yellow[700], size: 30,
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  XFile? res = await _picker.pickImage(source: ImageSource.gallery);
                  if (res != null) {
                    postImage(res.path);
                  }
                },
                child: Icon(Icons.image_outlined, size: 30,),
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 200,
                  maxWidth: 250,
                ),
                decoration: BoxDecoration(
                  border: Border.all(width: 0, color: Colors.transparent),
                ),
                child: new Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: InputDecorationTheme(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 42, vertical: 20),
                    ),),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    focusNode: focusNode,
                    minLines: 1,
                    maxLines: 4,
                    autofocus: false,
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: "Enter Message",
                      isDense: true,
                      fillColor: kSecondary,
                      filled: true,
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      if(value.isNotEmpty) {
                        setTyping("typing");
                      }else{
                        setTyping("null");
                      }
                    },
                  ),),
              ),
              Material(
                child: new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 8.0),
                  child: showprogress ? Container(
                    padding: EdgeInsets.all(10),
                    height: 40, width: 40,
                    child: Center(
                        child: CircularProgressIndicator()),
                  ) : new IconButton(
                    icon: new Icon(Icons.send),
                    onPressed: () async {
                      if (!showprogress) {
                        post();
                      }
                    },
                    color: Colors.blueGrey,
                  ),
                ),
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget getListItem(ConversationsModel obj, int index,
      BuildContext context) {
    final messageSender = obj.from.first.username;
    final messageText = obj.content;
    final time = obj.date;
    bool isMe = messageSender == username! ? true : false;
    bool isLocalFile = obj.to.first.id == "local->image" ||
        obj.from.first.id == "local->image" ? true : false;

    return MessageBubble(
      context, index, obj.id, messageSender, messageText, time, isMe, messageSender == username! ? obj.to.first : obj.from.first, isLocalFile, obj.imgUrl);
  }


Container MessageBubble(BuildContext context, int index, String cid, String sender, String text, String timestamp, bool isMe, UserModel to, bool isLocalFile, String imgUrl){
    final dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp!) * 1000);
    return Container(
        margin: isMe! ? EdgeInsets.only(left: 50.0) : EdgeInsets.only(right: 50.0),
        padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            borderRadius: isMe!
                ? BorderRadius.only(
              bottomLeft: Radius.circular(30.0),
              topLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
              )
                : BorderRadius.only(
              bottomLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            elevation: 5.0,
            color: isMe! ? kPrimaryColor : yellow100,
            child: text.contains("deleted->") ?
            Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: isMe! ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'deleted!',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: isMe! ? kSecondary : Colors.black,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Container(
                      width: 50,
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 5, top: 5),
                            child: Text(
                              "${DateFormat('h:mm a').format(dateTime)}",
                              style: TextStyle(
                                fontSize: 9.0,
                                color: isMe!
                                    ? kSecondary.withOpacity(0.5)
                                    : Colors.black54.withOpacity(0.5),
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          SizedBox(width: 5,),
                          isMe! ? Icon(list[index].id=="546574654" ? Icons.done_sharp : list[index].id=="546574651" ? Icons.file_download_done_outlined : Icons.done_all_outlined, size: 20, color: list[index].read=="true" ? Colors.green[700] : kSecondary.withOpacity(0.5),) : SizedBox(),
                        ],
                      ),
                    ),
                    list[index].loading?
                    Container(
                      margin: EdgeInsets.only(top: 10, left: 5),
                      height:20, width:20,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.yellow,
                        valueColor: AlwaysStoppedAnimation<Color>(kPrimaryDarkColor),
                      ),
                    ) :
                    SizedBox(),
                  ],
                ),
              ) : isLocalFile! && text=="image"?
             Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: isMe! ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      child: Image.file(File(imgUrl!), fit: BoxFit.cover),
                    ),
                    Container(
                      width: 50,
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 5, top: 5),
                            child: Text(
                              "${DateFormat('h:mm a').format(dateTime)}",
                              style: TextStyle(
                                fontSize: 9.0,
                                color: isMe!
                                    ? kSecondary.withOpacity(0.5)
                                    : Colors.black54.withOpacity(0.5),
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(width: 5,),
                          isMe! ? Icon(list[index].id=="546574654" ? Icons.done_sharp : list[index].id=="546574651" ? Icons.file_download_done_outlined : Icons.done_all_outlined, size: 20, color: list[index].read=="true" ? Colors.green[700] : kSecondary.withOpacity(0.5),) : SizedBox(),
                        ],
                      ),
                    ),
                    list[index].loading?
                    Container(
                      margin: EdgeInsets.only(top: 10, left: 5),
                      height:20, width:20,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.yellow,
                        valueColor: AlwaysStoppedAnimation<Color>(kPrimaryDarkColor),
                      ),
                    ) :
                    SizedBox(),
                  ],
                ),
              ) : list[index].id=="546574654" || list[index].id=="546574651" ?
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: imgUrl!.isNotEmpty && text=="image" ? Text("Save") : Text("Copy"),
                  ),
                ];
              },
              onSelected: (value) {
                if (value == 0) {
                  Clipboard.setData(ClipboardData(text: text!));
                  Toast.show("Text Copied to Clipboard!", duration: Toast.lengthLong, gravity: Toast.bottom);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: isMe! ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    imgUrl!.isNotEmpty && text=="image" ?
                    InkWell(
                      onTap: (){
                        ImagePreview().preview(context, imgUrl!, setState);
                      },
                      child: Container(
                        height: 150,
                        width: 150,
                        child: CachedNetworkImage(
                          imageUrl: imgUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ) :
                    Text(
                      text!,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: isMe! ? kSecondary : Colors.black,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Container(
                      width: 50,
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 5, top: 5),
                            child: Text(
                              "${DateFormat('h:mm a').format(dateTime)}",
                              style: TextStyle(
                                fontSize: 9.0,
                                color: isMe!
                                    ? kSecondary.withOpacity(0.5)
                                    : Colors.black54.withOpacity(0.5),
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(width: 5,),
                          isMe! ? Icon(list[index].id=="546574654" ? Icons.done_sharp : list[index].id=="546574651" ? Icons.file_download_done_outlined : Icons.done_all_outlined, size: 20, color: list[index].read=="true" ? Colors.green[700] : kSecondary.withOpacity(0.5),) : SizedBox(),
                        ],
                      ),
                    ),
                    list[index].loading?
                    Container(
                      margin: EdgeInsets.only(top: 10, left: 5),
                      height:20, width:20,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.yellow,
                        valueColor: AlwaysStoppedAnimation<Color>(kPrimaryDarkColor),
                      ),
                    ) :
                    SizedBox(),
                  ],
                ),
              ),
            ) : PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: imgUrl!.isNotEmpty && text=="image" ? Text("Save") : Text("Copy"),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text("Delete"),
                  ),
                ];
              },
              onSelected: (value) {
                if (value == 0) {
                  Clipboard.setData(ClipboardData(text: text!));
                  Toast.show("Text Copied to Clipboard!", duration: Toast.lengthLong, gravity: Toast.bottom);
                } else if (value == 1) {
                  deleteChat(index, cid);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: isMe! ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    imgUrl!.isNotEmpty && text=="image" ?
                    InkWell(
                      onTap: (){
                        ImagePreview().preview(context, imgUrl!, setState);
                      },
                      child: Container(
                        height: 150,
                        width: 150,
                        child: CachedNetworkImage(
                          imageUrl: imgUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ) :
                    Text(
                      text!,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: isMe! ? kSecondary : Colors.black,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Container(
                      width: 50,
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 5, top: 5),
                            child: Text(
                              "${DateFormat('h:mm a').format(dateTime)}",
                              style: TextStyle(
                                fontSize: 9.0,
                                color: isMe!
                                    ? kSecondary.withOpacity(0.5)
                                    : Colors.black54.withOpacity(0.5),
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(width: 5,),
                          isMe! ? Icon(list[index].id=="546574654" ? Icons.done_sharp : list[index].id=="546574651" ? Icons.file_download_done_outlined : Icons.done_all_outlined, size: 20, color: list[index].read=="true" ? Colors.green[700] : kSecondary.withOpacity(0.5),) : SizedBox(),
                        ],
                      ),
                    ),
                    list[index].loading?
                    Container(
                      margin: EdgeInsets.only(top: 10, left: 5),
                      height:20, width:20,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.yellow,
                        valueColor: AlwaysStoppedAnimation<Color>(kPrimaryDarkColor),
                      ),
                    ) :
                    SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  deleteChat(int i, String cid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username")!;
    String token = prefs.getString("token")!;
    setState(() {
      list[i].loading = true;
    });
    String apiurl = Strings.url + "/delete_chat";
    var response = null;
    try {
      Map data = {
        'username': username,
        'cid': cid,
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
        if (jsonBody["status"] == "success") {
          setState(() {
            list.elementAt(i).content="deleted->";
          });
          Toast.show("Deleted!", duration: Toast.lengthLong, gravity: Toast.bottom);
        }
      }
    } catch (e) {
      Toast.show(Language.network_error, duration: Toast.lengthLong,
          gravity: Toast.bottom);
    }

    setState(() {
      list[i].loading = false;
    });
  }

  String getDate(String timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp!) * 1000);
    return "${DateFormat('h:mm a').format(dateTime)}";
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

  List<CryptoModel> wList = List.empty(growable: true);
  cachedList() async {
    List<CryptoModel> iList = await getCryptosCached();
    setState(() {
      wList = iList;
    });
  }

  Widget getSingleChildScrollView(String title) {
    wList=wList.where((o) => !o.type.toLowerCase().contains("fiat")).toList();
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
                  MaterialPageRoute(builder: (context) => ViewCrypto(obj: obj, action: "@"+widget.to.username)));
            }else if(obj.type=="fiat"){
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ViewFiat(obj: obj, action: "@"+widget.to.username)));
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