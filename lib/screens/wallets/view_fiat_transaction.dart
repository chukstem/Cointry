import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import '../../../models/fiat_transaction_model.dart';
import '../../constants.dart';
import '../../language.dart';
import '../../radius.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import '../../widgets/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';

import '../home/home_screen.dart';

class ViewFiatTransaction extends StatefulWidget {
  ViewFiatTransaction({required this.Transaction});
  FiatTransactionModel Transaction;

  @override
  _ViewFiatTransactionState createState() => _ViewFiatTransactionState();
}


class _ViewFiatTransactionState extends State<ViewFiatTransaction> {
  String errormsg="", comment="", email="", token="";
  bool error=false, success=false, showprogress=false, loading=false;
  bool progress=false, progress2=false;

  dispute() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString("email")!;
    token = prefs.getString("token")!;
    if(comment.isEmpty){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Please Enter Comment";
      });
    }else{
      setState(() {
        showprogress = true;
        error=false;
      });
      Navigator.pop(context);
      showAlertDialog(context);
      String apiurl = Strings.url+"/dispute_transaction";
      var response = null;
      Map data = {
        'reference': widget.Transaction.reference,
        'email': email,
        'comment': comment,
      };

      var body = json.encode(data);
      try {
        response = await http.post(Uri.parse(apiurl),
            headers: {
              "Content-Type": "application/json",
              "Authentication": "Bearer $token"},
            body: body
        );
      } catch (e) {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = Language.network_error;
        });
      }
      if (response != null && response.statusCode == 200) {
        try {
          var jsondata = json.decode(response.body);
          if (jsondata["status"] != null &&
              jsondata["status"].toString().contains("success")) {
            setState(() {
              error = true;
              showprogress = false;
              success=true;
              errormsg = jsondata["response_message"];
              comment="";
            });

          }else if (jsondata["status"].toString().contains("error") &&
              jsondata["response_message"].toString().contains("Authentication")) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.clear();
            Toast.show(Language.session_expired, duration: Toast.lengthLong, gravity: Toast.bottom);
            Get.offAllNamed(HomeScreen.routeName);

          }  else {
            setState(() {
              showprogress = false; //don't show progress indicator
              error = true;
              errormsg = jsondata["response_message"];
            });
          }
        } catch (e) {
          setState(() {
            showprogress = false; //don't show progress indicator
            error = true;
            errormsg = Language.network_error;
          });
        }
      } else {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = Language.network_error;
        });

      }
    }

    Navigator.pop(context);
    showAlertDialog(context);
  }





  @override
  void initState() {
    super.initState();
  }

  showAlertDialog(BuildContext context){
    showDialog(context: context,
      builder: (BuildContext context){
        return StatefulBuilder(builder: (context, setState){
          return AlertDialog(
            insetPadding: EdgeInsets.all(10),
            title: Text("DISPUTE TRANSACTION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
            content: Container(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    error? Container(
                      //show error message here
                      margin: EdgeInsets.only(top:10),
                      padding: EdgeInsets.all(5),
                      child: errmsg(errormsg, success, context),
                      //if error == true then show error message
                      //else set empty container as child
                    ) : Container(),
                    Container(
                      margin:
                      EdgeInsets.only(top: 20, right: 10, left: 10),
                      height: 60,
                      child: SizedBox(
                        height: 60,
                        child: TextField(
                          keyboardType: TextInputType.text,
                          maxLength: 150,
                          decoration: InputDecoration(
                            fillColor: kSecondary,
                            filled: true,
                            hintText: Language.comment,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                          ),
                          onChanged: (value){
                            comment=value;
                          },
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top: 20, right: 10, left: 10, bottom: 15),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            minimumSize: Size.fromHeight(
                                50), // fromHeight use double.infinity as width and 40 is the height
                          ),
                          child: showprogress?
                          SizedBox(
                            height:20, width:20,
                            child: CircularProgressIndicator(
                              backgroundColor: kSecondary,
                              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                            ),
                          ) : Text(
                            'Send',
                            style: TextStyle(
                                color: kSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: (){
                            if(!showprogress) {
                              setState(() {
                                success = false;
                                showprogress = true;
                                error = false;
                              });
                              dispute();
                            }
                          },
                        ))
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
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
            backAppbar(context, Language.transactions),
            SizedBox(
              height: 20,
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            right: 20
                        ),
                        child:     Text(Strings.app_name, style: TextStyle(color: kPrimaryColor, fontSize: 29, fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Divider(),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.25,
                        child: Text(
                          "Transaction",
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
                          widget.Transaction.services,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.25,
                        child: Text(
                          "Transaction Type",
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
                          widget.Transaction.type.toUpperCase(),
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
                          widget.Transaction.beneficiary,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.25,
                        child: Text(
                          "Time",
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
                          widget.Transaction.time,
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
                          widget.Transaction.amount,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.25,
                        child: Text(
                          "Status",
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
                        child: widget.Transaction.status=="pending" || widget.Transaction.status=="Pending" ?
                        Text(
                          widget.Transaction.status.toUpperCase(),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: yellow80,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ) : widget.Transaction.status=="success" || widget.Transaction.status=="Success" ?
                        Text(
                          widget.Transaction.status.toUpperCase(),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ) :
                        Text(
                          widget.Transaction.status.toUpperCase(),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  widget.Transaction.token.isNotEmpty ?
                  Column(
                    children: [
                      SizedBox(height: 10,),
                      Divider(),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*0.25,
                            child: Text(
                              "Token",
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
                            child: InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: widget.Transaction.token));
                                Toast.show("Token copied!", duration: Toast.lengthLong, gravity: Toast.bottom);
                              },
                              child: Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.45,
                                      child: Text(
                                        widget.Transaction.token,
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                    Icon(
                                      Icons.copy,
                                      color: kPrimaryColor,
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ) ,
                    ],
                  ) : SizedBox(width: 0,),

                  SizedBox(height: 10,),
                  Divider(),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.25,
                        child: Text(
                          "Reference",
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
                        child: InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: widget.Transaction.reference));
                            Toast.show("Reference copied!", duration: Toast.lengthLong, gravity: Toast.bottom);
                          },
                          child: Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width*0.50,
                                  child: Text(
                                    widget.Transaction.reference.substring(0, 18)+"...",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ),
                                Icon(
                                  Icons.copy,
                                  color: kPrimaryColor,
                                ),
                              ]),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Divider(),
                  SizedBox(height: 10,),
                  Container(
                    width: MediaQuery.of(context).size.width*0.99,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width*0.40,
                          padding: EdgeInsets.only(
                              bottom: 2, left: 2, right: 2, top: 2),
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: circularRadius(AppRadius.border12),
                              color: kPrimaryColor
                          ),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            onPressed: () {
                              showAlertDialog(context);
                            },
                            child: Text(
                              "DISPUTE",
                              style: TextStyle(
                                fontSize: 14.0,
                                color: kSecondary,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30,),
                        Container(
                          width: MediaQuery.of(context).size.width*0.40,
                          padding: EdgeInsets.only(
                              bottom: 2, left: 2, right: 2, top: 2),
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: circularRadius(AppRadius.border12),
                              color: yellow100
                          ),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            onPressed: () {
                              if(!progress){
                                setState(() {
                                  progress=true;
                                });
                                Timer(Duration(seconds: 2), () async =>
                                {
                                  save()
                                });
                              }
                            },
                            child: progress?
                            SizedBox(
                              height:20, width:20,
                              child: CircularProgressIndicator(
                                backgroundColor: kSecondary,
                                valueColor: AlwaysStoppedAnimation<Color>(yellow100),
                              ),
                            ) : Text(
                              "DOWNLOAD RECEIPT",
                              style: TextStyle(
                                fontSize: 14.0,
                                color: kSecondary,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Future<String> getExternalDocumentPath() async {

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    Directory _directory = Directory("");
    if (Platform.isAndroid) {
      _directory = Directory("/storage/emulated/0/Download");
    } else {
      _directory = await getApplicationDocumentsDirectory();
    }

    final exPath = _directory.path;
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  Future<String> get _localPath async {
    final String directory = await getExternalDocumentPath();
    return directory;
  }

  Future<void> save() async {
    try {
      String name = "${widget.Transaction.services}-${Uuid().v4()}";
      final pdf = pw.Document();
      pdf.addPage(
          pw.Page(
              build: (pw.Context context) =>
                  pw.Container(
                    child: pw.Column(
                        children: [
                          pw.Text(Strings.app_name, style: pw.TextStyle(color: PdfColor.fromInt(0xFF280150), fontSize: 29, fontWeight: pw.FontWeight.bold),),
                          pw.SizedBox(height: 40),
                          pw.Text("TRANSACTION RECEIPT", style: pw.TextStyle(color: PdfColor.fromInt(0xFF280150), fontSize: 29, fontWeight: pw.FontWeight.bold),),
                          pw.SizedBox(height: 50),
                          pw.Table(
                              children: [
                                pw.TableRow(
                                    children: [
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment
                                              .start,
                                          mainAxisAlignment: pw.MainAxisAlignment.start,
                                          children: [
                                            pw.SizedBox(height: 20),
                                            pw.Container(
                                              width: 170,
                                              child: pw.Text("Transaction",
                                                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                            ),
                                            pw.SizedBox(height: 20),
                                          ]
                                      ),
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                                          mainAxisAlignment: pw.MainAxisAlignment.end,
                                          children: [
                                            pw.SizedBox(height: 20),
                                            pw.Text(widget.Transaction.services,
                                                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                            pw.SizedBox(height: 20),

                                          ]
                                      ),
                                    ]
                                ),
                                pw.TableRow(
                                    children: [
                                      pw.Divider(thickness: 1),
                                      pw.Divider(thickness: 1),
                                    ]),
                                pw.TableRow(
                                    children: [
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment
                                              .start,
                                          mainAxisAlignment: pw.MainAxisAlignment.start,
                                          children: [
                                            pw.SizedBox(height: 20),
                                            pw.Container(
                                              width: 180,
                                              child: pw.Text("Transaction Type",
                                                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                            ),
                                            pw.SizedBox(height: 20),

                                          ]
                                      ),
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                                          mainAxisAlignment: pw.MainAxisAlignment.end,
                                          children: [
                                            pw.SizedBox(height: 20),
                                            pw.Text(widget.Transaction.type.toUpperCase(),
                                                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                            pw.SizedBox(height: 20),

                                          ]
                                      ),
                                    ]
                                ),
                                pw.TableRow(
                                    children: [
                                      pw.Divider(thickness: 1),
                                      pw.Divider(thickness: 1),
                                    ]),
                                pw.TableRow(
                                    children: [
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          mainAxisAlignment: pw.MainAxisAlignment.start,
                                          children: [
                                            pw.SizedBox(height: 20),
                                            pw.Container(
                                              width: 150,
                                              child: pw.Text("Beneficiary",
                                                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                            ),
                                            pw.SizedBox(height: 20),

                                          ]
                                      ),
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                                          mainAxisAlignment: pw.MainAxisAlignment.end,
                                          children: [
                                            pw.SizedBox(height: 20),
                                            pw.Text(widget.Transaction.beneficiary,
                                                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                            pw.SizedBox(height: 20),

                                          ]
                                      ),
                                    ]
                                ),
                                pw.TableRow(
                                    children: [
                                      pw.Divider(thickness: 1),
                                      pw.Divider(thickness: 1),
                                    ]),
                                pw.TableRow(
                                    children: [
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          mainAxisAlignment: pw.MainAxisAlignment.start,
                                          children: [
                                            pw.SizedBox(height: 20),
                                            pw.Container(
                                              width: 150,
                                              child: pw.Text(Language.amount,
                                                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                            ),
                                            pw.SizedBox(height: 20),

                                          ]
                                      ),
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                                          mainAxisAlignment: pw.MainAxisAlignment.end,
                                          children: [
                                            pw.SizedBox(height: 20),
                                            pw.Text(widget.Transaction.amount,
                                                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                            pw.SizedBox(height: 20),

                                          ]
                                      ),
                                    ]
                                ),
                                pw.TableRow(
                                    children: [
                                      pw.Divider(thickness: 1),
                                      pw.Divider(thickness: 1),
                                    ]),
                                pw.TableRow(
                                    children: [
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          mainAxisAlignment: pw.MainAxisAlignment.start,
                                          children: [
                                            pw.SizedBox(height: 20),
                                            pw.Container(
                                              width: 150,
                                              child: pw.Text("Date",
                                                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                            ),
                                            pw.SizedBox(height: 20),

                                          ]
                                      ),
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                                          mainAxisAlignment: pw.MainAxisAlignment.end,
                                          children: [
                                            pw.SizedBox(height: 20),
                                            pw.Text(widget.Transaction.time,
                                                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                            pw.SizedBox(height: 20),

                                          ]
                                      ),
                                    ]
                                ),
                                pw.TableRow(
                                    children: [
                                      pw.Divider(thickness: 1),
                                      pw.Divider(thickness: 1),
                                    ]),
                                pw.TableRow(
                                    children: [
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          mainAxisAlignment: pw.MainAxisAlignment.start,
                                          children: [
                                            pw.SizedBox(height: 20),
                                            pw.Container(
                                              width: 150,
                                              child: pw.Text("Status",
                                                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                            ),
                                            pw.SizedBox(height: 20),

                                          ]
                                      ),
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                                          mainAxisAlignment: pw.MainAxisAlignment.end,
                                          children: [
                                            pw.SizedBox(height: 20),
                                            pw.Text(widget.Transaction.status.toUpperCase(),
                                                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                            pw.SizedBox(height: 20),

                                          ]
                                      ),
                                    ]
                                ),
                                pw.TableRow(
                                    children: [
                                      pw.Divider(thickness: 1),
                                      pw.Divider(thickness: 1),
                                    ]),
                                pw.TableRow(
                                    children: [
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          mainAxisAlignment: pw.MainAxisAlignment.start,
                                          children: [
                                            pw.SizedBox(height: 20),
                                            pw.Container(
                                              width: 150,
                                              child: pw.Text("TXN ID",
                                                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                            ),
                                            pw.SizedBox(height: 20),

                                          ]
                                      ),
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                                          mainAxisAlignment: pw.MainAxisAlignment.end,
                                          children: [
                                            pw.SizedBox(height: 20),
                                            pw.Text(widget.Transaction.reference,
                                                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                            pw.SizedBox(height: 20),

                                          ]
                                      ),
                                    ]
                                ),
                                pw.TableRow(
                                    children: [
                                      pw.Divider(thickness: 1),
                                      pw.Divider(thickness: 1),
                                    ]),
                              ]
                          ),
                        ]
                    ),
                  )
          ));
      final path = await _localPath;

      final file = File('$path/$name.pdf');
      await file.writeAsBytes(await pdf.save());
      Toast.show("Saved to ${file.path}", duration: Toast.lengthLong,
          gravity: Toast.bottom);
      OpenFile.open(file.path);
    }catch(e){
      Toast.show("Error: $e", duration: Toast.lengthLong, gravity: Toast.bottom);
    }
    setState(() {
      progress=false;
    });
  }


}
