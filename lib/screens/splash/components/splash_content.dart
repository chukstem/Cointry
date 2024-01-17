import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../size_config.dart';

class SplashContent extends StatelessWidget {
  SplashContent({
    Key? key,
    this.title,
    this.text,
    this.image,
  }) : super(key: key);
  final String? title, text, image;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
      children: <Widget>[
        Spacer(flex: 2),
        Container(
            height: 255,
            width: 255,
            child: CircleAvatar(
              radius: 45,
              backgroundColor: yellow100,
              child: Padding(
                padding: EdgeInsets.all(10), // Border radius
                child: ClipOval(child: Image.asset(image!,
                  fit: BoxFit.cover,
                  height: 245,
                  width: 245,), ),
              ),
            ),
            padding: EdgeInsets.all(10.0),
            decoration: new BoxDecoration(
              color: kSecondary, // border color
              shape: BoxShape.circle,
            )),
        Spacer(),
      ]),
    );
  }
}
