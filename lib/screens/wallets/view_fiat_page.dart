import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../helper/formatter.dart';
import '../../language.dart';
import '../../models/transactions_model.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';
import '../../components/get_products.dart';
import '../../constants.dart';
import '../../helper/networklayer.dart';
import '../../models/bills_model.dart';
import '../../models/crypto_model.dart';
import '../../radius.dart';
import '../../widgets/appbar.dart';
import '../../widgets/material.dart';
import '../../widgets/pin.dart';
import '../beneficiaries/beneficiaries_page.dart';
import '../services/services_page.dart';
import '../trade/buy_page.dart';
import '../trade/deposit_fiat_page.dart';
import '../trade/sell_page.dart';
import '../transactions/fiat_transactions_page.dart';
import '../transactions/transactions_page.dart';

class ViewFiat extends StatefulWidget {
  final CryptoModel obj;
  final String action;
  ViewFiat({required this.obj, required this.action});

  @override
  _ViewFiat createState() => _ViewFiat();
}

class Item{
  Item(this.name);
  final String name;
}

class _ViewFiat extends State<ViewFiat>  with SingleTickerProviderStateMixin {
  bool error=false, readOnly=false, visible=false, error2=false, wallet_button=false;
  String name="", email="";
  String username="", pin="", cryptoamount="", amount="", token="";
  String errormsg="";
  bool loading2=true, validated=false;
  String bankname="Wema", accountname="", fiatWallet="", address="", narration="", accountnumber="";
  List<CryptoModel> aList = List.empty(growable: true);

  final pageIndexNotifier = ValueNotifier<int>(0);
  TextEditingController sendController=TextEditingController();
  bool loading=true;
  List<TransactionsModel> list = List.empty(growable: true);
  List<TransactionsModel> olist = List.empty(growable: true);
  var _tabController;

  cachedList() async {
    List<TransactionsModel> iList = await getTransactionsCached();
    if (iList.isNotEmpty) {
      setState(() {
        loading = false;
        list = iList;
        olist = iList;
      });
    }
  }

