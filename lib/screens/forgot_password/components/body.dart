import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:crypto_app/components/custom_surfix_icon.dart';
import 'package:crypto_app/components/default_button.dart';
import 'package:crypto_app/components/form_error.dart';
import 'package:crypto_app/components/no_account_text.dart';
import 'package:crypto_app/size_config.dart';

import '../../../constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../helper/keyboard.dart';
import '../../../language.dart';
import '../../../strings.dart';
import '../../../widgets/material.dart';
import '../../../widgets/snackbar.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: Column(
            children: [
              SizedBox(height: SizeConfig.screenHeight * 0.04),
              SizedBox(height: 60,),
              Text(
                "Forgot Password",
                style: TextStyle(
                  fontSize: getProportionateScreenWidth(28),
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Please enter your email and we will send \nyou a link to return to your account",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.1),
              ForgotPassForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPassForm extends StatefulWidget {
  @override
  _ForgotPassFormState createState() => _ForgotPassFormState();
}

class _ForgotPassFormState extends State<ForgotPassForm> {
  final _formKey = GlobalKey<FormState>();
  List<String> errors = [];
  String? email;
  String errormsg='';
  bool error=false, success=false, showprogress=false;

  startRecover(BuildContext context) async {
    if (email!.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_email;
      });
    } else {
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
      String apiurl = Strings.url+"/reset-password";
      var response = null;
      try {
        Map data = {
          'email': email!.trim()
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

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["status"] != null &&
            jsondata["status"].toString().contains("success")) {
          setState(() {
            success=true;
            showprogress = false; //don't show progress indicator
            error = false;
            errormsg = jsondata["response_message"];
          });
        }else {
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
    }
    if(error!) {
      Snackbar().show(context, ContentType.failure, Language.error, errormsg);
    }else{
      Snackbar().show(context, ContentType.success, Language.success, errormsg);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            onSaved: (newValue) => email = newValue,
            onChanged: (value) {
              if (value.isNotEmpty && errors.contains(kEmailNullError)) {
                setState(() {
                  errors.remove(kEmailNullError);
                });
              } else if (emailValidatorRegExp.hasMatch(value) &&
                  errors.contains(kInvalidEmailError)) {
                setState(() {
                  errors.remove(kInvalidEmailError);
                });
              }
              return null;
            },
            validator: (value) {
              if (value!.isEmpty && !errors.contains(kEmailNullError)) {
                setState(() {
                  errors.add(kEmailNullError);
                });
              } else if (!emailValidatorRegExp.hasMatch(value) &&
                  !errors.contains(kInvalidEmailError)) {
                setState(() {
                  errors.add(kInvalidEmailError);
                });
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
          ),
          SizedBox(height: getProportionateScreenHeight(30)),
          FormError(errors: errors),
          SizedBox(height: SizeConfig.screenHeight * 0.1),
          DefaultButton(
            text: "Reset",
            press: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                KeyboardUtil.hideKeyboard(context);
                if(!showprogress) {
                  startRecover(context);
                  setState(() {
                    success=false;
                    showprogress = true;
                    error=false;
                  });
                }
              }
            },
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.1),
          NoAccountText(),
        ],
      ),
    );
  }
}
