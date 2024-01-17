import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../components/get_products.dart';
import '../../constants.dart';
import '../../language.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import '../../widgets/image.dart';
import '../../widgets/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'dart:async';
import '../../../models/bills_model.dart';
import 'package:uuid/uuid.dart';

import 'continue/continue_page.dart';

class Electricity extends StatefulWidget {
  Electricity({Key? key}) : super(key: key);

  @override
  _Electricity createState() => _Electricity();
}


class Item{
  Item(this.name);
  final String name;
}

class _Electricity extends State<Electricity> {
  String errormsg="";
  bool error=false, showprogress=false, success=false, validated=false, process=false;
  String username="", name="", customerid="", mobile="", pin="", number="", meter="", amount="", token="";

  Bills? electricityplan;
  List<Bills> electricityplans=Products().getProduct("electricity");


  electricitypay() async {
    if(meter.isEmpty){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Please Enter Meter Number";
      });
    }else if(amount.isEmpty){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_amount;
      });
    }else if(int.tryParse(amount)!<100){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Minimum Amount is ${Strings.default_fiat_symbol}100";
      });
    }else{
      setState(() {
        showprogress = false;
        error=false;
      });
      process=false;

      String apiurl = "/pay-electricity";
      Map data = {
      'customer_id': meter,
      'username': username,
      'amount': amount,
      'mobile': mobile,
      'customer_name': name,
      'product_id': electricityplan!.plan,
      'reference': username+'_'+Uuid().v4()+'_${DateTime.now().millisecondsSinceEpoch/1000}',
      'pin': pin
      };


    var body = json.encode(data);
      Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => ConfirmTransaction(
        url: apiurl,
        body: body,
        product: electricityplan!.name,
        amount: amount,
        charge: '',
        beneficiary: name,
        quantity: '',
        fee: '50',
      )));
    }
  }


  validateelectricity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    pin = prefs.getString("pin")!;
    token = prefs.getString("token")!;
    if(meter.isEmpty){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Please Enter Meter Number";
      });
    }else if(electricityplan==null){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.select_service;
      });
    }else{
      setState(() {
        //show progress indicator on click
        showprogress = true;
        error=false;
      });
      String apiurl = Strings.url+"/validate-electricity";
      var response;
      Map data = {
      'customer_id': meter,
      'username': username,
      'product_id': electricityplan!.plan,
      };

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
          errormsg = "Network connection error ";
        });
      }
      if (response != null && response.statusCode == 200) {
        try {
          var jsonElectricity = json.decode(response.body);
          if (jsonElectricity["status"] != null &&
              jsonElectricity["status"].toString().contains("success")) {
            setState(() {
              error = true;
              showprogress = false;
              validated=true;
              success = true;
              errormsg = jsonElectricity["customer_name"].toString();
              name=jsonElectricity["customer_name"].toString();
            });

          } else {
            setState(() {
              showprogress = false; //don't show progress indicator
              error = true;
              errormsg = jsonElectricity["response_message"];
            });
          }
        } catch (e) {
          setState(() {
            showprogress = false; //don't show progress indicator
            error = true;
            errormsg = Language.network_error;
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
            SizedBox(
              height: 20,
            ),
            backAppbar(context, "Electricity"),
            SizedBox(
              height: 20,
            ),
              Container(
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
                            child: Text(
                              "Select Provider",
                              style: TextStyle(color: Color.fromRGBO(111, 129, 132, 1), fontSize: 18, fontWeight: FontWeight.bold),
                            ),),
                          Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              alignment: Alignment.centerLeft,
                              height: 60,
                              child: DropdownButtonFormField<Bills>(
                                isExpanded: true,
                                alignment: Alignment.centerLeft,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                    ),
                                    filled: true,
                                    hintText: "Select Provider",
                                    hintStyle: TextStyle(color: Colors.grey[800], fontSize: 2),
                                    fillColor: kSecondary
                                ),
                                hint: Text('Select Provider'),
                                value: electricityplan,
                                onChanged: (Bills? value){
                                  electricityplan=value!;
                                  setState(() {
                                      validated=false;
                                  });
                                },
                                items: electricityplans.map((Bills user){
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
                                        Text(user.name, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
                                      ],
                                    ),
                                  ),);
                                }).toList(),
                              )
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
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: Language.customer_id,
                                isDense: true,
                                fillColor: kSecondary,
                                filled: true,
                              ),
                              onChanged: (value){
                                meter=value;
                                setState(() {
                                  validated=false;
                                });
                              },
                            ),
                          ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 30, right: 20),
                            alignment: Alignment.topLeft,
                            child: Text(Language.phone_number,
                              style: TextStyle(color: Color.fromRGBO(111, 129, 132, 1), fontSize: 18, fontWeight: FontWeight.bold),
                            ),),
                          Container(
                            margin:
                            EdgeInsets.only(top: 20, right: 20, left: 20),
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
                                    electricitypay();
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
                                      showprogress = true;
                                      error = false;
                                    });
                                    validateelectricity();
                                  }
                                },
                              )),
                          SizedBox(
                            height: 10.h,
                          ),
                        ],
                      ))
          ],
        ),
        ));
  }

}