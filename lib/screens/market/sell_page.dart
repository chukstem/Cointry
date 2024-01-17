import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../constants.dart';
import '../../helper/formatter.dart';
import '../../language.dart';
import '../../models/crypto_model.dart';
import '../../models/markets_model.dart';
import '../../widgets/appbar.dart';
import '../../widgets/pin.dart';

class SellScreen extends StatefulWidget {
  static String routeName = "/sell-crypto";
  CryptoModel from, to;
  MarketsModel market;
  SellScreen({Key? key, required this.from, required this.to, required this.market}) : super(key: key);

  @override
  _SellScreen createState() => _SellScreen();
}

class _SellScreen extends State<SellScreen> {
  String username="", token="", amount="", amount2="", pin="";

  TextEditingController CryptoAmountController=new TextEditingController();
  TextEditingController CryptoAmountController2=new TextEditingController();



  getusers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    token = prefs.getString("token")!;
    pin = prefs.getString("pin")!;
  }




  @override
  void initState() {
    super.initState();
    getusers();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFf2f2f2),
        body: Container(
            constraints: BoxConstraints(
                minHeight: 500, minWidth: double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                backAppbar(context, "${Language.sell} ${widget.from.networkModel[0].currency_symbol}"),
                SizedBox(
                  height: 30,
                ),
                Container(
                  margin:
                  EdgeInsets.only(top: 20, right: 10, left: 40),
                  child: Text("${Language.pay}: ${widget.from.networkModel[0].currency_symbol} (${widget.from.balance})", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 10),
                  height: 60,
                  child: SizedBox(
                    height: 60,
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      controller: CryptoAmountController,
                      decoration: InputDecoration(
                        fillColor: kSecondary,
                        filled: true,
                        hintText: Language.amount,
                        suffixIcon: Container(
                          margin: EdgeInsets.all(10),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: kPrimaryColor,),
                          child: Center(child: Text(widget.from.networkModel.first.currency_symbol, style: TextStyle(color: kSecondary),),),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          amount="$value";
                          double val=double.parse(value)*double.parse(widget.market.price.replaceAll(",", ""));
                          CryptoAmountController2.text=format("$val", widget.to.networkModel.first.decimals);
                        });
                      },
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: 50,
                    width: 50,
                    margin: EdgeInsets.only(top: 20, bottom: 20),
                    padding: EdgeInsets.all(1.0),
                    decoration: new BoxDecoration(
                      color: kSecondary, // border color
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.swap_horiz, size: 30, color: Colors.red,),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, right: 10, left: 40),
                  child: Text("${Language.receive}: ${widget.to.networkModel[0].currency_symbol} (${widget.to.balance})", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                  height: 60,
                  child: SizedBox(
                    height: 60,
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      controller: CryptoAmountController2,
                      decoration: InputDecoration(
                        fillColor: kSecondary,
                        filled: true,
                        hintText: Language.amount,
                        suffixIcon: Container(
                          margin: EdgeInsets.all(10),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: kPrimaryColor,),
                          child: Center(child: Text(widget.to.networkModel.first.currency_symbol, style: TextStyle(color: kSecondary),),),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          amount2="$value";
                          double val=double.parse(value)/double.parse(widget.market.price.replaceAll(",", ""));
                          CryptoAmountController.text=format("$val", widget.from.networkModel.first.decimals);
                        });
                      },
                    ),
                  ),
                ),

                SizedBox(
                  height: 10,
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
                      child: Text(Language.sell,
                        style: TextStyle(
                            color: kSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if(double.parse(CryptoAmountController.text.replaceAll(",", ""))>0){
                          _confirm(context, format(CryptoAmountController.text, widget.from.networkModel.first.decimals));
                        }
                      },
                    )),
                SizedBox(height: 10,),
                Center(
                  child: Text("${Language.rate}: 1 ${widget.from!.networkModel[0].currency_symbol} = ${widget.market.price} ${widget.to!.networkModel[0].currency_symbol}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kPrimaryColor),),
                ),
              ],
            )));
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
                                    child: Text(Language.amount,
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
                                      amount+ " ${widget.from.networkModel.first.currency_symbol}",
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
                                      "1 ${widget.from!.networkModel[0].currency_symbol} = ${widget.market.price} ${widget.to!.networkModel[0].currency_symbol}",
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
                                      "${(double.parse(amount.replaceAll(",", ""))*double.parse(widget.from.networkModel.first.buy_fee.replaceAll(",", ""))/100)+double.parse(widget.from.networkModel[0].buy_fee_fixed.replaceAll(",", ""))}"+" ${widget.from.networkModel.first.currency_symbol}",
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
                                    child: Text("USD "+format("${double.parse(amount.replaceAll(",", ""))*double.parse(widget.market.price.replaceAll(",", ""))+ (double.parse(amount.replaceAll(",", ""))*double.parse(widget.from.networkModel.first.buy_fee.replaceAll(",", ""))/100)+double.parse(widget.from.networkModel[0].buy_fee_fixed.replaceAll(",", ""))}", '2'),
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
                            Pin(context, amount.replaceAll((","), "") +
                                " ${widget.from.networkModel.first.currency_symbol}", json.encode({
                              'username': '$username',
                              'amount': amount,
                              'to_id': widget.to!.id,
                              'from_id': widget.from!.id,
                              'market': widget.market.pair,
                              'type': 'sell',
                              'swap_id': username+'_'+Uuid().v4()+'_${DateTime.now().millisecondsSinceEpoch/1000}',
                              'pin': '$pin'}), "/swap-sell", Language.sell, setState);
                          },),
                      ],
                    )),
              );
            });
      },
    );
  }

}