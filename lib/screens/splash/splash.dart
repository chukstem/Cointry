import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_app/constants.dart';
import 'package:crypto_app/screens/splash/splash_screen.dart';
import 'package:crypto_app/screens/splash/welcome.dart';

import '../../components/coustom_bottom_nav_bar.dart';

class Splash extends StatefulWidget {
  static String routeName = "/first_splash";
  Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  String? username, splash, verified;

  home() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username");
      splash = prefs.getString("splash");
      verified = prefs.getString("verified");
    });
    prefs.setString("splash", "user");
    prefs.setString("access", "locked");
  }

  @override
  void initState() {
    home();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    Timer(Duration(seconds: 5), () =>
    {
      if(splash == null) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            SplashScreen.routeName, (Route<dynamic> route) => false)
      } else if(username != null && verified != null && verified!.isNotEmpty) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => Dashboard()))
      } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
              WelcomeScreen.routeName, (Route<dynamic> route) => false)
      }

    });
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body:  Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        color: kPrimaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Image.asset("assets/images/cointry_white.jpeg",),
            ),
          ],
        ),
      ),
    );
  }

}