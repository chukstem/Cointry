import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../../constants.dart';

class More extends StatefulWidget {
  More({Key? key}) : super(key: key);

  @override
  _More createState() => _More();
}




class _More extends State<More> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
    ));
    return Scaffold(
        backgroundColor: kSecondary,
        body: Container(
            decoration: BoxDecoration(
              color: kSecondary,
              borderRadius: BorderRadius.only(topRight: Radius.circular(30.0), topLeft: Radius.circular(30.0)),
            ),
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:
                  EdgeInsets.only(top: 10, right: 20, left: 20),
                  child: Text(
                    'UPCOMING UPDATES',
                    style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding:
                  EdgeInsets.only(top: 10, right: 20, left: 20),
                  child: Text(
                    'Note: Deposit charge of N10 for amounts less than N2,500',
                    style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            )));
  }


}