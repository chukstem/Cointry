import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';  
import 'package:uuid/uuid.dart'; 
import '../../components/get_products.dart';
import '../../constants.dart'; 
import '../../language.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import '../../widgets/material.dart'; 
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart'; 
import '../../../models/bills_model.dart';
import 'dart:convert';

import 'continue/continue_page.dart';

class Cable extends StatefulWidget {
  Cable({Key? key}) : super(key: key);

  @override
  _Cable createState() => _Cable();
}

 
class _Cable extends State<Cable> with TickerProviderStateMixin {
  late TabController _providerTabController;
  String errormsg="";
  bool error=false, showprogress=false, success=false, validated=false, process=false;
  String username="", name="", mobile="", pin="", iuc="", number="", meter="", token="";

  Bills? plan;
  List<Bills> plans = List.empty(growable: true);

  String _getCables() {
    switch (_providerTabController.index) {
      case 0:
        return "8";
        break;
      case 1:
        return "13";
        break;
      case 2:
        return "12";
        break;
      default:
        return "8";
    }
  }


  getPlans() async {
    List<Bills> allplans = Products().getProduct("cable");
    if(allplans.isNotEmpty){
      setState(() {
        plans = allplans.where((o) => o.size == _getCables()).toList();
        plan=plans[0];
      });
    }
  }

  cablepay() async {
    if(iuc.isEmpty){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Please Enter IUC Number";
      });
    }else if(plan==null||plan!.name.isEmpty){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.select_subscription;
      });
    }else{
      setState(() {
        showprogress = false;
        error=false;
      });
      process=false;
      String apiurl = "/pay-cable";
      Map data = {
        'customer_id': iuc,
        'username': username,
        'mobile': mobile,
        'product_id': plan!.plan,
        'customer_name': name,
        'reference': username+'_'+Uuid().v4()+'_${DateTime.now().millisecondsSinceEpoch/1000}',
        'pin': pin
      };
      var body = json.encode(data);
      Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => ConfirmTransaction(
        url: apiurl,
        body: body,
        product: plan!.size,
        amount: plan!.amount,
        charge: '',
        beneficiary: name,
        quantity: '',
        fee: '50',
      )));
    }
  }

  validatecable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    pin = prefs.getString("pin")!;
    token = prefs.getString("token")!;
    if(iuc.isEmpty){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Please Enter IUC Number";
      });
    }else{
      setState(() {
        //show progress indicator on click
        showprogress = true;
        error=false;
      });
      String apiurl = Strings.url+"/validate-cable";
      var response = null;
      Map data = {
        'customer_id': iuc,
        'username': username,
        'product_id': plan!.plan
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
          var jsonBills = json.decode(response.body);
          if (jsonBills["status"] != null &&
              jsonBills["status"].toString().contains("success")) {
            setState(() {
              error = true;
              showprogress = false;
              success = true;
              validated=true;
              errormsg = jsonBills["customer_name"].toString();
              name=jsonBills["customer_name"].toString();
            });

          } else {
            setState(() {
              showprogress = false; //don't show progress indicator
              error = true;
              errormsg = jsonBills["response_message"];
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
    _providerTabController = TabController(length: 4, vsync: this);
    getFirstPlan();
    super.initState();
  }

  getFirstPlan(){
    try{
      plans = Products().getProduct("cable").where((o) => o.size == "8").toList();
      if(plans.isNotEmpty) plan = plans[0];
    }catch(e){}
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
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xFFf2f2f2),
        body: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              ListView(
                shrinkWrap: true,
                children: <Widget>[
                  backAppbar(context, "Pay Tv"),
                ],
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
                            margin: EdgeInsets.only(left: 30, right: 20),
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Select Provider",
                              style: TextStyle(color: Color.fromRGBO(111, 129, 132, 1), fontSize: 18, fontWeight: FontWeight.bold),
                            ),),
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            alignment: Alignment.center,
                            child: TabBar(
                              labelStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              onTap: (value) {
                                setState(() {
                                  getPlans();
                                });
                              },
                              labelColor: Colors.black,
                              labelPadding: EdgeInsets.only(top: 16.0),
                              controller: _providerTabController,
                              indicatorColor: kPrimaryDarkColor,
                              indicatorPadding: EdgeInsets.only(left: 20, right: 20, top: 10),
                              indicatorSize: TabBarIndicatorSize.tab,
                              tabs: [
                                Container(
                                  width: 70,
                                  height: 60,
                                  child: Image.asset(
                                    "assets/images/dstv.png",
                                    width: 50,
                                    height: 50,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kSecondary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.all(5),
                                ),
                                Container(
                                  width: 70,
                                  height: 60,
                                  child: Image.asset(
                                    "assets/images/gotv.png",
                                    width: 50,
                                    height: 50,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kSecondary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.all(5),
                                ),
                                Container(
                                  width: 70,
                                  height: 60,
                                  child: Image.asset(
                                    "assets/images/startimes.png",
                                    width: 50,
                                    height: 50,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kSecondary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.all(5),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 30, left: 30, right: 20),
                            alignment: Alignment.topLeft,
                            child: Text(Language.select_subscription,
                              style: TextStyle(color: Color.fromRGBO(111, 129, 132, 1), fontSize: 18, fontWeight: FontWeight.bold),
                            ),),
                          Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              alignment: Alignment.center,
                              height: 60,
                              child: DropdownButtonFormField<Bills>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    filled: true,
                                    hintText: Language.select_subscription,
                                    hintStyle: TextStyle(color: Colors.grey[800], fontSize: 2),
                                    fillColor: kSecondary
                                ),
                                hint: Text(Language.select_subscription),
                                value: plan,
                                onChanged: (Bills? value){
                                  setState(() {
                                    plan=value!;
                                  });
                                },
                                items: plans.map((Bills user){
                                  return DropdownMenuItem<Bills>(value: user, child: Container(
                                    width: MediaQuery.of(context).size.width-20,
                                    height: 40,
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(left: 10, right: 10),
                                    decoration: BoxDecoration(
                                        color: kSecondary,
                                        borderRadius: BorderRadius.circular(10),),
                                    child: Text(user.name+' = N'+user.amount, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
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
                                border: InputBorder.none,
                                ),
                                onChanged: (value){
                                iuc=value;
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
                            child: Text(Language.phone_number,
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
                                    cablepay();
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
                                    validatecable();
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