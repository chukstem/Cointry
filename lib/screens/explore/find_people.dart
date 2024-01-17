import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../../constants.dart';
import 'package:http/http.dart' as http;
import '../../language.dart';
import '../../strings.dart';
import '../../widgets/image.dart';
import '../profile/user_profile_screen.dart';

class FindPeople extends StatefulWidget {
  bool loading;
  List<UserModel> tList;
  FindPeople(
      {Key? key, required this.loading, required this.tList})
      : super(key: key);

  @override
  _FindPeopleState createState() => _FindPeopleState();
}

class _FindPeopleState extends State<FindPeople> {

  String token="", username="", errormsg="";
  bool error=false, showprogress=false, success=false; 
  
  
  @override
  void initState() {
    super.initState(); 
  }

  follow(int id, String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username")!;
    String token = prefs.getString("token")!;
    setState(() {
      widget.tList![id].loading=true;
    });
    String apiurl = Strings.url+"/follow_user";
    var response = null;
    try {
      Map data = {
        'username': username,
        'user': user,
      };
      var body = json.encode(data);
      response = await http.post(Uri.parse(apiurl),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "$token"},
          body: body
      );
      if (response.statusCode == 200) {
        var jsonBody = json.decode(response.body);
        if(jsonBody["status"]=="success"){
          setState(() {
            widget.tList!.removeAt(id);
          });
          Toast.show("You have followed @"+user, duration: Toast.lengthLong, gravity: Toast.bottom);
        }
      }
    } catch (e) {
      Toast.show(Language.network_error, duration: Toast.lengthLong, gravity: Toast.bottom);
    }

    setState(() {
      widget.tList![id].loading=false;
    });
  }

  unfollow(int id, String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username")!;
    String token = prefs.getString("token")!;
    setState(() {
      widget.tList![id].loading=true;
    });
    String apiurl = Strings.url+"/unfollow_user";
    var response = null;
    try {
      Map data = {
        'username': username,
        'user': user,
      };
      var body = json.encode(data);
      response = await http.post(Uri.parse(apiurl),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "$token"},
          body: body
      );
      if (response.statusCode == 200) {
        var jsonBody = json.decode(response.body);
        if(jsonBody["status"]=="success"){
          setState(() {
            widget.tList!.removeAt(id);
          });
          Toast.show("You have followed @"+user, duration: Toast.lengthLong, gravity: Toast.bottom);
        }
      }
    } catch (e) {
      Toast.show(Language.network_error, duration: Toast.lengthLong, gravity: Toast.bottom);
    }

    setState(() {
      widget.tList![id].loading=false;
    });
  }



  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Column(
      children: [
        widget.loading? Container(
            margin: EdgeInsets.all(50),
            child: Center(
                child: CircularProgressIndicator()))
            :
        widget.tList!.length <= 0 ?
        Container(
          height: 200,
          margin: EdgeInsets.all(20),
          child: Center(
            child: Text(Language.empty, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
          ),
        )
            :
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(0),
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: <Widget>[
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.tList!.length,
                    padding: EdgeInsets.only(top: 0),
                    itemBuilder: (context, i) {
                      return Card(
                        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        color: kSecondary,
                        child: InkWell(
                          onTap: (){
                            Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => UserProfile(user: widget.tList![i],)));
                          },
                          child: Container(
                          padding: EdgeInsets.all(5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: (){
                                      ImagePreview().preview(context, widget.tList![i].avatar, setState);
                                    },
                                    child: Container(
                                        height: 70,
                                        width: MediaQuery.of(context).size.width*0.20,
                                        margin: EdgeInsets.all(10),
                                        alignment: Alignment.topLeft,
                                        child: CircleAvatar(
                                          radius: 45,
                                          backgroundColor: kSecondary,
                                          child: Padding(
                                            padding: EdgeInsets.all(1), // Border radius
                                            child: ClipOval(child: CachedNetworkImage(
                                              height: 70,
                                              width: 70,
                                              imageUrl: widget.tList![i].avatar,
                                              fit: BoxFit.cover, ), ),
                                          ),
                                        ),
                                        padding: EdgeInsets.all(1),
                                        decoration: new BoxDecoration(
                                          color: kSecondary, // border color
                                          shape: BoxShape.circle,
                                        )),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10,),
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.60,
                                        margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              constraints: BoxConstraints(
                                                  maxWidth: MediaQuery.of(context).size.width*0.40),
                                              child: Text(
                                                widget.tList![i].first_name+" "+widget.tList![i].last_name,
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
                                            SizedBox(width: 2,),
                                            widget.tList![i].rank=="0" ?
                                            SizedBox() :
                                            widget.tList![i].rank=="1" ?
                                            Icon(Icons.verified_user, color: kPrimaryLightColor, size: 10,) :
                                            Row(mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Icon(Icons.star, color: widget.tList![i].rank=="3" ? Colors.orangeAccent : kPrimaryVeryLightColor, size: 10,),
                                                SizedBox(width: 2,),
                                                Icon(Icons.verified_user, color: kPrimaryLightColor, size: 10,),
                                              ],),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 10, right: 10),
                                        child: Text(
                                          "@"+widget.tList![i].username,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black45,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      widget.tList![i].isFollowed=="0" ?
                                      InkWell(
                                        onTap: (){
                                          if(!widget.tList![i].loading) {
                                            follow(i, widget.tList![i].username);
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          width: 95,
                                          margin: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: kPrimaryDarkColor,
                                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                          ),
                                          child: Center(
                                            child: widget.tList![i].loading?
                                            SizedBox(
                                              height:20, width:20,
                                              child: CircularProgressIndicator(
                                                backgroundColor: kSecondary,
                                                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryDarkColor),
                                              ),
                                            ) : Text(
                                              Language.follow,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                color: kSecondary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ) : InkWell(
                                        onTap: (){
                                          if(!widget.tList![i].loading) {
                                            unfollow(i, widget.tList![i].username);
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.all(10),
                                          width: 95,
                                          decoration: BoxDecoration(
                                            color: kPrimaryDarkColor,
                                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                          ),
                                          child: Center(
                                            child: widget.tList![i].loading?
                                            SizedBox(
                                              height:20, width:20,
                                              child: CircularProgressIndicator(
                                                backgroundColor: kSecondary,
                                                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryDarkColor),
                                              ),
                                            ) : Text(
                                              Language.unfollow,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                color: kSecondary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }

}