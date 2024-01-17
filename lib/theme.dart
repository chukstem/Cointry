import 'package:flutter/material.dart';

import 'constants.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: kSecondary,
    fontFamily: "SofiaPro",
    appBarTheme: appBarTheme(),
    textTheme: textTheme(),
    primaryColor: kSecondary,
    inputDecorationTheme: inputDecorationTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

InputDecorationTheme inputDecorationTheme() {
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: kTextColor),
    //gapPadding: 10,
  );
  return InputDecorationTheme(
    floatingLabelBehavior: FloatingLabelBehavior.always,
    //contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
    enabledBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder,
    border: outlineInputBorder,
    hintStyle: TextStyle(color: Colors.grey[800]),
    labelStyle: TextStyle(color: Colors.grey[800]),
  );
}

TextTheme textTheme() {
  return TextTheme().copyWith(
      bodySmall: const TextStyle(color: Colors.grey),
      bodyMedium: const TextStyle(color: Colors.grey),
      bodyLarge: const TextStyle(color: Colors.grey),
      labelSmall: const TextStyle(color: kWhite),
      labelMedium: const TextStyle(color: kWhite),
      labelLarge: const TextStyle(color: kWhite),
      displaySmall: const TextStyle(color: kWhite),
      displayMedium: const TextStyle(color: kWhite),
      displayLarge: const TextStyle(color: kWhite),
    ).apply(
    bodyColor: Colors.grey,
    displayColor: Colors.grey
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    color: kSecondary,
    elevation: 0,
    iconTheme: IconThemeData(color: kSecondary),
    titleTextStyle: TextStyle(color: kSecondary),
    toolbarTextStyle: TextStyle(color: kSecondary)
  );
}
