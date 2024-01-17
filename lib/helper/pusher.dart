import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_pusher/pusher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../strings.dart';
import '../widgets/snackbar.dart';

Future<void> generalPusher(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var username = prefs.getString("username");
  try {
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
    //Snackbar().show(context, ContentType.warning, Language.error, "${x!.message}");
  });


  try{
    Channel channel = await Pusher.subscribe("private-chat.$username");
    channel!.bind("client-conversations", (data) {
      var js = data!.toJson(); 
      var object = jsonDecode(js["data"]);
      String sender=object["sender"];
      var message=object["message"];
      if(sender!=username && object["isChat"] != "true"){
        Snackbar().show(context, ContentType.success, sender, message);
      }
    });

  }catch (e) {
   // Snackbar().show(context, ContentType.warning, Language.error, "$e");
  }
}