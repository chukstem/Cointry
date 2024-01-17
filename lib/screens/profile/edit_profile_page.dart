import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
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


class _EditProfileState extends State<EditProfile> {
  String errormsg="";
  bool error=false, success=false, showprogress=false;

  String email="", firstname="", lastname="", number="", token="", about="";
  TextEditingController emailController=new TextEditingController();
  TextEditingController numberController=new TextEditingController();
  TextEditingController firstnameController=new TextEditingController();
  TextEditingController lastnameController=new TextEditingController();
  TextEditingController aboutController=new TextEditingController();

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString("email")!;
      number = prefs.getString("number")!;
      firstname = prefs.getString("firstname")!;
      lastname = prefs.getString("lastname")!;
      about = prefs.getString("about")!;
      firstnameController.text="$firstname";
      lastnameController.text="$lastname";
      emailController.text="$email";
      numberController.text="$number";
      aboutController.text="$about";
    });
  }


  saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString("email")!;
    token = prefs.getString("token")!;
    if (firstname.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter First Name";
      });
    } else if (lastname.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Last Name";
      });
    }else {
      setState(() {
        showprogress = true;
        error=false;
      });
      String apiurl = Strings.url+"/update-profile";
      var response = null;
      try {
         Map data = {
          'email': email,
          'first_name': firstname.trim(),
          'last_name': lastname.trim(),
          'about': about.trim()
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
          prefs.setString("firstname", firstname.trim());
          prefs.setString("lastname", lastname.trim());
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
    getUser();
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
        child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              backAppbar(context, Language.edit_profile),
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
                  obscureText: false,
                keyboardType: TextInputType.text,
                controller: firstnameController, 
                decoration: InputDecoration(
                  hintText: Language.first_name,
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
                    firstname = value;
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
                  obscureText: false,
                    keyboardType: TextInputType.text,
                    controller: lastnameController,
                    decoration: InputDecoration(
                      hintText: Language.last_name,
                      fillColor: kSecondary,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                    ),
                  onChanged: (value){
                    //set username  text on change
                    lastname = value;
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
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    controller: emailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText:Language.email,
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
                  },
                ),
              ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin:
                EdgeInsets.only(top: 20, right: 20, left: 20),
                height: 60,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                    obscureText: false,
                    controller: numberController,
                    keyboardType: TextInputType.text,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: Language.enter_phone_number,
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
                  },

                ),
              ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin:
                EdgeInsets.only(top: 20, right: 20, left: 20),
                height: 120,
                child: SizedBox(
                  height: 120,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                    obscureText: false,
                    maxLength: 200,
                    minLines: null,
                    maxLines: null,
                    expands: true,
                    controller: aboutController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: Language.about,
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
                    setState(() {
                      about=value;
                    });
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
                        saveProfile();
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
    );
  }
}


