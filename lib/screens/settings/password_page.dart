import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
 
import '../../constants.dart';
import '../../language.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import '../../widgets/material.dart';
import '../splash/welcome.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

InputDecoration myInputDecoration({required String label, required IconData icon}){
  return InputDecoration(
    hintText: label,
    hintStyle: TextStyle(color:Colors.black87, fontSize:15), //hint text style
    prefixIcon: Padding(
        padding: EdgeInsets.only(left:20, right:10),
        child:Icon(icon, color: Colors.blue[100],)
      //padding and icon for prefix
    ),

    contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color:kSecondary, width: 0)
    ), //default border of input

    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color:kSecondary, width: 0)
    ), //focus border

    fillColor: kSecondary,
    filled: false, //set true if you want to show input background
  );
}


class _ChangePasswordState extends State<ChangePassword> {
  String errormsg="";
  bool error=false, success=false, showprogress=false;

  String email="", password="", token="", newpassword="", retypepassword="";

  savePassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString("email")!;
    token = prefs.getString("token")!;
    if (password.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Old Password";
      });
    } else if (newpassword.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter New Password";
      });
    } else if (retypepassword.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Retype Password";
      });
    } else if (retypepassword != newpassword) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Password not match";
      });
    } else {
      setState(() {
        //show progress indicator on click
        showprogress = true;
        error=false;
      });
      String apiurl = Strings.url+"/change-password";
      var response = null;
      try {
         Map data = {
          'email': email,
          'old_password': password.trim(),
          'password': newpassword.trim(),
          'password_confirmation': retypepassword.trim()
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
          errormsg = "Network connection error! $e";
        });
      }
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["status"] != null &&
            jsondata["status"].toString().contains("success")) {
          setState(() {
            success = true;
          });
          setState(() {
            showprogress = false; //don't show progress indicator
            error = true;
            errormsg = jsondata["response_message"];
          });
        }else if (jsondata["status"].toString().contains("error") &&
            jsondata["response_message"].toString().contains("Authentication")) {

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.clear();
          Toast.show(Language.session_expired, duration: Toast.lengthLong, gravity: Toast.bottom);
          Get.offAllNamed(WelcomeScreen.routeName);

        }else{
          setState(() {
            success = false;
          });
          setState(() {
            showprogress = false; //don't show progress indicator
            error = true;
            errormsg = jsondata["response_message"];
          });
        }
      } else {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = Language.network_error;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          height: 800,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              backAppbar(context, Language.change_password),
              SizedBox(
                height: 20,
              ),
              error? Container(
                //show error message here
                margin: EdgeInsets.only(bottom:10),
                padding: EdgeInsets.all(10),
                child: errmsg(errormsg, success, context),
                //if error == true then show error message
                //else set empty container as child
              ) : Container(),
              SizedBox(
                height: 10,
              ),
          Container(
            margin:
            EdgeInsets.only(top: 20, right: 20, left: 20),
            height: 60,
            child: SizedBox(
              height: 60,
              child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                  obscureText: true,
                keyboardType: TextInputType.text,
                maxLength: 20,
                decoration: InputDecoration(
                  hintText: Language.old_password,
                  isDense: true,
                  fillColor: kSecondary,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                ),
                  onChanged: (value){
                    //set username  text on change
                    password = value;
                  },
                ),
              ),
              ),
              SizedBox(
                height: 10,
              ),

              Container(
                margin:
                EdgeInsets.only(top: 20, right: 20, left: 20),
                height: 60,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                  obscureText: true,
                    keyboardType: TextInputType.text,
                    maxLength: 20,
                    decoration: InputDecoration(
                      hintText: Language.new_password,
                      isDense: true,
                      fillColor: kSecondary,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                    ),
                  onChanged: (value){
                    //set username  text on change
                    newpassword = value;
                  },
                ),
              ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin:
                EdgeInsets.only(top: 20, right: 20, left: 20),
                height: 60,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                  obscureText: true,
                    keyboardType: TextInputType.text,
                    maxLength: 20,
                    decoration: InputDecoration(
                      hintText: Language.retype_password,
                      isDense: true,
                      fillColor: kSecondary,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                    ),
                  onChanged: (value){
                    //set username  text on change
                    retypepassword = value;
                  },

                ),
              ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.only(
                  bottom: 10,
                  left: 20,
                  right: 20,
                ),
                child: SizedBox(
                  height: 50, width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (){
                      if(!showprogress) {
                        setState(() {
                          success = false;
                        });
                        savePassword();
                      }

                    },
                    style: ElevatedButton.styleFrom(primary: kPrimaryColor),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, right: 30.0, top: 10, bottom: 10),
                      child: showprogress?
                      SizedBox(
                        height:20, width:20,
                        child: CircularProgressIndicator(
                          backgroundColor: kSecondary,
                          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                        ),
                      ) : Text(
                        Language.submit,
                        style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                    ) ,
                    // if showprogress == true then show progress indicator
                    // else show "LOGIN NOW" text

                      //button corner radius
                    ),
                  ),
                ),
              ),
            ],

    ),
      ),
      ),
    );
  }
}


