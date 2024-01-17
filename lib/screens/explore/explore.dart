import 'dart:async';

import 'package:crypto_app/models/timeline_hashtags_model.dart';
import 'package:crypto_app/models/timeline_model.dart';
import 'package:crypto_app/screens/explore/post_timeline.dart';
import 'package:crypto_app/screens/explore/timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../helper/networklayer.dart';
import '../../helper/pusher.dart';
import '../../language.dart';
import '../../models/explore_model.dart';
import '../../models/user_model.dart';
import 'find_people.dart';
import 'followers.dart';
import 'following.dart';

class ExploreScreen extends StatefulWidget {
  ExploreScreen(
      {Key? key})
      : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>  with SingleTickerProviderStateMixin{
  bool loading=true;
  List<ExploreModel> list = List.empty(growable: true);
  List<ExploreModel> olist = List.empty(growable: true);
  String search="ALL";
  var _scrollController, _tabController;

  cachedList() async {
    List<ExploreModel> iList = await getExploreCached();
      if (iList.isNotEmpty) {
        setState(() {
          loading = false;
          list = iList;
          olist = iList;
        });
      }
  }

  fetch() async {
    if(search.isEmpty){
      setState(() {
        search="ALL";
      });
    }
    try{
      List<ExploreModel> iList = await getExplore(http.Client(), search, "0");
      setState(() {
        loading = false;
        list = iList;
        olist = iList;
      });

    }catch(e){
      setState(() {
        loading = false;
      });
    }

  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(vsync: this, length: 4);
    cachedList();
    Timer(Duration(seconds: 1), () =>
    {
      fetch(),
      generalPusher(context)
    });
  }

  fetchdelay(){
    Timer(Duration(seconds: 120), () =>
    {
      fetch(),
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: kWhite,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Text(Language.explore),
              pinned: false,
              floating: true,
              snap: false, 
              backgroundColor: kPrimaryDarkColor,
              forceElevated: innerBoxIsScrolled,
              bottom: TabBar(
                indicatorPadding: EdgeInsets.only(left: 10, right: 10),
                unselectedLabelStyle: TextStyle(color: Colors.white70),
                labelStyle: TextStyle(color: kSecondary, fontWeight: FontWeight.bold),
                padding: EdgeInsets.all(0),
                isScrollable: true,
                tabs: [
                  Container(width: MediaQuery.of(context).size.width/5.5,
                    child: Tab(
                      icon: Icon(Icons.timeline),
                      text: Language.posts,
                    ),),
                  Container(width: MediaQuery.of(context).size.width/5.5,
                    child: Tab(
                      icon: Icon(Icons.people),
                      text: Language.people,
                    ),),
                  Container(width: MediaQuery.of(context).size.width/5.5,
                    child: Tab(
                      icon: Icon(Icons.supervised_user_circle_sharp),
                      text: Language.following,
                    ),),
                  Container(width: MediaQuery.of(context).size.width/5.5,
                    child: Tab(
                      icon: Icon(Icons.supervised_user_circle_sharp),
                      text: Language.followers,
                    ),),
                ],
                controller: _tabController,
              ),
            ),
            createSilverAppBar2(), 
          ];
        },
        body: RefreshIndicator(
          onRefresh: () {
            return fetch();
          },
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              Timeline(loading: loading, tList: list.isEmpty?[]:list.first.timeline, hList: list.isEmpty?[]:list.first.hashtags),
              FindPeople(loading: loading, tList: list.isEmpty?[]:list.first.findpeople),
              Following(loading: loading, tList: list.isEmpty?[]:list.first.following),
              Followers(loading: loading, tList: list.isEmpty?[]:list.first.followers),
            ],
          ),
        ),
      ),
    );


  }

  SliverAppBar createSilverAppBar2() {
    return SliverAppBar(
      backgroundColor: kPrimaryDarkColor,
      pinned: true,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.withOpacity(0.6),
                offset: Offset(1.1, 1.1),
                blurRadius: 5.0),
          ],
        ),
        child: CupertinoTextField(
          keyboardType: TextInputType.text,
          placeholder: Language.find_people,
          placeholderStyle: TextStyle(
            color: Color(0xffC4C6CC),
            fontSize: 14.0,
          ),
          suffix: InkWell(
            onTap: (){
              fetch();
            },
            child: Container(
              height: 40,
              width: 80,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(top: 2, bottom: 2, right: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: kPrimaryLightColor,
              ),
              child: Center(
                child: Text(Language.search, style: TextStyle(color: kSecondary, fontSize: 12, fontWeight: FontWeight.bold),),
              ),
            ),
          ),
          onChanged: (value){
            list=olist;
            setState(() {
              loading=true;
            });
            if(value.length>0){
              List<TimelineModel> timeline = list.first.timeline.where((o) => o.content.toLowerCase().contains(value.toLowerCase()) || "${o.userModel.first.username} ${o.userModel.first.first_name} ${o.userModel.first.last_name}".toLowerCase().contains(value.toLowerCase())).toList();
              List<UserModel> findpeople = list.first.findpeople.where((o) => "${o.username} ${o.first_name} ${o.last_name}".toLowerCase().contains(value.toLowerCase())).toList();
              List<UserModel> followers = list.first.followers.where((o) => "${o.username} ${o.first_name} ${o.last_name}".toLowerCase().contains(value.toLowerCase())).toList();
              List<UserModel> following = list.first.following.where((o) => "${o.username} ${o.first_name} ${o.last_name}".toLowerCase().contains(value.toLowerCase())).toList();
              List<HashtagsModel> hashtags = list.first.hashtags.where((o) => o.subject.toLowerCase().contains(value.toLowerCase())).toList();
              List<ExploreModel> temp_list = List.empty(growable: true);
              temp_list.add(new ExploreModel(timeline: timeline, followers: followers, following: following, findpeople: findpeople, hashtags: hashtags));
              setState(() {
                list=temp_list;
              });

            }else{
              setState(() {
                list=olist;
              });
            }
            setState(() {
              loading=false;
              search=value;
            });
          },
          onSubmitted: (value){
            setState(() {
              search=value;
            });
            fetch();
          },
          prefix: Padding(
            padding: EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0),
            child: Icon(
              Icons.search,
              size: 18,
              color: Colors.black,
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: kSecondary,
          ),
        ),
      ),
    );
  }
}