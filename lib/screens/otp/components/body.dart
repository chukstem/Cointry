import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_app/constants.dart';
import 'package:crypto_app/size_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../language.dart';
import '../../../strings.dart';
import '../../../widgets/snackbar.dart';
import 'otp_form.dart';

class Body extends StatefulWidget {
  Body({
    Key? key,
  }) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String errormsg="";
  bool error=false, success=false, showprogress=false;

  resendOtp(BuildContext context) async {
    String apiurl = Strings.url+"/resend";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = null;
    try {
      QuickAlert.show(
        context: context,
        backgroundColor: kPrimaryColor,
        textColor: kSecondary,
        titleColor: kSecondary,
        type: QuickAlertType.loading,
        title: 'Processing request',
        text: 'Please wait...',
        barrierDismissible: false,
      );
      Map data = {
        'email': prefs.getString("email"),
      };
      var body = json.encode(data);
      response = await http.post(Uri.parse(apiurl),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "Bearer Access0987654321"},
          body: body
      );

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["status"].toString().contains("success")) {
        setState(() {
          success = true;
        });
      }
      setState(() {
        showprogress = false; //don't show progress indicator
        error = false;
        errormsg = jsondata["response_message"];
      });
    } else {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.network_error;
      });
    }
    Navigator.pop(context);
    if (error!) {
      Snackbar().show(context, ContentType.failure, Language.error, errormsg);
    }else{
      Snackbar().show(context, ContentType.success, Language.success, errormsg);
    }

    } catch (e) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg =  Language.network_error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: SizeConfig.screenHeight * 0.05),
              Text(
                Language.otp_verification,
                style: headingStyle,
              ),
              Text(Language.code_sent),
              Text(Language.check_email),
              OtpForm(),
              SizedBox(height: SizeConfig.screenHeight * 0.1),
              GestureDetector(
                onTap: () {
                  if(!showprogress) {
                    setState(() {
                      success=false;
                      showprogress = true;
                      error=false;
                    });
                    resendOtp(context);
                  }
                },
                child: Text(
                  Language.resend_otp,
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
