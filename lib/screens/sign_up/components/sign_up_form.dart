import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_app/components/custom_surfix_icon.dart';
import 'package:crypto_app/components/default_button.dart';
import 'package:crypto_app/components/form_error.dart';
import 'package:crypto_app/screens/complete_profile/complete_profile_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants.dart';
import '../../../helper/keyboard.dart';
import '../../../language.dart';
import '../../../size_config.dart';
import '../../../strings.dart';
import '../../../widgets/material.dart';
import '../../../widgets/snackbar.dart';


class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? phoneNumber;
  String? username;
  bool remember = false;
  final List<String?> errors = [];
  String errormsg="";
  bool error=false, success=false, showprogress=false;

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

  startReg(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (username!.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_username;
      });
    } else if (email!.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_email;
      });
    } else if (phoneNumber!.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_phone_number;
      });
    } else {
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
      String apiurl = Strings.url + "/confirm_register";
      var response = null;
      try {
        Map data = {
          'username': username!.trim(),
          'email': email!.trim(),
          'mobile': phoneNumber!.trim(),
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
              error = false;
              showprogress = false;
              success = true;
              errormsg = Language.complete_signup;
            });
            prefs.setString("temp_username", username!.trim());
            prefs.setString("temp_email", email!.trim());
            prefs.setString("temp_number", phoneNumber!.trim());
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
      } catch (e) {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = Language.network_error;
        });
      }
      Navigator.pop(context);
      if (error!) {
        Snackbar().show(context, ContentType.failure, Language.error, errormsg);
      } else {
        Snackbar().show(context, ContentType.success, Language.success, errormsg);
        Navigator.pushNamed(context, CompleteProfileScreen.routeName);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
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
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildUsernameFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPhoneNumberFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(40)),
          showprogress? Center(child: SizedBox(
            height:40, width:40,
            child: CircularProgressIndicator(
              backgroundColor: kSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
            ),
          ),) :
          DefaultButton(
            text: Language.submit,
            press: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                KeyboardUtil.hideKeyboard(context);
                if(!showprogress) {
                  startReg(context);
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

  TextFormField buildPhoneNumberFormField() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      onSaved: (newValue) => phoneNumber = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPhoneNumberNullError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPhoneNumberNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: Language.phone_number,
        hintText: Language.enter_phone_number,
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
      ),
    );
  }


  TextFormField buildUsernameFormField() {
    return TextFormField(
      onSaved: (newValue) => username = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kUsernameNullError);
        }
        username = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kUsernameNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText:Language.username,
        hintText: Language.enter_username,
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
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
