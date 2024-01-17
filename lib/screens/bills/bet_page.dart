import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart'; 
import '../../../models/bills_model.dart';
import '../../components/get_products.dart';
import '../../constants.dart';
import '../../language.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import '../../widgets/image.dart';
import '../../widgets/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'dart:convert';

import 'continue/continue_page.dart';

class Bet extends StatefulWidget {
  Bet({Key? key}) : super(key: key);

  @override
  _Bet createState() => _Bet();
}


class Item{
  Item(this.name);
  final String name;
}
class _Bet extends State<Bet> {
  String errormsg="";
  bool error=false, showprogress=false, success=false, validated=false, process=false;
  String username="", customerid="", name="", mobile="", pin="", number="", amount="", token="";

  Bills? betplan;

  List<Bills> betplans = Products().getProduct("betting");

  betpay() async {
    if(customerid.isEmpty){
      setState(() {
        showprogress = false;
        error = true;
        errormsg = Language.customer_id;
      });
    }else if(amount.isEmpty){
      setState(() {
        showprogress = false;
        error = true;
        errormsg = Language.enter_amount;
      });
    }else if(int.tryParse(amount)!<100){
      setState(() {
        showprogress = false;
        error = true;
        errormsg = "Minimum Amount is ${Strings.default_fiat_symbol}100";
      });
    }else if(betplan==null){
      setState(() {
        showprogress = false;
        error = true;
        errormsg = Language.select_service;
      });
    }else if(mobile.isEmpty){
      setState(() {
        showprogress = false;
        error = true;
        errormsg = Language.enter_phone_number;
      });
    }else {
      setState(() {
        showprogress = false;
        error = false;
      });
      process = false;
      String apiurl = "/pay-bet";
      Map data = {
        'username': username,
        'customer_id': customerid,
        'product_id': betplan!.plan,
        'customer_name': name,
        'mobile': mobile,
        'amount': amount,
        'reference': username+'_'+Uuid().v4()+'_${DateTime.now().millisecondsSinceEpoch/1000}',
        'pin': pin
      };

      var body = json.encode(data);

      Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => ConfirmTransaction(
        url: apiurl,
        body: body,
        product: betplan!.name,
        amount: amount,
        charge: '',
        beneficiary: name,
        quantity: '',
        fee: '50',
      )));
    }
  }

  validatebet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    pin = prefs.getString("pin")!;
    token = prefs.getString("token")!;
    if(customerid.isEmpty){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.customer_id;
      });
    }else if(betplan==null){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.select_service;
      });
    }else{
      setState(() {
        showprogress = true;
        error=false;
      });
      String apiurl = Strings.url+"/validate-bet";
      Map data = {
        'username': username,
        'customer_id': customerid,
        'product_id': betplan!.plan,
      };
      var response = null;
      var body = json.encode(data);
      try {
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
          errormsg = "! $e";
        });
      }
      if (response != null && response.statusCode == 200) {
        try {
          var jsonb = json.decode(response.body);
          if (jsonb["status"] != null &&
              jsonb["status"].toString().contains("success")) {
            setState(() {
              error = true;
              success = true;
              showprogress = false;
              validated=true;
              errormsg = "Verified! "+jsonb["customer_name"].toString();
              name=jsonb["customer_name"].toString();
            });

          } else {
            setState(() {
              showprogress = false; //don't show progress indicator
              error = true;
              errormsg = jsonb["response_message"];
            });
          }
        } catch (e) {
          setState(() {
            showprogress = false; //don't show progress indicator
            error = true;
            errormsg = "$e";
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
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    ToastContext().init(context);
    return Scaffold(
        backgroundColor: Color(0xFFf2f2f2),
        body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              backAppbar(context, "Betting"),
              SizedBox(
                height: 20,
              ),
              SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          error? Container(
                            //show error message here
                            margin: EdgeInsets.only(bottom:10),
                            padding: EdgeInsets.all(10),
                            child: errmsg(errormsg, success, context),
                            //if error == true then show error message
                            //else set empty container as child
                          ) : Container(),
                          Container(
                            margin: EdgeInsets.only(top: 30, left: 30, right: 20),
                            alignment: Alignment.topLeft,
                            child: Text(Language.select_service,
                              style: TextStyle(color: Color.fromRGBO(111, 129, 132, 1), fontSize: 18, fontWeight: FontWeight.bold),
                            ),),
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            alignment: Alignment.center,
                            height: 60,
                            child: DropdownButtonFormField<Bills>(
                              isExpanded: true,
                              alignment: Alignment.centerLeft,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  filled: true,
                                  hintText: Language.select_service,
                                  hintStyle: TextStyle(color: Colors.grey[800], fontSize: 2),
                                  fillColor: kSecondary
                              ),
                              hint: Text(Language.select_service),
                              value: betplan,
                              onChanged: (Bills? value){
                                setState(() {
                                  betplan=value!;
                                });
                              },
                              items: betplans.map((Bills user){
                                return DropdownMenuItem<Bills>(value: user, child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  alignment: Alignment.topLeft,
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                      color: kSecondary,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [BoxShadow(color: kSecondary,
                                        blurRadius: 2,
                                        offset: Offset(4, 8),),]),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      cacheNetworkImage(
                                          fit: BoxFit.fill,
                                          imgUrl: Strings.imageUrl + user.name.split(" ")[0]
                                              .toLowerCase() +
                                              ".png",
                                          height: 36,
                                          width: 36),
                                      SizedBox(width: 10,),
                                      Text(user.name, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: Colors.black), textAlign: TextAlign.start),
                                    ],
                                  ),
                                ),);
                              }).toList(),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 30, left: 30, right: 20),
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Customer ID",
                              style: TextStyle(color: Color.fromRGBO(111, 129, 132, 1), fontSize: 18, fontWeight: FontWeight.bold),
                            ),),
                          Container(
                            margin:
                            EdgeInsets.only(right: 20, left: 20),
                            height: 60,
                            child: SizedBox(
                              height: 60,
                              child: TextField(
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: Language.customer_id,
                                  isDense: true,
                                  fillColor: kSecondary,
                                  filled: true,
                                  border: InputBorder.none,
                                ),
                                onChanged: (value){
                                  customerid=value;
                                  setState(() {
                                    validated=false;
                                  });
                                },
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 30, left: 30, right: 20),
                            alignment: Alignment.topLeft,
                            child: Text(
                              Language.amount,
                              style: TextStyle(color: Color.fromRGBO(111, 129, 132, 1), fontSize: 18, fontWeight: FontWeight.bold),
                            ),),
                          Container(
                            margin:
                            EdgeInsets.only(right: 20, left: 20),
                            height: 60,
                            child: SizedBox(
                              height: 60,
                              child: TextField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: Language.enter_amount,
                                isDense: true,
                                fillColor: kSecondary,
                                filled: true,
                                border: InputBorder.none,
                              ),
                              onChanged: (value){
                                amount=value;
                              },
                            ),
                          ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 30, left: 30, right: 20),
                            alignment: Alignment.topLeft,
                            child: Text(Language.enter_phone_number,
                              style: TextStyle(color: Color.fromRGBO(111, 129, 132, 1), fontSize: 18, fontWeight: FontWeight.bold),
                            ),),
                          Container(
                            margin: EdgeInsets.only(right: 20, left: 20),
                            height: 60,
                            child: SizedBox(
                              height: 60,
                              child: TextField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: Language.enter_phone_number,
                                isDense: true,
                                fillColor: kSecondary,
                                filled: true,
                                border: InputBorder.none,
                              ),
                              onChanged: (value){
                                mobile=value;
                              },
                            ),
                          ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          validated?
                          Padding(
                              padding: EdgeInsets.only(
                                  top: 20, right: 20, left: 20, bottom: 25),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  minimumSize: Size.fromHeight(
                                      50), // fromHeight use double.infinity as width and 40 is the height
                                ),
                                child: showprogress?
                                SizedBox(
                                  height:20, width:20,
                                  child: CircularProgressIndicator(
                                    backgroundColor: kSecondary,
                                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                                  ),
                                ) : Text(
                                  Language.proceed,
                                  style: TextStyle(
                                      color: kSecondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: (){
                                  if(!showprogress) {
                                    setState(() {
                                      success = false;
                                      showprogress = true;
                                      error = false;
                                    });
                                    betpay();
                                  }
                                },
                              ))
                              :
                          Padding(
                              padding: EdgeInsets.only(
                                  top: 20, right: 20, left: 20, bottom: 25),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  minimumSize: Size.fromHeight(
                                      50), // fromHeight use double.infinity as width and 40 is the height
                                ),
                                child: showprogress?
                                SizedBox(
                                  height:20, width:20,
                                  child: CircularProgressIndicator(
                                    backgroundColor: kSecondary,
                                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                                  ),
                                ) : Text(
                                  Language.proceed,
                                  style: TextStyle(
                                      color: kSecondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: (){
                                  if(!showprogress) {
                                    setState(() {
                                      success = false;
                                      showprogress = true;
                                      error = false;
                                    });
                                    validatebet();
                                  }
                                },
                              )),
                          SizedBox(
                            height: 10.h,
                          ),
                        ],
                      )))
            ],
          ),
        ));
  }

}