import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants.dart';
import '../../language.dart';
import '../../models/fiat_transaction_model.dart';
import '../../widgets/appbar.dart';
import '../wallets/view_fiat_transaction.dart';

class FiatSuccessScreenWallet extends StatefulWidget {
  FiatSuccessScreenWallet({required this.message, required this.Transaction});
  final String message;
  final FiatTransactionModel Transaction;

  @override
  _FiatSuccessScreenState createState() => _FiatSuccessScreenState();
}

class _FiatSuccessScreenState extends State<FiatSuccessScreenWallet> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    Timer(Duration(seconds: 6), () =>
        Navigator.pushReplacement(context, MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => ViewFiatTransaction(Transaction: widget.Transaction,)))
    );
    return Scaffold(
      backgroundColor: kSecondary,
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          backAppbar(context, Language.thanks),
          SizedBox(
            height: 20,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 3.0,
            margin: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 10),
            padding: EdgeInsets.all(25),
            child: Image.asset(
              'assets/images/success.gif',
              fit: BoxFit.scaleDown,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
              width: MediaQuery.of(context).size.width*0.70,
              child: Center(
                  child: Text(
                    '${widget.message}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: TextStyle(
                        fontSize: 20),
                    textAlign: TextAlign.center,
                  ))),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.only(
              bottom: 10,
              left: 20,
              right: 20,
            ),
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => ViewFiatTransaction(Transaction: widget.Transaction)));
              },
              style: OutlinedButton.styleFrom(
                  side: BorderSide(width: 1.0, color: kPrimaryColor),
                  backgroundColor: kPrimaryColor
              ),
              child: Text(
                Language.view_details,
                style: TextStyle(
                  fontSize: 14.0,
                  color: kSecondary,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),

          ),
        ],
      ),
    );
  }
}
