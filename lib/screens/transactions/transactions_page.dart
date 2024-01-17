import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crypto_app/constants.dart';
import '../../language.dart';
import '../../models/crypto_transactions_model.dart';
import '../wallets/view_transaction.dart';

class Transactions extends StatefulWidget {
  List<CryptoTransactionsModel> tList;
  bool loading;
  Transactions({Key? key, required this.tList, required this.loading}) : super(key: key);

  @override
  _Transactions createState() => _Transactions();
}

class _Transactions extends State<Transactions> {

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
            ) :
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

  Container getListItem(CryptoTransactionsModel obj, int index, BuildContext context) {
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
                CupertinoPageRoute(builder: (context) => ViewTransaction(Transaction: obj, symbol: '',)));
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
                        .width * 0.20,
                    child: new CircleAvatar(
                        maxRadius: 23,
                        minRadius: 23,
                        child: CachedNetworkImage(
                          imageUrl: obj.img,
                          height: 45.0,
                          width: 45.0,
                        ),
                        backgroundColor: Colors.transparent),
                    padding: EdgeInsets.all(1.0),
                    decoration: new BoxDecoration(
                      color: kSecondary, // border color
                      shape: BoxShape.circle,
                    )),
                Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.70,
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
                                .width * 0.35,
                            child: Text(
                              obj.title,
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
                                .width * 0.35,
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
                                .width * 0.35,
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
                                .width * 0.35,
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