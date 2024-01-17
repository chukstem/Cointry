import 'dart:convert';
import 'dart:math';
import 'package:crypto_app/constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';
import '../../helper/formatter.dart';
import '../../language.dart';
import '../../models/p2p_model.dart';
import '../../widgets/pin.dart';
import '../profile/user_profile_screen.dart';

class P2PBuyScreen extends StatefulWidget {
  P2PModel obj;
  P2PBuyScreen({required this.obj});

  @override
  _P2PBuyScreenState createState() => _P2PBuyScreenState();
}

class _P2PBuyScreenState extends State<P2PBuyScreen> {
  bool isChecked=true;
  String token="", username="", pin="", quantity="0";
 TextEditingController quantityController=new TextEditingController();
 TextEditingController quantityControllerCrypto=new TextEditingController();

  getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username")!;
      token = prefs.getString("token")!;
      pin = prefs.getString("pin")!;
    });
  }


  @override
  void initState() {
    super.initState();
    quantityController.text="0";
    getuser();
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryDarkColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: kWhite,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          SizedBox(
          height: 50,
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width*0.30,
                padding: EdgeInsets.only(left: 15),
                alignment: Alignment.centerLeft,
                child: InkWell(
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 22,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                 ),
                ),
                 Text(Language.buy+" "+widget.obj.currency_symbol, maxLines: 2, style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),),
               ],
              ),
             ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.blue[50]
                    ),
                    padding: EdgeInsets.all(20),
                    child: Text(
                      Language.advertisers_terms,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black
                      ),
                    ),
                  ),
                   Container(
                       margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                       decoration: BoxDecoration(
                           borderRadius: BorderRadius.all(Radius.circular(10)),
                           color: kSecondary
                       ),
                       padding: EdgeInsets.all(10),
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.start,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Container(
                           margin: EdgeInsets.only(top: 10, left: 10, right: 20),
                           child: Text(
                               "${Language.rate}: ${widget.obj.fiat_symbol}" + widget.obj.amountRate,
                             style: TextStyle(
                                 fontSize: 16,
                                 fontWeight: FontWeight.bold,
                                 color: Colors.black
                             ),
                           ),
                         ),
                         Container(
                           margin: EdgeInsets.only(top: 5, left: 10, right: 20),
                           child: Text(
                               "${Language.limit}: ${widget.obj.fiat_symbol}" + widget.obj.amountMin +
                                   " - ${widget.obj.fiat_symbol}" + widget.obj.amountMax,
                             style: TextStyle(
                                 fontSize: 16,
                                 color: Colors.black
                             ),
                           ),
                         ),
                         Container(
                           margin: EdgeInsets.only(top: 5, left: 10, right: 20),
                           child: Text(
                               "${Language.payment_method}: " + widget.obj.paymentMethod,
                             style: TextStyle(
                                 fontSize: 16,
                                 color: Colors.black
                             ),
                           ),
                         ),
                         Container(
                           margin: EdgeInsets.only(top: 5, left: 10, right: 20),
                           child: Text(
                               "${Language.payment_time_limit}: " + widget.obj.window,
                             style: TextStyle(
                                 fontSize: 16,
                                 color: Colors.black
                             ),
                           ),
                         ),
                         Container(
                           margin: EdgeInsets.only(top: 20, left: 10, right: 20),
                           child: Text(
                             Language.you_pay,
                             style: TextStyle(
                                 fontSize: 18,
                                 fontWeight: FontWeight.bold,
                                 color: Colors.black
                             ),
                           ),
                         ),
                         Container(
                           margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                           padding: EdgeInsets.only(left: 10, right: 10),
                           height: 50,
                           width: MediaQuery.of(context).size.width,
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.all(Radius.circular(10)),
                             border: Border.all(color: Colors.grey),
                             color: kSecondary
                           ),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             crossAxisAlignment: CrossAxisAlignment.stretch,
                             children: [
                               Container(
                                 width: MediaQuery.of(context).size.width*0.40,
                                 child: new Theme(
                                   data: Theme.of(context).copyWith(
                                     inputDecorationTheme: InputDecorationTheme(border: InputBorder.none, floatingLabelBehavior: FloatingLabelBehavior.always,
                                       contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),),
                                   ),
                                   child: Center(
                                     child: TextField(
                                       keyboardType: TextInputType.phone,
                                       controller: quantityController,
                                       textAlign: TextAlign.left,
                                       decoration: InputDecoration(
                                         isDense: true,
                                         fillColor: kSecondary,
                                         hintText: Language.default_amount,
                                         hintStyle: TextStyle(fontSize: 16,
                                             fontWeight: FontWeight.bold,
                                             color: Colors.black),
                                         filled: true,
                                         contentPadding: EdgeInsets.symmetric(
                                             horizontal: 20, vertical: 20),
                                         border: InputBorder.none,
                                       ),
                                       style: TextStyle(fontSize: 16,
                                           fontWeight: FontWeight.bold,
                                           color: Colors.black),
                                       onChanged: (value){
                                         quantity=value;
                                         var val=double.parse(quantity.replaceAll(",", ""))/double.parse(widget.obj.amountRate.replaceAll(",", ""));
                                         quantityControllerCrypto.text="${format(val.toString(), widget.obj.currency_decimals)}";
                                       },
                                     ),
                                   )
                                 ),
                               ),
                               Container(
                                 width: MediaQuery.of(context).size.width*0.30,
                                 margin: EdgeInsets.only(right: 10),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.end,
                                   crossAxisAlignment: CrossAxisAlignment.end,
                                   children: [
                                     Container(
                                       margin: EdgeInsets.only(top: 5, bottom: 5, right: 10),
                                       child: Center(
                                         child: Text(
                                           widget.obj.fiat_symbol,
                                           style: TextStyle(
                                               fontSize: 16,
                                               fontWeight: FontWeight.bold,
                                               color: Colors.black
                                           ),
                                         ),
                                       ),
                                     ),
                                     Container(
                                       width: 40,
                                       height: 50,
                                       padding: EdgeInsets.all(5),
                                       margin: EdgeInsets.only(top: 5, bottom: 5, right: 0),
                                       decoration: BoxDecoration(
                                         color: kWhite,
                                         borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                       ),
                                       child: InkWell(
                                         onTap: (){
                                           setState(() {
                                             quantityController.text=widget.obj.amountMax;
                                             quantity=widget.obj.amountMax.replaceAll(",", "");
                                             var val=double.parse(quantity)/double.parse(widget.obj.amountRate.replaceAll(",", ""));
                                             quantityControllerCrypto.text="${format(val.toString(), widget.obj.currency_decimals)}";
                                           });
                                         },
                                         child: Center(child: Text("All", style: TextStyle(fontSize: 22, color: Colors.black),),),
                                       ),
                                     )
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ),
                         Container(
                           margin: EdgeInsets.only(top: 20, left: 10, right: 20),
                           child: Text(
                             Language.you_receive,
                             style: TextStyle(
                                 fontSize: 18,
                                 fontWeight: FontWeight.bold,
                                 color: Colors.black
                             ),
                           ),
                         ),
                         Container(
                           margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                           padding: EdgeInsets.only(left: 10, right: 10),
                           height: 50,
                           width: MediaQuery.of(context).size.width,
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.all(Radius.circular(10)),
                             border: Border.all(color: Colors.grey),
                             color: kSecondary
                           ),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             crossAxisAlignment: CrossAxisAlignment.stretch,
                             children: [
                               Container(
                                 width: MediaQuery.of(context).size.width*0.40,
                                 child: new Theme(
                                   data: Theme.of(context).copyWith(
                                     inputDecorationTheme: InputDecorationTheme(border: InputBorder.none, floatingLabelBehavior: FloatingLabelBehavior.always,
                                       contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),),
                                   ),
                                   child: Center(
                                     child: TextField(
                                       keyboardType: TextInputType.phone,
                                       controller: quantityControllerCrypto,
                                       textAlign: TextAlign.left,
                                       decoration: InputDecoration(
                                         isDense: true,
                                         fillColor: kSecondary,
                                         hintText: Language.default_amount,
                                         hintStyle: TextStyle(fontSize: 16,
                                             fontWeight: FontWeight.bold,
                                             color: Colors.black),
                                         filled: true,
                                         contentPadding: EdgeInsets.symmetric(
                                             horizontal: 20, vertical: 20),
                                         border: InputBorder.none,
                                       ),
                                       style: TextStyle(fontSize: 16,
                                           fontWeight: FontWeight.bold,
                                           color: Colors.black),
                                       onChanged: (value){
                                         var val=double.parse(value.replaceAll(",", ""))*double.parse(widget.obj.amountRate.replaceAll(",", ""));
                                         quantityController.text="${format(val.toString(), "2")}";
                                         quantity="${format(val.toString(), "2")}";
                                       },
                                     ),
                                   )
                                 ),
                               ),
                               Container(
                                 width: MediaQuery.of(context).size.width*0.30,
                                 margin: EdgeInsets.only(right: 10),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.end,
                                   crossAxisAlignment: CrossAxisAlignment.end,
                                   children: [
                                     Container(
                                       margin: EdgeInsets.only(top: 5, bottom: 5, right: 10),
                                       child: Center(
                                         child: Text(
                                           "${widget.obj.currency_symbol}",
                                           style: TextStyle(
                                               fontSize: 16,
                                               fontWeight: FontWeight.bold,
                                               color: Colors.black
                                           ),
                                         ),
                                       ),
                                     ),
                                     Container(
                                       width: 40,
                                       height: 50,
                                       padding: EdgeInsets.all(5),
                                       margin: EdgeInsets.only(top: 5, bottom: 5, right: 0),
                                       decoration: BoxDecoration(
                                         color: kWhite,
                                         borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                       ),
                                       child: InkWell(
                                         onTap: (){
                                           setState(() {
                                             var val=double.parse(widget.obj.amountMax.replaceAll(",", ""))/double.parse(widget.obj.amountRate.replaceAll(",", ""));
                                             quantityControllerCrypto.text="${format(val.toString(), widget.obj.currency_decimals)}";

                                             quantityController.text=widget.obj.amountMax;
                                             quantity=widget.obj.amountMax.replaceAll(",", "");
                                           });
                                         },
                                         child: Center(child: Text("All", style: TextStyle(fontSize: 22, color: Colors.black),),),
                                       ),
                                     )
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ),
                         Container(
                           margin: EdgeInsets.only(
                             bottom: 10,
                             left: 20,
                             right: 20,
                             top: 20
                           ),
                           child: SizedBox(
                             height: 50, width: double.infinity,
                             child: ElevatedButton(
                               onPressed: (){
                                 if(!isChecked){
                                   Toast.show("You must accept Trader Terms to proceed!", duration: Toast.lengthLong, gravity: Toast.bottom);
                                 }else if(double.parse(quantity.replaceAll(",", ""))>0){
                                   _confirm(context, format(quantity, widget.obj.currency_decimals));
                                 }
                               },
                               style: ElevatedButton.styleFrom(primary: kPrimaryDarkColor),
                               child: Padding(
                                 padding: EdgeInsets.only(
                                     left: 30.0, right: 30.0, top: 10, bottom: 10),
                                 child: Text(
                                   Language.buy_zero_fee,
                                   style:
                                   TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                 ),
                               ),
                             ),
                           ),
                         ),
                       ],
                     )
                   ),
                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => UserProfile(user: widget.obj.user.first,)));
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: kSecondary
                      ),
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                child: Text(
                                  widget.obj.user.first
                                      .first_name + " " +
                                      widget.obj.user.first
                                          .last_name,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(width: 2),
                              widget.obj.user.first.rank == "0" ?
                              SizedBox() :
                              widget.obj.user.first.rank == "1" ?
                              Icon(Icons.verified_user,
                                color: kPrimaryLightColor,
                                size: 10,) :
                              Icon(Icons.star,
                                color: widget.obj.user.first
                                    .rank == "3"
                                    ? Colors.orangeAccent
                                    : kPrimaryVeryLightColor,
                                size: 10,),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                Language.view_profile,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black
                                ),
                              ),
                              Icon(Icons.navigate_next),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: kSecondary
                    ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Language.trader_terms,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              ),
                            ),
                            Checkbox(
                              checkColor: kSecondary,
                              activeColor: Colors.blue,
                              value: isChecked,
                              shape: CircleBorder(),
                              onChanged: (value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                          child: Text(
                            widget.obj.terms,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black
                            ),
                          ),
                        ),
                      ],
                    )
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: kSecondary
                    ),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Language.trades,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                        Text(
                          widget.obj.user.first.trades,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: kSecondary
                    ),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Language.avg_speed,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                        Text(
                          widget.obj.avg_speed,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black
                          ),
                        ),
                ],
              ),
              ),
              SizedBox(height: 20,),
            ]
          ),
        ],
      ),
      ),
    );
  }


  _confirm(BuildContext context, String amount) {
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
                                      "${Language.amount}",
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
                                      widget.obj.fiat_symbol+amount,
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
                                      widget.obj.fiat_symbol+"${widget.obj.amountRate}",
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
                                      widget.obj.fiat_symbol+Language.default_amount,
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
                                    child: Text(format("${double.parse(amount.replaceAll(",", ""))/double.parse(widget.obj.amountRate.replaceAll(",", ""))}", widget.obj.currency_decimals)+" ${widget.obj.currency_symbol}",
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
                          onTap: () {
                            Navigator.of(context).pop();
                            Pin(context, format("${double.parse(amount.replaceAll(",", ""))/double.parse(widget.obj.amountRate.replaceAll(",", ""))}", widget.obj.currency_decimals)+" ${widget.obj.currency_symbol}", json.encode({
                              'username': username,
                              'amount': amount.replaceAll((","), ""),
                              'rate': widget.obj.amountRate.replaceAll((","), ""),
                              'uid': username+'_'+Uuid().v4()+'_${DateTime.now().millisecondsSinceEpoch/1000}',
                              'pin': pin}), "/trade/initiate/"+widget.obj.id, Language.buy, setState);
                          },),
                      ],
                    )),
              );
            });
      },
    );
  }

}
