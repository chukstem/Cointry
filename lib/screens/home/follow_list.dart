import 'dart:convert'; 
import 'package:crypto_app/models/timeline_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../../constants.dart';
import 'package:http/http.dart' as http;
import '../../language.dart';
import '../../strings.dart';

class FollowList extends StatefulWidget {
  final List<TimelineModel> model;

  FollowList(
      {Key? key, required this.model})
      : super(key: key);

  @override
  _FollowListState createState() => _FollowListState();
}

class _FollowListState extends State<FollowList> {


  @override
  void initState() {
    super.initState();

  }

  follow(int id, String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username")!;
    String token = prefs.getString("token")!;
    setState(() {
      widget.model.first.followersModel[id].loading=true;
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
            widget.model.first.followersModel.removeAt(id);
          });
          Toast.show("You have followed @"+user, duration: Toast.lengthLong, gravity: Toast.bottom);
        }
      }
    } catch (e) {
      Toast.show(Language.network_error, duration: Toast.lengthLong, gravity: Toast.bottom);
    }

    setState(() {
      widget.model.first.followersModel[id].loading=false;
    });
  }

  Widget progressBar() {
    return CircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return ListView(
      scrollDirection: Axis.horizontal,
      children: List.generate(
        widget.model.first.followersModel.length,
            (i) => Card(
          margin: EdgeInsets.all(10),
          color: kSecondary,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(5.0),
                    height: 70.0,
                    width: 70.0,
                    child: Image.asset("assets/images/Profile Image.png"),
                  ),
                ),
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
                          widget.model.first.followersModel[i].first_name+" "+widget.model.first.followersModel[i].last_name,
                          textAlign: TextAlign.center,
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
                      widget.model.first.followersModel[i].rank=="0" ?
                      SizedBox() :
                      widget.model.first.followersModel[i].rank=="1" ?
                      Icon(Icons.verified_user, color: kPrimaryLightColor, size: 10,) :
                      Row(mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.star, color: widget.model.first.followersModel[i].rank=="3" ? Colors.orangeAccent : kPrimaryVeryLightColor, size: 10,),
                          SizedBox(width: 2,),
                          Icon(Icons.verified_user, color: kPrimaryLightColor, size: 10,),
                        ],),
                    ],
                  ),
                ),
                SizedBox(height: 2),
                Center(
                  child: Text(
                    "@"+widget.model.first.followersModel[i].username,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black45,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: 5),
                InkWell(
                  onTap: (){
                    if(!widget.model.first.followersModel[i].loading) {
                      follow(i, widget.model.first.followersModel[i].username);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: 95,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: kPrimaryDarkColor,
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Center(
                      child: widget.model.first.followersModel[i].loading?
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}