import 'package:flutter/material.dart';
import 'package:crypto_app/constants.dart';
import 'package:crypto_app/screens/splash/welcome.dart';
import 'package:crypto_app/size_config.dart';

import '../../../language.dart';
import '../components/splash_content.dart';
import '../../../components/default_button.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {
      "title": Language.title1,
      "text": Language.text1,
      "image": "assets/images/cointry.png"
    },
    {
      "title": Language.title2,
      "text": Language.text2,
      "image": "assets/images/splash_2.jpeg"
    },
    {
      "title": Language.title3,
      "text": Language.text3,
      "image": "assets/images/splash_3.webp"
    },
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: PageView.builder(
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                itemCount: splashData.length,
                itemBuilder: (context, index) => SplashContent(
                  title: splashData[currentPage]["title"],
                  image: splashData[currentPage]["image"],
                  text: splashData[currentPage]['text'],
                ),
              ),
            ),
            Container(
                height: MediaQuery.of(context).size.height*0.50,
                decoration: BoxDecoration(
                  color: kSecondary,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
                  padding: EdgeInsets.all(40),
                  child: Column(
                  children: <Widget>[
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        splashData.length,
                        (index) => buildDot(index: index),
                      ),
                    ),
                    Spacer(flex: 1),
                    Center(
                      child: Text(
                        splashData[currentPage]["title"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: getProportionateScreenWidth(36),
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Spacer(flex: 1),
                    Center(
                      child: Text(
                        splashData[currentPage]["text"]!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Spacer(flex: 3),
                    DefaultButton(
                      text: currentPage==splashData.length-1? "Lets Get Started" : "Next Step",
                      press: () {
                        if(currentPage==splashData.length-1){
                          Navigator.pushNamed(context, WelcomeScreen.routeName);
                        }else{
                          setState(() {
                            currentPage+=1;
                          });
                        }
                      },
                    ),
                    Spacer(),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: EdgeInsets.only(right: 5),
      height: 6,
      width: currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: currentPage == index ? kPrimaryColor : Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
