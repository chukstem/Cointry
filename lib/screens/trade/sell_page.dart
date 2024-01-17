import 'dart:async';
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../../constants.dart';
import '../../helper/formatter.dart';
import '../../language.dart';
import '../../models/crypto_model.dart';

import '../../widgets/pin.dart';
import '../../widgets/snackbar.dart';

class SellScreen extends StatefulWidget {
  CryptoModel obj;
  CryptoModel fiat;
  SellScreen({required this.obj, required this.fiat});

  @override
  _SellScreen createState() => _SellScreen();
}

class _SellScreen extends State<SellScreen> {
  bool isFiat=true, loading=true;
  String username="", token="", amount="", amount2="", pin="";
  double rate=0;
  CryptoModel? wallet;
  CryptoModel? wallet2;

  TextEditingController CryptoAmountController=new TextEditingController();
  TextEditingController CryptoAmountController2=new TextEditingController();

  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username")!;
      token = prefs.getString("token")!;
      pin = prefs.getString("pin")!;
    });
  }
 

  cachedList() async {
    setState(() {
        if(widget.obj.type.toLowerCase()=="fiat"){
          rate=double.parse(widget.fiat.networkModel.first.sell_price.replaceAll(",", ""))/double.parse(widget.obj.networkModel.first.sell_price.replaceAll(",", ""));
        } else {
          rate = double.parse(widget.obj.networkModel.first.sell_price.replaceAll(",", "")) * double.parse(widget.fiat.networkModel.first.sell_price.replaceAll(",", ""));
        }
    });
  }
   
  @override
  void initState() {
    super.initState();
    getuser();
    cachedList();
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
        backgroundColor: kPrimaryDarkColor,
        body: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 15),
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            color: kSecondary,
                            size: 22,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Text(widget.obj.networkModel[0].currency_symbol+" to ${widget.fiat.networkModel.first.currency_symbol}", maxLines: 2, style: TextStyle(color: kSecondary, fontSize: 25, fontWeight: FontWeight.bold),),
                      Container(
                        padding: EdgeInsets.only(right: 15),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: indicators[1]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width*0.99,
                          margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: (){
                                  setState(() {
                                    var text = widget.obj.balance;
                                    CryptoAmountController.text = "$text";
                                    isFiat=false;
                                  });
                                },
                                child: Container(
                                    height: 40,
                                    width: 40,
                                    padding: EdgeInsets.all(1.0),
                                    decoration: new BoxDecoration(
                                      color: kPrimaryDarkColor,
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(color: kSecondary, width: 2.0, style: BorderStyle.solid),
                                    ),
                                    child: Center(child: Text("Max", style: TextStyle(color: kSecondary),),)
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 10),
                                height: 60,
                                alignment: Alignment.centerLeft,
                                width: MediaQuery.of(context).size.width*0.50,
                                child: Center(
                                  child: new Theme(
                                    data: Theme.of(context).copyWith(
                                      inputDecorationTheme: InputDecorationTheme(border: InputBorder.none, floatingLabelBehavior: FloatingLabelBehavior.always,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),),
                                    ),
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      autofocus: false,
                                      controller: CryptoAmountController,
                                      style: TextStyle(fontSize: 22, color: kPrimaryDarkColor, fontWeight: FontWeight.bold),
                                      decoration: new InputDecoration(
                                        border: InputBorder.none,
                                        suffixIcon: Container(padding: EdgeInsets.all(10), child: Text(isFiat? widget.fiat.networkModel.first.currency_symbol : "${widget.obj.networkModel.first.currency_symbol}", style: TextStyle(fontSize: 22, color: kPrimaryDarkColor, fontWeight: FontWeight.bold),),),
                                        hintText: Language.default_amount,
                                        hintStyle: TextStyle(fontSize: 22, color: kPrimaryDarkColor, fontWeight: FontWeight.bold),
                                      ),
                                      keyboardType: TextInputType.none,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: (){
                                  setState(() {
                                    if(isFiat){
                                      isFiat=false;
                                    }else{
                                      isFiat=true;
                                    }
                                  });
                                },
                                child: Container(
                                    height: 40,
                                    width: 40,
                                    padding: EdgeInsets.all(1.0),
                                    decoration: new BoxDecoration(
                                      color: kPrimaryDarkColor,
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(color: kSecondary, width: 2.0, style: BorderStyle.solid),
                                    ),
                                    child: Center(child: Icon(Icons.swap_vert, size: 20, color: kSecondary,),)
                                ),
                              ),
                            ],
                          )
                      ),
                      Center(
                        child: Container(
                            width: 250,
                            margin: EdgeInsets.only(top: 20, bottom: 10),
                            padding: EdgeInsets.all(10.0),
                            decoration: new BoxDecoration(
                                color: kPrimaryDarkColor, //
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                border: Border.all(color: kSecondary, width: 2.0, style: BorderStyle.solid),
                            ),
                            child: Center(child: Text("Available ${widget.obj.networkModel.first.currency_symbol}: \$"+widget.obj.usdBalance, style: TextStyle(color: kSecondary),),)
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 25,
                      width: 25,
                      decoration: new BoxDecoration(
                        color: Colors.transparent, //
                        shape: BoxShape.circle,
                      ),
                      child: new CircleAvatar(
                        maxRadius: 23,
                        minRadius: 23,
                        child: CachedNetworkImage(
                          imageUrl: widget.obj.networkModel[0].img,
                          height: 25,
                          width: 25,
                        ),),),
                    SizedBox(width: 4,),
                    Text("1 ${widget.obj.networkModel.first.currency_symbol} = ${format("$rate", "4")} ${widget.fiat.networkModel.first.currency_symbol}", style: TextStyle(color: kSecondary),),
                  ],
                ),
                SizedBox(height: 40,),
                Container(
                  height: 500,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    color: kSecondary,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 20,),
                          InkWell(
                            onTap: (){
                              setState(() {
                                  var text = double.parse(widget.obj.balance.replaceAll(",", ""))*25/100;
                                  CryptoAmountController.text = format(text.toString().replaceAll(",", ""), widget.obj.networkModel.first.decimals);
                                  isFiat=false;
                              });
                            },
                            child: Container(
                                height: 40,
                                width: 60,
                                padding: EdgeInsets.all(1.0),
                                decoration: new BoxDecoration(
                                  color: kPrimaryDarkColor,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  border: Border.all(color: indicators[1], width: 2.0, style: BorderStyle.solid),
                                ),
                                child: Center(child: Text("25%", style: TextStyle(color: kSecondary),),)
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              setState(() {
                                var text = double.parse(widget.obj.balance.replaceAll(",", ""))/2;
                                CryptoAmountController.text = format(text.toString().replaceAll(",", ""), widget.obj.networkModel.first.decimals);
                                isFiat=false;
                              });
                            },
                            child: Container(
                                height: 40,
                                width: 60,
                                padding: EdgeInsets.all(1.0),
                                decoration: new BoxDecoration(
                                  color: kPrimaryDarkColor,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  border: Border.all(color: indicators[1], width: 2.0, style: BorderStyle.solid),
                                ),
                                child: Center(child: Text("50%", style: TextStyle(color: kSecondary),),)
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              setState(() {
                                var text = double.parse(widget.obj.balance.replaceAll(",", ""))*75/100;
                                CryptoAmountController.text = format(text.toString().replaceAll(",", ""), widget.obj.networkModel.first.decimals);
                                isFiat=false;
                              });
                            },
                            child: Container(
                                height: 40,
                                width: 60,
                                padding: EdgeInsets.all(1.0),
                                decoration: new BoxDecoration(
                                  color: kPrimaryDarkColor,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  border: Border.all(color: indicators[1], width: 2.0, style: BorderStyle.solid),
                                ),
                                child: Center(child: Text("75%", style: TextStyle(color: kSecondary),),)
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              setState(() {
                                CryptoAmountController.text = widget.obj.balance;
                                isFiat=false;
                              });
                            },
                            child: Container(
                                height: 40,
                                width: 60,
                                padding: EdgeInsets.all(1.0),
                                decoration: new BoxDecoration(
                                  color: kPrimaryDarkColor,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  border: Border.all(color: indicators[1], width: 2.0, style: BorderStyle.solid),
                                ),
                                child: Center(child: Text("100%", style: TextStyle(color: kSecondary),),)
                            ),
                          ),
                          SizedBox(width: 20,),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      NumericKeyboard(
                        onKeyboardTap: _onKeyboardTap,
                        textColor: Colors.black,
                        rightButtonFn: () {
                          setState(() {
                            var text = CryptoAmountController.text.substring(0, CryptoAmountController.text.length - 1);
                            CryptoAmountController.text = "$text";
                          });
                        },
                        leftIcon: Icon(Icons.stop, color: Colors.black, size: 7,),
                        leftButtonFn: () {
                          _onKeyboardTap(".");
                        },
                        rightIcon: Icon(
                          Icons.backspace,
                          color: Colors.black,
                        ),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                      SizedBox(
                        height: 20,
                      ),
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
                              Language.proceed,
                              style: TextStyle(
                                  color: kSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        onTap: () {
                          if(double.parse(CryptoAmountController.text.replaceAll(",", ""))>0){
                            if(isFiat){
                              amount="${double.parse(CryptoAmountController.text.replaceAll(",", ""))/rate}";
                            }else{
                              amount=CryptoAmountController.text;
                            }
                            _confirm(context);
                          }
                        },
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height/0.20,),
                    ],
                  ),
                ),
              ],
            )));
  }

  _onKeyboardTap(String value) {
    setState(() {
      CryptoAmountController.text = "${CryptoAmountController.text}$value";
    });
  }

  _confirm(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(Language.confirm, maxLines: 2, style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
                              InkWell(
                                child: Icon(
                                  Icons.cancel,
                                  size: 30,
                                  color: Colors.grey[300],
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: indicators[1],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.25,
                                    child: Text(
                                      Language.amount,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.45,
                                    child: Text(
                                      format(amount, widget.obj.networkModel.first.decimals)+ " ${widget.obj.networkModel.first.currency_symbol}",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.25,
                                    child: Text(
                                      Language.rate,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.45,
                                    child: Text(
                                      "1 ${widget.obj.networkModel.first.currency_symbol} = ${format("$rate", "4")} ${widget.fiat.networkModel.first.currency_symbol}",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.25,
                                    child: Text(
                                      Language.fee,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.45,
                                    child: Text(
                                      format("${(double.parse(amount.replaceAll(",", ""))*(double.parse(widget.obj.networkModel.first.sell_fee.replaceAll(",", ""))/100))+double.parse(widget.obj.networkModel[0].sell_fee_fixed.replaceAll(",", ""))}", widget.obj.networkModel[0].decimals)+" ${widget.obj.networkModel.first.currency_symbol}",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.25,
                                    child: Text(
                                      Language.you_receive,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.45,
                                    child: Text("${widget.fiat.networkModel.first.currency_symbol} "+format("${double.parse(amount.replaceAll(",", ""))*rate-(((double.parse(amount.replaceAll(",", ""))*(double.parse(widget.obj.networkModel.first.sell_fee.replaceAll(",", ""))/100))+double.parse(widget.obj.networkModel[0].sell_fee_fixed.replaceAll(",", "")))*rate)}", '2'),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
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
                                Language.proceed,
                                style: TextStyle(
                                    color: kSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          onTap: () async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            username = prefs.getString("username")!;
                            token = prefs.getString("token")!;
                            pin = prefs.getString("pin")!;
                            Navigator.of(context).pop();
                            Pin(context, format(amount, widget.obj.networkModel.first.decimals) +
                                " ${widget.obj.networkModel.first
                                    .currency_symbol}", json.encode({
                              'username': '$username',
                              'amount': CryptoAmountController.text.replaceAll((","), ""),
                              'wallet_id': widget.obj.id,
                              'isFiat': '$isFiat',
                              'fiat_wallet_id': widget.fiat.id,
                              'swap_id': Uuid().v4(),
                              'pin': '$pin'}), "/sell-crypto", Language.sell, setState);
                          }),
                      ],
                    )),
              );
            });
      },
    );
  }


}