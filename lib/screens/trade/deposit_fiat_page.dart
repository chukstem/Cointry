import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:moncash_flutter/moncash_flutter.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../../components/get_products.dart';
import '../../constants.dart';
import '../../helper/formatter.dart';
import '../../language.dart';
import '../../models/banks_model.dart';
import '../../models/crypto_model.dart';
import '../../models/network_model.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import 'package:path/path.dart';
import '../../widgets/material.dart';
import '../../widgets/snackbar.dart';
import 'moncash.dart';

class DepositFiat extends StatefulWidget {
  CryptoModel obj;
  DepositFiat({required this.obj});

  @override
  _DepositFiat createState() => _DepositFiat();
}


typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);

class _DepositFiat extends State<DepositFiat> {
  bool error=false, showprogress = false, success=false;
  String walletAddress="", errormsg="", note="", popPath="", amount="0", bankname="", accountname="", accountnumber="";
  NetworkModel? item;
  TextEditingController amountController=TextEditingController();
  TextEditingController USDController=TextEditingController();
  List<BanksModel> bank_accounts = Products().getBankAccounts();
  BanksModel? bank_account;


  uploadPOP(StateSetter setState, context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token=prefs.getString("token");
    String? email=prefs.getString("email");
    if(popPath.isEmpty){
      setState(() {
        showprogress = false;
        error = true;
        errormsg = "Please select image file";
      });
    }else if(amount.isEmpty){
      setState(() {
        showprogress = false;
        error = true;
        errormsg = "Amount field is required";
      });
    }else if(note.isEmpty){
      setState(() {
        showprogress = false;
        error = true;
        errormsg = "Note field is required";
      });
    }else {
      setState(() {
        showprogress = true;
        error = false;
      });
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Processing',
        text: 'Submitting P.O.P',
      );
      try {
        File pop=File(popPath);
        var stream = new http.ByteStream(DelegatingStream.typed(pop.openRead()));
        var length = await pop.length();
        var uri = Uri.parse(Strings.url + "/upload-pop");
        var request = new http.MultipartRequest("POST", uri);
        var multipartFile = new http.MultipartFile(
            "image", stream, length, filename: basename(pop.path));
        request.files.add(multipartFile);
        request.headers['Content-Type'] = 'application/json';
        request.headers['Authentication'] = '$token';
        request.fields['token'] = token!;
        request.fields['email'] = email!;
        request.fields['amount'] = amount;
        request.fields['fiat_wallet_id'] = widget.obj.id;
        request.fields['network_id'] = item!.network_id;
        request.fields['note'] = note;
        var respond = await request.send();
        try{
          if (respond.statusCode == 200) {
            var responseData = await respond.stream.toBytes();
            var responseString = String.fromCharCodes(responseData);
            var jsondata = json.decode(responseString);
            if (jsondata["status"].toString() == "success") {
              setState(() {
                error = false;
                errormsg = jsondata["response_message"];
              });
            } else {
              setState(() {
                error = true;
                errormsg = jsondata["response_message"];
              });
            }
          } else {
            setState(() {
              error = true;
              errormsg = "Network connection error. Try again";
            });
          }
        } catch (e) {
          setState(() {
            error = true;
            errormsg = e.toString() + "Connection error.";
          });
        }
      } catch (e) {
        setState(() {
          error = true;
          errormsg = e.toString() + Language.network_error;
        });
      }
    }

    if(error!) {
      if(!showprogress){
        Snackbar().show(context, ContentType.failure, Language.error, errormsg!);
      }else {
        Snackbar().show(context, ContentType.failure, Language.error, errormsg!);
        Navigator.of(context).pop();
      }
    }else{
      Snackbar().show(context, ContentType.success, Language.success, errormsg!);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
    setState(() {
      showprogress = false;
    });

  }


