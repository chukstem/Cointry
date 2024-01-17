import 'dart:async';
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../../constants.dart';
import '../../language.dart';
import '../../models/crypto_model.dart';
import '../../models/network_model.dart';
import '../../strings.dart';
import '../../widgets/image.dart';
import '../../widgets/snackbar.dart';

class ReceiveScreen extends StatefulWidget {
  CryptoModel obj;
  ReceiveScreen({required this.obj});

  @override
  _ReceiveScreen createState() => _ReceiveScreen();
}

class _ReceiveScreen extends State<ReceiveScreen> {
  bool error=false, showprogress = false;
  String walletAddress="", errormsg="";
  NetworkModel? item;

  Future<String> generateWallet(NetworkModel item, setState) async {
    setState(() {
      showprogress = true; //don't show progress indicator
      error = false;
      errormsg = "";
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token")!;
    var email = prefs.getString("email")!;
    String address="Could not generate wallet address. Please try again";
    String apiurl = Strings.url + "/generate-address";
    var response = null;
    Map data = {
      'email': email,
      'network_id': item.network_id,
      'wallet_id': widget.obj.id,
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
        var jsonB = json.decode(response.body);
        if (jsonB["status"] != null &&
            jsonB["status"].toString().contains("success")) {
          setState(() {
            walletAddress=jsonB["address"];
            error = false;
            errormsg = "";
          });
        }else{
          setState(() {
            showprogress = false;
            error = true;
            errormsg = jsonB["response_message"];
          });
          Navigator.of(context).pop();
          Snackbar().show(context, ContentType.failure, Language.error, errormsg);
        }
      } catch (e) {
        setState(() {
          error = true;
          errormsg = "Network connection error ";
        });
      }
    }else{
      setState(() {
        error = true;
        errormsg = "Network connection error ";
      });
    }
    setState(() {
      showprogress = false;
    });
    return address;
  }

  

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFf2f2f2),
        body: Container(
        constraints: BoxConstraints(
        minHeight: 500, minWidth: double.infinity),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 60,),
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width*0.35,
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
                  Text("Receive "+widget.obj.networkModel[0].currency, maxLines: 2, style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 20, right: 10, left: 40),
              child: Text("Select Network", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
            ),
            Container(
                padding: EdgeInsets.all(1),
                margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                alignment: Alignment.center,
                height: 60,
                child: DropdownButtonFormField<NetworkModel>(
                  isExpanded: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                      filled: true,
                      hintText: "Select Network",
                      hintStyle: TextStyle(color: Colors.grey[800], fontSize: 2),
                      fillColor: kSecondary
                  ),
                  hint: Text('Select Network'),
                  onChanged: (NetworkModel? value){
                    setState(() {
                      item=value!;
                      walletAddress=value.address;
                      error=false;
                    });
                    if(value!.address.isEmpty && value.network !="Select Network"){
                      generateWallet(item!, setState);
                    }
                  },
                  items: widget.obj.networkModel.map((NetworkModel user){
                    return DropdownMenuItem<NetworkModel>(value: user, child: Text(user.network, style: TextStyle(color: Colors.black),),);
                  }).toList(),
                ),
            ),
            SizedBox(height: 15,),
            showprogress ?
            Column(
              children: [
                SizedBox(height: 15,),
                SizedBox(
                  height: 50, width: 50,
                  child: CircularProgressIndicator(
                    backgroundColor: kSecondary,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        kPrimaryColor),
                  ),
                ),
                SizedBox(height: 15,),
              ],
            ) : Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10),),
                color: Colors.grey[200]
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 20.0,
                  ),
                  walletAddress =="" || item!.deposit_status!="1" ?
                  Container() :
                  cacheNetworkImage(
                    fit: BoxFit.fill,
                    imgUrl: 'https://chart.googleapis.com/chart?chs=230x230&cht=qr&chl=${walletAddress}&choe=UTF-8',
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  item !=null && item!.deposit_status.contains("0") ?
                  Container(
                    padding: EdgeInsets.all(5.00),
                    margin: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: yellow50,
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 10.00),
                            child: Text('Deposit currently disabled for this network', style: TextStyle(color: kPrimaryColor, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,),
                          ),
                        ]),
                  ) : error ? Container(
                    padding: EdgeInsets.all(5.00),
                    margin: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: yellow50,
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 10.00),
                            child: Text('$errormsg', style: TextStyle(color: kPrimaryColor, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,),
                          ),
                        ]),
                  ): walletAddress =="" ?
                  Container() :
                  Container(
                    width: MediaQuery.of(context).size.width*0.90,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 10.00),
                    child: Text('$walletAddress', style: TextStyle(color: kPrimaryColor, fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2, textAlign: TextAlign.center,),
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width*0.90,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(
                          top: 20, right: 20, left: 20, bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: kPrimaryDarkColor,
                      ),
                      child: Center(
                        child: InkWell(
                          child: Text(
                            'Copy Wallet Address',
                            style: TextStyle(
                                color: kSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            if (walletAddress!="") {
                              Clipboard.setData(ClipboardData(text: walletAddress));
                              Toast.show("Address copied!", duration: Toast.lengthLong, gravity: Toast.bottom);
                            }
                          },
                        ),
                      )),
                  Container(
                    width: MediaQuery.of(context).size.width*0.60,
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(20),
                    child: Center(
                      child: Text('Transfer funds from an existing wallet or another recipient to your wallet address', style: TextStyle(color: kPrimaryColor, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3, textAlign: TextAlign.center,),
                    )
                  ),
                ],
              )
          ],
        )));
  }

  String format(String price){
    var value = price;
    if (price.length > 8) {
      value = value.substring(0, 8);
    }
    return value;
  }
}