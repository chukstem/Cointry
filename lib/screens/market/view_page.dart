import 'dart:async';
import 'package:crypto_app/models/markets_model.dart';
import 'package:crypto_app/screens/market/sell_page.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:crypto_market/Crypto_Market/Model/coin_model.dart';
import 'package:crypto_market/crypto_market.dart';
import '../../constants.dart';
import '../../helper/networklayer.dart';
import '../../language.dart';
import '../../models/crypto_model.dart';
import 'buy_page.dart';

class ViewMarket extends StatefulWidget {
  static String routeName = "/swap";
  MarketsModel market;
  ViewMarket({Key? key, required this.market}) : super(key: key);

  @override
  _ViewMarket createState() => _ViewMarket();
}

class _ViewMarket extends State<ViewMarket> {
  bool loading=true;
  List<Coin> coinsList = List.empty(growable: true);
  List<CryptoModel> firstList = List.empty(growable: true);
  List<CryptoModel> secondList = List.empty(growable: true);

  TextEditingController CryptoAmountController=new TextEditingController();
  TextEditingController CryptoAmountController2=new TextEditingController();


  cachedList() async {
    List<CryptoModel> iList = await getCryptosCached();
    setState(() {
      if (iList.isNotEmpty) {
        firstList = iList.where((o) => o.networkModel[0].currency_id==widget.market.prefix_currency_id).toList();
        secondList = iList.where((o) => o.networkModel[0].currency_id==widget.market.suffix_currency_id).toList();
      loading=false;
      }
    });
    updateCoins();
  }
  fetchList() async {
    try{
      List<CryptoModel> iList = await getCryptos(new http.Client());
      setState(() {
        if (iList.isNotEmpty) {
          firstList = iList.where((o) => o.networkModel[0].currency_id==widget.market.prefix_currency_id).toList();
          secondList = iList.where((o) => o.networkModel[0].currency_id==widget.market.suffix_currency_id).toList();
        }
      });

    }catch(e){
    }
    setState(() {
      loading=false;
    });
    updateCoins();
  }



  updateCoins() async {
    CryptoModel wb = firstList.first;
    CryptoModel wb2 = secondList.first;
    if(wb!=null && wb2!=null){
      setState(() {
        coinsList.add(Coin(
          id: '1',
          image: wb!.networkModel[0].img,
          name: wb!.networkModel[0].currency,
          shortName: wb!.networkModel[0].currency_symbol,
          price: wb!.networkModel[0].price,
          lastPrice: wb!.networkModel[0].price,
          percentage: "-0.5",
          symbol: wb!.networkModel[0].currency_symbol+wb2!.networkModel[0].currency_symbol,
          pairWith: wb2!.networkModel[0].currency_symbol,
          highDay: wb!.networkModel[0].high,
          lowDay: wb!.networkModel[0].low,
          decimalCurrency: 4,
        ),);
      });
    }
  }



  @override
  void initState() {
    super.initState();
    cachedList();
    Timer(Duration(seconds: 1), () =>
    {
      fetchList()
    });
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
        backgroundColor: Color(0xFFf2f2f2),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(0),
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0)),
              ),
              padding: EdgeInsets.only(top: 10),
              child: Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                              color: kPrimaryLightColor,
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0), topRight: Radius.circular(10.0), topLeft: Radius.circular(10.0)),
                            ),
                            margin: EdgeInsets.only(left: 15,),
                            padding: EdgeInsets.all(5),
                            alignment: Alignment.center,
                            child: InkWell(
                              child: Icon(
                                Icons.arrow_back,
                                color: kSecondary,
                                size: 22,
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            )
                        ),
                        Text(firstList.isNotEmpty && secondList.isNotEmpty? "${firstList.first!.networkModel.first.currency_symbol}/${secondList.first!.networkModel.first.currency_symbol}" : "Market", maxLines: 2, style: TextStyle(color: kSecondary, fontSize: 25, fontWeight: FontWeight.bold),),
                        Container(margin: EdgeInsets.only(right: 28),),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 20),
                      alignment: Alignment.bottomRight,
                      child: Text("High: ${widget.market.high}", style: TextStyle(color: kWhite, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 20),
                      alignment: Alignment.bottomRight,
                      child: Text("Low: ${widget.market.low}", style: TextStyle(color: kWhite, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 20),
                      alignment: Alignment.bottomRight,
                      child: Text("${widget.market.price}  ~ (${widget.market.percentage_change}%)", style: TextStyle(color: kWhite, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                )
              ),
            ),
            SizedBox(
              height: 10,
            ),
            firstList.isNotEmpty && secondList.isNotEmpty?
            Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
              padding: EdgeInsets.only(top: 6, left: 2, right: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  orderVolume(),
                ],
              ),
            ) : SizedBox(),
            SizedBox(height: 20,),
            /*
            firstList.isNotEmpty && secondList.isNotEmpty?
            Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 10),
              padding: EdgeInsets.only(top: 6, left: 2, right: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  tradeHistory(),
                ],
              ),
            ) : SizedBox(),
            */
          ],
        )),
    bottomSheet: Container(
      color: kSecondary,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => BuyScreen(from: firstList.first, to: secondList.first, market: widget.market)));
            },
            child: Container(
              margin: EdgeInsets.all(10),
              width: 90,
              height: 50,
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10),),
                color: Colors.green,),
              child: Center(child: Text(Language.buy, style: TextStyle(color: kSecondary),),),
            ),
          ),
          InkWell(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SellScreen(from: firstList.first, to: secondList.first, market: widget.market)));
            },
            child: Container(
              margin: EdgeInsets.all(10),
              width: 90,
              height: 50,
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.red,),
              child: Center(child: Text(Language.sell, style: TextStyle(color: kSecondary),),
            ),
          ),
          ),
        ],
      ),
    ),
    );
  }

  Widget candleChart() {
    return CandleChart(
      coinData: coinsList.elementAt(0),
      inrRate: 77.0,
      intervalSelectedTextColor: Colors.red,
      intervalTextSize: 20,
      intervalUnselectedTextColor: Colors.black,
    );
  }

  Widget lineChart() {
    return LineChart(
      coinData: coinsList.elementAt(0),
      inrRate: 77.0,
      intervalSelectedTextColor: Colors.red,
      intervalTextSize: 20,
      intervalUnselectedTextColor: Colors.black,
      chartBorderColor: Colors.green,
      showToolTip: false,
      showInterval: false,
      chartColor: LinearGradient(
        colors: [
          Colors.green.shade500.withOpacity(1),
          Colors.green.shade500.withOpacity(0.9),
          Colors.green.shade500.withOpacity(0.8),
          Colors.green.shade500.withOpacity(0.7),
          Colors.green.shade500.withOpacity(0.6),
          Colors.green.shade500.withOpacity(0.5),
          Colors.green.shade500.withOpacity(0.4),
          Colors.green.shade500.withOpacity(0.3),
          Colors.green.shade500.withOpacity(0.2),
          Colors.green.shade500.withOpacity(0.1),
          Colors.green.shade500.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      toolTipBgColor: Colors.green.shade900,
      toolTipTextColor: kSecondary,
    );
  }

  Widget orderVolume() {
    return OrderVolume(
      coinData: coinsList.elementAt(0),
      inrRate: 77.0,
    );
  }

  Widget tradeHistory() {
    return CoinTradeHistory(
      coinData: coinsList.elementAt(0),
      itemCount: 15,
      inrRate: 77,
    );
  }



  String format(String price){
    var value = price;
    if (price.length > 8) {
      value = value.substring(0, 8);
    }
    return value;
  }
}