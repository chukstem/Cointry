import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../language.dart';
import '../../screens/next_kin/save_next_kin.dart';
import 'package:toast/toast.dart';
import '../../constants.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';

class NextKin extends StatefulWidget {
  @override
  _NextKin createState() => _NextKin();
}



class _NextKin extends State<NextKin> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
        body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            backAppbar(context, Language.next_of_kin),
            SizedBox(height: 20,),
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width-20,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              child: Center(
                child: Text(Language.next_of_kin_body, style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 3,),
              ),
            ),
            SizedBox(height: 20,),
            ListMenu(
              text: Language.account_inactivity,
              desc: Language.account_inactivity_detail,
              icon: "assets/images/inactivity.svg",
            ),
            ListMenu(
              text: Language.contact_beneficiary,
              desc: Language.contact_beneficiary_detail,
              icon: "assets/icons/kyc.svg",
            ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Padding(
                padding: EdgeInsets.only(
                    top: 20, right: 20, left: 20, bottom: 25),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    minimumSize: Size.fromHeight(
                        60), // fromHeight use double.infinity as width and 40 is the height
                  ),
                  child: Text(
                    Language.add_next_kin,
                    style: TextStyle(
                        color: kSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: (){
                    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => SaveNextKin()));
                  },
                )),
             ),
          ],
        )));
  }




}



class ListMenu extends StatelessWidget {
  ListMenu({
    Key? key,
    required this.text,
    required this.desc,
    required this.icon,
  }) : super(key: key);

  final String text, desc, icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Color(0xFFF5F6F9),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width*0.15,
              padding: EdgeInsets.all(10.0),
              decoration: new BoxDecoration(
                color: kSecondary, // border color
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                icon,
                color: kPrimaryColor,
                width: 30,
                height: 30,
              ),
            ),
            SizedBox(width: 10),
            Container(
              width: MediaQuery.of(context).size.width*0.65,
              alignment: Alignment.topLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: TextStyle(fontSize: 18, color: kPrimaryDarkColor, overflow: TextOverflow.ellipsis), textAlign: TextAlign.start),
                  SizedBox(height: 10),
                  Text(desc, overflow: TextOverflow.ellipsis, maxLines: 8, style: TextStyle(fontSize: 14, color: Colors.grey, overflow: TextOverflow.ellipsis), textAlign: TextAlign.start,),
                ],
              ),
            )
          ],
      ),
    );
  }
}