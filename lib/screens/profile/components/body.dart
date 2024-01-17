import 'dart:convert';
import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../language.dart';
import '../../../models/user_model.dart';
import '../../../screens/beneficiaries/beneficiaries_page.dart';
import '../../../screens/notifications/notifications_page.dart';
import '../../../screens/profile/edit_profile_page.dart';
import '../../../screens/settings/kyc_page.dart';
import '../../../screens/settings/password_page.dart';
import '../../../screens/splash/welcome.dart';
import '../../../constants.dart';
import '../../../strings.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/snackbar.dart';
import '../../buzz/referrals.dart';
import '../../chat/chat_screen.dart';
import '../../next_kin/next_kin_page.dart';
import '../../settings/pin_page.dart';
import 'profile_menu.dart';
import 'profile_pic.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class Body extends StatefulWidget {
  Body({Key? key}) : super(key: key);

  @override
  _Body createState() => _Body();
}

class _Body extends State<Body> {
  String kyc_verified="0";

  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      kyc_verified = prefs.getString("kyc_status")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getuser();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          backAppbar(context, Language.profile),
          SizedBox(height: 20),
          ProfilePic(),
          SizedBox(height: 20),
          ProfileMenu(
            text: Language.my_account,
            icon: "assets/icons/User Icon.svg",
            press: () => {
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) => EditProfile()))
            },
          ),
          ProfileMenu(
            text: Language.beneficiaries,
            icon: "assets/icons/beneficiary.svg",
            press: () {
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => Beneficiaries()));
            },
          ),
          ProfileMenu(
            text: Language.notifications,
            icon: "assets/icons/Bell.svg",
            press: () {
              Navigator.of(context).push(
                  CupertinoPageRoute(
                      builder: (context) =>
                          Notifications()));
            },
          ),
          ProfileMenu(
            text: Language.change_password,
            icon: "assets/icons/Settings.svg",
            press: () {
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => ChangePassword()));
            },
          ),
          ProfileMenu(
            text: Language.change_pin,
            icon: "assets/icons/Settings.svg",
            press: () {
              Navigator.of(context).push(
                  CupertinoPageRoute(
                      builder: (context) =>
                          ChangePin()));
            },
          ),
          ProfileMenu(
            text: Language.referral,
            icon: "assets/icons/referrals.svg",
            press: () {
              Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) => Referrals()));
            },
          ),
          !kyc_verified.contains("Approved") ? ProfileMenu(
            text: Language.kyc_title,
            icon: "assets/icons/kyc.svg",
            press: () {
              Navigator.of(context).push(
                  CupertinoPageRoute(
                      builder: (context) =>
                          KycScreen()));
            },
          ) : SizedBox(),
          ProfileMenu(
            text: Language.next_of_kin,
            icon: "assets/images/next-kin.svg",
            press: () {
              Navigator.of(context).push(CupertinoPageRoute(builder: (context) => NextKin()));
            },
          ),
          ProfileMenu(
            text: Language.chat_support,
            icon: "assets/icons/chat.svg",
            press: () {
              UserModel to=  new UserModel(id: "4545", username: Strings.agent_name, first_name: "Customer",
                  reviews: "0", last_name: "Care", created_on: "", isFollowed: "", trades: "", about: "", avatar: "", cover: "", followers: "", following: "", rank: "", loading: false, isBlocked: '');
               Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ChatScreen(to: to)));
            },
          ),
          ProfileMenu(
            text: Language.terms,
            icon: "assets/images/policy.svg",
            press: () {
              _openLink("https://www.mycointry.com/terms-of-services");
            },
          ),
          ProfileMenu(
            text: Language.privacy_policy,
            icon: "assets/images/policy.svg",
            press: () {
              _openLink("https://www.mycointry.com/privacy-policy");
            },
          ),
          ProfileMenu(
            text: Language.deactivate_account,
            icon: "assets/images/deactivate.svg",
            press: () {
              delete(context);
            },
          ),
          ProfileMenu(
            text: Language.logout,
            icon: "assets/icons/Log out.svg",
            press: () {
              logout(context);
            },
          ),
        ],
      ),
    );
  }

  logout(BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Get.offAllNamed(WelcomeScreen.routeName);
  }

  update() async{
    if(Platform.isAndroid){
      await launchUrl(Uri.parse(Strings.android_store));
    }else{
      await launchUrl(Uri.parse(Strings.ios_store));
    }
  }

  Future<void> _openLink(String link) async {
    Uri url=Uri.parse(link);
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: WebViewConfiguration(
          headers: <String, String>{'my_header_key': 'my_header_value'}),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  delete(BuildContext context) async {
    QuickAlert.show(
        context: context,
        backgroundColor: kPrimaryDarkColor,
        type: QuickAlertType.confirm,
        title: Language.deactivation,
        titleColor: kSecondary,
        textColor: kSecondary,
        text: Language.deactivate_body,
        confirmBtnText: Language.deactivate_account,
        cancelBtnText: Language.cancel,
        confirmBtnColor: Colors.green,
        onConfirmBtnTap: () async {
          Navigator.pop(context);
          delete_account(context);
          return;
        },
        onCancelBtnTap: (){
          Navigator.pop(context);
          return;
        }
    );
  }

  delete_account(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token=prefs.getString("token");
    String? email=prefs.getString("email");
    var response = null;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: Language.deleting,
      text: Language.processing,
    );
    try {
      response = await http.post(Uri.parse(Strings.url+"/deactivate-account"),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "Bearer $token"},
          body: json.encode({
            'email': email,
          })
      );
      if (response != null && response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["status"] != null &&
            jsondata["status"].toString().contains("success")) {
          Navigator.pop(context);
          logout(context);
        }else{
          Navigator.pop(context);
          Snackbar().show(context, ContentType.failure, Language.error, jsondata["response_message"].toString());
        }

      }else{
        Navigator.pop(context);
        Snackbar().show(context, ContentType.failure, Language.error, Language.network_error);
      }

    } catch (e) {
      Navigator.pop(context);
      Snackbar().show(context, ContentType.failure, Language.error, e.toString());
    }

  }


}
