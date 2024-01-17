import 'package:crypto_app/screens/wallets/view_fiat_transaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crypto_app/constants.dart';
import 'package:flutter_svg/svg.dart';
import '../../language.dart';
import '../../models/fiat_transaction_model.dart';

class FiatTransactions extends StatefulWidget {
  List<FiatTransactionModel> tList;
  bool loading;
  FiatTransactions({Key? key, required this.tList, required this.loading}) : super(key: key);

  @override
  _FiatTransactions createState() => _FiatTransactions();
}

class _FiatTransactions extends State<FiatTransactions> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(0),
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.loading? Container(
                margin: EdgeInsets.all(50),
                child: Center(
                    child: CircularProgressIndicator()))
                :
            widget.tList.length <= 0 ?
            Container(
              height: 200,
              margin: EdgeInsets.all(20),
              child: Center(
                child: Text(Language.empty, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
              ),
            )
                :
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 0),
                itemCount: widget.tList.length,
                itemBuilder: (context, index) {
                  return getListItem(
                      widget.tList[index], index, context);
                }),
            SizedBox(height: 40,),
          ],
        ));
  }

  Container getListItem(FiatTransactionModel obj, int index, BuildContext context) {
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
          onTap: (){
            Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => ViewFiatTransaction(Transaction: obj)));
          },
          child: Container(
            padding: EdgeInsets.only(
                left: 5.0, right: 5, top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.15,
                    child: new CircleAvatar(
                      maxRadius: 23,
                      minRadius: 23,
                      child: obj.status=="success" || obj.status=="Success" ?
                      SvgPicture.asset(
                        "assets/icons/Success.svg" ,
                        height: 20.0,
                        width: 20.0,
                        color: Colors.green,
                      ) : SvgPicture.asset(
                        "assets/icons/pending.svg",
                        height: 35.0,
                        width: 35.0,
                        color: kPrimaryVeryLightColor,
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    padding: EdgeInsets.all(10.0),
                    decoration: new BoxDecoration(
                      color: Colors.transparent, // border color
                      shape: BoxShape.circle,
                    )),
                Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.75,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.50,
                            child: Text(
                              obj.services,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 17.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.25,
                            child: Text(
                              obj.amount,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 7,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.50,
                            child: Text(
                              obj.time,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.25,
                            child: Text(
                              obj.status,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                    ],
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