import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
 
import '../../components/get_products.dart';
import '../../constants.dart';
import '../../helper/formatter.dart';
import '../../helper/networklayer.dart';
import '../../language.dart';
import '../../models/bills_model.dart';
import '../../models/crypto_model.dart';
import '../../models/p2p_model.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import '../../widgets/material.dart';
import '../../widgets/pin.dart';
import '../../widgets/snackbar.dart';
import '../beneficiaries/beneficiaries_page.dart';

class CreateAds extends StatefulWidget {
  P2PModel? obj;
  bool create;
  CreateAds({required this.obj, required this.create});

  @override
  _CreateAdsState createState() => _CreateAdsState();
}

class Item{
  Item(this.name, this.id);
  final String name;
  final String id;
}

class _CreateAdsState extends State<CreateAds> {
  bool error=false;
  String email="", rate="", min="", terms="", max="", token="", errormsg="", pin="", username="";
  TextEditingController termsController=new TextEditingController();
  TextEditingController rateController=new TextEditingController();
  TextEditingController minController=new TextEditingController();
  TextEditingController maxController=new TextEditingController();
  Bills? beneficiary;
  List<Bills> beneficiaries = Products().getProduct("beneficiaries");
  List<Item> types=<Item>[
    Item('Buy', '1'),
    Item('Sell', '2'),
  ];
  Item? type;
  List<Item> windows=<Item>[
    Item(Language.select_window, '0'),
    Item('15 Minutes', '15'),
    Item('20 Minutes', '20'),
    Item('30 Minutes', '30'),
    Item('40 Minutes', '40'),
    Item('60 Minutes', '60'),
  ];
  Item? window;

  CryptoModel? currency;
  CryptoModel? fiat;

