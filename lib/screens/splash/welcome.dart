import 'package:flutter/material.dart';
import 'package:crypto_app/constants.dart';
import 'package:crypto_app/screens/sign_up/sign_up_screen.dart';

import '../../language.dart';
import '../../size_config.dart';
import '../sign_in/sign_in_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static String routeName = "/welcome";
  WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: kSecondary,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
           SizedBox(height:  MediaQuery.of(context).size.height*0.25,),
            Center(
              child: SizedBox(
                height: 270,
                width: 370,
                child: Image.asset("assets/images/onboard.png"),
              ),
              ),
              SizedBox(height:  MediaQuery.of(context).size.height*0.10,),
              Container(
                height: 60,
                  width: MediaQuery.of(context).size.width*0.90,
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0), bottomRight: Radius.circular(20.0), bottomLeft: Radius.circular(20.0)),
                      color: kPrimary
                  ),
                  child: OutlinedButton(
                    child: Text(
                      Language.create_account,
                      style: TextStyle(
                          color: kSecondary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: (){
                      Navigator.pushNamed(context, SignUpScreen.routeName);
                    },
                  )),
              SizedBox(height: 15,),
              InkWell(
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: Language.have_account,
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                        color: kPrimary,
                      ),
                      children: [
                        TextSpan(
                            text: Language.login,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: kPrimary,
                            )),
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, SignInScreen.routeName);
                },
              ),
              SizedBox(height: 15,),
           ],
         ),
      ),
    );
  }

}