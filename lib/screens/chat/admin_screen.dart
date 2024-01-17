import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../../constants.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';

final _firestore = FirebaseFirestore.instance;
final focusNode = FocusNode();

String username=Strings.agent_name, status="";
int limit=15;

class AdminScreen extends StatefulWidget {
  final String to;
  AdminScreen({required this.to});
  
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final controller = TextEditingController();
  var messageText; 


  Widget typing(){
    Toast.show("$username - ${widget.to}", duration: Toast.lengthLong, gravity: Toast.bottom);
    _firestore.collection('conversations').where('id', whereIn: ['$username\_${widget.to}', '${widget.to}\_$username']).get().then((value){
     final data = value.docs.first.data() as dynamic;
     final messageSender = data['sender'];
     if(messageSender!=username && data['status'].toString().contains("typing") && int.parse(data["timestamp"]) > (new DateTime.now()).millisecondsSinceEpoch - 10000){
      setState(() {
        status="$messageSender is typing...";
      });
     }else{
      setState(() {
        status="";
      });
     }

    });
    return Text("$status", style: TextStyle(color: kSecondary, fontSize: 14, fontWeight: FontWeight.bold),);

  }


  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() async {
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
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0)),
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
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0), topRight: Radius.circular(10.0), topLeft: Radius.circular(10.0)),
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Chat - Support", maxLines: 2, style: TextStyle(color: kSecondary, fontSize: 25, fontWeight: FontWeight.bold),),
                          typing(),
                        ],
                      ),
                      Container(margin: EdgeInsets.only(right: 28),),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              MessagesStream(to: widget.to,),
              Container(
                width: double.infinity,
                height: 70.0,
                decoration: new BoxDecoration(
                    border: new Border(
                        top:
                        new BorderSide(color: Colors.blueGrey, width: 0.5)),
                    color: kSecondary),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        height: 60,
                        child: new Theme(
                          data: Theme.of(context).copyWith(
                            inputDecorationTheme: InputDecorationTheme(border: InputBorder.none, floatingLabelBehavior: FloatingLabelBehavior.always,
                              contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),),
                          ),
                          child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          focusNode: focusNode,
                          maxLines: null,
                          controller: controller,
                          onChanged: (value) {
                            messageText = value;
                            _firestore.collection('conversations').where('id', whereIn: ['$username\_${widget.to}', '${widget.to}\_$username']).get().then((val){
                              if(value.isNotEmpty){
                                if(val.size>0){
                                  val.docs.first.reference.update({
                                    'sender': username,
                                    'status':  "is typing...",
                                    'read': "true",
                                    'timestamp': '${(new DateTime.now()).millisecondsSinceEpoch}',
                                  });
                                }
                              }else{
                                if(val.size>0){
                                  val.docs.first.reference.update({
                                    'status':  "closed",
                                    'read': "true",
                                    'timestamp': '${(new DateTime.now()).millisecondsSinceEpoch}',
                                  });
                                }
                              }
                            });
                          },
                            decoration: InputDecoration(
                              hintText: "Enter Message",
                              isDense: true,
                              fillColor: kSecondary,
                              filled: true,
                              border: InputBorder.none,
                            )
                        ),
                        ),
                      ),
                    ),
                    Material(
                      child: new Container(
                        margin: new EdgeInsets.symmetric(horizontal: 8.0),
                        child: new IconButton(
                          icon: new Icon(Icons.send),
                          onPressed: () async {
                            if(messageText.isNotEmpty) {
                              controller.clear();
                              _firestore.collection('messages').add({
                                'id': '$username\_${widget.to}',
                                'sender': '$username',
                                'to': widget.to,
                                'text': messageText,
                                'timestamp': Timestamp.now(),
                              });
                              _firestore.collection('conversations').where('id', whereIn: ['$username\_${widget.to}', '${widget.to}\_$username']).get().then((value){
                                if(value.size==0){
                                  _firestore.collection('conversations').add({
                                    'id': '$username\_${widget.to}',
                                    'text': messageText,
                                    'sender': username,
                                    'to': widget.to,
                                    'read': "true",
                                    'status': '',
                                    'timestamp': "${(new DateTime.now()).millisecondsSinceEpoch}",});
                                }else{
                                  value.docs.first.reference.update({
                                    'id': '$username\_${widget.to}',
                                    'text': messageText,
                                    'sender': username,
                                    'to': widget.to,
                                    'read': "true",
                                    'status': '',
                                    'timestamp': "${(new DateTime.now()).millisecondsSinceEpoch}",});
                                }
                              });
                            }
                          },
                          color: Colors.blueGrey,
                        ),
                      ),
                      color: kSecondary,
                    ),
                  ],
                ),
              ),
            ],
        ),
      ),
    );
  }


}



class MessagesStream extends StatelessWidget {
  final String to;
  MessagesStream({required this.to});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('messages')
          .where('id', whereIn: ['$username\_$to', '$to\_$username'])
          .orderBy("timestamp", descending: true)
          .limit(limit)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Container(
            margin: EdgeInsets.only(top: 100),
            padding: EdgeInsets.all(20),
            child: SizedBox(
              height: 150,
              child: Text("Start a conversation and one of our staff will attend to you shortly!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor), textAlign: TextAlign.center,),
              ),
            ),
          );
        }
        List<Widget> messageWidgets = snapshot.data!.docs.map<Widget>((m) {
          final data = m.data() as dynamic;
          final messageText = data['text'];
          final messageSender = data['sender'];
          final currentUser = '$username';
          final timeStamp = data['timestamp'];
          return Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
          child: Dismissible(
            key: Key(m.id),
            direction: currentUser != messageSender ? DismissDirection.startToEnd : DismissDirection.endToStart,
            onDismissed: (direction) {
              m.reference.delete();
            },
            background: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: kSecondary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Spacer(),
                  SvgPicture.asset("assets/icons/Trash.svg"),
                ],
              ),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: MessageBubble(
                sender: messageSender,
                text: messageText,
                timestamp: timeStamp,
                isMe: currentUser == messageSender,
              ),
            )
          ));
        }).toList();

        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageWidgets,
          ),
        );
      },
    );
  }
}



class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.timestamp, this.isMe});
  final String? sender;
  final String? text;
  final Timestamp? timestamp;
  final bool? isMe;

  @override
  Widget build(BuildContext context) {
    final dateTime =
    DateTime.fromMillisecondsSinceEpoch(timestamp!.seconds * 1000);
    return InkWell(
      onLongPress: (){
        Clipboard.setData(ClipboardData(text: text!));
        Toast.show("Text Copied to Clipboard!", duration: Toast.lengthLong, gravity: Toast.bottom);
      },
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment:
          isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "$sender",
              style: TextStyle(fontSize: 12.0, color: Colors.black54),
            ),
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
              color:
              isMe! ? kPrimaryColor : yellow100,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Column(
                  crossAxisAlignment:
                  isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      text!,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: isMe! ? kSecondary : kSecondary,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 6.0),
                      child: Text(
                        "${DateFormat('h:mm a').format(dateTime)}",
                        style: TextStyle(
                          fontSize: 9.0,
                          color: isMe!
                              ? kSecondary.withOpacity(0.5)
                              : Colors.black54.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}