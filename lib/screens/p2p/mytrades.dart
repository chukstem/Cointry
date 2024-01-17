import 'dart:async';
import 'package:crypto_app/models/trading_model.dart';
import 'package:crypto_app/models/user_model.dart';
import 'package:easy_load_more/easy_load_more.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import 'package:http/http.dart' as http;
import '../../helper/networklayer.dart';
import '../../language.dart';
import '../../strings.dart';
import '../profile/user_profile_screen.dart';
import 'detail_mytrades_screen.dart';

class MyTrades extends StatefulWidget {
  MyTrades({Key? key}) : super(key: key);

  @override
  _MyTradesState createState() => _MyTradesState();
}

class _MyTradesState extends State<MyTrades> with SingleTickerProviderStateMixin {
  bool loading = true;
  String token = "", username = "", errormsg = "", amount = "0", type="1";
  bool error = false, showprogress = false, success = false;
  List<TradingModel> tList = List.empty(growable: true);
  late TabController _tabController;

  cachedList() async {
    List<TradingModel> iList = await getTradingsCached(type);
    setState(() {
      if (iList.isNotEmpty) {
        loading = false;
        tList = iList;
      }
    });
  }

  fetch() async {
    try {
      List<TradingModel> iList = await getTradings(http.Client(), "0", type);
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
      List<TradingModel> iList = await getTradings(http.Client(), "$length", type);
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
    _tabController = TabController(vsync: this, length: 2);
    cachedList();
    Timer(Duration(seconds: 1), () =>
    {
      fetch(),
    });
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
                unselectedLabelStyle: TextStyle(color: Colors.white70),
                labelColor: kPrimaryDarkColor,
                labelPadding: EdgeInsets.only(left: 10, right: 10),
                indicatorColor: kPrimaryDarkColor,
                labelStyle: TextStyle(color: kPrimaryDarkColor, fontWeight: FontWeight.bold),
                padding: EdgeInsets.all(0),
                controller: _tabController,
                onTap: (value) {
                  setState(() {
                    type=_getTabID();
                    loading=true;
                    cachedList();
                    fetch();
                  });
                },
                tabs: [
                  Container(width: MediaQuery.of(context).size.width*0.50,
                    child: Tab(
                      text: "Running",
                    ),),
                  Container(width: MediaQuery.of(context).size.width*0.50,
                    child: Tab(
                      text: Language.completed,
                    ),),
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
                      UserModel user=tList[i].buyer.first.username==username? tList[i].seller.first : tList[i].buyer.first;
                      return Card(
                        margin: EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        color: kSecondary,
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => P2PDetailScreen(obj: tList[i],)));
                            setState(() {
                              fetch();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      child: Text(
                                        tList[i].type+" " +
                                            tList[i].currency_symbol,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 22.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: (){
                                        Navigator.push(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => UserProfile(user: user,)));
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: kWhite,
                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                        ),
                                        child: Text("@" +
                                            user.username,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: kPrimaryDarkColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Text(
                                    tList![i].time,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: kPrimaryDarkColor,
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
                                    "${Language.price}: "+tList![i].fiat_symbol+tList![i].amountRate,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: kPrimaryDarkColor,
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
                                    "${Language.amount}: "+tList![i].amountCrypto,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: kPrimaryDarkColor,
                                        fontWeight: FontWeight.bold
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.only(left: 3, right: 3),
                                  padding: EdgeInsets.all(5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        width: 95,
                                        margin: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: kWhite,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                        ),
                                        child: Center(
                                          child: tList[i].status=="0" ?
                                          Text(
                                            Language.pending,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: yellow100,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ) : tList[i].status=="1" ?
                                          Text(
                                            Language.completed,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ) : tList[i].status=="2" ?
                                          Text(
                                            "Paid",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ) :  tList[i].status=="8" ?
                                          Text(
                                            Language.disputed,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ) :
                                          Text(
                                            Language.cancelled,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Text(
                                          "Window: "+tList![i].window+" Minutes",
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
                                ),
                              ],
                            ),
                          ),
                        )
                      );
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTabID() {
    switch (_tabController.index) {
      case 0:
        return "1";
      case 1:
        return "2";
      default:
        return "1";
    }
  }

}