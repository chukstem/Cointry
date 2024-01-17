import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';

class TransferMenu extends StatelessWidget {
  TransferMenu({
    Key? key,
    required this.text,
    required this.desc,
    required this.icon,
    this.press,
  }) : super(key: key);

  final String text, desc, icon;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          backgroundColor: indicators[1],
        ),
        onPressed: press,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: MediaQuery.of(context).size.width*0.15,
                height: 45,
                child: CircleAvatar(
                    maxRadius: 23,
                    minRadius: 23,
                    child: SvgPicture.asset(
                      icon,
                      color: kPrimaryColor,
                      width: 20,
                      height: 20,
                    ),
                    backgroundColor: kSecondary),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: indicators[1], // border color
                  shape: BoxShape.circle,
                )), 
            Container(
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width*0.70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: TextStyle(fontSize: 18, color: Colors.black, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold)),
                  Text(desc, overflow: TextOverflow.ellipsis,
                      maxLines: 4, style: TextStyle(fontSize: 14, color: Colors.black, overflow: TextOverflow.ellipsis)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
