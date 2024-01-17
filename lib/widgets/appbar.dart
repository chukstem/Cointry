import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';

 Widget backAppbar(BuildContext context, String title) {
  return Container(
    height: 150,
    decoration: BoxDecoration(
      color: kPrimaryColor,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0)),
    ),
    padding: EdgeInsets.only(top: 10),
    child: Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: kPrimaryLightColor,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0), topRight: Radius.circular(10.0), topLeft: Radius.circular(10.0)),
              ),
              margin: EdgeInsets.only(left: 15,),
              padding: EdgeInsets.all(5),
              alignment: Alignment.center,
              child: InkWell(
                child: Icon(
                  Icons.arrow_back,
                  color: kSecondary,
                  size: 22,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              )
          ),
          Text(title, maxLines: 2, style: TextStyle(color: kSecondary, fontSize: 25, fontWeight: FontWeight.bold),),
          Container(margin: EdgeInsets.only(right: 28),),
        ],
      ),
    ),
  );
}
 Widget AppBarDefault(BuildContext context, String title) {
  return Container(
    height: 80,
    decoration: BoxDecoration(
      color: kPrimaryColor,
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    ),
    padding: EdgeInsets.only(top: 10),
    child: Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              width: 28.w,
              height: 28.w,
              margin: EdgeInsets.only(left: 15,),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: kPrimaryLightColor,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0), topRight: Radius.circular(10.0), topLeft: Radius.circular(10.0)),
              ),
              alignment: Alignment.center,
              child: InkWell(
                child: Icon(
                  Icons.arrow_back,
                  color: kSecondary,
                  size: 22,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              )
          ),
          Text(title, maxLines: 2, style: TextStyle(color: kSecondary, fontSize: 25, fontWeight: FontWeight.bold),),
          Container(margin: EdgeInsets.only(right: 28),),
        ],
      ),
    ),
  );
}







