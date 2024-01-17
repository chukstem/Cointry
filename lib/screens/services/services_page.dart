import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:toast/toast.dart';
import '../../constants.dart';
import '../../radius.dart';
import '../../widgets/appbar.dart';
import '../../widgets/material.dart';
import '../bills/airtime_page.dart';
import '../bills/bet_page.dart';
import '../bills/cable_page.dart';
import '../bills/data_page.dart';
import '../bills/electricity_page.dart';

class Services extends StatefulWidget {
  Services({Key? key}) : super(key: key);

  @override
  _Services createState() => _Services();
}


class _Services extends State<Services> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryDarkColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    ToastContext().init(context);
    String assetElectricity = 'assets/images/electricity.svg';
    String assetAirtime = 'assets/images/airtime.svg';
    String assetData = 'assets/images/data.svg';
    String assetCable = 'assets/images/cable.svg';
    String assetBet = 'assets/images/betting.svg';
    String assetInternet = 'assets/images/internet.svg';
    return Scaffold(
        backgroundColor: Color(0xFFf2f2f2),
        body: Container(
            width: MediaQuery.of(context).size.width,
            constraints: BoxConstraints(
                minHeight: 500, minWidth: double.infinity),
            child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    backAppbar(context, "Pay Bills"),
                    SizedBox(height: 20,),
                    Padding(padding: EdgeInsets.only(left: 30),
                      child: Text("Explore our range of services designed to simplify your life.", style: TextStyle(fontSize: 14, color: Colors.black45),),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.of(context).push(
                                CupertinoPageRoute(builder: (context) => Airtime()));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.40,
                            height: 170,
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: circularRadius(AppRadius.border12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10,),
                                SvgPicture.asset(
                                  assetAirtime,
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(height: 10,),
                                Text("Buy Airtime", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[600]),),
                                SizedBox(height: 10,),
                                Text("Topup your mobile number easily. Mtn, Airtel, Glo & 9mobile.", style: TextStyle(fontSize: 12, color: Colors.black),),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            Navigator.of(context).push(
                                CupertinoPageRoute(builder: (context) => Data()));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.40,
                            height: 170,
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: circularRadius(AppRadius.border12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10,),
                                SvgPicture.asset(
                                  assetData,
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(height: 10,),
                                Text("Buy Data", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[600]),),
                                SizedBox(height: 10,),
                                Text("Buy Cheap Mtn, Airtel, Glo & 9mobile data bundles.", style: TextStyle(fontSize: 12, color: Colors.black),),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.of(context).push(
                                CupertinoPageRoute(builder: (context) => Cable()));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.40,
                            height: 170,
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: circularRadius(AppRadius.border12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10,),
                                SvgPicture.asset(
                                  assetCable,
                                  width: 24,
                                  height: 24,
                                  color: Colors.black,
                                ),
                                SizedBox(height: 10,),
                                Text("Pay Cable", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),),
                                SizedBox(height: 10,),
                                Text("Recharge your DSTV, GOTV, Startimes decoder at a go.", style: TextStyle(fontSize: 12, color: Colors.black),),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            Navigator.of(context).push(
                                CupertinoPageRoute(builder: (context) => Electricity()));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.40,
                            height: 170,
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              borderRadius: circularRadius(AppRadius.border12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10,),
                                SvgPicture.asset(
                                  assetElectricity,
                                  width: 24,
                                  height: 24,
                                  color: Colors.black,
                                ),
                                SizedBox(height: 10,),
                                Text("Pay Electricity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple),),
                                SizedBox(height: 10,),
                                Text("Topup your Electricity. BEDC, IEDC, KEDCO, AEDC e.t.c", style: TextStyle(fontSize: 12, color: Colors.black),),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.of(context).push(
                                CupertinoPageRoute(builder: (context) => Bet()));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.40,
                            height: 170,
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: circularRadius(AppRadius.border12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10,),
                                SvgPicture.asset(
                                  assetBet,
                                  width: 24,
                                  height: 24,
                                  color: Colors.black,
                                ),
                                SizedBox(height: 10,),
                                Text("Pay Bet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),),
                                SizedBox(height: 10,),
                                Text("Topup your Bet9ja, Betking, SupaBet, BetWay, MerryBet e.t.c. ", style: TextStyle(fontSize: 12, color: Colors.black),),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            Toast.show("Coming Soon...", duration: Toast.lengthLong, gravity: Toast.bottom);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.40,
                            height: 170,
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: circularRadius(AppRadius.border12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10,),
                                SvgPicture.asset(
                                  assetInternet,
                                  width: 24,
                                  height: 24,
                                  color: Colors.black,
                                ),
                                SizedBox(height: 10,),
                                Text("Internet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[800]),),
                                SizedBox(height: 10,),
                                Text("Recharge all Internet services. Smile, Spectranet, IPNX e.t.c", style: TextStyle(fontSize: 12, color: Colors.black),),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ))));
  }



}