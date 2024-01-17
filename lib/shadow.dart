import 'package:flutter/material.dart';

import 'constants.dart';

class AppShadow {
  static List<BoxShadow> button = [
    BoxShadow(
      color: kSecondary,
      blurRadius: 10,
      offset: Offset(3, 6), // changes position of shadow
    ),
  ];

  static List<BoxShadow> buttonWhite = [
    BoxShadow(
      color: kPrimaryColor,
      blurRadius: 15,
      offset: Offset(5, 10), // changes position of shadow
    ),
  ];

  static List<BoxShadow> bottomTab = [
    BoxShadow(
      color: kPrimaryColor,
      blurRadius: 15,
      offset: Offset(0, -10), // changes position of shadow
    ),
  ];
}
