import 'dart:async';
import 'package:crypto_app/screens/p2p/sell_screen.dart';
import 'package:easy_load_more/easy_load_more.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import 'package:http/http.dart' as http;
import '../../helper/networklayer.dart';
import '../../language.dart';
import '../../models/p2p_model.dart';
import '../../strings.dart';

class Sell extends StatefulWidget {
  final ValueNotifier clearCallback;
  Sell({Key? key, required this.clearCallback}) : super(key: key);

  @override
  _SellState createState() => _SellState();
}

class _SellState extends State<Sell> with SingleTickerProviderStateMixin {
  bool loading = true;
  String token = "", username = "", errormsg = "", amount="0", bank_id="1", sort="1";
  bool error = false, showprogress = false, success = false;
  List<P2PModel> tList = List.empty(growable: true);
  late TabController _tabController;
  String currency_id = "4";

  cachedList() async {
    List<P2PModel> iList = await getP2PCached(currency_id, "2");
    setState(() {
      if (iList.isNotEmpty) {
        loading = false;
        tList = iList;
      }
    });
  }

  fetch() async {
    try {
      List<P2PModel> iList = await getP2P(http.Client(), "0", currency_id, amount, bank_id, "2", sort);
      setState(() {
        tList = iList;
      });
    } catch (e) {}
    setState(() {
      loading = false;
    });
  }

  bool stopRefresh = false;

  addItems() async {
    int length = tList.length + 100;
    try {
      List<P2PModel> iList = await getP2P(http.Client(), "$length", currency_id, amount, bank_id, "2", sort);
      setState(() {
        tList.addAll(iList);
        if (iList.isEmpty) {
          stopRefresh = true;
        }
      });
    } catch (e) {
    }
    setState(() {
      loading = false;
    });
  }

  Future<bool> _loadMore() async {
    await Future.delayed(
      Duration(
        seconds: 0,
        milliseconds: 2000,
      ),
    );

    if (stopRefresh == false) {
      addItems();
    }
    return true;
  }


  getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username")!;
      token = prefs.getString("token")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getuser();
    _tabController = TabController(vsync: this, length: 4);
    cachedList();
    Timer(Duration(seconds: 1), () =>
    {
      fetch(),
    });
    widget.clearCallback.addListener(() {
      query();
    });
  }

  query() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    amount = prefs.getString("temp_amount")!;
    sort=prefs.getString("temp_sort")!;
    bank_id=prefs.getString("temp_payment_method")!;
    if(double.parse(amount)>0) {
      setState(() {
        loading = true;
      });
      try {
        List<P2PModel> iList = await getP2P(http.Client(), "0", currency_id, amount, bank_id, "2", sort);
        setState(() {
          tList = iList;
        });
      } catch (e) {}
      setState(() {
        loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () {
          return fetch();
        },
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: TabBar(
                indicatorPadding: EdgeInsets.only(left: 10, right: 10),
                unselectedLabelStyle: TextStyle(color: Colors.black),
                labelColor: kPrimaryDarkColor,
                labelPadding: EdgeInsets.only(left: 10, right: 10),
                indicatorColor: kPrimaryDarkColor,
                labelStyle: TextStyle(color: kPrimaryDarkColor, fontWeight: FontWeight.bold),
                padding: EdgeInsets.all(0),
                //tabAlignment: TabAlignment.start,
                controller: _tabController,
                onTap: (value) {
                  setState(() {
                    currency_id=_getCurrencyID();
                    loading=true;
                    fetch();
                  });
                },
                tabs: <Tab>[
                  Tab(
                    text: "USDT",
                  ),
                  Tab(
                    text: "BTC",
                  ),
                  Tab(
                    text: "ETH",
                  ),
                  Tab(
                    text: "BNB",
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              height: 700,
              child: getTabView(),
            ),
          ],
        )
    );
  }


  Widget getTabView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(0),
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          loading ? Container(
              margin: EdgeInsets.all(50),
              child: Center(
                  child: CircularProgressIndicator()))
              :
          tList!.length <= 0 ?
          Container(
            height: 200,
            margin: EdgeInsets.all(20),
            child: Center(
              child: Text(Language.empty, style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: kPrimaryColor),),
            ),
          )
              :
          Column(
            children: <Widget>[
              EasyLoadMore(
                isFinished: tList!.length < 30 || tList!.length >= 500 ||
                    stopRefresh,
                onLoadMore: _loadMore,
                runOnEmptyResult: false,
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 0),
                    itemCount: tList!.length,
                    itemBuilder: (context, i) {
                      return Card(
                        margin: EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        color: kSecondary,
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.70,
                                margin: EdgeInsets.only(left: 10,
                                    right: 10,
                                    top: 10,
                                    bottom: 5),
                                alignment: Alignment.topLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: Text(
                                        tList![i].user.first
                                            .first_name + " " +
                                            tList![i].user.first
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
                                    tList![i].user.first.rank == "0" ?
                                    SizedBox() :
                                    tList![i].user.first.rank == "1" ?
                                    Icon(Icons.verified_user,
                                      color: kPrimaryLightColor,
                                      size: 10,) :
                                    Icon(Icons.star,
                                      color: tList![i].user.first
                                          .rank == "3"
                                          ? Colors.orangeAccent
                                          : kPrimaryVeryLightColor,
                                      size: 10,),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    left: 10, right: 10),
                                child: Text(
                                  tList![i].time,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black45,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Text(
                                      tList![i].user.first.trades+" Trades",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black45,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 15,),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Text(
                                      tList![i].avg_speed,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black45,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],),
                              Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)),
                                  color: kSecondary,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 5),
                                      child: Text(
                                        "Rate: "+tList![i].fiat_symbol + tList![i].amountRate,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.black45,
                                            fontWeight: FontWeight.bold
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Text(
                                        tList![i].paymentMethod,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.black45,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                margin: EdgeInsets.only(left: 3, right: 3),
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)),
                                  color: kWhite,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .start,
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Text(
                                            "Crypto Amount: " +
                                                tList![i].amountCrypto,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black45,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Text(
                                            "Limit: "+tList![i].fiat_symbol + tList![i].amountMin +
                                                " - "+tList![i].fiat_symbol + tList![i].amountMax,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black45,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        final result = await Navigator.push(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => P2PSellScreen(obj: tList![i],)));
                                        setState(() {
                                          fetch();
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        width: 95,
                                        margin: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            Language.sell,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: kSecondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrencyID() {
    switch (_tabController.index) {
      case 0:
        return "4";
      case 1:
        return "1";
      case 2:
        return "14";
      case 3:
        return "9";
      default:
        return "4";
    }
  }

}