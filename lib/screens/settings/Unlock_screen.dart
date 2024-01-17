import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart'; 
import 'package:flutter/material.dart'; 
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pin_code_view/pin_code_view.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:crypto_app/screens/splash/welcome.dart';
import 'package:toast/toast.dart'; 
import '../../components/coustom_bottom_nav_bar.dart';
import '../../constants.dart';
import '../../language.dart';
import '../../radius.dart';
import '../../strings.dart';
import '../../widgets/material.dart';
import '../../widgets/snackbar.dart';


class PinScreen extends StatefulWidget {
  @override
  _PinUIState createState() => _PinUIState();
}


class _PinUIState extends State<PinScreen> {
  String msg="";
  bool error=false, showprogress=false;
  String pin="", errorText="";
  int count=0;

  void getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    pin = prefs.getString("pin")!;
  }

  @override
  void initState() {
    getuser();
    super.initState();
  }

  void _saveSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("access", "unlocked");
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => Dashboard()));
  }

  recoverPin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString("email");
    var token = prefs.getString("token");
    String apiurl = Strings.url+"/reset-pin"; //api url
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: Language.loading,
        text: Language.processing,
      );
      var response = null;
      Map data = {
        'email': email,
      };

      var body = json.encode(data);
      try {
        response = await http.post(Uri.parse(apiurl),
            headers: {
              "Content-Type": "application/json",
              "Authentication": "Bearer $token"},
            body: body
        );
        if (response != null && response.statusCode == 200) {
          try {
            var jsondata = json.decode(response.body);
            if (jsondata["status"] != null &&
                jsondata["status"].toString().contains("success")) {
              error=false;
              msg=jsondata["response_message"];
              prefs.setString("pin", jsondata["pin"]);

               pin=jsondata["pin"];
            }else if (jsondata["status"].toString().contains("error") &&
                jsondata["response_message"].toString().contains("Authentication")) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              Toast.show(Language.session_expired, duration: Toast.lengthLong, gravity: Toast.bottom);
              Get.offAllNamed(WelcomeScreen.routeName);

            } else {
              error=true;
              msg=jsondata["response_message"];
            }
          } catch (e) {
            error=true;
            msg=Language.network_error;
          }
        } else {
          error=true;
          msg=Language.network_error;
        }
      } catch (e) {
        error=true;
        msg=Language.network_error;
      }

    if(error!) {
      Snackbar().show(context, ContentType.failure, Language.error, msg!);
    }else{
      Snackbar().show(context, ContentType.success, Language.success, msg!);
    }
     Navigator.pop(context);
  }

  resetPin(){
    QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: Language.error,
        text: Language.reset_pin_text,
        confirmBtnText: Language.yes,
        cancelBtnText: Language.no,
        showCancelBtn: true,
        confirmBtnColor: kPrimaryColor,
        onConfirmBtnTap: (){
          Navigator.pop(context);
          recoverPin();
          return;
        },
        onCancelBtnTap: (){
          Navigator.pop(context);
          return;
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(bottom: 20),
          margin: EdgeInsets.only(bottom: 20, top: 40),
        child: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
        Container(
        height: 600,
        width: MediaQuery.of(context).size.width,
          child: PinCode(
            title: Language.enter_pin,
            subtitle: Language.unlock_pin,
            backgroundColor: kPrimaryColor,
            codeLength: 4,
            error: errorText,
            keyboardType: KeyboardType.numeric,
            onChange: (String code) {
              setState(() {
                count=count+1;
              });
              if(code.length!=4){
                setState(() {
                  errorText="";
                });
              }else if(pin==code){
                setState(() {
                  errorText=Language.success;
                });
                _saveSession();
              }else {
                setState(() {
                  errorText = Language.incorrect_pin+" ($count)";
                });
                if (count >= 6) {
                  logout();
                }else if (count > 4) {
                  resetPin();
                }
              }
            },
            obscurePin: true,
           ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: Language.forgot_pin,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                    color: kSecondary,
                  ),
                  children: [
                    TextSpan(
                        text: Language.reset,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          color: yellow100,
                        )),
                  ],
                ),
              ),
            ),
            onTap: () {
              resetPin();
            },
          ),
          SizedBox(
            height: 20,
          ),
          Container(
              width: MediaQuery.of(context).size.width*0.70,
              padding: EdgeInsets.only(
                  bottom: 2, left: 2, right: 2, top: 2),
              decoration: BoxDecoration(
                  borderRadius: circularRadius(AppRadius.border12),
                  color: kPrimaryLightColor
              ),
              child: OutlinedButton(
                child: Text(
                  Language.logout_session,
                  style: TextStyle(
                      color: kSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: (){
                  logout();
                },
              )),
          SizedBox(
            height: 10,
          ),
        ],
       ),
      ),
      ),
    );
  }

  logout() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Get.offAllNamed(WelcomeScreen.routeName);
  }

}
