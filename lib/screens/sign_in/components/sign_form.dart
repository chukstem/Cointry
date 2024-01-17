import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_app/components/coustom_bottom_nav_bar.dart';
import 'package:crypto_app/components/custom_surfix_icon.dart';
import 'package:crypto_app/components/form_error.dart';
import 'package:crypto_app/helper/keyboard.dart';
import 'package:crypto_app/screens/forgot_password/forgot_password_screen.dart';
import '../../../components/default_button.dart';
import '../../../constants.dart';
import '../../../language.dart';
import '../../../size_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../strings.dart';
import '../../../widgets/material.dart';
import '../../../widgets/snackbar.dart';
import '../../otp/otp_screen.dart';

class SignForm extends StatefulWidget {
  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  bool? remember = false;
  final List<String?> errors = [];
  String errormsg="Login to continue";
  bool error=false, success=false, showprogress=false;
  String username="", verified="", number="";

  void addError({String? error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
      });
  }

  void removeError({String? error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  startLogin(BuildContext context) async {
    QuickAlert.show(
        context: context,
        backgroundColor: kPrimaryColor,
        textColor: kSecondary,
        titleColor: kSecondary,
        type: QuickAlertType.loading,
        title: Language.loading,
        text: Language.processing,
        barrierDismissible: false,
    );
    String apiurl = Strings.url+"/login";
      var response = null;
      try {
        Map data = {
          'username': email!,
          'password': password!
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
          errormsg = Language.network_error;
        });
      }
      if (response != null && response.statusCode == 200) {
        var user = json.decode(response.body);
        try {
          var jsond = user["user_details"] as List<dynamic>;
          for (var jsondata in jsond) {
            if (user["status"] != null &&
                user["status"].toString().contains("success")) {
              setState(() {
                error = false;
                showprogress = false;
                errormsg = "success";
              });
              username = jsondata["username"] ?? "";
              String token = jsondata["app_token"] ?? "";
              String firstname = jsondata["first_name"] ?? "";
              String lastname = jsondata["last_name"] ?? "";
              String number = jsondata["phone"] ?? "";
              String email = jsondata["email"] ?? "";
              verified = "${jsondata["email_verified_at"]}";
              try {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString("firstname", firstname);
                prefs.setString("lastname", lastname);
                prefs.setString("number", number);
                prefs.setString("email", email);
                prefs.setString("token", token);
                prefs.setString("verified", verified);
                prefs.setString("pin", "${jsondata["app_pin"]}");
                prefs.setString("avatar", "${jsondata["image"]}");
                prefs.setString("about", "${jsondata["about"]}");
                prefs.setString("kyc_verified", "${jsondata["kyc_verified_at"]}");
                Navigator.pop(context);
                if (verified != null && verified.length>5) {
                  setState(() {
                    success=true;
                  });
                  prefs.setString("username", username);
                  Navigator.pushAndRemoveUntil<dynamic>(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => Dashboard(),), (
                      route) => false,);

                } else {
                  setState(() {
                    success=false;
                  });
                }
              } catch (e) {
                setState(() {
                  showprogress = false; //don't show progress indicator
                  error = true;
                  errormsg = e.toString();
                });
              }
            } else {
              setState(() {
                showprogress = false; //don't show progress indicator
                error = true;
                errormsg = user["response_message"];
              });
            }
          }
        } catch (e) {
          setState(() {
            showprogress = false; //don't show progress indicator
            error = true;
            errormsg = user["response_message"];
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
    if(error!) {
      Snackbar().show(context, ContentType.failure, Language.error, errormsg);
    }else if(success){
      Navigator.pushAndRemoveUntil<dynamic>(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => Dashboard(),), (
          route) => false,);

    } else {
      Navigator.pushAndRemoveUntil<dynamic>(
          context, MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => OtpScreen(),), (route) => false,);
    }

    }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            //show error message here
            margin: EdgeInsets.only(bottom:10),
            padding: EdgeInsets.all(10),
            child: errmsg(errormsg, success, context),
            //if error == true then show error message
            //else set empty container as child
          ),
          SizedBox(
            height: 10,
          ),
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          Row(
            children: [
              Checkbox(
                value: remember,
                activeColor: kPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    remember = value;
                  });
                },
              ),
              Text("Remember me"),
              Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, ForgotPasswordScreen.routeName),
                child: Text(
                  "Forgot Password",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              )
            ],
          ),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(20)),
          showprogress? Center(child: SizedBox(
            height:40, width:40,
            child: CircularProgressIndicator(
              backgroundColor: kSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
            ),
          ),) :
          DefaultButton(
            text: "Continue",
            press: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // if all are valid then go to success screen
                KeyboardUtil.hideKeyboard(context);
                //Navigator.pushNamed(context, LoginSuccessScreen.routeName);
                if(!showprogress) {
                  startLogin(context);
                  setState(() {
                    success=false;
                    showprogress = true;
                    error=false;
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 5) {
          removeError(error: kShortPassError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 5) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: Language.password,
        hintText: Language.enter_password,
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidEmailError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kEmailNullError);
          return "";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidEmailError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText:Language.email,
        hintText: Language.enter_email,
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
      ),
    );
  }
}
