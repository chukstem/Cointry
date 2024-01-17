import 'package:flutter/material.dart';
import 'package:crypto_app/size_config.dart';

import 'language.dart';

List<Color> indicators = [
  Color(0xffFED2C7),
  Color(0xFFCFD0F3),
  Color(0xff886b07),
  Color(0xffce8b27),
  Color(0xffab7d07),
];

Color yellow100 = Color(0xfff89503);
Color yellow80 = Color(0xfff89503);
Color yellow50 = Color(0xffFFDF8B);
Color yellow20 = Color(0xffFFEFC3);

const kWhite = Color(0xfff3f4f5);
const kSecondary = Color(0xffffffff);
const kPrimary = Color(0xFF111660);
const kPrimaryColor = Color(0xFF040950);
const kPrimaryDarkColor = Color(0xFF040950);
const kPrimaryLightColor = Color(0xFF0088FF);
const kPrimaryVeryLightColor = Color(0xFF9096F5);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF2836EA), Color(0xFFF6B205)],
);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Color(0xFF757575);

const kAnimationDuration = Duration(milliseconds: 200);

final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
String kEmailNullError = "Please Enter your email";
String kUsernameNullError = "Please Enter your username";
String kInvalidEmailError = "Please Enter Valid Email";
String kInvalidNumberError = "Please Enter Valid Phone Number";
String kPassNullError = "Please Enter your password";
String kShortPassError = "Password is too short. At least 5 characters";
String kMatchPassError = "Passwords don't match";
String kNamelNullError = "Please Enter your name";
String kPhoneNumberNullError = Language.enter_phone_number;

final otpInputDecoration = InputDecoration(
  contentPadding:
      EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: BorderSide(color: kTextColor),
  );
}
