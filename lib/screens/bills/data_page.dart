import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import '../../components/get_products.dart';
import '../../constants.dart';
import '../../language.dart';
import '../../models/provider_model.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import '../../widgets/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'dart:async';
import '../../../models/bills_model.dart';
import 'dart:convert';

import 'continue/continue_page.dart';
class Data extends StatefulWidget {
  Data({Key? key}) : super(key: key);

  @override
  _Data createState() => _Data();
}


class _Data extends State<Data> with TickerProviderStateMixin {
  late TabController _providerTabController;
  String errormsg="";
  bool error=false, showprogress=false, success=false, validated=false, process=false;
  String username="", pin="", number="", token="";

  Bills? plan;
  List<Bills> plans = List.empty(growable: true);

  String _getNetwork() {
    switch (_providerTabController.index) {
      case 0:
        return "25,37";
        break;
      case 1:
        return "23,23";
        break;
      case 2:
        return "24,24";
        break;
      case 3:
        return "22,22";
        break;
      default:
        return "25,37";
    }
  }


  datapay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    pin = prefs.getString("pin")!;
    token = prefs.getString("token")!;
    if(number.isEmpty){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_phone_number;
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
      String apiurl = "/buy-data";
      Map data = {
        'customer_id': number,
        'username': username,
        'product_id': plan!.plan,
        'reference': username+'_'+Uuid().v4()+'_${DateTime.now().millisecondsSinceEpoch/1000}',
        'pin': pin
      };

      var body = json.encode(data);
      Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => ConfirmTransaction(
        url: apiurl,
        body: body,
        product: plan!.name,
        amount: plan!.amount,
        charge: '',
        beneficiary: number,
        quantity: '',
        fee: '0',
      )));
    }
  }

  getPlans() async {
    List<Bills> allplans = Products().getProduct("data");
    if(allplans.isNotEmpty){
      setState(() {
        plans = allplans.where((o) => o.size == _getNetwork().split(",")[0] || o.size == _getNetwork().split(",")[1]).toList();
        plan=plans[0];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _providerTabController = TabController(length: 4, vsync: this);
    getFirstPlan();
    plan = plans[0];
  }

  getFirstPlan(){
    try{
      plans = Products().getProduct("data").where((o) => o.size == "25").toList();
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
        backgroundColor: Color(0xFFf2f2f2),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              backAppbar(context, "Buy Data"),
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
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 30, right: 20),
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Select Network Provider",
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
                              indicatorPadding: EdgeInsets.only(left: 10, right: 10, top: 10),
                              indicatorSize: TabBarIndicatorSize.tab,
                              tabs: [
                                Container(
                                  width: 70,
                                  height: 60,
                                  child: Image.asset(
                                    "assets/images/mtn.png",
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
                                    "assets/images/airtel.png",
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
                                    "assets/images/glo.png",
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
                                    "assets/images/etisalat.png",
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
                                    width: MediaQuery.of(context).size.width,
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
                            child: Text(Language.phone_number,
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
                                number=value;
                              },
                            ),
                           ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: 10, right: 20, left: 20, bottom: 25),
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
                                    datapay();
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