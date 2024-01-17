import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../size_config.dart';
import '../../widgets/snackbar.dart';
import '../profile/profile_screen.dart';
import '../settings/Unlock_screen.dart';
import '../settings/set_pin.dart';
import '../sign_in/sign_in_screen.dart';
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
  int maxRenderAvatar = 5;
  double size = 30;
  double borderSize = 5;

  bool loading = true, loading2 = true;
  final pageIndexNotifier = ValueNotifier<int>(0);
  List<CryptoModel> iList = List.empty(growable: true);
  List<CryptoModel> aList = List.empty(growable: true);

  Bills? currency;
  List<Bills> currencies=Products().getCurrencies();
  List<Bills> new_currencies = List.empty(growable: true);

  updateCurrencies(){
    for(var curr in currencies){
      List<CryptoModel> outputList = iList.where((o) =>
          o.networkModel[0].currency_symbol.toLowerCase()
              .contains(curr.size.toLowerCase())).toList();
      setState(() {
        if(outputList.isEmpty){
          currency=curr;
          new_currencies.remove(curr);
          new_currencies.add(curr);
        }
      });
    }
  }

  addWallet(setState) async {
    if(currency==null){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.select_currency;
      });
    }else {
      setState(() {
        showprogress = true;
        error=false;
      });
      String apiurl = Strings.url+"/add-wallet";
      var response;
      Map data = {
        'username': username,
        'currency_id': currency!.plan,
      };
      var body = json.encode(data);
      try {
        response = await http.post(Uri.parse(apiurl),
            headers: {
              "Content-Type": "application/json",
              "Authentication": "Bearer $token"},
            body: body
        );
      } catch (e) {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = Language.network_error;
        });
      }
      if (response != null && response.statusCode == 200) {
        try {
          var jsonb = json.decode(response.body);
          if (jsonb["status"] != null &&
              jsonb["status"].toString().contains("success")) {
            setState(() {
              error = true;
              showprogress = false;
              errormsg = jsonb["response_message"];
              success = true;
              loading=true;
            });
            Navigator.of(context).pop();
            Snackbar().show(context, ContentType.success, Language.success, errormsg);
          } else {
            setState(() {
              showprogress = false; //don't show progress indicator
              error = true;
              errormsg = jsonb["response_message"];
            });
          }
        } catch (e) {
          setState(() {
            showprogress = false; //don't show progress indicator
            error = true;
            errormsg = Language.network_error;
          });
        }
      } else {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = Language.network_error;
        });
      }
    }
    fetchList();
  }

  cachedList() async {
    iList = await getCryptosCached();
    setState(() {
      if (iList.isNotEmpty) {
        loading = false;
        updateCurrencies();
      }
      aList = iList;
    });

  }

  fetchList() async {
    try{
      iList = await getCryptos(new http.Client());
      setState(() {
        loading = false;
        aList = iList;
      });
      updateCurrencies();
    }catch(e){

    }
    setState(() {
      loading = false;
    });
  }

  Future<void> subscribe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    await FirebaseMessaging.instance.subscribeToTopic(username);
    await FirebaseMessaging.instance.subscribeToTopic("general");
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



  @override
  void initState() {
    super.initState();
    getuser();
    cachedList();
    Timer(Duration(seconds: 1), () =>
    {
      fetchList(),
      fetchQuery(),
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
      body: SingleChildScrollView(
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
                padding: EdgeInsets.only(top: 20),
                color: kSecondary,
                child: Column(
                  children: [
                    getSingleChildScrollView("Portfolio", true),
                  ],
                ),
              ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: PageView(
                onPageChanged: (index) => pageIndexNotifier.value = index,
                scrollDirection: Axis.horizontal,
                children: <Widget>[
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
              SizedBox(height: 20,),
            ],
          ),
      ),
    );
  }


  Widget getSingleChildScrollView(String title, bool isWallet) {
      if(!isWallet) aList=aList.where((o) =>
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
              ) :
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
        margin: EdgeInsets.only(
          bottom: 5,
          top: 5,
          left: 10,
          right: 10,
        ),
        child: InkWell(
          onTap: (){
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
                    child: new CircleAvatar(
                        maxRadius: 23,
                        minRadius: 23,
                        child: CachedNetworkImage(
                          imageUrl: obj.networkModel[0].img,
                          height: 45.0,
                          width: 45.0,
                        ),
                        backgroundColor: Colors.transparent),
                    padding: EdgeInsets.all(1.0),
                    decoration: new BoxDecoration(
                      color: Colors.transparent, // border color
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
                            width: MediaQuery.of(context).size.width*0.40,
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.23,
                            child: Text(
                              "\$" + format(obj.usdBalance, '2'),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                          SizedBox(height: 5,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.23,
                            child: Text(
                              obj.balance + " " + obj.networkModel[0].currency_symbol,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
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
                    getSingleChildScrollView("$title", false),
                  ]),
            ),
          );
        });
  }





}

