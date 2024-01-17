import 'dart:async';
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:crypto_app/constants.dart';
import 'package:crypto_app/helper/networklayer.dart';
import 'package:crypto_app/models/trading_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_pusher/pusher.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';
import '../../language.dart';
import '../../models/post.dart';
import '../../models/user_model.dart';
import '../../strings.dart';
import '../../widgets/material.dart';
import '../../widgets/pin.dart';
import '../../widgets/snackbar.dart';
import '../chat/chat_screen.dart';
import '../profile/user_profile_screen.dart';
import 'package:http/http.dart' as http;

class P2PDetailScreen extends StatefulWidget {
  TradingModel obj;
  P2PDetailScreen({required this.obj});

  @override
  _P2PDetailScreenState createState() => _P2PDetailScreenState();
}

class _P2PDetailScreenState extends State<P2PDetailScreen> {
  bool isChecked=true;
  bool error = false, loading=true, showprogress = false, wallet_button = false, success = false;
  String pin="", email = "", username = "", amount = "", token = "", content = "", errormsg="";
  Channel? channel; 
  final CountDownController _controller = CountDownController();

  getuser() async { 
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username")!;
      token = prefs.getString("token")!;
      pin = prefs.getString("pin")!;
    });
  }

  Future<void> initPusher() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("token");
      await Pusher.init(
        "qwerty",
        PusherOptions(
          host: Strings.domain,
          port: 6001,
          encrypted: true,
          cluster: "mt1",
          auth: PusherAuth(
            Strings.home + "/broadcasting/auth",
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'auth-token': '$token',
              'Access-Control-Allow-Origin': '*'
            },),
        ),
        enableLogging: true,
      );
    } on PlatformException catch (e) {}
    Pusher.connect(onConnectionStateChange: (x) async {
      // Snackbar().show(context, ContentType.help, "State", "Last: ${x!.previousState}  Current: ${x!.currentState}");
    }, onError: (x) {
      // Snackbar().show(context, ContentType.warning, Language.error, "${x!.message}");
    });

    channel = await Pusher.subscribe("private-chat.$username");
    channel!.bind("client-conversations", (data) {
      fetch();
    });
  }

  fetch() async {
    setState(() {
      loading=true;
    });
    try{
     List<TradingModel> iList = await getTradingById(http.Client(), widget.obj.id);
     if(iList.isNotEmpty){
       setState(() {
         widget.obj=iList.first;
       });
     }
    }catch(e){
    }
    setState(() {
      loading = false;
    });

  }


  @override
  void initState() {
    getuser();
    Timer(Duration(seconds: 1), () =>
    {
      fetch(),
      initPusher(),
    });
    super.initState();
  }

  @override
  void deactivate() {
    Pusher.disconnect();
    super.deactivate();
  }

  @override
  void activate() {
    Pusher.connect();
    super.activate();
  }

  @override
  void dispose() {
    Pusher.disconnect();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryDarkColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    ToastContext().init(context);
    UserModel user=widget.obj.buyer.first.username==username? widget.obj.seller.first : widget.obj.buyer.first;
    return Scaffold(
      backgroundColor: kWhite,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          SizedBox(
          height: 50,
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width*0.30,
                padding: EdgeInsets.only(left: 15),
                alignment: Alignment.centerLeft,
                child: InkWell(
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 22,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                 ),
                ),
                 Text(username==widget.obj.buyer.first.username ? "Buy ${widget.obj.currency_symbol}" : "Sell ${widget.obj.currency_symbol}", maxLines: 2, style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),),
               ],
              ),
             ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  username==widget.obj.buyer.first.username?
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: kSecondary
                    ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width*0.60,
                              child: Text(
                                "Seller is waiting for your payment",
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width*0.30,
                              child: Countdown(),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Text(
                          widget.obj.status=="8" ? "Disputed!" : "Expected to make payment in ${widget.obj.endMin}:00",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ) :
                  Container(
                    padding: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: kSecondary
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width*0.60,
                              child: Text(
                                "Waiting for buyer's payment",
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width*0.30,
                              child: Countdown(),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Text(
                          widget.obj.status=="8" ? "Disputed!" : "Expected to receive payment in ${widget.obj.endMin}:00",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black
                          ),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  username==widget.obj.buyer.first.username?
                  Container(
                    margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.blue[50]
                    ),
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Transfer the correct amount to the provided account details below. Your money may be lost if you pay to a wrong account or incorrect value.",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black
                      ),
                    ),
                  ) :
                  Container(
                    margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.blue[50]
                    ),
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Do not release funds until you have received the correct amount from the buyer. Endeavour to check your mobile banking app for payment confirmation before releasing funds.",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black
                      ),
                    ),
                  ),
                   Container(
                       margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                       decoration: BoxDecoration(
                           borderRadius: BorderRadius.all(Radius.circular(10)),
                           color: kSecondary
                       ),
                       padding: EdgeInsets.all(10),
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.start,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Container(
                           margin: EdgeInsets.only(top: 10, left: 10, right: 20),
                           child: Text(
                             Language.payment_info,
                             style: TextStyle(
                                 fontSize: 16,
                                 fontWeight: FontWeight.bold,
                                 color: Colors.black
                             ),
                           ),
                         ),
                         Container(
                           margin: EdgeInsets.only(top: 5, left: 10, right: 10),
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             crossAxisAlignment: CrossAxisAlignment.center,
                             children: [
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 crossAxisAlignment: CrossAxisAlignment.center,
                                 children: [
                                   Text(
                                     Language.amount,
                                     style: TextStyle(
                                         fontSize: 16,
                                         color: Colors.black87
                                     ),
                                   ),
                                   Text(
                                     "${widget.obj.fiat_symbol}"+widget.obj.amount,
                                     style: TextStyle(
                                         fontSize: 16,
                                         fontWeight: FontWeight.bold,
                                         color: Colors.black
                                     ),
                                   ),
                                 ],
                               ),
                               SizedBox(height: 5,),
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 crossAxisAlignment: CrossAxisAlignment.center,
                                 children: [
                                   Text(
                                     Language.price,
                                     style: TextStyle(
                                         fontSize: 16,
                                         color: Colors.black87
                                     ),
                                   ),
                                   Text(
                                     "${widget.obj.fiat_symbol}"+widget.obj.amountRate,
                                     style: TextStyle(
                                         fontSize: 16,
                                         color: Colors.black
                                     ),
                                   ),
                                 ],
                               ),
                               SizedBox(height: 5,),
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 crossAxisAlignment: CrossAxisAlignment.center,
                                 children: [
                                   Text(
                                     "Total Quantity",
                                     style: TextStyle(
                                         fontSize: 16,
                                         color: Colors.black87
                                     ),
                                   ),
                                   Text(
                                     widget.obj.amountCrypto,
                                     style: TextStyle(
                                         fontSize: 16,
                                         color: Colors.black
                                     ),
                                   ),
                                 ],
                               ),
                               SizedBox(height: 5,),
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 crossAxisAlignment: CrossAxisAlignment.center,
                                 children: [
                                   Text(
                                     "Created Time",
                                     style: TextStyle(
                                         fontSize: 16,
                                         color: Colors.black87
                                     ),
                                   ),
                                   Text(
                                     widget.obj.time,
                                     style: TextStyle(
                                         fontSize: 16,
                                         color: Colors.black
                                     ),
                                   ),
                                 ],
                               ),
                               SizedBox(height: 2,),
                               Divider(),
                               SizedBox(height: 2,),
                               username==widget.obj.buyer.first.username && widget.obj.status=="0"?
                               Column(
                                 mainAxisAlignment: MainAxisAlignment.start,
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Container(
                                     margin: EdgeInsets.only(top: 5, right: 20),
                                     child: Text(
                                       "Bank Details",
                                       style: TextStyle(
                                           fontSize: 16,
                                           fontWeight: FontWeight.bold,
                                           color: Colors.black
                                       ),
                                     ),
                                   ),
                                   Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     children: [
                                       Text(
                                         "Bank Name",
                                         style: TextStyle(
                                             fontSize: 16,
                                             color: Colors.black87
                                         ),
                                       ),
                                       Text(
                                         widget.obj.bankname,
                                         style: TextStyle(
                                             fontSize: 16,
                                             color: Colors.black
                                         ),
                                       ),
                                     ],
                                   ),
                                   SizedBox(height: 5,),
                                   Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     children: [
                                       Text(
                                         "Account Name",
                                         style: TextStyle(
                                             fontSize: 16,
                                             color: Colors.black87
                                         ),
                                       ),
                                       Text(
                                         widget.obj.accountname,
                                         style: TextStyle(
                                             fontSize: 16,
                                             color: Colors.black
                                         ),
                                       ),
                                     ],
                                   ),
                                   SizedBox(height: 5,),
                                   Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     children: [
                                       Text(
                                         "Account Number",
                                         style: TextStyle(
                                             fontSize: 16,
                                             color: Colors.black87
                                         ),
                                       ),
                                       InkWell(
                                         onTap: () {
                                           Clipboard.setData(ClipboardData(text: widget.obj.accountnumber));
                                           Toast.show("Account number copied!", duration: Toast.lengthLong, gravity: Toast.bottom);
                                         },
                                         child: Text('${widget.obj.accountnumber}', style: TextStyle(color: kPrimaryColor, fontSize: 13),
                                           overflow: TextOverflow.ellipsis,
                                           maxLines: 2,),
                                       ),
                                     ],
                                   ),
                                   SizedBox(height: 10,),
                                 ],
                               ) :  Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 crossAxisAlignment: CrossAxisAlignment.center,
                                 children: [
                                   Text(
                                     "Bank",
                                     style: TextStyle(
                                         fontSize: 16,
                                         color: Colors.black87
                                     ),
                                   ),
                                   Text(
                                     "${widget.obj.bankname} (${widget.obj.accountnumber})",
                                     style: TextStyle(
                                         fontSize: 16,
                                         color: Colors.black
                                     ),
                                   ),
                                 ],
                               ),
                             ],
                           ),
                         ),
                         widget.obj.status=="1"?
                         Container(
                           margin: EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 20),
                           child: SizedBox(
                             height: 50, width: double.infinity,
                             child: ElevatedButton(
                               onPressed: () {

                               },
                               style: ElevatedButton.styleFrom(primary: Colors.green),
                               child: Padding(
                                 padding: EdgeInsets.only(
                                     left: 30.0, right: 30.0, top: 10, bottom: 10),
                                 child: Text(
                                   'Completed!',
                                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: kSecondary),
                                 ),
                               ),
                             ),
                           ),
                         ) :
                         username==widget.obj.buyer.first.username && (widget.obj.status=="0" || widget.obj.status=="8")?
                         Container(
                           margin: EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 20),
                           child: SizedBox(
                             height: 50, width: double.infinity,
                             child: ElevatedButton(
                               onPressed: () {
                                paid(context);
                               },
                               style: ElevatedButton.styleFrom(primary: kPrimaryDarkColor),
                               child: Padding(
                                 padding: EdgeInsets.only(
                                     left: 30.0, right: 30.0, top: 10, bottom: 10),
                                 child: Text(
                                   'I Have Paid',
                                   style:
                                   TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                 ),
                               ),
                             ),
                           ),
                         ) : username==widget.obj.buyer.first.username?
                         Container(
                           margin: EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 20),
                           child: SizedBox(
                             height: 50, width: double.infinity,
                             child: ElevatedButton(
                               onPressed: () {

                               },
                               style: ElevatedButton.styleFrom(primary: kWhite),
                               child: Padding(
                                 padding: EdgeInsets.only(
                                     left: 30.0, right: 30.0, top: 10, bottom: 10),
                                 child: Text(
                                   'I Have Paid!',
                                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.grey),
                                 ),
                               ),
                             ),
                           ),
                         ) : widget.obj.status=="1"?
                         Container(
                           margin: EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 20),
                           child: SizedBox(
                             height: 50, width: double.infinity,
                             child: ElevatedButton(
                               onPressed: () {

                               },
                               style: ElevatedButton.styleFrom(primary: kWhite),
                               child: Padding(
                                 padding: EdgeInsets.only(
                                     left: 30.0, right: 30.0, top: 10, bottom: 10),
                                 child: Text(
                                   'Completed!',
                                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.grey),
                                 ),
                               ),
                             ),
                           ),
                         ) : username==widget.obj.seller.first.username && (widget.obj.status=="2" || widget.obj.status=="8")?
                         Container(
                           margin: EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 20),
                           child: SizedBox(
                             height: 50, width: double.infinity,
                             child: ElevatedButton(
                               onPressed: () {
                                 _confirm(context);
                               },
                               style: ElevatedButton.styleFrom(primary: kPrimaryDarkColor),
                               child: Padding(
                                 padding: EdgeInsets.only(
                                     left: 30.0, right: 30.0, top: 10, bottom: 10),
                                 child: Text(
                                   'Payment Received',
                                   style:
                                   TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                 ),
                               ),
                             ),
                           ),
                         ) :
                         Container(
                           margin: EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 20),
                           child: SizedBox(
                             height: 50, width: double.infinity,
                             child: ElevatedButton(
                               onPressed: () {

                               },
                               style: ElevatedButton.styleFrom(primary: kWhite),
                               child: Padding(
                                 padding: EdgeInsets.only(
                                     left: 30.0, right: 30.0, top: 10, bottom: 10),
                                 child: Text(
                                   'Pending',
                                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.grey),
                                 ),
                               ),
                             ),
                           ),
                         ),
                       ],
                     )
                   ),
                  Container(
                    margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: kSecondary
                    ),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => UserProfile(user: user,)));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                child: Text(
                                  user.first_name + " " +
                                      user.last_name,
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
                              user.rank == "0" ?
                              SizedBox() :
                              user.rank == "1" ?
                              Icon(Icons.verified_user,
                                color: kPrimaryLightColor,
                                size: 10,) :
                              Icon(Icons.star,
                                color: user.rank == "3"
                                    ? Colors.orangeAccent
                                    : kPrimaryVeryLightColor,
                                size: 10,),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final result = await Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ChatScreen(to: user)));
                            setState(() {
                              fetch();
                              initPusher();
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Chat",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: yellow100,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Icon(Icons.chat, color: yellow100),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: kSecondary
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Language.payment_method,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10, right: 10),
                            child: Text(
                              "Bank Transfer",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: kSecondary
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Advertiser's Terms",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black
                                ),
                              ),
                              Icon(Icons.follow_the_signs),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10, right: 10),
                            child: Text(
                              widget.obj.terms,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 10,
                            ),
                          ),
                        ],
                      )
                  ),
              SizedBox(height: 20,),
            ]
          ),
        ],
      ),
      ),
      floatingActionButton: widget.obj.type=="Sell" && widget.obj.buyer.first.username!=username && widget.obj.status=="1" ?
          FloatingActionButton.extended(
            onPressed: () {
              _post(context, widget.obj.buyer.first.username);
            },
            label: Text('Add Review', style: TextStyle(color: kSecondary)),
            icon: Icon(Icons.add_comment, color: kSecondary),
            backgroundColor: kPrimary,
          ) : widget.obj.type=="Buy" && widget.obj.seller.first.username!=username && widget.obj.status=="1" ?
          FloatingActionButton.extended(
            onPressed: () {
              _post(context, widget.obj.seller.first.username);
            },
            label: Text('Add Review', style: TextStyle(color: kSecondary)),
            icon: Icon(Icons.add_comment, color: kSecondary),
            backgroundColor: kPrimary,
          ) : widget.obj.status=="2" ?
          FloatingActionButton.extended(
            onPressed: () {
              dispute(context);
            },
            label: Text('Dispute', style: TextStyle(color: kSecondary)),
            icon: Icon(Icons.report, color: kSecondary,),
            backgroundColor: kPrimary,
          ) : SizedBox(),
    );
  }

  final controller = TextEditingController();
  post(String user) async {
    List<Post> posts = List.empty(growable: true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("username");
    try {
      var old_post = json.decode(prefs.getString("queued_posts")!) as List<dynamic>;
      for (var post in old_post) {
        posts.add(Post(user: post["user"], content: post["content"], url: post["url"], var1: post["var1"], retries: post["retries"], uid: post["uid"]));
      }
    } catch (e) {
      //Snackbar().show(context, ContentType.failure, Language.error, e.toString());
    }

    if (content.isNotEmpty) {
      try {
        posts.add(Post(user: username!,
            content: content,
            url: "/trade-review/add",
            var1: "${user}",
            retries: 0,
            uid: username+'_'+Uuid().v4()+'_${DateTime.now().millisecondsSinceEpoch/1000}'));
        prefs.setString("queued_posts", jsonEncode(posts));
      } catch (e) {
      }
        setState(() {
          controller.clear();
          content = "";
        });
        Snackbar().show(context, ContentType.success, Language.success, "Review Submitted");
        Navigator.of(context).pop();
     }
    }

    Widget Countdown(){
      return Center(
        child: CircularCountDownTimer(
          // Countdown duration in Seconds.
          duration: int.parse(widget.obj.window)*60,
          initialDuration: widget.obj.status=="1" ? int.parse(widget.obj.window)*60 : (int.parse(widget.obj.window)*60)-int.parse(widget.obj.endMin)*60,
          controller: _controller,
          width: MediaQuery.of(context).size.width*0.15,
          height: MediaQuery.of(context).size.width*0.15,
          ringColor: Colors.grey[300]!,
          ringGradient: null,
          fillColor: yellow100,
          fillGradient: null,
          backgroundColor: kPrimary,
          backgroundGradient: null,
          strokeWidth: 10.0,
          strokeCap: StrokeCap.round,
          textStyle: const TextStyle(
            fontSize: 18.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textFormat: CountdownTextFormat.MM_SS,
          isReverse: true,
          isReverseAnimation: false,
          isTimerTextShown: true,
          autoStart: true,
          onStart: () {

          },
          onComplete: () {

          },
          onChange: (String timeStamp) {

          },
          timeFormatterFunction: (defaultFormatterFunction, duration) {
            if (duration.inSeconds == 0) {
              return 0;
            } else {
              return Function.apply(defaultFormatterFunction, [duration]);
            }
          },
        ),
      );
    }

  void _post(context, String user) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, state) {
                return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        padding: EdgeInsets.only(
                            bottom: MediaQuery
                                .of(context)
                                .viewInsets
                                .bottom),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            error ? Container(
                              //show error message here
                              margin: EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.all(10),
                              child: errmsg(errormsg, success, context),
                              //if error == true then show error message
                              //else set empty container as child
                            ) : Container(),
                            Padding(
                              padding:
                              EdgeInsets.only(
                                  top: 10, right: 20, left: 20),
                              child: TextField(
                                minLines: 3,
                                controller: controller,
                                maxLines: 6,
                                // and this
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  hintText: Language.write_review,
                                  isDense: true,
                                  // now you can customize it here or add padding widget
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  content = value;
                                },
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    top: 20, right: 20, left: 20, bottom: 25),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: kPrimaryDarkColor,
                                    minimumSize: Size.fromHeight(
                                        40), // fromHeight use double.infinity as width and 40 is the height
                                  ),
                                  child: Text(
                                    'Post',
                                    style: TextStyle(
                                        color: kSecondary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    post(user);
                                  },
                                )),
                          ],
                        )));
              });
        },
        context: context);
  }


  void _dispute(context2) {
    content="";
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, state) {
                return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        padding: EdgeInsets.only(
                            bottom: MediaQuery
                                .of(context)
                                .viewInsets
                                .bottom),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                              EdgeInsets.only(
                                  top: 10, right: 20, left: 20),
                              child: TextField(
                                minLines: 3,
                                controller: controller,
                                maxLines: 6,
                                // and this
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  hintText: "Write something...",
                                  isDense: true,
                                  // now you can customize it here or add padding widget
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  content = value;
                                },
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    top: 20, right: 20, left: 20, bottom: 25),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: kPrimaryDarkColor,
                                    minimumSize: Size.fromHeight(
                                        40), // fromHeight use double.infinity as width and 40 is the height
                                  ),
                                  child: Text(
                                    'Send Dispute',
                                    style: TextStyle(
                                        color: kSecondary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    send_dispute(context2);
                                  },
                                )),
                          ],
                        )));
              });
        },
        context: context);
  }


  paid(BuildContext context) async {
    QuickAlert.show(
        context: context,
        backgroundColor: kPrimaryDarkColor,
        type: QuickAlertType.confirm,
        title: Language.i_have_paid,
        titleColor: kSecondary,
        textColor: kSecondary,
        text: Language.seller_paid,
        confirmBtnText: Language.proceed,
        cancelBtnText: Language.cancel,
        confirmBtnColor: Colors.green,
        onConfirmBtnTap: () async {
          Navigator.pop(context);
          have_paid(context);
          return;
        },
        onCancelBtnTap: (){
          Navigator.pop(context);
          return;
        }
    );
  }

  dispute(BuildContext context) async{
    QuickAlert.show(
        context: context,
        backgroundColor: kPrimaryDarkColor,
        type: QuickAlertType.confirm,
        title: 'Dispute Trade',
        titleColor: kSecondary,
        textColor: kSecondary,
        text: 'Kindly drop a clear screenshot of your account statement. A staff will review this shortly.',
        confirmBtnText: Language.proceed,
        cancelBtnText: 'Discard',
        confirmBtnColor: Colors.green,
        onConfirmBtnTap: () async {
          Navigator.pop(context);
          _dispute(context);
          return;
        },
        onCancelBtnTap: (){
          Navigator.pop(context);
          return;
        }
    );
  }

  have_paid(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token=prefs.getString("token");
    String? username=prefs.getString("username");
    var response = null;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Notifying user',
      text: 'Wait a few secs...',
    );
    try {
      response = await http.post(Uri.parse(Strings.url+"/trade/paid"),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "Bearer $token"},
          body: json.encode({
            'username': username,
            'trade_id': widget.obj.id
          })
      );
      if (response != null && response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["status"] != null &&
            jsondata["status"].toString().contains("success")) {
          Navigator.pop(context);
          setState(() {
            widget.obj.status="2";
          });

        }else{
          Navigator.pop(context);
          Snackbar().show(context, ContentType.failure, Language.error, jsondata["response_message"].toString());
        }

      }else{
        Navigator.pop(context);
        Snackbar().show(context, ContentType.failure, Language.error, Language.network_error);
      }

    } catch (e) {
      Navigator.pop(context);
      Snackbar().show(context, ContentType.failure, Language.error, e.toString());
    }

  }

  send_dispute(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token=prefs.getString("token");
    String? username=prefs.getString("username");
    UserModel user=widget.obj.buyer.first.username==username? widget.obj.seller.first : widget.obj.buyer.first;
    var response = null;
    if(content.isNotEmpty){
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Sending Dispute',
        text: 'Wait a few secs...',
      );
      try {
        response = await http.post(Uri.parse(Strings.url + "/trade/dispute"),
            headers: {
              "Content-Type": "application/json",
              "Authentication": "Bearer $token"},
            body: json.encode({
              'username': username,
              'trade_id': widget.obj.id,
              'content': content
            })
        );
        if (response != null && response.statusCode == 200) {
          var jsondata = json.decode(response.body);
          if (jsondata["status"] != null && jsondata["status"].toString().contains("success")) {
            Navigator.pop(context);
            setState(() {
              widget.obj.status="8";
            });
            Snackbar().show(context, ContentType.success, Language.disputed,  jsondata["response_message"].toString());
          } else {
            Navigator.pop(context);
            Snackbar().show(context, ContentType.failure, Language.error,  jsondata["response_message"].toString());
          }
        } else {
          Navigator.pop(context);
          Snackbar().show(context, ContentType.failure, Language.error, Language.network_error);
        }

      } catch (e) {
        Navigator.pop(context);
        Snackbar().show(context, ContentType.failure, Language.error, e.toString());
      }

    }


  }



  _confirm(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(Language.confirm, maxLines: 2, style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
                              InkWell(
                                child: Icon(
                                  Icons.cancel,
                                  size: 30,
                                  color: Colors.grey[300],
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: indicators[1],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.25,
                                    child: Text(
                                      Language.sell_amount,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.45,
                                    child: Text(
                                      widget.obj.amountCrypto,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.25,
                                    child: Text(
                                      Language.price,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.45,
                                    child: Text(
                                      "${widget.obj.fiat_symbol}"+widget.obj.amountRate,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.25,
                                    child: Text(
                                      Language.fee,
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
                                  SizedBox(width: 20,),
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.45,
                                    child: Text(
                                      "${widget.obj.fiat_symbol}"+Language.default_amount,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.25,
                                    child: Text(
                                      Language.receive_amount,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.45,
                                    child: Text("${widget.obj.fiat_symbol}"+widget.obj.amount,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
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
                        SizedBox(height: 20,),
                        InkWell(
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.90,
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(
                                top: 20, right: 20, left: 20, bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: kPrimaryDarkColor,
                            ),
                            child: Center(
                              child: Text(
                                Language.proceed,
                                style: TextStyle(
                                    color: kSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            Pin(context, widget.obj.amountCrypto, json.encode({
                              'username': username,
                              'trade_id': widget.obj.id,
                              'trx': username+'_'+Uuid().v4()+'_${DateTime.now().millisecondsSinceEpoch/1000}',
                              'pin': pin}), "/trade/release", Language.release, setState);
                          },),
                      ],
                    )),
              );
            });
      },
    );
  }


}
