import 'dart:convert';
import 'package:crypto_app/models/timeline_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../screens/notifications/notifications_page.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../screens/splash/welcome.dart';
import 'package:toast/toast.dart';
import '../../../constants.dart';
import '../../../helper/networklayer.dart';
import '../../../models/bills_model.dart';
import '../../../models/crypto_model.dart';
import '../../../strings.dart';
import '../../components/get_products.dart';
import '../../helper/formatter.dart';
import '../../helper/pusher.dart';
import '../../language.dart';
import '../../models/markets_model.dart';
import '../../size_config.dart';
import '../timeline/home_timeline.dart';
import '../profile/profile_screen.dart';
import '../profile/user_profile_screen.dart';
import '../settings/Unlock_screen.dart';
import '../settings/set_pin.dart';
import '../sign_in/sign_in_screen.dart';
import '../market/view_page.dart';
import '../wallets/view_fiat_page.dart';
import '../wallets/view_page.dart';
import 'IconBtnWithCounter.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreen createState() => _HomeScreen();
}


class Item{
  Item(this.name);
  final String name;
}

class _HomeScreen extends State<HomeScreen> {
  String errormsg="";
  bool error=false, showprogress=false, wallet_button=false, success=false;
  String name="", wallet="0.0", email="";
  String username="", amount="", token="";
  List<MarketsModel> mList = List.empty(growable: true);
  int maxRenderAvatar = 5;
  double size = 30;
  double borderSize = 5;

  List<CryptoModel> aList = List.empty(growable: true);
  List<TimelineModel> tList = List.empty(growable: true);
  bool loading = true, loading2 = true;
  final pageIndexNotifier = ValueNotifier<int>(0);

  Bills? currency;
  List<Bills> currencies=Products().getCurrencies();



  cachedCryptos() async {
    List<CryptoModel> iList = await getCryptosCached();
    if(iList.isNotEmpty){
      setState(() {
        loading = false;
        aList = iList;
      });
    }
  }

  fetchList() async {
    try{
      List<CryptoModel> iList = await getCryptos(http.Client());
      setState(() {
        loading = false;
        aList = iList;
      });
      double bal=0;
      for(var cr in iList) {
        try{
          bal=bal+double.parse(cr.usdBalance.replaceAll(",", ""));
          setState(() {
            wallet=format("$bal", "2");
          });
        }catch(e){

        }
      }
      setState(() {
        loading = false;
      });

    }catch(e){
      setState(() {
        loading = false;
      });
    }

  }

