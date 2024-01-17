import 'dart:async';
import 'package:crypto_app/screens/transactions/transactions_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../helper/networklayer.dart';
import '../../helper/pusher.dart';
import '../../language.dart';
import '../../models/crypto_transactions_model.dart';
import '../../models/fiat_transaction_model.dart';
import '../../models/transactions_model.dart';
import 'fiat_transactions_page.dart';

class TransactionsScreen extends StatefulWidget {
  TransactionsScreen(
      {Key? key})
      : super(key: key);

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with SingleTickerProviderStateMixin {
  bool loading=true;
  List<TransactionsModel> list = List.empty(growable: true);
  List<TransactionsModel> olist = List.empty(growable: true);
  var _scrollController, _tabController;

  cachedList() async {
    List<TransactionsModel> iList = await getTransactionsCached();
      if (iList.isNotEmpty) {
        setState(() {
          loading = false;
          list = iList;
          olist = iList;
        });
      }
  }

  fetch() async {
    try{
      List<TransactionsModel> iList = await getTransactions(new http.Client(), "ALL");
      setState(() {
        loading = false;
        list = iList;
        olist = iList;
      });

    }catch(e){
      setState(() {
        loading = false;
      });
    }

  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(vsync: this, length: 5);
    cachedList();
    Timer(Duration(seconds: 1), () =>
    {
      fetch(),
      generalPusher(context)
    });
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
      body: RefreshIndicator(
        onRefresh: () {
          return fetch();
        },
        child: NestedScrollView(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Text(Language.transactions, style: TextStyle(color: kSecondary, fontWeight: FontWeight.bold, fontSize: 25, overflow: TextOverflow.ellipsis),),
              pinned: false,
              floating: true,
              snap: false, 
              backgroundColor: kPrimaryDarkColor,
              forceElevated: innerBoxIsScrolled,
              bottom: TabBar(
                isScrollable: true,
                indicatorPadding: EdgeInsets.only(left: 10, right: 10),
                unselectedLabelStyle: TextStyle(color: Colors.white70, fontSize: 20),
                labelStyle: TextStyle(color: kSecondary, fontWeight: FontWeight.bold, fontSize: 14),
                padding: EdgeInsets.all(0),
                tabAlignment: TabAlignment.start,
                tabs: <Tab>[
                  Tab(
                    //icon: Icon(Icons.arrow_downward),
                    text: Language.deposits,
                  ),
                  Tab(
                    //icon: Icon(Icons.arrow_upward),
                    text: Language.withdrawals,
                  ),
                  Tab(
                    //icon: Icon(Icons.swap_horiz),
                    text: Language.trades,
                  ),
                  Tab(
                    //icon: Icon(Icons.mobile_friendly_outlined),
                    text: Language.bills,
                  ),
                  Tab(
                    //icon: Icon(Icons.money),
                    text: Language.fiat_deposits,
                  ),
                  Tab(
                    //icon: Icon(Icons.money_off),
                    text: Language.fiat_withdrawals,
                  ),
                ],
                controller: _tabController,
              ),
            ),
           // createSilverAppBar2(),
          ];
        },
        body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              new Transactions(loading: loading, tList: list.isEmpty?[]:list.first.deposit),
              new Transactions(loading: loading, tList: list.isEmpty?[]:list.first.withdraw),
              new Transactions(loading: loading, tList: list.isEmpty?[]:list.first.swap),
              new FiatTransactions(loading: loading, tList: list.isEmpty?[]:list.first.bills),
              new Transactions(loading: loading, tList: list.isEmpty?[]:list.first.fiat_deposit),
              new Transactions(loading: loading, tList: list.isEmpty?[]:list.first.fiat_withdraw),
            ],
          ),
      ),
      ),
    );


  }

  SliverAppBar createSilverAppBar2() {
    return SliverAppBar(
      backgroundColor: kPrimaryDarkColor,
      pinned: true,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.withOpacity(0.6),
                offset: Offset(1.1, 1.1),
                blurRadius: 5.0),
          ],
        ),
        child: CupertinoTextField(
          keyboardType: TextInputType.text,
          placeholder: Language.filter_by,
          placeholderStyle: TextStyle(
            color: Color(0xffC4C6CC),
            fontSize: 14.0,
          ),
          suffix: InkWell(
            onTap: (){
              fetch();
            },
            child: Container(
              height: 40,
              width: 80,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(top: 2, bottom: 2, right: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: kPrimaryLightColor,
              ),
              child: Center(
                child: Text(Language.search, style: TextStyle(color: kSecondary, fontSize: 12, fontWeight: FontWeight.bold),),
              ),
            ),
          ),
          onChanged: (value){
            list=olist;
            setState(() {
              loading=true;
            });
            if(value.length>0){
              List<CryptoTransactionsModel> deposit = list.first.deposit.where((o) => o.hash.toLowerCase().contains(value.toLowerCase()) || o.title.toLowerCase().contains(value.toLowerCase())).toList();
              List<CryptoTransactionsModel> withdrawals = list.first.withdraw.where((o) => o.hash.toLowerCase().contains(value.toLowerCase()) || o.title.toLowerCase().contains(value.toLowerCase())).toList();
              List<CryptoTransactionsModel> fiat_deposit = list.first.fiat_deposit.where((o) => o.hash.toLowerCase().contains(value.toLowerCase()) || o.title.toLowerCase().contains(value.toLowerCase())).toList();
              List<CryptoTransactionsModel> fiat_withdrawals = list.first.fiat_withdraw.where((o) => o.hash.toLowerCase().contains(value.toLowerCase()) || o.title.toLowerCase().contains(value.toLowerCase())).toList();
              List<CryptoTransactionsModel> swap = list.first.swap.where((o) => o.hash.toLowerCase().contains(value.toLowerCase()) || o.title.toLowerCase().contains(value.toLowerCase())).toList();
              List<FiatTransactionModel> bills = list.first.bills.where((o) => o.reference.toLowerCase().contains(value.toLowerCase()) || o.services.toLowerCase().contains(value.toLowerCase())).toList();
              List<TransactionsModel> temp_list = List.empty(growable: true);
              temp_list.add(new TransactionsModel(deposit: deposit, withdraw: withdrawals, fiat_deposit: fiat_deposit, fiat_withdraw: fiat_withdrawals, swap: swap, bills: bills));
              setState(() {
                list=temp_list;
              });

            }else{
              setState(() {
                list=olist;
              });
            }
            setState(() {
              loading=false;
            });
          },
          prefix: Padding(
            padding: EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0),
            child: Icon(
              Icons.search,
              size: 18,
              color: Colors.black,
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: kSecondary,
          ),
        ),
      ),
    );
  }
}