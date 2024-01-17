import 'package:flutter/material.dart';


class moncash extends StatefulWidget {
  moncash({Key? key}) : super(key: key);

  _moncashState createState() => _moncashState();

}

class _moncashState extends State<moncash>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          InkWell(
          onTap: (){
        Navigator.of(context).pop();
          },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        height: 60.0,
        child: Row(
        children: [
          Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 22,
          ),
          Expanded(
            child: Text(
              "Moncash",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  ?.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 30.0,
              ),
            ]),
          ),
      ),
      SizedBox(
        height: 30,
      ),
     CircularProgressIndicator(),
    ],
    ),
    );
  }
}
