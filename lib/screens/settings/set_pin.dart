import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pin_code_view/pin_code_view.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:crypto_app/constants.dart';
import 'package:toast/toast.dart';

import '../../components/coustom_bottom_nav_bar.dart';
import '../../language.dart';
import '../../strings.dart';
import '../../widgets/snackbar.dart';
import '../splash/welcome.dart';

class setPin extends StatefulWidget {
  @override
  _setPinState createState() => _setPinState();
}

class _setPinState extends State<setPin> {


  String msg="", new_Pin="", confirm_Pin="";
  bool? error=false, showprogress=false;

  start() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username=prefs.getString("username");
    String? email=prefs.getString("email");
    String? token=prefs.getString("token");

    if (new_Pin.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        msg = "Enter New Pin";
      });
    } else if (confirm_Pin.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        msg = "Enter Confirm Pin";
      });
    } else if (new_Pin!=confirm_Pin) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        msg = "Pins not match";
      });
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: Language.loading,
        text: Language.processing,
      );
      String apiurl = Strings.url+"/change-pin";
      var response = null;
      try {
        Map data = {
          'email': email,
          'old_pin': '1234',
          'pin': new_Pin,
          'pin_confirmation': confirm_Pin
        };
        var body = json.encode(data);
        response = await http.post(Uri.parse(apiurl),
            headers: {
              "Content-Type": "application/json",
              "Authentication": "Bearer $token"},
            body: body
        );
      } catch (e) {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          msg = Language.network_error;
        });
        Navigator.pop(context);
      }
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["status"] != null &&
            jsondata["status"].toString().contains("success")) {

          prefs.setString("pin", new_Pin);
          prefs.setString("access", "unlocked");
          setState(() {
            showprogress = false; //don't show progress indicator
            error = false;
            msg = jsondata["response_message"];
          });
        }else if (jsondata["status"].toString().contains("error") &&
            jsondata["response_message"].toString().contains("Authentication")) {

          await FirebaseMessaging.instance.unsubscribeFromTopic(username!);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.clear();
          Toast.show(Language.session_expired, duration: Toast.lengthLong, gravity: Toast.bottom);
          Get.offAllNamed(WelcomeScreen.routeName);

        }else{
          setState(() {
            showprogress = false; //don't show progress indicator
            error = true;
            msg = jsondata["response_message"];
          });
        }
        Navigator.pop(context);
      } else {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          msg = Language.network_error;
        });
        Navigator.pop(context);
      }
    }

    if(error!) {
      Snackbar().show(context, ContentType.failure, Language.error, msg!);
    }else{
      Snackbar().show(context, ContentType.success, Language.success, msg!);
      Navigator.pushAndRemoveUntil<dynamic>(
        context, MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => Dashboard(),), (
          route) => false,);
    }
  }

  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: PinCode(
        title: Language.enter_new_pin,
        subtitle: Language.unlock_new_pin,
        backgroundColor: kPrimaryColor,
        codeLength: 4,
        error: msg,
        keyboardType: KeyboardType.numeric,
        onChange: (String code) {
          if(code.length!=4){
            setState(() {
              msg="Pin must be 4 digits";
            });
          }else{
            new_Pin=code;
            confirm_Pin=code;
            start();
          }
        },
        obscurePin: false,
      ),
    );
  }

}
