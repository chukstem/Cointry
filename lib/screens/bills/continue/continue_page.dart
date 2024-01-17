import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import '../../../constants.dart';
import '../../../language.dart';
import '../../../radius.dart';
import '../../../size_config.dart';
import '../../../strings.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../trade/pin_form.dart';

class ConfirmTransaction extends StatefulWidget {
  ConfirmTransaction({required this.url, required this.body, required this.product, required this.amount, required this.charge, required this.beneficiary, required this.quantity, required this.fee});
  var body;
  final String url;
  final String charge;
  final String amount;
  final String product;
  final String beneficiary;
  final String quantity;
  final String fee;

  @override
  _ConfirmTransactionState createState() => _ConfirmTransactionState();
}

class _ConfirmTransactionState extends State<ConfirmTransaction> {
  String errormsg="By clicking the Submit button, You agree to our terms & conditions",  pin="", token="";
  bool error=true, success=false, showprogress=false, process=false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    SizeConfig().init(context);
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: kSecondary,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            backAppbar(context, "Payment Confirmation"),
            SizedBox(
              height: 40,
            ),
            Container(
              height: 800,
              margin: EdgeInsets.only(
                bottom: 5,
                top: 5,
                left: 10,
                right: 5,
              ),
              padding: EdgeInsets.only(left: 15.0, right: 2, top: 10, bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.25,
                        child: Text(
                          "Product",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 20,),
                      Container(
                        width: MediaQuery.of(context).size.width*0.55,
                        child: Text(
                          widget.product,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Divider(),
                  SizedBox(height: 10,),
                  widget.beneficiary.isNotEmpty ?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*0.25,
                            child: Text(
                              "Beneficiary",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.55,
                            child: Text(
                              widget.beneficiary,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Divider(),
                      SizedBox(height: 10,),
                    ],
                  ): SizedBox(),
                  widget.quantity.isNotEmpty ?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*0.25,
                            child: Text(
                              "Quantity",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.55,
                            child: Text(
                              widget.quantity,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Divider(),
                      SizedBox(height: 10,),
                    ],
                  ): SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.25,
                        child: Text(
                          Language.amount,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 20,),
                      Container(
                        width: MediaQuery.of(context).size.width*0.55,
                        child: Text(
                          Strings.default_fiat_symbol+widget.amount,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Divider(),
                  SizedBox(height: 10,),
                  widget.charge.isNotEmpty ?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*0.25,
                            child: Text(
                              Language.charge,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.55,
                            child: Text(
                              Strings.default_fiat_symbol+widget.charge,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Divider(),
                      SizedBox(height: 10,),
                    ],
                  ): SizedBox(),
                  widget.fee.isNotEmpty ?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*0.25,
                            child: Text(
                              "Processing Fee",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.55,
                            child: Text(
                              Strings.default_fiat_symbol+widget.fee,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Divider(),
                      SizedBox(height: 10,),
                    ],
                  ): SizedBox(),
                  SizedBox(height: 10,),
                  Container(
                    //show error message here
                    margin: EdgeInsets.only(bottom:10),
                    padding: EdgeInsets.all(10),
                    child: InkWell(onTap: (){
                      _openLink("https://vouchernet.com.ng/terms-of-use");
                    },
                      child: errmsg(errormsg, success, context),),
                    //if error == true then show error message
                    //else set empty container as child
                  ),
                  SizedBox(height: 10,),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: circularRadius(AppRadius.border12),
                        color: kPrimaryDarkColor
                    ),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      onPressed: () {
                        _pin(context);
                      },
                      child: Text(Language.proceed,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: kSecondary,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  _pin(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(Language.confirm, maxLines: 2, style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
                              InkWell(
                                child: Icon(
                                  Icons.cancel,
                                  size: 30,
                                  color: Colors.grey[300],
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Text(
                                "You want to purchase ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(width: 5,),
                            Container(
                              child: Text(
                                "${widget.product} of NGN ${widget.amount}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        PinForm(body: widget.body, url: widget.url, setState: setState),
                        SizedBox(height: 20,),
                      ],
                    )),
              );
            });
      },
    );
  }

  Future<void> _openLink(String link) async {
    Uri url=Uri.parse(link);
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: WebViewConfiguration(
          headers: <String, String>{'my_header_key': 'my_header_value'}),
    )) {
      throw Exception('Could not launch $url');
    }
  }
}
