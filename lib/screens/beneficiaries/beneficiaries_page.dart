import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_view/pin_code_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../../../models/bills_model.dart';
import '../../components/get_products.dart';
import '../../constants.dart';
import '../../helper/networklayer.dart';
import '../../language.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import 'package:http/http.dart' as http; 
import '../../widgets/material.dart';
import '../../widgets/snackbar.dart';
import '../sign_in/sign_in_screen.dart';

class Beneficiaries extends StatefulWidget {
  Beneficiaries({Key? key}) : super(key: key);

  @override
  _Beneficiaries createState() => _Beneficiaries();
}


class _Beneficiaries extends State<Beneficiaries> {
  String errormsg=Language.add_beneficiary_accounts;
  bool loading=true, error=true, process=false, showprogress=false, validated=false, success=false;
  String username="", bankname="", name="", account_number="", narration="", pin="", accountnumber="", amount="", token="";


  Bills? bank;
  List<Bills> banks=Products().getProduct("banks");
  Bills? beneficiary;
  List<Bills> beneficiaries=[];

  fetchQuery() async {
    setState(() {
      loading=true;
    });
    try {
      await getQuery(http.Client());
    }catch(e){}
    await new Products().getProducts();
    setState(() {
      beneficiaries=Products().getProduct("beneficiaries");
      loading=false;
    });
  }

  saveBeneficiary(setState) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    token = prefs.getString("token")!;
    pin = prefs.getString("pin")!;

