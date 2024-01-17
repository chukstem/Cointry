import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_app/components/default_button.dart';
import 'package:crypto_app/screens/home/home_screen.dart';
import 'package:crypto_app/size_config.dart';
import 'package:toast/toast.dart';

import '../../../constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../language.dart';
import '../../../strings.dart';
import '../../../widgets/material.dart';
import '../../../widgets/snackbar.dart';
import '../../sign_in/sign_in_screen.dart';

class OtpForm extends StatefulWidget {
  OtpForm({
    Key? key,
  }) : super(key: key);

  @override
  _OtpFormState createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  FocusNode? pin2FocusNode;
  FocusNode? pin3FocusNode;
  FocusNode? pin4FocusNode;
  String errormsg="";
  bool error=false, success=false, showprogress=false, showprogress2=false;
  String otp="";
  String one="", two="", three="", four="";

  @override
  void initState() {
    super.initState();
    pin2FocusNode = FocusNode();
    pin3FocusNode = FocusNode();
    pin4FocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    pin2FocusNode!.dispose();
    pin3FocusNode!.dispose();
    pin4FocusNode!.dispose();
  }

  void nextField(String value, FocusNode? focusNode) {
    if (value.length == 1) {
      focusNode!.requestFocus();
    }
  }

  startOtp(BuildContext context) async {
    otp="$one$two$three$four";
    if (otp.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Please enter OTP";
      });
    } else {
      QuickAlert.show(
        context: context,
        backgroundColor: kPrimaryColor,
        textColor: kSecondary,
        titleColor: kSecondary,
        type: QuickAlertType.loading,
        title: Language.loading,
        text:  Language.processing,
        barrierDismissible: false,
      );
      String apiurl = Strings.url + "/verify";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var response = null;
      try {
        Map data = {
          'email': prefs.getString("email"),
          'otp': otp
        };
        var body = json.encode(data);
        response = await http.post(Uri.parse(apiurl),
            headers: {
              "Content-Type": "application/json",
              "Authentication": "Bearer Access0987654321"},
            body: body
        );
      } catch (e) {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = "Network connection error ";
        });
      }
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["status"].toString().contains("success")) {
          setState(() {
            error = false;
            showprogress = false;
            success = true;
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.clear();
          errormsg = jsondata["response_message"];
        } else {
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
      Navigator.pop(context);
      if (error!) {
        Snackbar().show(context, ContentType.failure, Language.error, errormsg+otp);
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context, SignInScreen.routeName, (route) => false,);
        Snackbar().show(context, ContentType.success, Language.success, errormsg);
      }
    }

  }



  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          SizedBox(height: 20,),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: getProportionateScreenWidth(60),
                child: TextFormField(
                  autofocus: true,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    LengthLimitingTextInputFormatter(1)],
                  style: TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) {
                    one=value;
                    nextField(value, pin2FocusNode);
                  },
                ),
              ),
              SizedBox(
                width: getProportionateScreenWidth(60),
                child: TextFormField(
                  focusNode: pin2FocusNode,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    LengthLimitingTextInputFormatter(1)],
                  style: TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value){
                    two=value;
                    nextField(value, pin3FocusNode);
                }
                ),
              ),
              SizedBox(
                width: getProportionateScreenWidth(60),
                child: TextFormField(
                  focusNode: pin3FocusNode,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    LengthLimitingTextInputFormatter(1)],
                  style: TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value){
                    three=value;
                    nextField(value, pin4FocusNode);
                  },
                ),
              ),
              SizedBox(
                width: getProportionateScreenWidth(60),
                child: TextFormField(
                  focusNode: pin4FocusNode,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    LengthLimitingTextInputFormatter(1)],
                  style: TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) {
                    if (value.length == 1) {
                      four=value;
                      pin4FocusNode!.unfocus();
                      // Then you need to check is the code is correct or not
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.15),
          showprogress? Center(child: SizedBox(
            height:40, width:40,
            child: CircularProgressIndicator(
              backgroundColor: kSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
            ),
          ),) :
          DefaultButton(
            text:  Language.proceed,
            press: () {
              if(!showprogress) {
                setState(() {
                  success=false;
                  showprogress = true;
                  error=false;
                });
                startOtp(context);
              }
            },
          )
        ],
      ),
    );
  }
}