  fetch() async {
    try{
      List<TransactionsModel> iList = await getTransactions(new http.Client(), widget.obj.networkModel.first.currency);
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

  cachedCryptos() async {
    List<CryptoModel> iList = await getCryptosCached();
    if(iList.isNotEmpty){
      setState(() {
        aList = iList;
        loading2=false;
      });
    }
  }

  fetchList() async {
    try{
      List<CryptoModel> iList = await getCryptos(http.Client());
      setState(() {
        aList = iList;
      });
    }catch(e){
    }
    setState(() {
      loading2=false;
    });

  }


  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bankname = prefs.getString("bankname")!;
      accountnumber = prefs.getString("accountnumber")!;
      accountname = prefs.getString("accountname")!;
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
                  Text(widget.obj.networkModel[0].currency+" ${Language.wallet}", maxLines: 2, style: TextStyle(color: kSecondary, fontSize: 25, fontWeight: FontWeight.bold),),
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
                                    Text(
                                      Language.balance+":",
                                      style: TextStyle(fontSize: 16,
                                          fontWeight: FontWeight.bold, color: kSecondary),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
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
                                                    "${widget.obj.networkModel.first.currency_symbol}${format(widget.obj.balance, "2")}",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: kSecondary,),
                                                  ) :
                                                  Text(
                                                    "${widget.obj.networkModel.first.currency_symbol} ****",
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
                                            margin: EdgeInsets.only(left: 20, bottom: 10),
                                            padding: EdgeInsets.only(top: 5),
                                            child: Text(Language.change_percentage+" ${widget.obj.networkModel[0].percentage_change}", style: TextStyle(color: kSecondary),),
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
                                          Navigator.of(context).push(
                                              MaterialPageRoute(builder: (context) => Services()));
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
                                                  color: Colors.redAccent, // border color
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.add, size: 30, color: kSecondary,),),
                                              Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                  "Pay Bills",
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
                                        onTap: () async {
                                          widget.obj.networkModel.first.network.toLowerCase().contains("bank")?
                                          _bankWithdraw(context) :
                                          _moncashWithdraw(context);
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
                                                child: Icon(Icons.arrow_upward, size: 30, color: kPrimaryColor,),),
                                              Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                  Language.withdraw,
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
                                          //Toast.show("Deposit currently unavailable for your Country.", duration: Toast.lengthLong, gravity: Toast.bottom);
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => DepositFiat(obj: widget.obj,)));
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
                                                  Language.deposit,
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
                                          _action("Sell "+widget.obj.networkModel.first.currency_symbol+" to");
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
                                        ),
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
                      padding: EdgeInsets.all(0),
                      tabs: <Tab>[
                        Tab(
                          text: Language.fiat_deposits,
                        ),
                        Tab(
                          text: Language.fiat_withdrawals,
                        ),
                        Tab(
                          text: Language.bills,
                        ),
                      ],
                      controller: _tabController,
                    ),
                    SizedBox(height: 10,),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: <Widget>[
                          new Transactions(loading: loading, tList: list.isEmpty?[]:list.first.fiat_deposit),
                          new Transactions(loading: loading, tList: list.isEmpty?[]:list.first.fiat_withdraw),
                          new FiatTransactions(loading: loading, tList: list.isEmpty?[]:list.first.bills),
                        ],
                      ),
                    )
                  ],
                )
            ),
            SizedBox(height: 40,),
          ],
        ),
      ),);
  }


  _action(String title) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        builder: (BuildContext context) {
          return  SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Container(
              padding: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: kSecondary,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    getSingleChildScrollView("$title"),
                  ]),
            ),
          );
        });
  }
  Widget getSingleChildScrollView(String title) {
    aList=aList.where((o) =>
    !o.type.toLowerCase()
        .contains("fiat")).toList();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 30.0, top: 10.0, bottom: 10),
                    child: Text(
                      '$title',
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
                  child: Text(Language.empty, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
                ),
              )
                  :
              ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 0),
                  itemCount: aList!.length,
                  itemBuilder: (context, index) {
                    return getListItem(
                        aList![index], index, context, title);
                  }),
              SizedBox(height: 20,)
            ]
        );
      },
    );
  }

  Container getListItem(CryptoModel obj, int index, BuildContext context, String title) {
    return Container(
      child: Card(
        color: kWhite,
        margin: EdgeInsets.only(bottom: 5, top: 5, left: 10, right: 10),
        child: InkWell(
          onTap: (){
            if(obj.type=="coin"){
             if(title.contains("Sell")){
               Navigator.of(context).push(MaterialPageRoute(builder: (context) => BuyScreen(obj: obj, fiat: widget.obj,))).whenComplete(() => fetch());
             }else{
               Navigator.of(context).push(MaterialPageRoute(builder: (context) => SellScreen(obj: obj, fiat: widget.obj))).whenComplete(() => fetch());
             }
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
                              "${widget.obj.networkModel.first.currency_symbol}"+obj.networkModel[0].price+"/\$",
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

  Bills? beneficiary;
  List<Bills> beneficiaries = Products().getProduct("beneficiaries");


  TextEditingController RecipientController = new TextEditingController();
  _bankWithdraw(BuildContext context) {
    TextEditingController CryptoAmountController=TextEditingController();
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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                    ),
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBarDefault(context, Language.withdraw+" to ${widget.obj.networkModel.first.network}"),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                        padding: EdgeInsets.all(1),
                        margin: EdgeInsets.only(top: 10, right: 20, left: 20),
                        alignment: Alignment.center,
                        height: 60,
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
                              hintStyle: TextStyle(color: Colors.grey[800],
                                  fontSize: 2),
                              fillColor: kSecondary
                          ),
                          hint: Text(Language.select_beneficiary),
                          value: beneficiary,
                          onChanged: (Bills? value) {
                            setState(() {
                              RecipientController.text = value!.size;
                              beneficiary = value;
                              name = value.amount;
                              accountnumber = value.size;
                              validated = true;
                              errormsg = name;
                            });
                          },
                          items: beneficiaries.map((Bills user){
                            return DropdownMenuItem<Bills>(value: user, child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:  MainAxisAlignment.start, children: [
                              Text(user.name+' - '+user.amount, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
                              Divider()
                            ],),);
                          }).toList(),
                        ),
                        ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin:
                      EdgeInsets.only(top: 20, right: 10, left: 20),
                      child: Text(Language.amount+" (${widget.obj.networkModel.first.currency_symbol})"),
                    ),
                    Container(
                      margin:
                      EdgeInsets.only(top: 20, right: 20, left: 20),
                      height: 60,
                      child: SizedBox(
                        height: 60,
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          controller: CryptoAmountController,
                          decoration: InputDecoration(
                            fillColor: kSecondary,
                            filled: true,
                            hintText: Language.amount+" (${widget.obj.networkModel.first.currency_symbol})",
                            //suffixIcon: Icon(Icons.input),
                            suffix: InkWell(
                              onTap: (){
                                setState(() {
                                  cryptoamount = widget.obj.balance;
                                  CryptoAmountController.text=widget.obj.balance;
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
                                child: Text("Max: ${widget.obj.balance} ${widget.obj.networkModel.first.currency_symbol}", style: TextStyle(color: kPrimaryColor, fontSize: 10),),
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
                              cryptoamount = value;
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
                                'Withdraw',
                                style: TextStyle(
                                    color: kSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                if(cryptoamount.isNotEmpty && beneficiary!=null){
                                  _confirm(context, "$cryptoamount "+widget.obj.networkModel.first.currency_symbol, json.encode({
                                    'customer_id': accountnumber,
                                    'username': username,
                                    'wallet_id': widget.obj.id,
                                    'currency_symbol': widget.obj.networkModel.first.currency_symbol,
                                    'amount': cryptoamount.replaceAll(",", ""),
                                    'customer_name': name,
                                    'bank_code': beneficiary!.plan,
                                    'payment_id': Uuid().v4(),
                                    'pin': pin}), "/withdraw-fiat");
                                }
                              },
                            ))),
                        SizedBox(height: 20),
                  ],
                )),
          );
        });
      },
    );
  }

  _moncashWithdraw(BuildContext context2) {
    TextEditingController CryptoAmountController=TextEditingController();
    showModalBottomSheet(
      isScrollControlled: true,
      context: context2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                    ),
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBarDefault(context, "Withdraw to ${widget.obj.networkModel.first.network}"),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      padding: EdgeInsets.all(1),
                      margin: EdgeInsets.only(top: 10, right: 20, left: 20),
                      alignment: Alignment.center,
                      height: 60,
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
                            hintStyle: TextStyle(color: Colors.grey[800],
                                fontSize: 2),
                            fillColor: kSecondary
                        ),
                        hint: Text(Language.select_beneficiary),
                        value: beneficiary,
                        onChanged: (Bills? value) {
                          setState(() {
                            RecipientController.text = value!.size;
                            beneficiary = value;
                            name = value.amount;
                            accountnumber = value.size;
                            error2 = true;
                            validated = true;
                            errormsg = name;
                          });
                        },
                        items: beneficiaries.map((Bills user){
                          return DropdownMenuItem<Bills>(value: user, child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:  MainAxisAlignment.start, children: [
                            Text(user.name+' - '+user.amount, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
                            Divider()
                          ],),);
                        }).toList(),
                      ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                      height: 60,
                      child: SizedBox(
                        height: 60,
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          controller: CryptoAmountController,
                          decoration: InputDecoration(
                            fillColor: kSecondary,
                            filled: true,
                            labelText: widget.obj.networkModel.first.currency_symbol,
                            hintText: Language.amount+" (${widget.obj.networkModel.first.currency_symbol})",
                            suffix: InkWell(
                              onTap: (){
                                setState(() {
                                  CryptoAmountController.text=widget.obj.balance;
                                  cryptoamount=widget.obj.balance;
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
                                child: Text("Max: ${widget.obj.balance} ${widget.obj.networkModel.first.currency_symbol}", style: TextStyle(color: kPrimaryColor, fontSize: 10),),
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
                              cryptoamount="$value";
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
                                'Withdraw',
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
                                if(cryptoamount.isNotEmpty && beneficiary!=null){
                                    _confirm(context, "$cryptoamount "+widget.obj.networkModel.first.currency_symbol, json.encode({
                                      'customer_id': accountnumber,
                                      'username': username,
                                      'wallet_id': widget.obj.id,
                                      'currency_symbol': widget.obj.networkModel.first.currency_symbol,
                                      'amount': cryptoamount.replaceAll(",", ""),
                                      'customer_name': name,
                                      'bank_code': beneficiary!.plan,
                                      'payment_id': Uuid().v4(),
                                      'pin': pin}), "/withdraw-fiat");
                                  }
                              },
                            ))),
                          SizedBox(height: 20),
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
                                      cryptoamount+" ${widget.obj.networkModel.first.currency_symbol}",
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
                                      name,
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
                                      "${(double.parse(cryptoamount.replaceAll(",", ""))*double.parse(widget.obj.networkModel.first.withdraw_fee.replaceAll(",", ""))/100)+double.parse(widget.obj.networkModel[0].withdraw_fee_fixed.replaceAll(",", ""))}"+" ${widget.obj.networkModel.first.currency_symbol}",
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
                                  SizedBox(width: 20),
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.45,
                                    child: Text(
                                      format("${double.parse(cryptoamount.replaceAll(",", ""))-((double.parse(cryptoamount.replaceAll(",", ""))*double.parse(widget.obj.networkModel.first.withdraw_fee.replaceAll(",", ""))/100)+double.parse(widget.obj.networkModel[0].withdraw_fee_fixed.replaceAll(",", "")))}", "2")+" ${widget.obj.networkModel.first.currency_symbol}",
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
                            Pin(context, amount, body, url, Language.withdraw, setState);
                          },),
                      ],
                    )),
              );
            });
      },
    );
  }


}