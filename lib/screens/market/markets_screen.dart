import 'package:crypto_app/screens/market/view_page.dart';
import 'package:crypto_app/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../constants.dart';
import '../../../helper/networklayer.dart';
import '../../../models/bills_model.dart';
import '../../components/get_products.dart';
import '../../language.dart';
import '../../models/markets_model.dart';

class MarketsScreen extends StatefulWidget {
  static String routeName = "/markets";
  MarketsScreen({Key? key}) : super(key: key);

  @override
  _MarketsScreen createState() => _MarketsScreen();
}


class Item{
  Item(this.name);
  final String name;
}

class _MarketsScreen extends State<MarketsScreen> {
  String errormsg="";
  bool error=false, showprogress=false, wallet_button=false, success=false;
  String name="", email="";
  String username="", bankname="",  bankname2="", customerid="", accountname="", pin="", quantity="", iuc="", mybrowser="", number="", meter="", accountnumber="",  accountnumber2="", amount="", token="";

  int maxRenderAvatar = 5;
  double size = 30;
  double borderSize = 5;
  List<MarketsModel> mList = List.empty(growable: true);
  bool loading = true;
  final pageIndexNotifier = ValueNotifier<int>(0);

  Bills? currency;
  List<Bills> currencies=Products().getCurrencies();
  List<Bills> new_currencies = List.empty(growable: true);


  cachedMarketList() async {
    List<MarketsModel> marketlist = await getMarketsCached();
    if(marketlist.isNotEmpty){
      setState(() {
        loading=false;
        mList = marketlist;
      });
    }
  }

  fetchMarketList() async {
    try{
      List<MarketsModel> marketlist = await getMarkets(new http.Client());
      if(marketlist.isNotEmpty){
        setState(() {
          mList = marketlist;
        });
      }
      setState(() {
        loading=false;
      });
    }catch(e){
      setState(() {
        loading=false;
      });
    }
  }



  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var fname = prefs.getString("firstname");
      var lname = prefs.getString("lastname");
      name = "$fname $lname";
      email = prefs.getString("email")!;
      username = prefs.getString("username")!;
      bankname = prefs.getString("bankname")!;
      accountnumber = prefs.getString("accountnumber")!;
      accountname = prefs.getString("accountname")!;
      token = prefs.getString("token")!;
    });
  }

  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    //Get.offAllNamed(AppLinks.WELCOME);
  }

  fetchQuery() async {
    await getQuery(http.Client());
    getuser();
  }

  @override
  void initState() {
    super.initState();
    getuser();
    cachedMarketList();
    Timer(Duration(seconds: 1), () =>
    {
      fetchQuery(),
      fetchMarketList(),
    });
  }

  int counter = 0;


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: kSecondary,
      body: RefreshIndicator(
        onRefresh: () {
          return fetchMarketList();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20,),
              backAppbar(context, "Markets"),
              loading ? Container(
                  height: 300,
                  margin: EdgeInsets.only(top: 50),
                  child: Center(
                      child: CircularProgressIndicator()))
                  :
              mList.length <= 0 ?
              Container(
                height: 150,
                margin: EdgeInsets.all(20),
                child: Center(
                  child: Text(Language.empty, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
                ),
              )
                  :
              Container(
                padding: EdgeInsets.only(top: 20),
                color: kSecondary,
                constraints: BoxConstraints(
                    minHeight: 600, minWidth: double.infinity),
                child:  Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            width: MediaQuery.of(context).size.width*0.30,
                            child: Text(Language.market_pair, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kPrimaryColor),),
                          ),
                          Container(
                            padding: EdgeInsets.all(15),
                            width: MediaQuery.of(context).size.width*0.20,
                            child: Text(Language.price, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kPrimaryColor),),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 15, bottom: 15, left: 25, right: 25),
                            width: MediaQuery.of(context).size.width*0.30,
                            child: Text(Language.change_percentage, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kPrimaryColor),),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 0),
                        itemCount: mList.length,
                        itemBuilder: (context, index) {
                          return getMarketItem(
                              mList[index], context);
                        })
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container getMarketItem(MarketsModel obj, BuildContext context) {
    return Container(
      child: Card(
        margin: EdgeInsets.only(
          bottom: 5,
          top: 5,
          left: 10,
          right: 10,
        ),
        child: InkWell(
          onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewMarket(market: obj)));
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
                        .width * 0.15,
                    child: new CircleAvatar(
                        maxRadius: 23,
                        minRadius: 23,
                        child: CachedNetworkImage(
                          imageUrl: obj.img,
                          height: 35.0,
                          width: 35.0,
                        ),
                        backgroundColor: kSecondary),
                    padding: EdgeInsets.all(1.0),
                    decoration: new BoxDecoration(
                      color: kSecondary, // border color
                      shape: BoxShape.circle,
                    )),
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  child: Text(
                    obj.pair,
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
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  child: Text(
                    "\$" + obj.price,
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
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                    color: obj.percentage_change.contains("-") ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Text(
                    obj.percentage_change.contains("-") ? ""+obj.percentage_change+"%" : "+"+obj.percentage_change+"%",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: kSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
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