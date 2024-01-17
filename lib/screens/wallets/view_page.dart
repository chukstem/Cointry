import 'dart:async';
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_app/screens/p2p/p2p.dart';
import 'package:crypto_app/screens/wallets/transfer_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_view/pin_code_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helper/formatter.dart';
import '../../helper/networklayer.dart';
import '../../language.dart';
import '../../models/transactions_model.dart';
import '../../screens/wallets/success_page.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';
import '../../components/get_products.dart';
import '../../constants.dart';
import '../../models/bills_model.dart';
import '../../models/crypto_model.dart';
import '../../models/crypto_transactions_model.dart';
import '../../models/network_model.dart';
import '../../radius.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import '../../widgets/image.dart';
import '../../widgets/material.dart';
import '../../widgets/pin.dart';
import '../../widgets/snackbar.dart';
import '../trade/buy_page.dart';
import '../trade/sell_page.dart';
import '../transactions/transactions_page.dart';

class ViewCrypto extends StatefulWidget {
  final CryptoModel obj;
  final String action;
  ViewCrypto({required this.obj, required this.action});

  @override
  _ViewCrypto createState() => _ViewCrypto();
}

class Item{
  Item(this.name);
  final String name;
}

class _ViewCrypto extends State<ViewCrypto> with SingleTickerProviderStateMixin {
  bool error=false, readOnly=false, visible=false, error2=false,  error3=false, wallet_button=false;
  String name="", wallet=Language.default_amount, email="", bal="0";
  String username="", pin="", cryptoamount="", amount="", token="";
  String errormsg="", errormsg2="", walletAddress="", errormsg3="";
  bool save_beneficiary=false, success=false, showprogress=false, validated=false, process=false, showprogress2=false, showprogress3=false, process2=false;
  String bankname="Wema", account_number="", fiatWallet="", address="", narration="", quantity="", iuc="", mybrowser="", number="", accountnumber="";
  final pageIndexNotifier = ValueNotifier<int>(0);
  TextEditingController sendController=TextEditingController();
  NetworkModel? networkItem;
  List<TransactionsModel> list = List.empty(growable: true);
  List<TransactionsModel> olist = List.empty(growable: true);
  List<CryptoModel> aList = List.empty(growable: true);
  bool loading = true, loading2 = true;
  var _tabController;


  cachedCryptos() async {
    List<CryptoModel> iList = await getCryptosCached();
    if(iList.isNotEmpty){
      setState(() {
        loading2 = false;
        aList=iList.where((o) => o.type.toLowerCase().contains("fiat")).toList();
      });
    }
  }
  cachedCryptos2(setState) async {
    List<CryptoModel> iList = await getCryptosCached();
    if(iList.isNotEmpty){
      setState(() {
        loading2 = false;
        aList=iList.where((o) => o.type.toLowerCase().contains("fiat")).toList();
      });
    }

    try{
      List<CryptoModel> iList = await getCryptos(http.Client());
      setState(() {
        aList=iList.where((o) => o.type.toLowerCase().contains("fiat")).toList();
        loading2 = false;
      });

    }catch(e){
      setState(() {
        loading2 = false;
      });
    }
  }

  fetchList() async {
    try{
      List<CryptoModel> iList = await getCryptos(http.Client());
      setState(() {
        aList=iList.where((o) => o.type.toLowerCase().contains("fiat")).toList();
        loading2 = false;
      });

    }catch(e){
      setState(() {
        loading2 = false;
      });
    }

  }


  fetch() async {
    try{
      List<TransactionsModel> iList = await getTransactions(new http.Client(), widget.obj.networkModel.first.currency_id);
      setState(() {
        loading = false;
        list = iList;
        olist = iList;
      });

    }catch(e){
      setState(() {
        loading = false;
      });
    }

  }


