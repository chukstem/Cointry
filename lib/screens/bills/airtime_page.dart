import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../../../models/bills_model.dart';
import 'dart:convert';
import '../../components/get_products.dart';
import '../../constants.dart';
import '../../language.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import '../../widgets/material.dart';
import 'package:uuid/uuid.dart';

import 'continue/continue_page.dart';

class Airtime extends StatefulWidget {
  Airtime({Key? key}) : super(key: key);

  @override
  _Airtime createState() => _Airtime();
}




 
class _Airtime extends State<Airtime> with TickerProviderStateMixin {
  late TabController _providerTabController;
  String errormsg="";
  bool error=false, success=false, process=false;
  String username="", pin="", number="", amount="", token="";
  List<Bills> networks = Products().getProduct("vtu");
  Bills? network;

  String _getNetwork() {
    switch (_providerTabController.index) {
      case 0:
        return "MTN";
        break;
      case 1:
        return "Airtel";
        break;
      case 2:
        return "GLO";
        break;
      case 3:
        return "9mobile";
        break;
      default:
        return "AIRTEL";
    }
  }

  airtimepay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    pin = prefs.getString("pin")!;
    token = prefs.getString("token")!;
    if(number.isEmpty){
      setState(() {
        error = true;
        errormsg = Language.enter_phone_number;
      });
    }else if(amount.isEmpty){
      setState(() {
        error = true;
        errormsg = Language.enter_amount;
      });
    }else if(int.tryParse(amount)!<100){
      setState(() {
        error = true;
        errormsg = "Minimum Amount is ${Strings.default_fiat_symbol}100";
      });
    }else if(network==null||network!.name.isEmpty){
      setState(() {
        error = true;
        errormsg = Language.select_network;
      });
    }else{
      setState(() {
        error=false;
      });
      process=false;
      String apiurl = "/buy-vtu";
      Map data = {
        'customer_id': number,
        'username': username,
        'amount': amount,
        'product_id': network!.plan,
        'reference': username+'_'+Uuid().v4()+'_${DateTime.now().millisecondsSinceEpoch/1000}',
        'pin': pin
      };
      var body = json.encode(data);
      Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => ConfirmTransaction(
        url: apiurl,
        body: body,
        product: network!.name,
        amount: amount,
        charge: "",
        beneficiary: number,
        quantity: '',
        fee: '0',
        )));
    }
  }




  @override
  void initState() {
    super.initState();
    _providerTabController = TabController(length: 4, vsync: this);
    if(networks.isNotEmpty){
      network = networks.where((o) => o.name.toLowerCase().contains("mtn")).first;
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
            SizedBox(
              height: 20,
            ),
            backAppbar(context, "Buy Airtime"),
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
                                if(networks.isNotEmpty){
                                  network = networks.where((o) => o.name.toLowerCase().contains(_getNetwork().toLowerCase())).first;
                                }
                              });
                            },
                            labelColor: Colors.black,
                            labelPadding: EdgeInsets.only(top: 16.0),
                            indicatorPadding: EdgeInsets.only(left: 10, right: 10, top: 10),
                            controller: _providerTabController,
                            indicatorColor: kPrimaryDarkColor,
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
                          child: Text(Language.phone_number,
                            style: TextStyle(color: Color.fromRGBO(111, 129, 132, 1), fontSize: 18, fontWeight: FontWeight.bold),
                          ),),
                        Container(
                          margin: EdgeInsets.only(right: 20, left: 20),
                          height: 60,
                          child: SizedBox(
                            height: 60,
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                LengthLimitingTextInputFormatter(11)],
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
                              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                LengthLimitingTextInputFormatter(5)],
                            decoration: InputDecoration(
                              fillColor: kSecondary,
                              filled: true,
                              isDense: true,
                              hintText: Language.enter_amount,
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
                        Padding(
                            padding: EdgeInsets.only(
                                top: 20, right: 20, left: 20, bottom: 25),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                minimumSize: Size.fromHeight(
                                    50), // fromHeight use double.infinity as width and 40 is the height
                              ),
                              child: Text(
                                Language.proceed,
                                style: TextStyle(
                                    color: kSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: (){
                                  setState(() {
                                    success = false;
                                    error = false;
                                  });
                                  airtimepay();
                              },
                            )),
                        SizedBox(
                          height: 10.h,
                        ),
                      ],
                    )))
          ],
        ),
      ),
    );
  }

}