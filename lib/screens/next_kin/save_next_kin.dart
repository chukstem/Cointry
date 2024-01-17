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

class SaveNextKin extends StatefulWidget {
  @override
  _SaveNextKinState createState() => _SaveNextKinState();
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

class Item{
  Item(this.name);
  final String name;
}


class _SaveNextKinState extends State<SaveNextKin> {
  String errormsg="";
  bool error=false, success=false, showprogress=false;

  String email="", firstname="", lastname="", number="", token="", username="", state="", address="";

  List<Item> items=<Item>[
    Item('Select Relationship'),
    Item('Father'),
    Item('Mother'),
    Item('Brother'),
    Item('Sister'),
    Item('Spouse'),
    Item('Uncle'),
    Item('Aunty'),
    Item('Nephew'),
    Item('Niece'),
    Item('Cousin'),
  ];

  Item? item;

  Save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    token = prefs.getString("token")!;
    if (firstname.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_kin_first_name;
      });
    } else if (lastname.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_kin_last_name;
      });
    } else if (number.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_kin_phone_number;
      });
    }  else if (email.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_kin_email;
      });
    } else if (address.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_kin_email;
      });
    } else if (state.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_kin_state;
      });
    } else if (item==null || item!.name==Language.select_relationship) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.select_relationship;
      });
    }else {
      setState(() {
        showprogress = true;
        error=false;
      });
      String apiurl = Strings.url+"/add-next-kin";
      var response = null;
      try {
         Map data = {
          'username': username,
          'email': email,
          'first_name': firstname.trim(),
          'last_name': lastname.trim(),
          'address': address.trim(),
          'state': state.trim(),
          'number': number.trim(),
          'relationship': item!.name
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
          errormsg = Language.network_error;
        });
      }
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["status"] != null &&
            jsondata["status"].toString().contains("success")) {
          setState(() {
            success = true;
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
        child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              backAppbar(context, Language.add_next_kin),
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
                decoration: InputDecoration(
                  hintText: Language.kin_first_name,
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
                EdgeInsets.only(right: 20, left: 20),
                height: 60,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                  obscureText: false,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: Language.kin_last_name,
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
                EdgeInsets.only(right: 20, left: 20),
                height: 60,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: Language.kin_email,
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
                    email=value;
                  },

                ),
              ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin:
                EdgeInsets.only(right: 20, left: 20),
                height: 60,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                    obscureText: false,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: Language.kin_phone_number,
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
                    number=value;
                  },

                ),
              ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin:
                EdgeInsets.only(right: 20, left: 20),
                height: 60,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: Language.kin_address,
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
                    address=value;
                  },
                 ),
               ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                alignment: Alignment.center,
                height: 60,
                child: DropdownButtonFormField<Item>(
                  isExpanded: true,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      hintText: Language.select_relationship,
                      hintStyle: TextStyle(color: Colors.grey[800], fontSize: 2),
                      fillColor: kSecondary
                  ),
                  hint: Text(Language.select_relationship),
                  value: item,
                  onChanged: (Item? value){
                    setState(() {
                      item=value!;
                    });
                  },
                  items: items.map((Item user){
                    return DropdownMenuItem<Item>(value: user, child: Text(user.name, style: TextStyle(color: Colors.black),),);
                  }).toList(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin:
                EdgeInsets.only(right: 20, left: 20),
                height: 60,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: Language.kin_state,
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
                    state=value;
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
                        Save();
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
                      ),
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