  void action(){
    if(visible==false) {
      if (widget.action == "Buy Crypto") {
        chooseFiat('buy');
      } else if (widget.action == "Sell Crypto") {
        chooseFiat('sell');
      }else if (widget.action == "Receive") {
        _receive(context);
      }else if (widget.action.contains("@")){
        sendController.text=widget.action;
        address=widget.action;
        setState(() {
          readOnly=true;
        });
        _sendToUser(context);
      } else if (widget.action == "Send"){
        sendController.text=widget.action;
        address=widget.action;
        _send(context);
      }
    }
    setState(() {
      visible=true;
    });
  }

  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var fname = prefs.getString("firstname");
      var lname = prefs.getString("lastname");
      name = "$fname $lname";
      email = prefs.getString("email")!;
      username = prefs.getString("username")!;
      token = prefs.getString("token")!;
      pin = prefs.getString("pin")!;
    });
  }




  int maxRenderAvatar = 5;
  double size = 30;
  double borderSize = 5;

  Widget buildStackedImages({
    TextDirection direction = TextDirection.ltr,
  }) {
    List<Widget> items = [];

    final renderItemCount = 1;
    for (int i = 0; i < renderItemCount; i++) {
      items.add(
        Positioned(
          left: maxRenderAvatar * size * .8,
          child: buildImage(),
        ),
      );
    }

    return SizedBox(
      height: size + (borderSize * 2),
      width: 160,
      child: Stack(
        children: items,
      ),
    );
  }

  Widget buildImage() {
    return ClipOval(
      child: Container(
        padding: EdgeInsets.all(borderSize),
        color: kSecondary,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.obj.networkModel[0].img,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }



  @override
  void initState() {
    super.initState();
    setState(() {
      wallet=format("${widget.obj.usdBalance.replaceAll(",", "")}", widget.obj.networkModel[0].decimals);
    });
    _tabController = TabController(vsync: this, length: 5);
    cachedCryptos();
    Timer(Duration(seconds: 1), () =>
    {
      getuser(),
      fetch(),
      fetchList(),
    });
  }

  int counter = 0;


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: kPrimaryDarkColor,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
  ));
  ToastContext().init(context);
    action();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: kPrimaryColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40,),
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
                  Text(widget.obj.networkModel[0].currency+" "+Language.wallet, maxLines: 2, style: TextStyle(color: kSecondary, fontSize: 25, fontWeight: FontWeight.bold),),
                  Container(
                    padding: EdgeInsets.only(right: 15),
                  ),
                ],
              ),
            ),
            Container(
              color: kPrimaryColor,
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: 250,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                //color: kPrimaryColor,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: circularRadius(AppRadius.border12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                      padding: EdgeInsets.only(top: 10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Language.usd_balance,
                                  style: TextStyle(fontSize: 16,
                                      fontWeight: FontWeight.bold, color: kSecondary),
                                ),
                                SizedBox(height: 5,),
                                Text(
                                  "${Language.price}: ${widget.obj.networkModel[0].price}",
                                  style: TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.bold, color: kSecondary),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          wallet_button == true ?
                                          Text(
                                            "\$"+format(wallet, "2"),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: kSecondary,),
                                          ) :
                                          Text(
                                            "\$ ****",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: kSecondary),
                                          ),
                                          SizedBox(width: 10,),
                                          Center(
                                            child: InkWell(
                                              child: SizedBox(
                                                height: 30,
                                                width: 30,
                                                child: Icon(
                                                  wallet_button == true ?
                                                  Icons.remove_red_eye : Icons
                                                      .remove_red_eye_outlined,
                                                  color: kSecondary,
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  if (wallet_button == true) {
                                                    wallet_button = false;
                                                  } else {
                                                    wallet_button = true;
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ]),),
                                  Container(
                                    margin: EdgeInsets.only(left: 20, bottom: 5),
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text("${Language.change_percentage} ${widget.obj.networkModel[0].percentage_change}", style: TextStyle(color: kSecondary),),
                                  ),
                                ],
                              ),
                            )
                          ]),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: (){
                                _send(context);
                              },
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      padding: EdgeInsets.all(1.0),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent, // border color
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.send, size: 30, color: kSecondary,),),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        Language.send,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: kSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),)
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                                onTap: (){
                                  _receive(context);
                                },
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 50,
                                        padding: EdgeInsets.all(1.0),
                                        decoration: new BoxDecoration(
                                          color: kSecondary, // border color
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.arrow_downward, size: 30, color: kPrimaryColor,),),
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          Language.receive,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: kSecondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),)
                                    ],
                                  ),
                                )
                            ),
                            InkWell(
                                onTap: (){
                                 chooseFiat('buy');
                                },
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 50,
                                        padding: EdgeInsets.all(1.0),
                                        decoration: new BoxDecoration(
                                          color: kSecondary, // border color
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.keyboard_double_arrow_down, size: 30, color: kPrimaryColor,),),
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          Language.buy,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: kSecondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),)
                                    ],
                                  ),
                                )
                            ),
                            InkWell(
                                onTap: (){
                                  chooseFiat('sell');
                                },
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 50,
                                        padding: EdgeInsets.all(1.0),
                                        decoration: new BoxDecoration(
                                          color: kSecondary, // border color
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.keyboard_double_arrow_up, size: 30, color: kPrimaryColor,),),
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          Language.sell,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: kSecondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),)
                                    ],
                                  ),
                                )
                            ),
                          ]
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5, right: 5, top: 10),
                      padding: EdgeInsets.only(left: 20, right: 10),
                      height: 60,
                      decoration: BoxDecoration(
                        color: kSecondary,
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Language.show_assets,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          buildStackedImages(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                color: kSecondary,
              ),
              padding: EdgeInsets.only(top: 30,),
              height: 600,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TabBar(
                    indicatorPadding: EdgeInsets.only(left: 10, right: 10),
                    unselectedLabelStyle: TextStyle(color: Colors.grey),
                    indicatorColor: Colors.black,
                    labelColor: Colors.black,
                    labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                    padding: EdgeInsets.only(bottom: 10),
                    tabs: <Tab>[
                      Tab(
                        //icon: Icon(Icons.arrow_downward),
                        text: Language.crypto_deposits,
                      ),
                      Tab(
                        //icon: Icon(Icons.arrow_upward),
                        text: Language.crypto_withdrawals,
                      ),
                      Tab(
                        //icon: Icon(Icons.swap_horiz),
                        text: Language.trades,
                      ),
                    ],
                    controller: _tabController,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        new Transactions(loading: loading, tList: list.isEmpty?[]:list.first.deposit),
                        new Transactions(loading: loading, tList: list.isEmpty?[]:list.first.withdraw),
                        new Transactions(loading: loading, tList: list.isEmpty?[]:list.first.swap),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),);
  }



  Future<String> generateWallet(NetworkModel item, setState) async {
    setState(() {
      showprogress3 = true; //don't show progress indicator
      error3 = false;
      errormsg3 = "";
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token")!;
    email = prefs.getString("email")!;
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
        showprogress3 = false; //don't show progress indicator
        error3 = true;
        errormsg3 = Language.network_error;
      });
    }
    if (response != null && response.statusCode == 200) {
      try {
        var jsonB = json.decode(response.body);
        if (jsonB["status"] != null &&
            jsonB["status"].toString().contains("success")) {
          setState(() {
            walletAddress=jsonB["address"];
            error3 = false;
            errormsg3 = "";
          });
        }else{
          setState(() {
            showprogress3 = false;
            error3 = true;
            errormsg3 = jsonB["response_message"];
          });
          Navigator.of(context).pop();
          Snackbar().show(context, ContentType.failure, Language.error, errormsg3);
        }
      } catch (e) {
        setState(() {
          error3 = true;
          errormsg3 = Language.network_error;
        });
      }
    }else{
      setState(() {
        error3 = true;
        errormsg3 = Language.network_error;
      });
    }
    setState(() {
      showprogress3 = false;
    });
    return address;
  }

  _receive(BuildContext context) {
   NetworkModel? item;
    walletAddress="";
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Container(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppBarDefault(context, Language.receive+" ${widget.obj.networkModel[0].currency}"),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                                padding: EdgeInsets.all(1),
                                margin: EdgeInsets.only(left: 20, right: 20),
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
                                      hintText: Language.select_network,
                                      hintStyle: TextStyle(color: Colors.grey[800], fontSize: 2),
                                      fillColor: kSecondary
                                  ),
                                  hint: Text(Language.select_network),
                                  onChanged: (NetworkModel? value){
                                    setState(() {
                                      item=value!;
                                      walletAddress=value.address;
                                      error=false;
                                    });
                                    if(value!.address.isEmpty && value.network !=Language.select_network){
                                      generateWallet(value, setState);
                                    }
                                  },
                                  items: widget.obj.networkModel.map((NetworkModel user){
                                    return DropdownMenuItem<NetworkModel>(value: user, child: Text(user.network, style: TextStyle(color: Colors.black),),);
                                  }).toList(),
                                )
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10, right: 20, left: 20),
                              child: Text(
                                Language.scan_copy,
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 5,),
                            showprogress3 ?
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
                            ) : Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 20.0,
                                ),
                                walletAddress =="" || (item !=null && item!.deposit_status=="0")?
                                Container() :
                                cacheNetworkImage(
                                  fit: BoxFit.fill,
                                  imgUrl: 'https://chart.googleapis.com/chart?chs=230x230&cht=qr&chl=${walletAddress}&choe=UTF-8',
                                  height: 200,
                                  width: 200,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
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
                            ): error3 ?
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
                                      child: Text('$errormsg3', style: TextStyle(color: kPrimaryColor, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,),
                                    ),
                                  ]),
                            ):
                            walletAddress =="" ?
                            Container() :
                            Container(
                              padding: EdgeInsets.all(5.00),
                              margin: EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: yellow50,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: walletAddress));
                                  Toast.show("Address copied!", duration: Toast.lengthLong, gravity: Toast.bottom);
                                },
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(left: 10.00),
                                        child: Text('$walletAddress', style: TextStyle(color: kPrimaryColor, fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,),
                                      ), // icon for error message
                                      Container(
                                          margin: EdgeInsets.only(left: 10.00),
                                          child: Icon(Icons.copy, color: kPrimaryColor)),
                                    ]),
                              ),
                            ),
                            SizedBox(height: 3,),
                            item==null? SizedBox() : errmsg('Send only ${item!.currency} to this address.\nEnsure the network is ${item!.network}.\nDo not send NFTs to this address', false, context),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(height: 10,),
                            SizedBox(height: 20,),
                          ],
                        )));
              });
        },
        context: context);
  }


  _sendToUser(BuildContext context) {
    TextEditingController CryptoAmountController=TextEditingController();
    TextEditingController USDAmountController=TextEditingController();
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
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppBarDefault(context, "Send ${widget.obj.networkModel[0].currency}"),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          margin:
                          EdgeInsets.only(top: 20, right: 20, left: 20),
                          height: 60,
                          child: SizedBox(
                            height: 60,
                            child: TextField(
                              controller: sendController,
                              keyboardType: TextInputType.text,
                              readOnly: readOnly,
                              decoration: InputDecoration(
                                fillColor: kSecondary,
                                filled: true,
                                hintText:Language.username,
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                address = value;
                              },
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                          height: 50,
                          child: SizedBox(
                            height: 50,
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              controller: CryptoAmountController,
                              decoration: InputDecoration(
                                fillColor: kSecondary,
                                filled: true,
                                hintText: Language.amount+" (${widget.obj.networkModel[0]
                                    .currency_symbol})",
                                //suffixIcon: Icon(Icons.input),
                                suffix: InkWell(
                                  onTap: (){
                                    setState(() {
                                      double val=double.parse(widget.obj.balance.replaceAll(",", ""))*double.parse(widget.obj.networkModel[0]
                                          .price.replaceAll(",", ""));
                                      var amt=format("$val", "2");
                                      USDAmountController.text="$amt";
                                      CryptoAmountController.text="${widget.obj.balance.replaceAll(",", "")}";
                                    });
                                    cryptoamount = widget.obj.balance.replaceAll(",", "");
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    padding: EdgeInsets.all(5),
                                    margin: EdgeInsets.only(top: 10, bottom: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: yellow50,
                                    ),
                                    child: Center(
                                      child: Text("Max: ${widget.obj.balance} ${widget.obj.networkModel[0]
                                          .currency_symbol}", style: TextStyle(color: kPrimaryColor, fontSize: 10),),
                                    ),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  double val=double.parse(value.replaceAll(",", ""))*double.parse(widget.obj.networkModel[0]
                                      .price.replaceAll(",", ""));
                                  USDAmountController.text=format("$val", "2");
                                  cryptoamount = "$value";
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        widget.obj.networkModel.first.currency_symbol=="USDT" ?
                        Container() :
                        Container(
                          margin:
                          EdgeInsets.only(top: 20, right: 10, left: 20),
                          child: Text(Language.amount+" in (USD)"),
                        ),
                        widget.obj.networkModel.first.currency_symbol=="USDT" ?
                        Container() :
                        Container(
                          margin:
                          EdgeInsets.only(top: 10, right: 20, left: 20),
                          height: 60,
                          child: SizedBox(
                            height: 60,
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              controller: USDAmountController,
                              decoration: InputDecoration(
                                fillColor: kSecondary,
                                filled: true,
                                hintText: Language.amount+" in (USD)",
                                isDense: true,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  var val=double.parse(value.replaceAll(",", ""))/double.parse(widget.obj.networkModel[0].price.replaceAll(",", ""));
                                  var amt=format("$val", widget.obj.networkModel[0].decimals);
                                  CryptoAmountController.text="$amt";
                                  cryptoamount = "$val";
                                });
                                amount = value;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            child: Padding(
                                padding: EdgeInsets.only(
                                    top: 20, right: 20, left: 20, bottom: 25),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor,
                                    minimumSize: Size.fromHeight(
                                        50), // fromHeight use double.infinity as width and 40 is the height
                                  ),
                                  child: Text(
                                    Language.send,
                                    style: TextStyle(
                                        color: kSecondary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () async {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    username = prefs.getString("username")!;
                                    token = prefs.getString("token")!;
                                    pin = prefs.getString("pin")!;
                                    if(double.parse(CryptoAmountController.text.replaceAll(",", ""))>0){
                                      _confirm2(context, CryptoAmountController.text, json.encode({
                                        'username': username,
                                        'amount': cryptoamount,
                                        'currency_symbol': widget.obj.networkModel[0].currency_symbol,
                                        'wallet_id': widget.obj.id,
                                        'customer_id': address,
                                        'payment_id': Uuid().v4(),
                                        'pin': pin}), "/send-crypto");
                                    }
                                  },
                                ))),
                      ],
                    )),
              );
            });
      },
    );
  }

  _sendToAddress(BuildContext context) {
    TextEditingController CryptoAmountController=TextEditingController();
    TextEditingController USDAmountController=TextEditingController();
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
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppBarDefault(context, Language.send+" ${widget.obj.networkModel[0].currency}"),
                        SizedBox(
                          height: 40,
                        ),
                        networkItem !=null && networkItem!.withdraw_status.contains("0") ?
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
                                  child: Text('Withdraw currently disabled for this network', style: TextStyle(color: kPrimaryColor, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,),
                                ),
                              ]),
                        ) : SizedBox(),
                        Container(
                            padding: EdgeInsets.all(1),
                            margin: EdgeInsets.only(top: 20, left: 20, right: 20),
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
                                  hintText: Language.select_network,
                                  hintStyle: TextStyle(color: Colors.grey[800], fontSize: 2),
                                  fillColor: kSecondary
                              ),
                              hint: Text(Language.select_network),
                              onChanged: (NetworkModel? value){
                                setState(() {
                                  networkItem=value!;
                                });
                              },
                              items: widget.obj.networkModel.map((NetworkModel user){
                                return DropdownMenuItem<NetworkModel>(value: user, child: Text(user.network, style: TextStyle(color: Colors.black),),);
                              }).toList(),
                            )
                        ),
                        Container(
                          margin:
                          EdgeInsets.only(top: 20, right: 20, left: 20),
                          height: 60,
                          child: SizedBox(
                            height: 60,
                            child: TextField(
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                fillColor: kSecondary,
                                filled: true,
                                hintText: Language.address,
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                address = value;
                              },
                            ),
                          ),
                        ),
                        Container(
                          margin:
                          EdgeInsets.only(top: 20, right: 20, left: 20),
                          height: 50,
                          child: SizedBox(
                            height: 50,
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              controller: CryptoAmountController,
                              decoration: InputDecoration(
                                fillColor: kSecondary,
                                filled: true,
                                hintText: Language.amount+" (${widget.obj.networkModel[0]
                                    .currency_symbol})",
                                //suffixIcon: Icon(Icons.input),
                                suffix: InkWell(
                                  onTap: (){
                                    setState(() {
                                      var val=double.parse(widget.obj.balance.replaceAll(",", ""))*double.parse(widget.obj.networkModel[0].price.replaceAll(",", ""));
                                      var amt=format("$val", "2");
                                      USDAmountController.text="$amt";
                                      CryptoAmountController.text="${widget.obj.balance.replaceAll(",", "")}";
                                      cryptoamount = widget.obj.balance.replaceAll(",", "");
                                    });
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    padding: EdgeInsets.all(5),
                                    margin: EdgeInsets.only(top: 10, bottom: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: yellow50,
                                    ),
                                    child: Center(
                                      child: Text("Max: ${widget.obj.balance} ${widget.obj.networkModel[0]
                                          .currency_symbol}", style: TextStyle(color: kPrimaryColor, fontSize: 10),),
                                    ),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  double val=double.parse(value.replaceAll(",", ""))*double.parse(widget.obj.networkModel[0]
                                      .price.replaceAll(",", ""));
                                  USDAmountController.text=format("$val", "2");
                                  cryptoamount = "$value";
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        widget.obj.networkModel.first.currency_symbol=="USDT" ?
                        Container() :
                        Container(
                          margin:
                          EdgeInsets.only(top: 20, right: 10, left: 20),
                          child: Text(Language.amount+" in (USD)"),
                        ),
                        widget.obj.networkModel.first.currency_symbol=="USDT" ?
                        Container() :
                        Container(
                          margin: EdgeInsets.only(top: 10, right: 20, left: 20),
                          height: 60,
                          child: SizedBox(
                            height: 60,
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              controller: USDAmountController,
                              decoration: InputDecoration(
                                fillColor: kSecondary,
                                filled: true,
                                hintText: Language.amount+" in (USD)",
                                isDense: true,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  var val=double.parse(value.replaceAll(",", ""))/double.parse(widget.obj.networkModel[0].price.replaceAll(",", ""));
                                  var amt=format("$val", widget.obj.networkModel[0].decimals);
                                  CryptoAmountController.text="$amt";
                                  cryptoamount = "$val";
                                });
                                amount = value;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            child: Padding(padding: EdgeInsets.only(
                                top: 20, right: 20, left: 20, bottom: 25),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor,
                                    minimumSize: Size.fromHeight(
                                        50),),
                                  child: Text(
                                    Language.send,
                                    style: TextStyle(
                                        color: kSecondary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () async {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    username = prefs.getString("username")!;
                                    token = prefs.getString("token")!;
                                    pin = prefs.getString("pin")!;
                                    if(double.parse(CryptoAmountController.text)>0 && networkItem!.withdraw_status.contains("1")){
                                      _confirm(context, CryptoAmountController.text, json.encode({
                                        'username': username,
                                        'amount': cryptoamount,
                                        'currency_symbol': widget.obj.networkModel[0].currency_symbol,
                                        'wallet_id': widget.obj.id,
                                        'network_id': networkItem!.network_id,
                                        'customer_id': address,
                                        'payment_id': Uuid().v4(),
                                        'pin': pin}), "/withdraw-crypto");
                                    }
                                  },
                                ))),
                        SizedBox(height: 20,),
                      ],
                    )),
              );
            });
      },
    );
  }


  _send(BuildContext context) {
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
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppBarDefault(context, Language.choose_sending_method),
                        SizedBox(
                          height: 40,
                        ),
                        TransferMenu(
                          text: Language.external_wallet,
                          desc: Language.external_wallet_desc,
                          icon: "assets/images/send.svg",
                          press: () => {
                            Navigator.of(context).pop(),
                            _sendToAddress(context)
                          },
                        ),
                        TransferMenu(
                          text: Language.internal_wallet,
                          desc: Language.internal_wallet_desc,
                          icon: "assets/images/send.svg",
                          press: () => {
                            Navigator.of(context).pop(),
                            _sendToUser(context)
                          },
                        ),
                        SizedBox(height: 20,),
                      ],
                    )),
              );
            });
      },
    );
  }



  _confirm(BuildContext context, String amount, body, url) {
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
                                      amount+ " ${widget.obj.networkModel.first.currency_symbol}",
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
                                      "To",
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
                                      address,
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
                                      "${(double.parse(amount.replaceAll(",", ""))*double.parse(widget.obj.networkModel.first.withdraw_fee.replaceAll(",", ""))/100)+double.parse(widget.obj.networkModel[0].withdraw_fee_fixed.replaceAll(",", ""))}"+" ${widget.obj.networkModel.first.currency_symbol}",
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
                                    child: Text(format("${double.parse(amount.replaceAll(",", ""))-((double.parse(amount.replaceAll(",", ""))*double.parse(widget.obj.networkModel.first.withdraw_fee.replaceAll(",", ""))/100)+double.parse(widget.obj.networkModel[0].withdraw_fee_fixed.replaceAll(",", "")))}", "2"),
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
                                Language.confirm,
                                style: TextStyle(
                                    color: kSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            Pin(context, amount +
                                " ${widget.obj.networkModel.first
                                    .currency_symbol}", body, url, Language.withdraw, setState);
                          },),
                      ],
                    )),
              );
            });
      },
    );
  }





  _confirm2(BuildContext context, String amount, body, url) {
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
                                      amount+ " ${widget.obj.networkModel.first.currency_symbol}",
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
                                      "To",
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
                                      address,
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
                                      "${widget.obj.networkModel[0].user_user_fixed.replaceAll(",", "")} ${widget.obj.networkModel.first.currency_symbol}",
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
                                    child: Text(format("${double.parse(amount.replaceAll(",", ""))-double.parse(widget.obj.networkModel[0].user_user_fixed.replaceAll(",", ""))}", "2")+" ${widget.obj.networkModel.first.currency_symbol}",
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
                                Language.confirm,
                                style: TextStyle(
                                    color: kSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            Pin(context, amount +
                                " ${widget.obj.networkModel.first
                                    .currency_symbol}", body, url, Language.withdraw, setState);
                          },),
                      ],
                    )),
              );
            });
      },
    );
  }



  chooseFiat(String type) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, setState) {
                cachedCryptos2(setState);
                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: kSecondary,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0)),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 30.0, top: 10.0, bottom: 10),
                                child: Text(
                                  Language.select_fiat,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          loading2 ? Container(
                              height: 300,
                              margin: EdgeInsets.only(top: 20),
                              child: Center(
                                  child: CircularProgressIndicator()))
                              :
                          aList!.length <= 0 ?
                          Container(
                            height: 80,
                            margin: EdgeInsets.all(20),
                            child: Center(
                              child: Text(Language.empty, style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: kPrimaryColor),),
                            ),
                          ) :
                          ListView.builder(
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.only(top: 0),
                              itemCount: aList!.length,
                              itemBuilder: (context, index) {
                                return getListItem(
                                    aList![index], index, context, type);
                              }),
                          SizedBox(height: 20,)
                        ]
                    ),
                  ),
                );
              });
        });
  }



  Container getListItem(CryptoModel obj, int index, BuildContext context, String type) {
    return Container(
      child: Card(
        color: kWhite,
        margin: EdgeInsets.only(bottom: 5, top: 5, left: 10, right: 10),
        child: InkWell(
          onTap: (){
            Navigator.of(context).pop();
            if(type=="buy"){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => BuyScreen(obj: widget.obj, fiat: obj))).whenComplete(() => (){
                fetch();
              });
            }else {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SellScreen(obj: widget.obj, fiat: obj))).whenComplete(() => (){
                fetch();
              });
            }
          },
          child: Container(
            padding: EdgeInsets.only(
                left: 5.0, right: 5, top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.20,
                    child: CircleAvatar(
                        maxRadius: 23,
                        minRadius: 23,
                        child: CachedNetworkImage(
                          imageUrl: obj.networkModel[0].img,
                          height: 45.0,
                          width: 45.0,
                        ),
                        backgroundColor: kSecondary),
                    padding: EdgeInsets.all(1.0),
                    decoration: BoxDecoration(
                      color: kSecondary, // border color
                      shape: BoxShape.circle,
                    )),
                Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.23,
                            child: Text(
                              obj.networkModel[0].currency,
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
                          SizedBox(height: 5,),
                          obj.type=="fiat" ?
                          Container(
                            width: MediaQuery.of(context).size.width*0.23,
                            child: Text(
                              obj.networkModel.first.currency_symbol+obj.networkModel[0].price+"/\$",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ) :
                          Container(
                            width: MediaQuery.of(context).size.width*0.23,
                            child: Text(
                              "\$" + obj.networkModel[0].price,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      Container(
                          padding: EdgeInsets.all(10),
                          width: 95,
                          decoration: BoxDecoration(
                            color: obj.networkModel[0].percentage_change.contains("-") ? Colors.red : Colors.green,
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: Center(
                            child: Text(
                              obj.networkModel[0].percentage_change.contains("-") ? ""+obj.networkModel[0].percentage_change+"%" : "+"+obj.networkModel[0].percentage_change+"%",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: kSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}