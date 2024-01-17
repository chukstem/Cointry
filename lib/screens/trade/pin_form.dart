import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../../language.dart';
import '../../models/trading_model.dart';
import '../../models/user_model.dart';
import '../p2p/detail_mytrades_screen.dart';
import '../success/success_page.dart';
import '../wallets/success_page.dart';
import '../../../constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../strings.dart';
import '../../../widgets/material.dart';
import '../../../widgets/snackbar.dart';
import '../../models/crypto_transactions_model.dart';
import '../../models/fiat_transaction_model.dart';
import '../../size_config.dart';
import '../splash/welcome.dart';

class PinForm extends StatefulWidget {
  final String body;
  final String url;
  final setState;
  PinForm({required this.body, required this.url, required this.setState});

  @override
  _PinFormState createState() => _PinFormState();
}

class _PinFormState extends State<PinForm> {
  FocusNode? pin2FocusNode;
  FocusNode? pin3FocusNode;
  FocusNode? pin4FocusNode;
  String errormsg="";
  bool error=false, success=false, showprogress=false, showprogress2=false;
  String one="", two="", three="", four="";

  String Pin="", userpin="", msg="", newPin="", retypePin="";


  @override
  void initState() {
    super.initState();
    pin2FocusNode = FocusNode();
    pin3FocusNode = FocusNode();
    pin4FocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    pin2FocusNode!.dispose();
    pin3FocusNode!.dispose();
    pin4FocusNode!.dispose();
  }

  void nextField(String value, FocusNode? focusNode) {
    if (value.length == 1) {
      focusNode!.requestFocus();
    }
  }


