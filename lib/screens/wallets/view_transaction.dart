import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';
import '../../../models/transactions_model.dart';
import '../../constants.dart';
import '../../language.dart';
import '../../models/crypto_transactions_model.dart';
import '../../radius.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import '../../widgets/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';

class ViewTransaction extends StatefulWidget {
  ViewTransaction({required this.Transaction, required this.symbol});
  CryptoTransactionsModel Transaction;
  String symbol;

  @override
  _ViewTransactionState createState() => _ViewTransactionState();
}

class _ViewTransactionState extends State<ViewTransaction> {
  bool progress=false;

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
            backAppbar(context, "Transaction"),
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
                          widget.Transaction.title,
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
                          "To",
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
                          widget.Transaction.to,
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
                          widget.Transaction.charge,
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
                          "Final Amount",
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
                          widget.Transaction.final_amount,
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
                  SizedBox(height: 10,),
                  Divider(),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.25,
                        child: Text(
                          "Hash",
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
                            Clipboard.setData(ClipboardData(text: widget.Transaction.hash));
                            Toast.show("Hash ID copied!", duration: Toast.lengthLong, gravity: Toast.bottom);
                          },
                          child: Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width*0.50,
                                  child: Text(
                                    widget.Transaction.hash.length > 18 ?
                                    widget.Transaction.hash.substring(0, 18)+"..." : widget.Transaction.hash,
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
                    width: MediaQuery.of(context).size.width*0.80,
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
      String name = "${widget.Transaction.title}-${Uuid().v4()}";
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
                                            pw.Text(widget.Transaction.title,
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
                                              child: pw.Text("To",
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
                                            pw.Text(widget.Transaction.to,
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
                                              child: pw.Text("HASH ID",
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
                                            pw.Text(widget.Transaction.hash,
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

  share(TransactionsModel obj) async{

  }
}
