import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:crypto_app/screens/market/view_page.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_app/screens/wallets/view_fiat_page.dart';
import 'package:crypto_app/screens/wallets/view_page.dart';
import 'package:toast/toast.dart';
import '../../../constants.dart';
import '../../../helper/networklayer.dart';
import '../../../models/bills_model.dart';
import '../../../models/crypto_model.dart';
import '../../../widgets/material.dart';
import '../../../strings.dart';
import '../../components/get_products.dart';
import '../../helper/pusher.dart';
import '../../language.dart';
import '../../models/markets_model.dart';
import '../../size_config.dart';
import '../../widgets/snackbar.dart';

class WalletsScreen extends StatefulWidget {
  static String routeName = "/wallets";
  WalletsScreen({Key? key}) : super(key: key);

  @override
  _WalletsScreen createState() => _WalletsScreen();
}


class Item{
  Item(this.name);
  final String name;
}

class _WalletsScreen extends State<WalletsScreen> {
  String errormsg="";
  bool error=false, showprogress=false, wallet_button=false, success=false;
  String name="", email="";
  String username="", bankname="",  bankname2="", customerid="", accountname="", pin="", quantity="", iuc="", mybrowser="", number="", meter="", accountnumber="",  accountnumber2="", amount="", token="";

  int maxRenderAvatar = 5;
  double size = 30;
  double borderSize = 5;
  List<CryptoModel> iList = List.empty(growable: true);
  List<CryptoModel> aList = List.empty(growable: true);
  bool loading = true;
  final pageIndexNotifier = ValueNotifier<int>(0);

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



  Widget buildStackedImages({
    TextDirection direction = TextDirection.ltr,
  }) {
    List<Widget> items = [];

    final renderItemCount = currencies.length > maxRenderAvatar
        ? maxRenderAvatar
        : currencies.length;
    for (int i = 0; i < renderItemCount; i++) {
      items.add(
        Positioned(
          left: (i * size * .8),
          child: buildImage(
            currencies[i],
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
            border: Border.all(color: kSecondary, width: 4),
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            "+4",
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
    cachedList();
    Timer(Duration(seconds: 1), () =>
    {
      fetchList(),
      fetchQuery(),
      generalPusher(context)
    });
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
      backgroundColor: kSecondary,
      body: RefreshIndicator(
        onRefresh: () {
          return fetchList();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0)),
                ),
                padding: EdgeInsets.only(top: 20),
                child: Padding(
                  padding: EdgeInsets.only(top: 20.0, bottom: 10),
                  child: Center(child: Text(
                    'Wallets',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: kSecondary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, right: 20, left: 20),
                child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    prefixIconColor: kPrimaryLightColor,
                    fillColor: kWhite,
                    filled: true,
                    prefixIcon: Icon(Icons.search, size: 30,),
                  ),
                  onChanged: (value){
                    if(value.length>0){
                      List<CryptoModel> outputList = iList.where((o) => o.networkModel[0].currency.toLowerCase().contains(value.toLowerCase())).toList();
                      setState(() {
                        aList=outputList;
                      });
                    }else{
                      setState(() {
                        aList=iList;
                      });
                    }
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 20),
                color: kSecondary,
                child: getSingleChildScrollView(Language.wallets),
              ),
              SizedBox(height: 40)
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _addWallet();
        },
        label: Text(Language.add_wallet),
        icon: Icon(Icons.add),
        backgroundColor: kPrimaryDarkColor,
      ),
    );
  }


  Widget getSingleChildScrollView(String title) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              loading ? Container(
                  height: 300,
                  margin: EdgeInsets.only(top: 50),
                  child: Center(
                      child: CircularProgressIndicator()))
                  :
              aList.length <= 0 ?
              Container(
                height: 150,
                margin: EdgeInsets.all(20),
                child: Center(
                  child: Text(Language.empty, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
                ),
              ) :
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 0),
                  itemCount: aList.length,
                  itemBuilder: (context, index) {
                    return getListItem(
                        aList[index], index, context, title);
                  }),
              SizedBox(height: 20,),
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
                        backgroundColor: kSecondary),
                    padding: EdgeInsets.all(1.0),
                    decoration: new BoxDecoration(
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
                      /*
                      Container(
                        width: MediaQuery.of(context).size.width*0.23,
                        height: 30.0,
                        child: Center(
                          child: Sparkline(
                            data: [double.parse(obj.networkModel[0].price), double.parse(obj.networkModel[0].high), double.parse(obj.networkModel[0].low), double.parse(obj.networkModel[0].price)],
                            lineColor: obj.networkModel[0].percentage_change.contains("-") ? Colors.red : Colors.green,
                            useCubicSmoothing: true,
                            cubicSmoothingFactor: 0.4,
                            lineWidth: 2,
                            fillMode: FillMode.below,
                            fillGradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: obj.networkModel[0].percentage_change.contains("-") ? [Colors.red[50]!, Colors.red[100]!] : [Colors.green[50]!, Colors.green[100]!],
                            ),
                          ),
                        ),
                      ),
                       */
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.23,
                            child: Text(
                              "\$" + format(obj.usdBalance),
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



  _addWallet() {
    new_currencies = List.empty(growable: true);
    updateCurrencies();
    error=false;
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, setState)
              {
                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: kSecondary,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0)),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding:
                            EdgeInsets.only(top: 10, right: 20, left: 20),
                            child: Text(
                              Language.add_wallet,
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          error ? Container(
                            //show error message here
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(10),
                            child: errmsg(errormsg, success, context),
                            //if error == true then show error message
                            //else set empty container as child
                          ) : Container(),

                          Container(
                              padding: EdgeInsets.all(1),
                              margin: EdgeInsets.only(left: 20, right: 20),
                              alignment: Alignment.center,
                              height: 60,
                              child: DropdownButtonFormField<Bills>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                    ),
                                    filled: true,
                                    hintText: Language.select_currency,
                                    hintStyle: TextStyle(
                                        color: Colors.grey[800], fontSize: 2),
                                    fillColor: kSecondary
                                ),
                                hint: Text(Language.select_currency),
                                value: currency,
                                onChanged: (Bills? value) {
                                  setState((){
                                    currency=value!;
                                  });
                                },
                                items: new_currencies.map((Bills user) {
                                  return DropdownMenuItem<Bills>(value: user,
                                    child: Text(user.name,
                                      style: TextStyle(color: Colors.black),),);
                                }).toList(),
                              )
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: 20, right: 20, left: 20, bottom: 25),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  minimumSize: Size.fromHeight(
                                      50), // fromHeight use double.infinity as width and 40 is the height
                                ),
                                child: showprogress ?
                                SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(
                                    backgroundColor: kSecondary,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        kPrimaryColor),
                                  ),
                                ) : Text(
                                  Language.add_wallet,
                                  style: TextStyle(
                                      color: kSecondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  if (!showprogress) {
                                    setState(() {
                                      success = false;
                                      showprogress = true;
                                      error = false;
                                    });
                                    addWallet(setState);
                                  }
                                },
                              ))
                        ]),
                  ),
                );
              });
        });
  }




  String format(String price){
    var value = price;
    if (price.length > 2) {
      //value = value.replaceAll(RegExp(r'\D'), '');
      //value = value.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');
    }
    return value;
  }


}