    if(accountnumber.isEmpty){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_account_number;
      });
    }else if(bank==null){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.select_service;
      });
    }else if(process==false){
      showAlertDialog(context, 'You want to add $name ($accountnumber) as beneficiary', setState);
    }else{
      setState(() {
        showprogress = true;
        error=false;
      });
      process=false;

      String apiurl = Strings.url+"/add-beneficiary";
      var response = null;
      Map data = {
        'account_number': accountnumber,
        'username': username,
        'account_name': name,
        'bank_code': bank!.plan,
        'bank_name': bank!.name,
        'pin': pin
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
          var jsonb = json.decode(response.body);
          if (jsonb["status"] != null &&
              jsonb["status"].toString().contains("success")) {
            setState(() {
              error = false;
              showprogress = false;
              errormsg = jsonb["response_message"];
              success = true;
              accountnumber="";
            });

          }else if (jsonb["status"].toString().contains("error") &&
              jsonb["response_message"].toString().contains("Authentication")) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.clear();
            Toast.show(Language.session_expired, duration: Toast.lengthLong, gravity: Toast.bottom);
            Navigator.pushNamedAndRemoveUntil(context, SignInScreen.routeName, (
                route) => false,);

          }  else {
            setState(() {
              showprogress = false; //don't show progress indicator
              error = true;
              errormsg = jsonb["response_message"];
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

      Navigator.pop(context);
      if(success){
        Snackbar().show(context, ContentType.success, Language.success, errormsg);
      }else{
        Snackbar().show(context, ContentType.failure, Language.error, errormsg);
      }
    }
    fetchQuery();
  }

  validate(setState) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    token = prefs.getString("token")!;
    if(accountnumber.isEmpty){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.enter_account_number;
      });
    } else if(bank==null){
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = Language.select_bank;
      });
    }else{
      setState(() {
        //show progress indicator on click
        showprogress = true;
        error=false;
      });
      String apiurl = Strings.url+"/validate-bank"; //api url
      var response = null;
      Map data = {
        'username': username,
        'customer_id': accountnumber,
        'bank_code': bank!.plan,
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
          var jsonElectricity = json.decode(response.body);
          if (jsonElectricity["status"] != null &&
              jsonElectricity["status"].toString().contains("success")) {
            setState(() {
              error = true;
              showprogress = false;
              validated=true;
              success = true;
              errormsg = jsonElectricity["customer_name"].toString();
              name=jsonElectricity["customer_name"].toString();
            });

          } else {
            setState(() {
              showprogress = false; //don't show progress indicator
              error = true;
              errormsg = jsonElectricity["response_message"];
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
  }


  showAlertDialog(BuildContext context, String msg, setState){
    setState(() {
      errormsg="";
      showprogress=false;
    });
    Widget cancel=ElevatedButton(onPressed: (){
      Navigator.of(context).pop();
      setState(() {
        showprogress=false;
      });
    }, child: Text("Cancel"));

    AlertDialog alert=AlertDialog(
      insetPadding: EdgeInsets.all(1),
      backgroundColor: kPrimaryColor,
      content: Container(
        width: MediaQuery.of(context).size.width,
        child: PinCode(
          title: Language.confirm,
          subtitle: Language.enter_pin_proceed,
          backgroundColor: kPrimaryColor,
          codeLength: 4,
          error: errormsg,
          keyboardType: KeyboardType.numeric,
          onChange: (String code) {
            if(pin==code){
              setState(() {
                showprogress = false; //don't show progress indicator
                error = true;
                errormsg="Pin Accepted!";
                process=true;
                saveBeneficiary(setState);
              });

            }else{
              setState(() {
                showprogress = false; //don't show progress indicator
                error = true;
                errormsg=Language.incorrect_pin;
              });
            }
            Navigator.of(context).pop();
          },
          obscurePin: true,
        ),
      ),
      actions: [cancel],
    );
    showDialog(context: context,
      builder: (BuildContext context){
        return alert;
      },
    );
  }


  @override
  void initState() {
    super.initState();
    fetchQuery();
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
        backgroundColor: Color(0xFFf2f2f2),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            backAppbar(context, Language.beneficiaries),
            SizedBox(
              height: 20,
            ),
            loading? Container(
                margin: EdgeInsets.all(50),
                child: Center(
                    child: CircularProgressIndicator()))
                :
            beneficiaries.length <= 0 ?
            Container(
              height: 200,
              margin: EdgeInsets.all(20),
              child: Center(
                child: Text(Language.empty, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
              ),
              )
              : Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(0),
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 0),
                        itemCount: beneficiaries.length,
                        itemBuilder: (context, index) {
                          return getListItem(
                              beneficiaries[index], index, context);
                        })
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _addBeneficiary(context);
        },
        backgroundColor: kPrimaryColor,
        label: Text(Language.add_beneficiary),
        icon: Icon(Icons.add, size: 40,),
      ),);
  }



  _addBeneficiary(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Container(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppBarDefault(context, Language.add_beneficiary),
                            SizedBox(
                              height: 20,
                            ),
                            error? Container(
                              //show error message here
                              margin: EdgeInsets.only(bottom:10),
                              padding: EdgeInsets.all(10),
                              child: errmsg(errormsg, success, context),
                              //if error == true then show error message
                              //else set empty container as child
                            ) : Container(),

                            Container(
                                padding: EdgeInsets.all(1),
                                margin: EdgeInsets.only(left: 20, right: 20),
                                alignment: Alignment.center,
                                height: 60,
                                child: DropdownButtonFormField<Bills>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      filled: true,
                                      hintText: Language.select_bank,
                                      hintStyle: TextStyle(color: Colors.grey[800], fontSize: 2),
                                      fillColor: kSecondary
                                  ),
                                  hint: Text(Language.select_bank),
                                  value: bank,
                                  onChanged: (Bills? value){
                                    setState(() {
                                      bank=value!;
                                      validated=false;
                                    });
                                  },
                                  items: banks.map((Bills user){
                                    return DropdownMenuItem<Bills>(value: user, child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      alignment: Alignment.topLeft,
                                      padding: EdgeInsets.only(left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          color: kSecondary,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [BoxShadow(color: kSecondary,
                                            blurRadius: 2,
                                            offset: Offset(4, 8),),]),
                                      child: Text(user.name, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: Colors.black), textAlign: TextAlign.start),
                                    ),);
                                  }).toList(),
                                )
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              margin:
                              EdgeInsets.only(top: 20, right: 20, left: 20),
                              height: 60,
                              child: SizedBox(
                                height: 60,
                                child: TextField(
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                    LengthLimitingTextInputFormatter(10)],
                                  decoration: InputDecoration(
                                    fillColor: kSecondary,
                                    filled: true,
                                    hintText: Language.account_number,
                                    isDense: true, 
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value){
                                    accountnumber=value;
                                    setState(() {
                                      validated=false;
                                    });
                                    if(accountnumber.length == 10 && bank!=null && !showprogress) {
                                      setState(() {
                                        showprogress = true;
                                        error = false;
                                      });
                                      validate(setState);
                                    }
                                  },
                                ),
                              ),
                            ),
                            validated?
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
                                      child: showprogress?
                                      SizedBox(
                                        height:20, width:20,
                                        child: CircularProgressIndicator(
                                          backgroundColor: kSecondary,
                                          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                                        ),
                                      ) : Text(
                                        Language.proceed,
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
                                          saveBeneficiary(setState);
                                        }
                                      },
                                    )))
                                :
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
                                      child: showprogress?
                                      SizedBox(
                                        height:20, width:20,
                                        child: CircularProgressIndicator(
                                          backgroundColor: kSecondary,
                                          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                                        ),
                                      ) : Text(
                                        Language.proceed,
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
                                          validate(setState);
                                        }
                                      },
                                    ))),
                            SizedBox(height: 20,),
                          ],
                        )));
              });
        },
        context: context);
  }

  Container getListItem(Bills obj, int index, BuildContext context) {
    return Container(
      child: Card(
        color: kWhite,
        margin: EdgeInsets.only(
          bottom: 5,
          top: 5,
          left: 10,
          right: 10,
        ),
        child: InkWell(
          onTap: () => {},
          child: Container(
                padding: EdgeInsets.only(left: 15.0, right: 5, top: 10, bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                   Container(
                            child: Text(
                            obj.name,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                          ),
                          SizedBox(height: 2,),
                              Container(
                                child: Text(
                                  obj.amount,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(height: 2,),
                              Container(
                                child: Text(
                                  obj.size,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                        ],
                    ),
              ),
        ),
      ),
    );
  }


}