  cachedMarketList() async {
    List<MarketsModel> marketlist = await getMarketsCached();
    if(marketlist.isNotEmpty){
      setState(() {
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
    }catch(e){
      //Snackbar().show(context, ContentType.failure, "Error!!", e.toString());
    }
  }

  Future<void> subscribe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    await FirebaseMessaging.instance.subscribeToTopic(username);
    await FirebaseMessaging.instance.subscribeToTopic("general");
  }



  bool stopRefresh=false;
  addItems() async {
    int length=tList.length+1;
    try{
      List<TimelineModel> iList = await getTimeline(http.Client(), "ALL", "$length");
      setState(() {
        loading2 = false;
        tList.addAll(iList);
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

  fetchQuery() async {
    Products().getProducts();
    try {
      var res = await getQuery(http.Client());
      if (res.contains("Authentication")) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.clear();
        Toast.show(Language.session_expired, duration: Toast.lengthLong, gravity: Toast.bottom);
        Get.offAllNamed(WelcomeScreen.routeName);
      } else {
        getuser();
        Products().getProducts();
        currencies=Products().getCurrencies();
      }
    }catch(e){ }
  }


  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPasscode = prefs.getString("pin");
    String? access = prefs.getString("access");
    if(mounted) setState(() {
      var fname = prefs.getString("firstname");
      var lname=prefs.getString("lastname");
      name="$fname $lname";
      email = prefs.getString("email")!;
      username = prefs.getString("username")!;
      token = prefs.getString("token")!;
    });

    if(storedPasscode == "1234") {
      Future.delayed(Duration(seconds: 5), () async {
        Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (context) => setPin()));
      });
    }else if (access != "unlocked") {
      Future.delayed(Duration(seconds: 5), () async {
          Navigator.of(context).pushReplacement(
              CupertinoPageRoute(builder: (context) => PinScreen()));
      });
    }

  }


  Widget buildStackedImages({
    TextDirection direction = TextDirection.ltr,
  }) {
    List<Widget> items = [];

    final renderItemCount = currencies!.length > maxRenderAvatar
        ? maxRenderAvatar
        : currencies!.length;
    for (int i = 0; i < renderItemCount; i++) {
      items.add(
        Positioned(
          left: (i * size * .8),
          child: buildImage(
            currencies![i],
          ),
        ),
      );
    }
    // add counter if  urlImages.length > maxRenderAvatar
    items.add(
      Positioned(
        left: maxRenderAvatar * size * .8,
        child: Container(
          width: 35,
          height: 35,
          padding: EdgeInsets.all(borderSize),
          decoration: BoxDecoration(
            border: Border.all(color: kSecondary, width: 2),
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            "+${maxRenderAvatar}",
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ),
    );

    return SizedBox(
      height: size + (borderSize * 2),
      width: 160,
      child: Stack(
        children: items,
      ),
    );
  }

  Widget buildImage(Bills urlImage) {
    return ClipOval(
      child: Container(
        padding: EdgeInsets.all(borderSize),
        color: kSecondary,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: urlImage.amount,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, SignInScreen.routeName, (
        route) => false,);
  }

  refresh() async {
    addItems();
  }



  @override
  void initState() {
    super.initState();
    getuser();
    cachedCryptos();
    cachedMarketList();
    Timer(Duration(seconds: 1), () =>
    {
      fetchList(),
      fetchQuery(),
      fetchMarketList(),
      generalPusher(context),
      subscribe(),
    });
  }


  @override
  void dispose() {
    super.dispose();
  }

  int counter = 0;


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: kWhite,
      body: RefreshIndicator(
        onRefresh: () {
          return refresh();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 310,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(30.0), bottomLeft: Radius.circular(30.0)),
                ),
                child: Container(
                  height: 280,
                  padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10, top: 30),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment
                                      .start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total Balance",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(color: kSecondary,),
                                    ),
                                    Container(
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
                                      margin: EdgeInsets.only(bottom: 10),
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text("Change 24H +0.0% - \$\+ 0.0", style: TextStyle(color: kSecondary),),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconBtnWithCounter(
                                    svgSrc: "assets/icons/Bell.svg",
                                    numOfitem: 1,
                                    press: () {
                                      Navigator.pushNamed(context, Notifications.routeName);
                                    },
                                  ),
                                  SizedBox(width: 12,),
                                  InkWell(
                                    onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName),
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: kPrimaryLightColor,
                                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(10.0), bottomLeft: Radius.circular(10.0), topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
                                      ),
                                      child: Icon(Icons.person,
                                        size: 35,
                                        color: kSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                      ),
                      SizedBox(height: 10,),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                                onTap: (){
                                  _action("Send");
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
                                )
                            ),
                            InkWell(
                                onTap: (){
                                  _action("Receive");
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
                                  _action("Buy Crypto");
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
                                  _action("Sell Crypto");
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
                                          color: kSecondary, // border color
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.keyboard_double_arrow_up, size: 30, color: Colors.green,),),
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
                      SizedBox(height: 10,),
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 2),
                        padding: EdgeInsets.only(left: 20, right: 10),
                        height: 50,
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
                padding: EdgeInsets.only(top: 0),
                color: kSecondary,
                child: Column(
                  children: [
                    //getSingleChildScrollView("Portfolio"),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 20),
                color: kSecondary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //getFollow(),
                   // Timeline(),
                    Container(
                      color: kWhite,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 30.0, top: 10.0, bottom: 10),
                      child: Text(
                        'Top Markets',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
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
                            child: Text("24hr chg%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kPrimaryColor),),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 0),
                        itemCount: mList.length>5 ? 5 : mList.length,
                        itemBuilder: (context, index) {
                          return getMarketItem(
                              mList[index], context);
                        })
                  ],
                ),
              ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: PageView(
                onPageChanged: (index) => pageIndexNotifier.value = index,
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  /*
                  InkWell(
                    onTap: () async {
                      UserModel to=  new UserModel(id: "4545", username: Strings.app_name, first_name: "Customer",
                          reviews: "0", last_name: "Care", created_on: "", isFollowed: "", trades: "", about: "", avatar: "", cover: "", followers: "", following: "", rank: "", loading: false);
                      Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ChatScreen(to: to)));
                    },
                    child: Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: Center(
                          child: SvgPicture.asset(
                              "assets/images/live-chat.svg",
                              height: 210,
                              width: MediaQuery.of(context).size.width, fit: BoxFit.fitWidth),
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    ),
                  ),
                  */
                  InkWell(
                    onTap: () async {
                      await launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=precinet.viga'),
                        mode: LaunchMode.externalApplication);
                    },
                    child: Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: Center(
                          child: CachedNetworkImage(
                              imageUrl: "https://cloudapi.ng/banners/banner1.jpg",
                              height: 210,
                              width: MediaQuery.of(context).size.width, fit: BoxFit.fitWidth),
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    ),
                  ),
                ],
               ),
               height: 200,
              ),
              Timeline(),
              SizedBox(height: 20,),
            ],
          ),
        ),

      ),

    );
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
              loading ? Container(
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
                  child: Text("No Wallet Yet!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
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
        margin: EdgeInsets.only(bottom: 5, top: 5, left: 10, right: 10),
        child: InkWell(
          onTap: (){
            Navigator.of(context).pop();
            if(obj.type=="coin"){
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ViewCrypto(obj: obj, action: title,))).whenComplete(() => fetchList());
            }else if(obj.type=="fiat"){
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ViewFiat(obj: obj, action: title,))).whenComplete(() => fetchList());
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
                              obj.networkModel[0].currency_symbol+obj.networkModel[0].price+"/\$",
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

  Container getFollow(){
    return tList.isNotEmpty ?
    Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              color: kWhite,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 30, right: 10, top: 10, bottom: 10),
              child: Text(
                "Cointriers",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )),
          Container(
            height: 200,
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(2),
            margin: EdgeInsets.only(top: 5, bottom: 15, left: 5, right: 5),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(
                tList.first.followersModel.length,
                    (i) => Card(
                  margin: EdgeInsets.all(10),
                  color: kSecondary,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => UserProfile(user: tList.first.followersModel[i],)));
                          },
                          child: Container(
                              height: 70,
                              width: 70,
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: kSecondary,
                                child: Padding(
                                  padding: EdgeInsets.all(1), // Border radius
                                  child: ClipOval(child: CachedNetworkImage(
                                    height: 70,
                                    width: 70,
                                    imageUrl: tList.first.followersModel[i].avatar,
                                    fit: BoxFit.cover, ), ),
                                ),
                              ),
                              padding: EdgeInsets.all(1),
                              decoration: new BoxDecoration(
                                color: kSecondary, // border color
                                shape: BoxShape.circle,
                              )),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: (){
                                  Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => UserProfile(user: tList.first.followersModel[i],)));
                                },
                                child: Container(
                                  width: 120,
                                  alignment: Alignment.center,
                                  child: Text(
                                    tList.first.followersModel[i].first_name+" "+tList.first.followersModel[i].last_name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2),
                              tList.first.followersModel[i].rank=="0" ?
                              SizedBox() :
                              tList.first.followersModel[i].rank=="1" ?
                              Icon(Icons.verified_user, color: kPrimaryLightColor, size: 10,) :
                              Row(mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.star, color: tList.first.followersModel[i].rank=="3" ? Colors.orangeAccent : kPrimaryVeryLightColor, size: 10,),
                                  SizedBox(width: 2,),
                                  Icon(Icons.verified_user, color: kPrimaryLightColor, size: 10,),
                                ],),
                            ],
                          ),
                        ),
                        SizedBox(height: 2),
                        Center(
                          child: Text(
                            "@"+tList.first.followersModel[i].username,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black45,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(height: 5),
                        InkWell(
                          onTap: (){
                            if(!tList.first.followersModel[i].loading) {
                              follow(i, tList.first.followersModel[i].username);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            width: 95,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: kPrimaryDarkColor,
                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: Center(
                              child: tList.first.followersModel[i].loading?
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ) : Container();
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
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ViewMarket(market: obj))).whenComplete(() => fetchList());
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
                  width: MediaQuery.of(context).size.width*0.24,
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


  follow(int id, String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username")!;
    String token = prefs.getString("token")!;
    setState(() {
      tList.first.followersModel[id].loading=true;
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
            tList.first.followersModel.removeAt(id);
          });
          Toast.show("You have followed @"+user, duration: Toast.lengthLong, gravity: Toast.bottom);
        }
      }
    } catch (e) {
      Toast.show(Language.network_error, duration: Toast.lengthLong, gravity: Toast.bottom);
    }

    setState(() {
      tList.first.followersModel[id].loading=false;
    });
  }


}