  List<CryptoModel> currencies = List.empty(growable: true);
  List<CryptoModel> fiats = List.empty(growable: true);
  cachedList() async {
    List<CryptoModel> iList = await getCryptosCached();
    setState(() {
      currencies = iList.where((o) => !o.type.toLowerCase().contains("fiat")).toList();
      fiats = iList.where((o) => o.type.toLowerCase().contains("fiat")).toList();
    });
    updateAds();
  }
  getList() async {
    List<CryptoModel> iList = await getCryptos(new http.Client());
    if(iList.isNotEmpty){
      setState(() {
        currencies = iList.where((o) => !o.type.toLowerCase().contains("fiat")).toList();
        fiats = iList.where((o) => o.type.toLowerCase().contains("fiat")).toList();
      });
      updateAds();
    }
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString("email")!;
      username = prefs.getString("username")!;
      token = prefs.getString("token")!;
      pin = prefs.getString("pin")!;
    });
  }


  submit(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString("email")!;
    username = prefs.getString("username")!;
    token = prefs.getString("token")!;
    pin = prefs.getString("pin")!;
    token = prefs.getString("token")!;
    if (window==null || window!.name.contains("Window")) {
      setState(() {
        error = true;
        errormsg = "Select Ads Type";
      });
    } else if (rate.isEmpty) {
      setState(() {
        error = true;
        errormsg = "Rate can not be empty";
      });
    } else if (beneficiary==null || beneficiary!.name.contains("Select")) {
      setState(() {
        error = true;
        errormsg = Language.select_beneficiary;
      });
    }else if (currency==null) {
      setState(() {
        error = true;
        errormsg = Language.select_currency;
      });
    }else if (fiat==null) {
      setState(() {
        error = true;
        errormsg = Language.select_fiat;
      });
    }else if (type==null || type!.name.contains("Select")) {
      setState(() {
        error = true;
        errormsg = "Select Ads Type";
      });
    } else if (min.isEmpty) {
      setState(() {
        error = true;
        errormsg = "Minimum can not be empty";
      });
    }else if (max.isEmpty) {
      setState(() {
        error = true;
        errormsg = "Maximum can not be empty";
      });
    } else if (terms.isEmpty) {
      setState(() {
        error = true;
        errormsg = "Payment Terms can not be empty";
      });
    } else {
      setState(() {
        error = false;
      });
      _confirm(context);
    }
  }

  updateAds(){
    if(!widget.create){
      String fiat_curr="${widget.obj?.fiat_symbol.toLowerCase()}";
      setState(() {
        type=widget.obj!.rate_attribute.toLowerCase().contains("$fiat_curr/") ? types.first : types.last;
        window=windows.where((o) => widget.obj!.window.contains(o.id)).last;
        rateController.text="${widget.obj!.amountRate}";
        rate="${widget.obj!.amountRate}";
        minController.text="${widget.obj!.amountMin}";
        min="${widget.obj!.amountMin}";
        maxController.text="${widget.obj!.amountMax}";
        max="${widget.obj!.amountMax}";
        termsController.text="${widget.obj!.terms}";
        terms="${widget.obj!.terms}";
        if(currencies.isNotEmpty){
          currency=currencies.where((o) => o.networkModel[0].currency_symbol.toLowerCase().contains(widget.obj!.currency_symbol.toLowerCase())).last;
        }
        if(fiats.isNotEmpty){
          fiat=fiats.where((o) => o.networkModel[0].currency_symbol.toLowerCase().contains(widget.obj!.currency_symbol.toLowerCase())).last;
        }
      });
    }
  }

  close(BuildContext context) async{
    QuickAlert.show(
        context: context,
        backgroundColor: kPrimaryDarkColor,
        type: QuickAlertType.confirm,
        title: 'Close Trade',
        titleColor: kSecondary,
        textColor: kSecondary,
        text: 'You are about to close this Trade. This can not be undone',
        confirmBtnText: Language.proceed,
        cancelBtnText: Language.cancel,
        confirmBtnColor: Colors.green,
        onConfirmBtnTap: () async {
          Navigator.pop(context);
          _close(context);
          return;
        },
        onCancelBtnTap: (){
          Navigator.pop(context);
          return;
        }
    );
  }

  _close(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token=prefs.getString("token");
    String? username=prefs.getString("username");
    var response = null;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: Language.loading,
      text: Language.processing,
    );
    try {
      response = await http.post(Uri.parse(Strings.url+"/trade/close"),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "Bearer $token"},
          body: json.encode({
            'username': username,
            'advertisement_id': widget.obj!.id
          })
      );
      if (response != null && response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["status"] != null &&
            jsondata["status"].toString().contains("success")) {
          Navigator.pop(context);
          Navigator.pop(context);
        }else{
          Navigator.pop(context);
          Snackbar().show(context, ContentType.failure, Language.error, jsondata["response_message"].toString());
        }

      }else{
        Navigator.pop(context);
        Snackbar().show(context, ContentType.failure, Language.error, Language.network_error);
      }

    } catch (e) {
      Navigator.pop(context);
      Snackbar().show(context, ContentType.failure, Language.error, e.toString());
    }

  }

  @override
  void initState() {
    super.initState();
    getUser();
    cachedList();
    updateAds();
    Timer(Duration(seconds: 1), () =>
    {
      getList(),
    });
  }

  @override
  void dispose() {
    super.dispose();
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
      body: SingleChildScrollView(
        child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              backAppbar(context, widget.create==true? Language.create_ads : Language.update_ads),
              SizedBox(
                height: 20,
              ),
              error? Container(
                //show error message here
                margin: EdgeInsets.only(bottom:10),
                padding: EdgeInsets.all(10),
                child: errmsg(errormsg, false, context),
                //if error == true then show error message
                //else set empty container as child
              ) : Container(),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(top: 20, right: 10, left: 20),
                child: Text(Language.ads_info, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                width: MediaQuery.of(context).size.width*0.98,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width*0.30,
                        margin: EdgeInsets.all(5),
                        child: DropdownButtonFormField<Item>(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                              ),
                              filled: true,
                              hintText: Language.select_trade,
                              labelText: "I Want To",
                              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              fillColor: kSecondary
                          ),
                          hint: Text(Language.select_trade, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                          value: type,
                          onChanged: (Item? value) {
                            setState(() {
                              type = value;
                            });
                          },
                          items: types.map((Item user){
                            return DropdownMenuItem<Item>(value: user, child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:  MainAxisAlignment.start, children: [
                              Text(user.name, overflow: TextOverflow.ellipsis, maxLines: 3, style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
                              Divider()
                            ],),);
                          }).toList(),
                        )
                    ),
                    Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width*0.25,
                        margin: EdgeInsets.all(5),
                        child: DropdownButtonFormField<CryptoModel>(
                          isExpanded: true,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              hintText: Language.select_currency,
                              labelText: Language.select_currency,
                              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              fillColor: kSecondary
                          ),
                          value: currency,
                          hint: Text(Language.select_currency, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                          //value: currency!,
                          onChanged: (CryptoModel? value){
                            setState(() {
                              currency = value;
                            });
                          },
                          items: currencies.map((CryptoModel item){
                            return DropdownMenuItem<CryptoModel>(value: item, child: Container(
                              width: MediaQuery.of(context).size.width-20,
                              height: 40,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                color: kSecondary,
                                borderRadius: BorderRadius.circular(10),),
                              child: Text(item.networkModel.first.currency_symbol, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
                            ),);
                          }).toList(),
                        )
                    ),
                    Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width*0.25,
                        margin: EdgeInsets.all(5),
                        child: DropdownButtonFormField<CryptoModel>(
                          isExpanded: true,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              hintText: Language.select_fiat,
                              labelText: Language.select_fiat,
                              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              fillColor: kSecondary
                          ),
                          value: fiat,
                          hint: Text(Language.select_fiat, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                          //value: currency!,
                          onChanged: (CryptoModel? value){
                            setState(() {
                              fiat = value;
                            });
                          },
                          items: fiats.map((CryptoModel item){
                            return DropdownMenuItem<CryptoModel>(value: item, child: Container(
                              width: MediaQuery.of(context).size.width-20,
                              height: 40,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                color: kSecondary,
                                borderRadius: BorderRadius.circular(10),),
                              child: Text(item.networkModel.first.currency_symbol, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
                            ),);
                          }).toList(),
                        )
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(top: 20, right: 10, left: 20),
                child: Text(Language.payment_info, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              SizedBox(
                height: 10,
              ),
              fiat!=null?
               Column(
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Container(
                           height: 60,
                           width: MediaQuery.of(context).size.width*.45,
                           margin: EdgeInsets.all(10),
                           child: DropdownButtonFormField<Item>(
                             decoration: InputDecoration(
                                 border: OutlineInputBorder(
                                   borderRadius: BorderRadius.all(
                                     Radius.circular(5.0),
                                   ),
                                 ),
                                 filled: true,
                                 hintText: Language.select_window,
                                 labelText: Language.payment_window,
                                 labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                 hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                 fillColor: kSecondary
                             ),
                             hint: Text(Language.select_window, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                             value: window,
                             onChanged: (Item? value) {
                               setState(() {
                                 window = value;
                               });
                             },
                             items: windows.map((Item user){
                               return DropdownMenuItem<Item>(value: user, child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 mainAxisAlignment:  MainAxisAlignment.start, children: [
                                 Text(user.name, overflow: TextOverflow.ellipsis, maxLines: 3, style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
                                 Divider()
                               ],),);
                             }).toList(),
                           )
                       ),
                       Container(
                         margin: EdgeInsets.all(10),
                         height: 60,
                         width: MediaQuery.of(context).size.width*.45,
                         child: SizedBox(
                           height: 60,
                           child: TextField(
                             style:TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                             controller: rateController,
                             keyboardType: TextInputType.number,
                             decoration: InputDecoration(
                               labelText: "${Language.rate} (${fiat!.networkModel.first.currency})",
                               labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                               hintText: Language.default_amount,
                               hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                               isDense: true,
                               fillColor: kSecondary,
                               filled: true,
                               contentPadding: EdgeInsets.symmetric(
                                   horizontal: 20, vertical: 20),
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.all(
                                   Radius.circular(5.0),
                                 ),
                               ),
                             ),
                             onChanged: (value){
                               rate=value;
                             },
                           ),
                         ),
                       ),
                     ],
                   ),
                   SizedBox(
                     height: 10,
                   ),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Container(
                         margin: EdgeInsets.all(10),
                         height: 60,
                         width: MediaQuery.of(context).size.width*.45,
                         child: SizedBox(
                           height: 60,
                           child: TextField(
                             style:TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                             controller: minController,
                             keyboardType: TextInputType.number,
                             decoration: InputDecoration(
                               labelText: "Minimum (${fiat!.networkModel.first.currency})",
                               labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                               hintText: Language.default_amount,
                               hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                               isDense: true,
                               fillColor: kSecondary,
                               filled: true,
                               contentPadding: EdgeInsets.symmetric(
                                   horizontal: 20, vertical: 20),
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.all(
                                   Radius.circular(5.0),
                                 ),
                               ),
                             ),
                             onChanged: (value){
                               min=value;
                             },

                           ),
                         ),
                       ),
                       Container(
                         margin: EdgeInsets.all(10),
                         height: 60,
                         width: MediaQuery.of(context).size.width*.45,
                         child: SizedBox(
                           height: 60,
                           child: TextField(
                             style:TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                             controller: maxController,
                             keyboardType: TextInputType.number,
                             decoration: InputDecoration(
                               labelText: "Maximum (${fiat!.networkModel.first.currency})",
                               labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                               hintText: Language.default_amount,
                               hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                               isDense: true,
                               fillColor: kSecondary,
                               filled: true,
                               contentPadding: EdgeInsets.symmetric(
                                   horizontal: 20, vertical: 20),
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.all(
                                   Radius.circular(5.0),
                                 ),
                               ),
                             ),
                             onChanged: (value){
                               max=value;
                             },

                           ),
                         ),
                       ),
                     ],
                   ),
                   SizedBox(
                     height: 10,
                   ),
                   Container(
                     height: 60,
                     margin: EdgeInsets.all(10),
                     child: InkWell(
                       onTap: (){
                         if(beneficiaries.isEmpty){
                           Toast.show(Language.beneficiary_required, duration: Toast.lengthLong, gravity: Toast.bottom);
                           Navigator.of(context).push(
                               CupertinoPageRoute(builder: (context) => Beneficiaries()));
                         }
                       },
                       child: DropdownButtonFormField<Bills>(
                         decoration: InputDecoration(
                             border: OutlineInputBorder(
                               borderRadius: BorderRadius.all(
                                 Radius.circular(5.0),
                               ),
                             ),
                             filled: true,
                             hintText: Language.select_beneficiary,
                             labelText: Language.select_beneficiary,
                             labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                             hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                             fillColor: kSecondary
                         ),
                         hint: Text(Language.select_beneficiary, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                         value: beneficiary,
                         onChanged: (Bills? value) {
                           setState(() {
                             beneficiary = value;
                           });
                         },
                         items: beneficiaries.map((Bills user){
                           return DropdownMenuItem<Bills>(value: user, child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             mainAxisAlignment:  MainAxisAlignment.start, children: [
                             Text(user.name+' - '+user.amount, overflow: TextOverflow.ellipsis, maxLines: 3, style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
                             Divider()
                           ],),);
                         }).toList(),
                       ),
                     ),
                   ),
                   Container(
                     margin:
                     EdgeInsets.only(top: 20, right: 10, left: 10),
                     height: 120,
                     child: SizedBox(
                       height: 120,
                       child: TextField(
                         style:TextStyle(color: kPrimaryColor, fontSize:14),
                         obscureText: false,
                         maxLength: 200,
                         minLines: null,
                         maxLines: null,
                         expands: true,
                         controller: termsController,
                         keyboardType: TextInputType.multiline,
                         decoration: InputDecoration(
                           hintText: Language.trading_terms,
                           isDense: true,
                           fillColor: kSecondary,
                           filled: true,
                           contentPadding: EdgeInsets.symmetric(
                               horizontal: 20, vertical: 20),
                           border: OutlineInputBorder(
                             borderRadius: BorderRadius.all(
                               Radius.circular(5.0),
                             ),
                           ),
                         ),
                         onChanged: (value){
                           terms=value;
                         },
                       ),
                     ),
                   ),
                   SizedBox(
                     height: 20,
                   ),
                   Container(
                     margin: EdgeInsets.only(
                       bottom: 10,
                       left: 20,
                       right: 20,
                     ),
                     child: SizedBox(
                       height: 50, width: double.infinity,
                       child: ElevatedButton(
                         onPressed: (){
                           submit(context);
                         },
                         style: ElevatedButton.styleFrom(primary: kPrimaryColor),
                         child: Padding(
                           padding: EdgeInsets.only(
                               left: 30.0, right: 30.0, top: 10, bottom: 10),
                           child: Text(
                             widget.create==true? Language.create_ads : Language.update_ads,
                             style:
                             TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                           ),
                         ),
                       ),
                     ),
                   ),
                   SizedBox(height: 20,),
                   !widget.create?
                   Container(
                     margin: EdgeInsets.only(
                       bottom: 10,
                       left: 20,
                       right: 20,
                     ),
                     child: widget.obj!.status=="1"? SizedBox(
                       height: 50, width: double.infinity,
                       child: ElevatedButton(
                         onPressed: (){
                           close(context);
                         },
                         style: ElevatedButton.styleFrom(primary: Colors.red),
                         child: Padding(
                           padding: EdgeInsets.only(
                               left: 30.0, right: 30.0, top: 10, bottom: 10),
                           child: Text("Close Trade",
                             style:
                             TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                           ),
                         ),
                       ),
                     ) : Center(
                       child: RichText(
                         text: TextSpan(
                           text: "This Trade is ",
                           style: TextStyle(
                             fontWeight: FontWeight.bold,
                             fontSize: 16,
                             color: kPrimary,
                           ),
                           children: [
                             TextSpan(
                                 text: widget.obj!.status=="0"? "Pending Review" : widget.obj!.status=="1"? "Active": "Closed",
                                 style: TextStyle(
                                   fontWeight: FontWeight.bold,
                                   fontSize: 18,
                                   color: widget.obj!.status=="0"? kPrimaryVeryLightColor : widget.obj!.status=="1"? Colors.green: Colors.red,
                                 )),
                           ],
                         ),
                       ),
                     ),
                   ) : SizedBox(),
                 ],
               )
              :
              SizedBox(),
              SizedBox(height: 20,),
            ],
         ),
      ),
    );
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
                                      Language.crypto_amount,
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
                                      format("${double.parse(max.replaceAll(",", ""))/double.parse(rate.replaceAll(",", ""))}", currency!.networkModel.first.decimals),
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
                                      Language.price,
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
                                      fiat!.networkModel.first.currency+"$rate",
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
                                      fiat!.networkModel.first.currency+" 0.00",
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
                                      Language.limit,
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
                                    child: Text("${fiat!.networkModel.first.currency}$min - ${fiat!.networkModel.first.currency}$max",
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
                            Pin(context, "${fiat!.networkModel.first.currency}$min - ${fiat!.networkModel.first.currency}$max", json.encode({
                              'username': username,
                              'ads_id': widget.create==true? '0' : widget.obj!.id,
                              'min': min.replaceAll(",", ""),
                              'max': max.replaceAll(",", ""),
                              'rate': rate.replaceAll(",", ""),
                              'currency_id': currency!.networkModel.first.currency_id,
                              'fiat_currency_id': fiat!.networkModel.first.currency_id,
                              'terms': terms.trim(),
                              'beneficiary': beneficiary!.size,
                              'window': window!.id,
                              'pin': pin,
                              'type': type!.id}), widget.create==true? "/trade/create" : "/trade/update", type!.name, setState);
                          },),
                      ],
                    )),
              );
            });
      },
    );
  }
}