  Future<void> start(BuildContext context) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var email = prefs.getString("email");
      var token = prefs.getString("token");
      try {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.loading,
          title: Language.loading,
          text: Language.processing,
        );
        String apiurl = Strings.url + "/deposit-moncash";
        var response = null;
        Map data = {
          'email': email,
          'amount': amount,
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
            error = true;
            errormsg = "Network connection error ";
          });
        }
        if (response != null && response.statusCode == 200) {
          var jsondata = json.decode(response.body);
          if (jsondata["status"] != null &&
              jsondata["status"].toString().contains("success")) {
            var orderid = jsondata["orderid"];
            Navigator.pop(context);
            WidgetsBinding.instance!.addPostFrameCallback((_) async {
              PaymentResponse? data = await Navigator.push(
                context, MaterialPageRoute(
                    builder: (context) =>
                        MonCashPayment(
                          isStaging: false,
                          amount: double.parse(amount),
                          clientId: Strings.moncash_client_id,
                          orderId: orderid,
                          clientSecret: Strings.moncash_client_secret,
                          loadingWidget: moncash(),
                        )),
              );
              if (data != null && data.status == paymentStatus.success &&
                  data.transanctionId != null) {
                setState(() {
                  setState(() {
                    error = false;
                    errormsg = "Your deposit was successful";
                  });
                  amountController.text = "";
                  amount = "";
                });
                Snackbar().show(context, ContentType.success, Language.success, errormsg);
              } else {
                if (data == null) {
                  setState(() {
                    error = true;
                    errormsg = "Payment Failed. Try again later";
                  });
                } else {
                  setState(() {
                    error = true;
                    errormsg = "${data.message}";
                  });
                }

              }
            });
          } else {
            setState(() {
              error = true;
              errormsg = "${jsondata["response_message"]}";
            });
            Navigator.pop(context);
          }
        } else {
          setState(() {
            error = true;
            errormsg = Language.network_error;
          });
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          error = true;
          errormsg = "Error Occurred. $e";
        });
        Navigator.pop(context);
      }
      if(error){
        Snackbar().show(context, ContentType.failure, Language.error, errormsg);
      }
  }

  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bankname = prefs.getString("bankname")!;
      accountnumber = prefs.getString("accountnumber")!;
      accountname = prefs.getString("accountname")!;
    });
  }


  @override
  void initState() {
    super.initState();
    getuser();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kWhite,
        body: Container(
        constraints: BoxConstraints(
        minHeight: 500, minWidth: double.infinity),
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            backAppbar(context, "Deposit "+widget.obj.networkModel[0].currency),
            SizedBox(height: 20,),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 20, right: 10, left: 20),
              child: Text("Select Payment Gateway", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),),
            ),
            Container(
                padding: EdgeInsets.all(1),
                margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                alignment: Alignment.center,
                height: 60,
                child: DropdownButtonFormField<NetworkModel>(
                  isExpanded: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                      filled: true,
                      hintText: "Select Payment",
                      hintStyle: TextStyle(color: Colors.grey[800], fontSize: 2),
                      fillColor: kSecondary
                  ),
                  hint: Text('Select Payment'),
                  onChanged: (NetworkModel? value){
                    setState(() {
                      item=value!;
                    });
                  },
                  items: widget.obj.networkModel.map((NetworkModel user){
                    return DropdownMenuItem<NetworkModel>(value: user, child: Text(user.network, style: TextStyle(color: Colors.black),),);
                  }).toList(),
                )
            ),
            SizedBox(height: 15),
            item!=null && item!.network_symbol == 'moncash'?
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               Container(
                 margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                 height: 50,
                 child: SizedBox(
                   height: 50,
                   child: TextField(
                     keyboardType: TextInputType.phone,
                     controller: amountController,
                     decoration: InputDecoration(
                       fillColor: kSecondary,
                       filled: true,
                       labelText: '${widget.obj.networkModel[0].currency_symbol}',
                       hintText: "Amount (${widget.obj.networkModel[0].network})",
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.all(
                           Radius.circular(5.0),
                         ),
                       ),
                     ),
                     onChanged: (value) {
                       setState(() {
                         double val=double.parse(value.replaceAll(",", ""))*double.parse(widget.obj.networkModel[0]
                             .price.replaceAll(",", ""));
                         USDController.text=format("$val", "2");
                         amount = "$value";
                       });
                     },
                   ),
                 ),
               ),
               SizedBox(height: 10),
               Container(
                 margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                 height: 60,
                 child: SizedBox(
                   height: 60,
                   child: TextField(
                     keyboardType: TextInputType.phone,
                     controller: USDController,
                     decoration: InputDecoration(
                       fillColor: kSecondary,
                       filled: true,
                       labelText: 'USD',
                       hintText: "Amount in (USD)",
                       isDense: true,
                     ),
                     onChanged: (value) {
                       setState(() {
                         var val=double.parse(value.replaceAll(",", ""))/double.parse(widget.obj.networkModel[0].price.replaceAll(",", ""));
                         var amt=format("$val", widget.obj.networkModel[0].decimals);
                         amountController.text="$amt";
                         amount = "$val";
                       });
                     },
                   ),
                 ),
               ),
               SizedBox(height: 10),
               Container(
                   child: Padding(
                       padding: EdgeInsets.only(
                           top: 20, right: 20, left: 20, bottom: 25),
                       child: ElevatedButton(
                         style: ElevatedButton.styleFrom(
                           backgroundColor: kPrimaryColor,
                           minimumSize: Size.fromHeight(
                               50), // fromHeight use double.infinity as width and 40 is the height
                         ),
                         child: Text(
                           Language.proceed,
                           style: TextStyle(
                               color: kSecondary,
                               fontSize: 16,
                               fontWeight: FontWeight.bold),
                         ),
                         onPressed: () {
                           if(double.parse(amountController.text.replaceAll(",", ""))>0) {
                            start(context);
                           }
                         },
                       ))),
               ],
              ) : item!=null && item!.network_symbol == 'bank'?
            Container(
                margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: kSecondary
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 20, right: 10, left: 20),
                      child: Text("Select Bank", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                    ),
                    Container(
                        padding: EdgeInsets.all(1),
                        margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                        alignment: Alignment.center,
                        height: 60,
                        child: DropdownButtonFormField<BanksModel>(
                          isExpanded: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                              ),
                              filled: true,
                              hintText: "Select Bank",
                              hintStyle: TextStyle(color: Colors.grey[800], fontSize: 2),
                              fillColor: kSecondary
                          ),
                          hint: Text('Select Bank'),
                          onChanged: (BanksModel? value){
                            setState(() {
                              bank_account=value!;
                            });
                          },
                          items: bank_accounts.map((BanksModel user){
                            return DropdownMenuItem<BanksModel>(value: user, child: Text(user.name, style: TextStyle(color: Colors.black),),);
                          }).toList(),
                        )
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Bank Account Name",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                        Text(
                          bank_account!=null? bank_account!.name : "Loading",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Reference Number",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                        Text(
                          bank_account!=null? bank_account!.reference_number : "Loading",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "IBAN",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                        Text(
                          bank_account!=null? bank_account!.iban : "Loading",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "SWIFT",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                        Text(
                          bank_account!=null? bank_account!.swift : "Loading",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Country",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                        Text(
                          bank_account!=null? bank_account!.country : "Loading",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "IFSC Code",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                        Text(
                          bank_account!=null? bank_account!.fsc : "Loading",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Holder Name",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                        Text(
                          bank_account!=null? bank_account!.account_holder_name : "Loading",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Holder Address",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                        Text(
                          bank_account!=null? bank_account!.account_holder_address : "Loading",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Bank Address",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                        Text(
                          bank_account!=null? bank_account!.address : "Loading",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(
                                top: 20, right: 20, left: 20, bottom: 25),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                minimumSize: Size.fromHeight(
                                    50), // fromHeight use double.infinity as width and 40 is the height
                              ),
                              child: Text(
                                'I Have Paid',
                                style: TextStyle(
                                    color: kSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                _pop(context);
                              },
                            ))),
                  ],
                )
            ) : item!=null && item!.network_symbol == 'virtual_account'?
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: kSecondary,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20,),
                  Center(
                    child: SizedBox(
                      height: 200,
                      width: 200,
                      child: Image.asset("assets/images/deposit_money.png"),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Padding(
                    padding: EdgeInsets.only(top: 10, right: 10, left: 10),
                    child: Text(
                      'DEPOSIT INTO THIS INSTANT ACCOUNT',
                      style: TextStyle(
                          color: kPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(height: 5,),
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 5, right: 20),
                          child: Text(
                            "Bank Details",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                            ),
                          ),
                        ),
                        SizedBox(height: 2),
                        Divider(),
                        SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bank Name",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87
                              ),
                            ),
                            Text(
                              bankname,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Divider(),
                        SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Account Name",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87
                              ),
                            ),
                            Text(
                              accountname,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Divider(),
                        SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Account Number",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: accountnumber));
                                Toast.show("Account number copied!", duration: Toast.lengthLong, gravity: Toast.bottom);
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(left: 10.00),
                                      child: Text('Acc/No: $accountnumber', style: TextStyle(color: kPrimary, fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,),
                                    ), // icon for error message
                                    Container(
                                        margin: EdgeInsets.only(left: 10.00),
                                        child: Icon(Icons.copy, color: kPrimary)),
                                  ]),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Divider(),
                        SizedBox(height: 10,),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  const Padding(
                    padding:
                    EdgeInsets.only(top: 10, right: 20, left: 20),
                    child: Text(
                      'Note: Deposit charge of N52 for amounts less than ₦2,500',
                      style: TextStyle(
                          color: kPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ) :
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                Center(
                  child: SizedBox(
                    height: 200,
                    width: 200,
                    child: Image.asset("assets/images/deposit_money.png"),
                  ),
                ),
              ],
            )
          ],
        ))));
  }


  _pop(BuildContext context2) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                    ),
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppBarDefault(context, "Upload POP"),
                        SizedBox(
                          height: 40,
                        ),
                        error ? Container(
                          //show error message here
                          margin: EdgeInsets.only(top: 10),
                          padding: EdgeInsets.all(10),
                          child: errmsg(errormsg, success, context),
                          //if error == true then show error message
                          //else set empty container as child
                        ) : Container(),
                        Container(
                          margin:
                          EdgeInsets.only(top: 20, right: 10, left: 20),
                          child: Text("Amount (${item!.currency_symbol})"),
                        ),
                        Container(
                          margin:
                          EdgeInsets.only(top: 20, right: 20, left: 20),
                          height: 60,
                          child: SizedBox(
                            height: 60,
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                fillColor: kSecondary,
                                filled: true,
                                hintText: "Amount (${item!.currency_symbol})",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  amount = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Container(
                          margin:
                          EdgeInsets.only(top: 20, right: 10, left: 20),
                          child: Text("Note"),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                          height: 60,
                          child: SizedBox(
                            height: 60,
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                fillColor: kSecondary,
                                filled: true,
                                hintText: "Note",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  note = value;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: InkWell(
                            onTap: () async {
                              final ImagePicker _picker = ImagePicker();
                              XFile? res = await _picker.pickImage(source: ImageSource.gallery);
                              if (res != null) {
                                setState(() {
                                  popPath =res.path;
                                });
                              }
                            },
                            child: popPath.isNotEmpty? SizedBox(
                              height: 200,
                              width: 200,
                              child: kIsWeb
                                  ? Image.network(popPath)
                                  : Image.file(File(popPath)),
                            ) : Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'Click here to select your P.O.P image (png, jpg & jpeg only allowed).',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: yellow100, fontSize: 18),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                            child: Padding(
                                padding: EdgeInsets.only(
                                    top: 20, right: 20, left: 20, bottom: 25),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor,
                                    minimumSize: Size.fromHeight(
                                        50), // fromHeight use double.infinity as width and 40 is the height
                                  ),
                                  child: showprogress ?
                                  SizedBox(
                                    height: 20, width: 20,
                                    child: CircularProgressIndicator(
                                      backgroundColor: kSecondary,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          kPrimaryColor),
                                    ),
                                  ) : Text(
                                    'Upload',
                                    style: TextStyle(
                                        color: kSecondary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    if (!showprogress) {
                                      setState(() {
                                        success = false;
                                        showprogress = true;
                                        error = false;
                                      });
                                      uploadPOP(setState, context);
                                    }
                                  },
                                ))),
                        SizedBox(height: 20),
                      ],
                    )),
              );
            });
      },
    );
  }

}