  recoverPin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString("email");
    var token = prefs.getString("token");
    String apiurl = Strings.url+"/reset-pin"; //api url
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: Language.loading,
      text: Language.processing,
    );
    var response = null;
    Map data = {
      'email': email,
    };

    var body = json.encode(data);
    try {
      response = await http.post(Uri.parse(apiurl),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "Bearer $token"},
          body: body
      );
      if (response != null && response.statusCode == 200) {
        try {
          var jsondata = json.decode(response.body);
          if (jsondata["status"] != null &&
              jsondata["status"].toString().contains("success")) {
            error=false;
            msg=jsondata["response_message"];
            prefs.setString("pin", jsondata["pin"]);

            userpin=jsondata["pin"];
          }else if (jsondata["status"].toString().contains("error") &&
              jsondata["response_message"].toString().contains("Authentication")) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.clear();
            Toast.show(Language.session_expired, duration: Toast.lengthLong, gravity: Toast.bottom);
            Get.offAllNamed(WelcomeScreen.routeName);

          } else {
            error=true;
            msg=jsondata["response_message"];
          }
        } catch (e) {
          error=true;
          msg="Network connection error. $e";
        }
      } else {
        error=true;
        msg=Language.network_error;
      }
    } catch (e) {
      error=true;
      msg="Network connection error! $e";
    }

    if(error!) {
      Snackbar().show(context, ContentType.failure, Language.error, msg!);
    }else{
      Snackbar().show(context, ContentType.success, Language.success, msg!);
    }
    Navigator.pop(context);
  }

  resetPin(){
    QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'Seems you forgot your pin. Do you want to reset?',
        confirmBtnText: 'Yes',
        cancelBtnText: 'No',
        showCancelBtn: true,
        confirmBtnColor: kPrimaryColor,
        onConfirmBtnTap: (){
          Navigator.pop(context);
          recoverPin();
          return;
        },
        onCancelBtnTap: (){
          Navigator.pop(context);
          return;
        }
    );
  }

  process(BuildContext context, setState) async {
    var jsondata;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userpin = prefs.getString("pin")!;
    Pin="$one$two$three$four";
    if (Pin.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_pin;
      });
    } else if (Pin.length!=4) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.incorrect_pin;
      });
    } else if (Pin!=userpin) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.incorrect_pin;
      });
    } else {
      setState(() {
        showprogress = true;
      });
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

      SharedPreferences prefs = await SharedPreferences.getInstance();
        var token=prefs.getString("token");
      String apiurl = Strings.url + widget.url;
      var response = null;
      try {
        response = await http.post(Uri.parse(apiurl),
            headers: {
              "Content-Type": "application/json",
              "Authentication": "Bearer $token"},
            body: widget.body
        );

        if (response.statusCode == 200) {
          jsondata = json.decode(response.body);
          if (jsondata["status"].toString().contains("success")) {
            setState(() {
              error = false;
              showprogress = false;
              success = true;
            });
            errormsg = jsondata["response_message"];
          } else {
            setState(() {
              showprogress = false; //don't show progress indicator
              error = true;
              errormsg = jsondata["response_message"];
            });
          }
        }else if (response.statusCode == 429) {
          setState(() {
            showprogress = false; //don't show progress indicator
            error = true;
            errormsg = 'Please try again in 2mins time.';
          });
        } else {
          setState(() {
            showprogress = false; //don't show progress indicator
            error = true;
            errormsg = Language.error;
          });
        }

        if (error!) {
          Navigator.pop(context);
          Snackbar().show(context, ContentType.failure, Language.error, errormsg);
        }else {
          Navigator.pop(context);
          Navigator.pop(context);
          if (jsondata["type"] == "crypto") {
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) {
                  return SuccessScreenWallet(
                    message: jsondata["response_message"],
                    Transaction: new CryptoTransactionsModel(
                        hash: jsondata["reference"].toString(),
                        title: jsondata["title"],
                        time: jsondata["time"].toString(),
                        amount: jsondata["amount"].toString(),
                        final_amount: jsondata["final_amount"].toString(),
                        charge: jsondata["charge"].toString(),
                        status: jsondata["status"],
                        to: jsondata["to"],
                        total: "0",
                        img: jsondata["img"]),
                        symbol: jsondata["from"]);
                }));
          } else if (jsondata["type"] == "p2p") {
            var buyerlist=jsondata["buyer"] as List;
            List<UserModel> buyerdata=buyerlist.map((i) => UserModel.fromJson(i)).toList();

            var sellerlist=jsondata["seller"] as List;
            List<UserModel> sellerdata=sellerlist.map((i) => UserModel.fromJson(i)).toList();
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) {
              return P2PDetailScreen(obj: new TradingModel(
                  id: jsondata["id"] as String,
                  amountRate: jsondata["rate"] as String,
                  time: jsondata["time"] as String,
                  amountCrypto: jsondata["amountCrypto"] as String,
                  amount: jsondata["amount"] as String,
                  status: jsondata["status2"] as String,
                  window: jsondata["window"] as String,
                  endMin: jsondata["endMin"] as String,
                  terms: jsondata["terms"] as String,
                  details: jsondata["details"] as String,
                  currency_symbol: jsondata["currency_symbol"] as String,
                  fiat_symbol: jsondata["fiat_symbol"] as String,
                  currency_decimals: jsondata["currency_decimals"] as String,
                  type: jsondata["type2"] as String,
                  bankname: jsondata["bank_name"] as String,
                  accountname: jsondata["account_name"] as String,
                  accountnumber: jsondata["account_number"] as String,
                  buyer: buyerdata,
                  seller: sellerdata));
            }));
          } else if (jsondata["type"] == "p2p_detail") {
            Navigator.pop(context);
            Snackbar().show(context, ContentType.success, Language.success, errormsg);
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) {
                  return FiatSuccessScreenWallet(
                      message: jsondata["response_message"],
                      Transaction: new FiatTransactionModel(
                          services: jsondata["product"].toString(),
                          amount: jsondata["amount"].toString(),
                          status: jsondata["transaction_status"].toString(),
                          time: jsondata["time"].toString(),
                          reference: jsondata["reference"].toString(),
                          type: jsondata["type"].toString(),
                          token: "",
                          beneficiary: jsondata["beneficiary"].toString()));
                }));
          }
        }
      } catch (e) {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = Language.error;
        });
        Navigator.pop(context);
        Snackbar().show(context, ContentType.failure, Language.error, errormsg);
      }

    }

  }



  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            width: MediaQuery.of(context).size.width,
            height: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: getProportionateScreenWidth(50),
                  child: TextFormField(
                    autofocus: true,
                    obscureText: true,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      LengthLimitingTextInputFormatter(1)],
                    style: TextStyle(fontSize: 24),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: otpInputDecoration,
                    onChanged: (value) {
                      one=value;
                      nextField(value, pin2FocusNode);
                    },
                  ),
                ),
                SizedBox(
                  width: getProportionateScreenWidth(50),
                  child: TextFormField(
                      focusNode: pin2FocusNode,
                      obscureText: true,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        LengthLimitingTextInputFormatter(1)],
                      style: TextStyle(fontSize: 24),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: otpInputDecoration,
                      onChanged: (value){
                        two=value;
                        nextField(value, pin3FocusNode);
                      }
                  ),
                ),
                SizedBox(
                  width: getProportionateScreenWidth(50),
                  child: TextFormField(
                    focusNode: pin3FocusNode,
                    obscureText: true,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      LengthLimitingTextInputFormatter(1)],
                    style: TextStyle(fontSize: 24),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: otpInputDecoration,
                    onChanged: (value){
                      three=value;
                      nextField(value, pin4FocusNode);
                    },
                  ),
                ),
                SizedBox(
                  width: getProportionateScreenWidth(50),
                  child: TextFormField(
                    focusNode: pin4FocusNode,
                    obscureText: true,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      LengthLimitingTextInputFormatter(1)],
                    style: TextStyle(fontSize: 24),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: otpInputDecoration,
                    onChanged: (value) {
                      if (value.length == 1) {
                        four=value;
                        pin4FocusNode!.unfocus();
                        // Then you need to check is the code is correct or not
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          InkWell(
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: "Forgot Your Pin? ",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                        text: "Reset",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          color: yellow100,
                        )),
                  ],
                ),
              ),
            ),
            onTap: () {
              resetPin();
            },
          ),
          SizedBox(height: 40),
          showprogress? Center(child: SizedBox(
            height:40, width:40,
            child: CircularProgressIndicator(
              backgroundColor: kSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
            ),
          ),) :
          InkWell(
            child: Container(
              width: MediaQuery.of(context).size.width*0.90,
              alignment: Alignment.center,
              padding: EdgeInsets.only(
                  top: 20, right: 20, left: 20, bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: kPrimaryDarkColor,
              ),
              child: Center(
                child: Text(
                  'Confirm Details',
                  style: TextStyle(
                      color: kSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            onTap: () {
              process(context, widget.setState);
            },),
        ],
      ),
    );
  }
}
