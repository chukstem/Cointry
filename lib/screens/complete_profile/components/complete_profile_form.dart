import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_app/components/custom_surfix_icon.dart';
import 'package:crypto_app/components/default_button.dart';
import 'package:crypto_app/components/form_error.dart';
import 'package:crypto_app/screens/otp/otp_screen.dart';
import '../../../constants.dart';
import '../../../language.dart';
import '../../../size_config.dart';
import '../../../strings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../widgets/material.dart';
import '../../../widgets/snackbar.dart';

class CompleteProfileForm extends StatefulWidget {
  @override
  _CompleteProfileFormState createState() => _CompleteProfileFormState();
}

class Item{
  Item(this.name);
  final String name;
}

class _CompleteProfileFormState extends State<CompleteProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String?> errors = [];
  String? firstName="";
  String? lastName="";
  String? password="";
  String? confirm_password="";
  String referral="";
  String errormsg="Login to continue";
  bool error=false, success=false, showprogress=false;

  List<Item> countries=<Item>[
    Item('Select Country'),
    Item('Algeria'),
    Item('Angola'),
    Item('Benin'),
    Item('Botswana'),
    Item('Burkina Faso'),
    Item('Burundi'),
    Item('Cabo Verde'),
    Item('Cameroon'),
    Item('Central African Republic'),
    Item('Chad'),
    Item('Comoros'),
    Item('Congo, Democratic Republic of the Congo'),
    Item("Republic of the Cote d'Ivoire"),
    Item('Djibouti'),
    Item('Egypt'),
    Item('Equatorial Guinea'),
    Item('Eritrea'),
    Item('Eswatini'),
    Item('Ethiopia'),
    Item('Gabon'),
    Item('Gambia'),
    Item('Ghana'),
    Item('Guinea'),
    Item('Guinea-Bissau'),
    Item('Kenya'),
    Item('Lesotho'),
    Item('Liberia'),
    Item('Libya'),
    Item('Madagascar'),
    Item('Malawi'),
    Item('Mali'),
    Item('Mauritania'),
    Item('Mauritius'),
    Item('Morocco'),
    Item('Mozambique'),
    Item('Namibia'),
    Item('Niger'),
    Item('Nigeria'),
    Item('Rwanda'),
    Item('Sao Tome and Principe'),
    Item('Senegal'),
    Item('Seychelles'),
    Item('Sierra Leone'),
    Item('Somalia'),
    Item('South Africa'),
    Item('Somalia'),
    Item('South Sudan'),
    Item('Sudan'),
    Item('Tanzania'),
    Item('Togo'),
    Item('Tunisia'),
    Item('Uganda'),
    Item('Zambia'),
    Item('Zimbabwe'),
  ];
  List<Item> genders=<Item>[
    Item('Select Gender'),
    Item('Male'),
    Item('Female'),
  ];

  Item? country, gender;



  startReg() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("temp_username")!;
    String email = prefs.getString("temp_email")!;
    String number = prefs.getString("temp_number")!;
    if (username.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_username;
      });
    } else if (email.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_email;
      });
    } else if (number.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_phone_number;
      });
    } else if (firstName!.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_firstname;
      });
    } else if (lastName!.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_lastname;
      });
    } else if (password!.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_password;
      });
    } else if (confirm_password!.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_confirm_password;
      });
    } else if (gender==null || gender!.name.contains("Select")) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.select_gender;
      });
    } else if (country==null || country!.name.contains("Select")) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.select_country;
      });
    } else if (password != confirm_password!) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.password_mismatch;
      });
    } else {
      setState(() {
        showprogress=true;
      });
      String apiurl = Strings.url + "/complete-register";
      var response;

      try {
        Map data = {
          'username': username.trim(),
          'first_name': firstName!.trim(),
          'last_name': lastName!.trim(),
          'email': email.trim(),
          'referral': referral.trim(),
          'mobile': number.trim(),
          'password': password!.trim(),
          'gender': gender!.name,
          'country': country!.name,
          'password_confirmation': confirm_password!.trim()
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
            errormsg = jsondata["response_message"];
          });
          prefs.setString("firstname", firstName!);
          prefs.setString("lastname", lastName!);
          prefs.setString("number", number);
          prefs.setString("email", email);
          prefs.setString("username", username);
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
      }

    if (error!) {
      Snackbar().show(context, ContentType.failure, Language.error, errormsg);
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context, OtpScreen.routeName, (route) => false,);
      Snackbar().show(context, ContentType.success, Language.success, errormsg);
    }

  }


  @override
  void initState() {
    super.initState();
    country=countries[38];
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
          buildFirstNameFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildLastNameFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildConfirmPassFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildGenderFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildCountryFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildReferralFormField(),
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
            text: Language.proceed,
            press: () {
                if(!showprogress) {
                  startReg();
              }
            },
          ),
        ],
      ),
    );
  }


  TextFormField buildConfirmPassFormField() {
    return TextFormField(
      obscureText: true,
      onChanged: (value) {
        confirm_password = value;
      },
      decoration: InputDecoration(
        labelText: Language.confirm_password,
        hintText: Language.confirm_password,
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }


  Container buildGenderFormField() {
    return Container(
        alignment: Alignment.center,
        height: 60,
        child: DropdownButtonFormField<Item>(
          isExpanded: true,
          decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
              hintText: Language.select_gender,
              labelText: Language.select_gender,
              hintStyle: TextStyle(color: Colors.grey[800], fontSize: 2),
              fillColor: kSecondary
          ),
          hint: Text(Language.select_gender),
          value: gender,
          onChanged: (Item? value){
            gender = value;
          },
          items: genders.map((Item item){
            return DropdownMenuItem<Item>(value: item, child: Container(
              width: MediaQuery.of(context).size.width-20,
              height: 40,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: kSecondary,
                borderRadius: BorderRadius.circular(10),),
              child: Text(item.name, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
            ),);
          }).toList(),
        )
    );
  }

  Container buildCountryFormField() {
    return Container(
        alignment: Alignment.center,
        height: 60,
        child: DropdownButtonFormField<Item>(
          isExpanded: true,
          decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
              hintText: Language.select_country,
              labelText: Language.select_country,
              hintStyle: TextStyle(color: Colors.grey[800], fontSize: 2),
              fillColor: kSecondary
          ),
          hint: Text(Language.select_country),
          value: country,
          onChanged: (Item? value){
            country = value;
          },
          items: countries.map((Item item){
            return DropdownMenuItem<Item>(value: item, child: Container(
              width: MediaQuery.of(context).size.width-20,
              height: 40,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: kSecondary,
                borderRadius: BorderRadius.circular(10),),
              child: Text(item.name, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
            ),);
          }).toList(),
        )
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onChanged: (value) {
        password = value;
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


  TextFormField buildLastNameFormField() {
    return TextFormField(
      onChanged: (value) {
        if (value.isNotEmpty) {
          lastName = value;
        }
      },
      decoration: InputDecoration(
        labelText: Language.last_name,
        hintText: Language.enter_lastname,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  TextFormField buildReferralFormField() {
    return TextFormField(
      onChanged: (value){
        referral=value;
      },
      decoration: InputDecoration(
        labelText: "Referral (optional)",
        hintText: "Referral (optional)",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  TextFormField buildFirstNameFormField() {
    return TextFormField(
      onSaved: (newValue) => firstName = newValue,
      onChanged: (newValue) {
        firstName = newValue;
      },
      decoration: InputDecoration(
        labelText: Language.first_name,
        hintText: Language.first_name,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }
}
