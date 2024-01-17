import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_app/models/signal_model.dart';
import 'package:easy_load_more/easy_load_more.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../../constants.dart';
import 'package:http/http.dart' as http;
import '../../helper/networklayer.dart';
import '../../language.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';

class Airdrops extends StatefulWidget {
  Airdrops(
      {Key? key})
      : super(key: key);

  @override
  _AirdropsState createState() => _AirdropsState();
}

class _AirdropsState extends State<Airdrops> {

  String token="", username="", errormsg="";
  bool error=false, showprogress=false, loading=true,  loading2=false, success=false;
  List<AirdropsModel> list = List.empty(growable: true);
  
  
  @override
  void initState() {
    super.initState();
    fetchCached();
    Timer(Duration(seconds: 1), () =>
    {
      fetch(),
    });
  }


  bool stopRefresh=false;
  addItems() async {
    int length=list.length+1;
    try{
      List<AirdropsModel> iList = await getAirdrops(http.Client(), "$length");
      setState(() {
        loading2 = false;
        list.addAll(iList);
        if(iList.isEmpty){
          stopRefresh=true;
        }
      });

    }catch(e){
      setState(() {
        loading2 = false;
      });
    }
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

  fetchCached() async {
    try {
      List<AirdropsModel> iList = await getAirdropsCached();
      if(iList.isNotEmpty){
        setState(() {
          loading = false;
          list = iList;
        });
      }
    } catch (e) {
    }
  }

  fetch() async {
    try{
      List<AirdropsModel> iList = await getAirdrops(http.Client(), "0");
      setState(() {
        loading = false;
        list = iList;
      });

    }catch(e){
      setState(() {
        loading = false;
      });
    }

  }

  Future<void> _refresh() async {
    await Future.delayed(
      Duration(
        seconds: 0,
        milliseconds: 2000,
      ),
    );
    fetch();
  }

  win() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username")!;
    String token = prefs.getString("token")!;

    String apiurl = Strings.url+"/win_airdrop";
    var response = null;
    try {
      Map data = {
        'username': username,
      };
      var body = json.encode(data);
      response = await http.post(Uri.parse(apiurl),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "$token"},
          body: body
      );
      if (response.statusCode == 200) {
        var jsonBody = json.decode(response.body);

          Toast.show(jsonBody["response_message"], duration: Toast.lengthLong, gravity: Toast.bottom);
      }else{
        Toast.show(Language.network_error, duration: Toast.lengthLong, gravity: Toast.bottom);
      }
    } catch (e) {
      Toast.show(Language.network_error, duration: Toast.lengthLong, gravity: Toast.bottom);
    }

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
      backgroundColor: kSecondary,
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
                SizedBox(height: 20,),
                backAppbar(context, "Airdrops"),
                SizedBox(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width-20,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Text("Win Free daily Airdrops by just clicking the Win button below. \nYou can only win once per day.", style: TextStyle(fontSize: 18, color: kPrimaryDarkColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 3,),
                  ),
                ),
                SizedBox(height: 20,),
                loading? Container(
                    margin: EdgeInsets.all(50),
                    child: Center(
                        child: CircularProgressIndicator()))
                    :
                list.length <= 0 ?
                Container(
                  height: 200,
                  margin: EdgeInsets.all(20),
                  child: Center(
                    child: Text("You have Zero wins!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    RefreshIndicator(
                      onRefresh: _refresh,
                      child: EasyLoadMore(
                        isFinished: list!.length < 30 || list.length >= 500 || stopRefresh,
                        onLoadMore: _loadMore,
                        runOnEmptyResult: false,
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.only(top: 0),
                            itemCount: list.length,
                            itemBuilder: (context, i) {
                              return  Container(
                                child: Card(
                                  margin: EdgeInsets.only(bottom: 5, top: 5, left: 10, right: 10),
                                  child: InkWell(
                                    onTap: (){

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
                                                    imageUrl: list[i].img,
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
                                                        list[i].title,
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
                                                      width: MediaQuery.of(context).size.width*0.23,
                                                      child: Text(
                                                        "\$" + list[i].amount,
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
                                                  ],
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
                            }),
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }

}