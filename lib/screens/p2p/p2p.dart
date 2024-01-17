import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../helper/pusher.dart';
import '../../language.dart';
import '../../strings.dart';
import 'advertisements.dart';
import 'buy.dart';
import 'mytrades.dart';
import 'sell.dart';

class P2PScreen extends StatefulWidget {
  P2PScreen(
      {Key? key})
      : super(key: key);

  @override
  _P2PScreenState createState() => _P2PScreenState();
}

class Item{
  Item(this.name, this.id);
  final String name;
  final String id;
}

class _P2PScreenState extends State<P2PScreen>  with SingleTickerProviderStateMixin{
  var _scrollController;
  late TabController _tabController;
  int index=0;
  final ValueNotifier<bool> clearNotifier = ValueNotifier(false);
  final ValueNotifier<bool> clearNotifier2 = ValueNotifier(false);
  List<Item> payment_methods=<Item>[
    Item('Bank Transfer', '1'),
  ];
  Item? payment_method;
  List<Item> sorts=<Item>[
    Item('Highest Price', '1'),
    Item('Lowest Price', '2'),
  ];
  Item? sort;



  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(vsync: this, length: 4);
    _tabController.addListener((){
      setState(() {
        index=getTabs();
      });
    });
    Timer(Duration(seconds: 1), () =>
    {
      generalPusher(context)
    });
  }

  int getTabs() {
    return _tabController.index;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: kWhite,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(Language.p2p_title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                    index==0 || index==1?
                    InkWell(
                      onTap: (){
                        _showFilter(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.filter_list, color: kSecondary,),
                          SizedBox(width: 3,),
                          Text("Filter", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kSecondary,),),
                        ],
                      ),
                    ) : SizedBox(),
                  ],
                ),
              ),
              pinned: false,
              floating: true,
              snap: false,
              backgroundColor: kPrimaryDarkColor,
              forceElevated: innerBoxIsScrolled,
              bottom: TabBar(
                isScrollable: true,
                indicatorPadding: EdgeInsets.only(left: 10, right: 10),
                unselectedLabelStyle: TextStyle(color: Colors.white70),
                labelStyle: TextStyle(color: kSecondary, fontWeight: FontWeight.bold),
                padding: EdgeInsets.all(0),
                tabAlignment: TabAlignment.start,
                onTap: (value) {
                  setState(() {
                    index=getTabs();
                  });
                },
                tabs: [
                  Container(width: MediaQuery.of(context).size.width/5.8,
                    child: Tab(
                      text: Language.buy,
                    ),),
                  Container(width: MediaQuery.of(context).size.width/5.8,
                    child: Tab(
                      text: Language.sell,
                    ),),
                  Container(width: MediaQuery.of(context).size.width/5.8,
                    child: Tab(
                      text: Language.my_ads,
                    ),),
                  Container(width: MediaQuery.of(context).size.width/5.8,
                    child: Tab(
                      text: Language.my_trades,
                    ),),
                ],
                controller: _tabController,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Buy(clearCallback: clearNotifier),
            Sell(clearCallback: clearNotifier2),
            Advertisements(),
            MyTrades(),
          ],
        ),
      ),
    );

  }


  _showFilter(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("temp_amount", "0");
    prefs.setString("temp_sort", "1");
    prefs.setString("temp_payment_method", "1");
    sort=sorts.first;
    payment_method=payment_methods.first;
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
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20,),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  height: 60,
                                  width: MediaQuery.of(context).size.width*.43,
                                  margin: EdgeInsets.all(10),
                                  child: DropdownButtonFormField<Item>(
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                        ),
                                        filled: true,
                                        labelText: Language.payment_method,
                                        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        fillColor: kSecondary
                                    ),
                                    value: payment_method,
                                    onChanged: (Item? value) {
                                      prefs.setString("temp_payment_method", value!.id);
                                    },
                                    items: payment_methods.map((Item user){
                                      return DropdownMenuItem<Item>(value: user, child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment:  MainAxisAlignment.start, children: [
                                        Text(user.name, overflow: TextOverflow.ellipsis, maxLines: 3, style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
                                        Divider()
                                      ],),);
                                    }).toList(),
                                  )
                              ),
                              SizedBox(width: 2,),
                              Container(
                                  height: 60,
                                  width: MediaQuery.of(context).size.width*.43,
                                  margin: EdgeInsets.all(10),
                                  child: DropdownButtonFormField<Item>(
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                        ),
                                        filled: true,
                                        labelText: "Sort By",
                                        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        fillColor: kSecondary
                                    ),
                                    value: sort,
                                    onChanged: (Item? value) {
                                      prefs.setString("temp_sort", value!.id);
                                    },
                                    items: sorts.map((Item user){
                                      return DropdownMenuItem<Item>(value: user, child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment:  MainAxisAlignment.start, children: [
                                        Text(user.name, overflow: TextOverflow.ellipsis, maxLines: 3, style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
                                        Divider()
                                      ],),);
                                    }).toList(),
                                  )
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.all(10),
                                height: 60,
                                width: MediaQuery.of(context).size.width*.43,
                                child: SizedBox(
                                  height: 60,
                                  child: TextField(
                                    style:TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: "${Language.price}",
                                      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      hintText: Language.default_amount,
                                      hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      isDense: true,
                                      fillColor: kSecondary,
                                      filled: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                      ),
                                    ),
                                    onChanged: (value){
                                      prefs.setString("temp_amount", value);
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 2,),
                              Container(
                                margin: EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width*0.43,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: kPrimary,
                                    minimumSize: Size.fromHeight(
                                        60), // fromHeight use double.infinity as width and 40 is the height
                                  ),
                                  child: Text(
                                    Language.filter,
                                    style: TextStyle(
                                        color: kSecondary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: (){
                                     if(index==0){
                                       clearNotifier.value = !clearNotifier.value;
                                     }else{
                                       clearNotifier2.value = !clearNotifier2.value;
                                     }
                                     Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                      ],
                    )),
              );
            });
      },
    );
  }


}