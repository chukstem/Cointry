import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_app/models/user_model.dart';
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
import '../next_kin/next_kin_page.dart';
import '../profile/user_profile_screen.dart';

class Referrals extends StatefulWidget {
  Referrals(
      {Key? key})
      : super(key: key);

  @override
  _ReferralsState createState() => _ReferralsState();
}

class _ReferralsState extends State<Referrals> {

  String token="", username="", errormsg="";
  bool error=false, showprogress=false, loading=true,  loading2=false, success=false;
  List<UserModel> list = List.empty(growable: true);

  fetchCached() async {
    try {
      List<UserModel> iList = await getReferralsCached();
      if(iList.isNotEmpty){
        setState(() {
          loading = false;
          list = iList;
        });
      }
    } catch (e) {
    }
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
    fetchCached();
    Timer(Duration(seconds: 1), () =>
    {
      fetch(),
    });
  }

  follow(int id, String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username")!;
    String token = prefs.getString("token")!;
    setState(() {
      list[id].loading=true;
    });
    String apiurl = Strings.url+"/follow_user";
    var response = null;
    try {
      Map data = {
        'username': username,
        'user': user,
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
        if(jsonBody["status"]=="success"){
          setState(() {
            list.removeAt(id);
          });
          Toast.show("You have followed @"+user, duration: Toast.lengthLong, gravity: Toast.bottom);
        }
      }
    } catch (e) {
      Toast.show(Language.network_error, duration: Toast.lengthLong, gravity: Toast.bottom);
    }

    setState(() {
      list[id].loading=false;
    });
  }

  unfollow(int id, String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username")!;
    String token = prefs.getString("token")!;
    setState(() {
      list[id].loading=true;
    });
    String apiurl = Strings.url+"/unfollow_user";
    var response = null;
    try {
      Map data = {
        'username': username,
        'user': user,
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
        if(jsonBody["status"]=="success"){
          setState(() {
            list.removeAt(id);
          });
          Toast.show("You have followed @"+user, duration: Toast.lengthLong, gravity: Toast.bottom);
        }
      }
    } catch (e) {
      Toast.show(Language.network_error, duration: Toast.lengthLong, gravity: Toast.bottom);
    }

    setState(() {
      list[id].loading=false;
    });
  }

  fetch() async {
    setState(() {
      loading = true;
    });
    try{
      List<UserModel> iList = await getReferrals(http.Client(), "0");
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

  bool stopRefresh=false;
  addItems() async {
    int length=list.length+1;
    try{
      List<UserModel> iList = await getReferrals(http.Client(), "$length");
      setState(() {
        loading = false;
        list.addAll(iList);
        if(iList.isEmpty){
          stopRefresh=true;
        }
      });

    }catch(e){
      setState(() {
        loading = false;
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

  Future<void> _refresh() async {
    await Future.delayed(
      Duration(
        seconds: 0,
        milliseconds: 2000,
      ),
    );
    fetch();
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
                backAppbar(context, "Referral"),
                SizedBox(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width-20,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Text(Strings.app_name+" gives you the opportunity to start making money using our referral program. \nT&C Applies.", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 3,),
                  ),
                ),
                SizedBox(height: 20,),
                ListMenu(
                  text: "Crypto Transactions",
                  desc: "You can Earn up to \$1 when your referral performs up to \$200 worth of crypto transactions.",
                  icon: "assets/icons/trading.svg",
                ),
                ListMenu(
                  text: "Bills Payment",
                  desc: "You receive service bonuses on every bills payment performed by your referral.",
                  icon: "assets/icons/Phone.svg",
                ),
                Container(
                  alignment: Alignment.topLeft,
                  width: MediaQuery.of(context).size.width-20,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  child: Text("Your Referral Code: @$username", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 3,),
                ),
                SizedBox(height: 20,),
                Padding(
                    padding: EdgeInsets.only(left: 20, right: 10, top: 15),
                    child: Text(
                      "My Referrals",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )),
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
                    child: Text(Language.empty, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
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
                                  return Card(
                                    margin: EdgeInsets.all(10),
                                    color: kSecondary,
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              InkWell(
                                                onTap: (){
                                                  Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => UserProfile(user: list[i],)));
                                                },
                                                child: Container(
                                                    height: 70,
                                                    width: MediaQuery.of(context).size.width*0.20,
                                                    margin: EdgeInsets.all(10),
                                                    alignment: Alignment.topLeft,
                                                    child: CircleAvatar(
                                                      radius: 45,
                                                      backgroundColor: kSecondary,
                                                      child: Padding(
                                                        padding: EdgeInsets.all(1), // Border radius
                                                        child: ClipOval(child: CachedNetworkImage(
                                                          height: 70,
                                                          width: 70,
                                                          imageUrl: list[i].avatar,
                                                          fit: BoxFit.cover, ), ),
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
                                                  SizedBox(height: 10,),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width*0.70,
                                                    margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
                                                    alignment: Alignment.topLeft,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(context).size.width*0.60,
                                                          child: Text(
                                                            list[i].first_name+" "+list[i].last_name,
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
                                                        list[i].rank=="0" ?
                                                        SizedBox() :
                                                        list[i].rank=="1" ?
                                                        Icon(Icons.verified_user, color: kPrimaryLightColor, size: 10,) :
                                                        Row(mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(Icons.star, color: list[i].rank=="3" ? Colors.orangeAccent : kPrimaryVeryLightColor, size: 10,),
                                                            SizedBox(width: 2,),
                                                            Icon(Icons.verified_user, color: kPrimaryLightColor, size: 10,),
                                                          ],),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(left: 10, right: 10),
                                                    child: Text(
                                                      "@"+list[i].username,
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
                                                    margin: EdgeInsets.only(left: 10, right: 10),
                                                    child: Text(
                                                      "Trades: "+list[i].trades,
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.black45,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  list[i].isFollowed=="0" ?
                                                  InkWell(
                                                    onTap: (){
                                                      if(!list[i].loading) {
                                                        follow(i, list[i].username);
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(10),
                                                      width: 95,
                                                      margin: EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                        color: kPrimaryDarkColor,
                                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                      ),
                                                      child: Center(
                                                        child: list[i].loading?
                                                        SizedBox(
                                                          height:20, width:20,
                                                          child: CircularProgressIndicator(
                                                            backgroundColor: kSecondary,
                                                            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryDarkColor),
                                                          ),
                                                        ) : Text(
                                                          Language.follow,
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
                                                  ) : InkWell(
                                                    onTap: (){
                                                      if(!list[i].loading) {
                                                        unfollow(i, list[i].username);
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(10),
                                                      margin: EdgeInsets.all(10),
                                                      width: 95,
                                                      decoration: BoxDecoration(
                                                        color: kPrimaryDarkColor,
                                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                      ),
                                                      child: Center(
                                                        child: list[i].loading?
                                                        SizedBox(
                                                          height:20, width:20,
                                                          child: CircularProgressIndicator(
                                                            backgroundColor: kSecondary,
                                                            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryDarkColor),
                                                          ),
                                                        ) : Text(
                                                          Language.unfollow,
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
                                            ],
                                          ),
                                        ],
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