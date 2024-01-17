import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../language.dart';
import '../screens/trade/pin_form.dart';

Pin(BuildContext context, title, body, url, type, setState) {
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
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  padding: EdgeInsets.only(
                      top: 20, left: 20, right: 20, bottom: MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10.0, bottom: 10, left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(Language.confirm, maxLines: 2,
                              style: TextStyle(color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),),
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
                              Language.about_to+" $type",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 5,),
                          Container(
                            child: Text(title,
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
                      new PinForm(body: body, url: url, setState: setState),
                      SizedBox(height: 20,),
                    ],
                  )),
            );
          });
    },
  );

}