import 'package:flutter/material.dart';

import '../constants.dart';

BorderRadiusGeometry circularRadius(double radius) {
  return BorderRadius.all(Radius.circular(radius));
}
Widget errmsg(String text, bool success, BuildContext context){
  //error message widget.
  return Container(
    padding: EdgeInsets.all(5.00),
    margin: EdgeInsets.only(bottom: 10.00, left: 10, right: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      color: !success? yellow50 : Colors.green,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width*0.60,
        margin: EdgeInsets.only(left: 10.00),
        child: Text(text, style: TextStyle(color: !success? kPrimaryColor : kSecondary, fontSize: 15),
          overflow: TextOverflow.ellipsis,
          maxLines: 4,),
      ), // icon for error message
      Container(
        margin: EdgeInsets.only(right: 10.00),
        child: !success? Icon(Icons.info, color: kSecondary) : Icon(Icons.check, color: kSecondary),
      ),
    ]),
  );
}