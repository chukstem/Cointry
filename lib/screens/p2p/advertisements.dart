import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_load_more/easy_load_more.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import 'package:http/http.dart' as http;
import '../../helper/networklayer.dart';
import '../../language.dart';
import '../../models/p2p_model.dart';
import '../../strings.dart';
import '../profile/user_profile_screen.dart';
import 'create_ads.dart';

class Advertisements extends StatefulWidget {
  Advertisements({Key? key}) : super(key: key);

  @override
  _AdvertisementsState createState() => _AdvertisementsState();
}

class _AdvertisementsState extends State<Advertisements> {
  bool loading=true;
  String token="", username="", errormsg="";
  bool error=false, showprogress=false, success=false;
  List<P2PModel> tList = List.empty(growable: true);

  cachedList() async {
    List<P2PModel> iList = await getP2PCached("user", "3");
    setState(() {
      if (iList.isNotEmpty) {
        loading = false;
        tList = iList;
      }
    });
  }

  fetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    try{
      List<P2PModel> iList = await getP2PUser(http.Client(), "0");
      setState(() {
        tList=iList;
      });
    }catch(e){
    }
    setState(() {
      loading = false;
    });

  }

  bool stopRefresh=false;
  addItems() async {
    int length=tList.length+1;
    try{
      List<P2PModel> iList = await getP2PUser(http.Client(), "$length");
      setState(() {
        tList.addAll(iList);
        if (iList.isEmpty) {
          stopRefresh = true;
        }
      });

    }catch(e){
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

    if(stopRefresh==false){ addItems();}
    return true;
  }


  @override
  void initState() {
    super.initState();
    cachedList();
    Timer(Duration(seconds: 1), () =>
    {
      fetch(),
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
      onRefresh: () {
        return fetch();
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(0),
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            loading? Container(
                margin: EdgeInsets.all(50),
                child: Center(
                    child: CircularProgressIndicator()))
                :
            tList!.length <= 0 ?
            Container(
              height: 200,
              margin: EdgeInsets.all(20),
              child: Center(
                child: Text(Language.empty, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
              ),
            ) :
            Column(
              children: <Widget>[
                EasyLoadMore(
                  isFinished: tList!.length < 30 || tList!.length >= 500 || stopRefresh,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => UserProfile(user: tList![i].user.first,)));
                                      },
                                      child: Container(
                                          height: 40,
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.10,
                                          margin: EdgeInsets.all(10),
                                          alignment: Alignment.topLeft,
                                          child: CircleAvatar(
                                            radius: 45,
                                            backgroundColor: kSecondary,
                                            child: Padding(
                                              padding: EdgeInsets.all(1),
                                              // Border radius
                                              child: ClipOval(
                                                child: CachedNetworkImage(
                                                  height: 40,
                                                  width: 40,
                                                  imageUrl: tList![i].user.first.avatar,
                                                  fit: BoxFit.cover,),),
                                            ),
                                          ),
                                          padding: EdgeInsets.all(1),
                                          decoration: new BoxDecoration(
                                            color: kSecondary, // border color
                                            shape: BoxShape.circle,
                                          )),
                                    ),
                                    Column(
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
                                                tList![i].user.first.trades+" ${Language.trades}",
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
                                      ],
                                    )
                                  ],
                                ),
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
                                        margin: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Text(
                                          "${Language.rate}: "+tList![i].fiat_symbol + tList![i].amountRate,
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
                                              "${Language.crypto_amount}: " +
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
                                              "${Language.limit}: "+tList![i].fiat_symbol + tList![i].amountMin +
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
                                          final result = await Navigator.push(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => CreateAds(obj: tList![i], create: false,)));
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
                                              Language.view,
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
      ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => CreateAds(create: true, obj: null,)));
          setState(() {
            fetch();
          });
        },
        label: Text('Create Ads', style: TextStyle(color: kSecondary),),
        icon: Icon(Icons.add_comment, color: kSecondary,),
        backgroundColor: kPrimary,
      ),
    );
  }

}