import 'dart:async';
import 'dart:convert';

import 'package:crypto_app/models/explore_model.dart';
import 'package:crypto_app/models/signal_model.dart';
import 'package:crypto_app/models/timeline_comment_replies_model.dart';
import 'package:crypto_app/models/trading_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversations_model.dart';
import '../models/crypto_model.dart';
import '../models/markets_model.dart';
import '../models/notifications_model.dart';
import '../models/p2p_model.dart';
import '../models/reviews.dart';
import '../models/timeline_model.dart';
import '../models/transactions_model.dart';
import '../models/user_model.dart';
import '../strings.dart';



Future<String> getQuery(http.Client client) async {
  var res="";
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/query'),
        headers: {
          "Content-Type": "application/json",
          "Authentication": "Bearer $token"},
      body: body
    );
  var user = json.decode(response.body);
  try {
    var jsond = user["user_details"] as List<dynamic>;
    for (var jsondata in jsond) {
      if (user["status"] != null &&
          user["status"].toString().contains("success")) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("pin", "${jsondata["app_pin"]}");
          prefs.setString("avatar", "${jsondata["image"]}");
          prefs.setString("cover", "${jsondata["cover"]}");
          prefs.setString("about", "${jsondata["about"]}");
          prefs.setString("kyc_status", "${jsondata["kyc_verified_at"]}");
          prefs.setString("rejected_reason", "${jsondata["rejected_reason"]}");
      }
    }
  } catch (e) {
    if(user!=null){
      try {
        res = user["response_message"].toString();
      }catch(ex){
      }
    }
  }

  try{
    var jsond = user["virtual_accounts"] as List<dynamic>;
    for (var jsondata in jsond) {
      String bankname = jsondata["bank_name"] ?? "";
      String accountname = jsondata["account_name"] ?? "";
      String accountnumber = jsondata["account_number"] ?? "";
      prefs.setString("bankname", bankname);
      prefs.setString("accountname", accountname);
      prefs.setString("accountnumber", accountnumber);
    }
  }catch(e){
    prefs.setString("bankname", "");
    prefs.setString("accountname", "");
    prefs.setString("accountnumber", "");
  }


  try{
      prefs.setString("banks", user["banks"]);
      prefs.setString("beneficiaries", user["beneficiaries"]);
      prefs.setString("crypto_currencies", user["crypto_currencies"]);
      prefs.setString("electricity", user["electricity"]);
      prefs.setString("betting", user["betting"]);
      prefs.setString("cable", user["cable"]);
      prefs.setString("data", user["data"]);
      prefs.setString("vtu", user["vtu"]);
      prefs.setString("bank_accounts", user["bank_accounts"]);
  }catch(e){
  }

  return res;
}


Future<List<TimelineModel>> getTimeline(http.Client client, String user, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'query': user,
    'start': start
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/timeline'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
    if(start=="0"){
      if(response.statusCode == 200) prefs.setString("timeline", response.body);
    }
  return compute(parseTimeline, response.body);
}
Future<List<TimelineModel>> getTimelineCached() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cache = prefs.getString("timeline");
  return compute(parseTimeline, cache);
}

List<TimelineModel> parseTimeline(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  List<TimelineModel> list =
  parsed.map<TimelineModel>((json) => new TimelineModel.fromJson(json)).toList();
  return list;
}


Future<List<ExploreModel>> getExplore(http.Client client, String search, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'query': search,
    'start': start
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/explore'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  if(search.contains("ALL")){
    if(response.statusCode == 200) prefs.setString("explore", response.body);
  }
  return compute(parseExplore, response.body);
}
Future<List<ExploreModel>> getExploreCached() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cache = prefs.getString("explore");
  return compute(parseExplore, cache);
}

List<ExploreModel> parseExplore(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  List<ExploreModel> list =
  parsed.map<ExploreModel>((json) => new ExploreModel.fromJson(json)).toList();
  return list;
}


Future<List<UserModel>> getFollowers(http.Client client, String user, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'user': user,
    'start': start
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/user_followers'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  return compute(parseFollowers, response.body);
}

List<UserModel> parseFollowers(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  List<UserModel> list =
  parsed.map<UserModel>((json) => new UserModel.fromJson(json)).toList();
  return list;
}


Future<List<UserModel>> getFollowing(http.Client client, String user, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'user': user,
    'start': start
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/user_following'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  return compute(parseFollowing, response.body);
}

List<UserModel> parseFollowing(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  List<UserModel> list =
  parsed.map<UserModel>((json) => new UserModel.fromJson(json)).toList();
  return list;
}


Future<List<TimelineModel>> getTimelineComments(http.Client client, String cid, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'cid': cid,
    'start': start
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/timeline_comments'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  return compute(parseTimeline, response.body);
}



Future<List<TimelineCommentRepliesModel>> getTimelineCommentReplies(http.Client client, String cid, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'cid': cid,
    'start': start
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/timeline_comment_replies'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  return compute(parseReplies, response.body);
}
List<TimelineCommentRepliesModel> parseReplies(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  List<TimelineCommentRepliesModel> list =
  parsed.map<TimelineCommentRepliesModel>((json) => new TimelineCommentRepliesModel.fromJson(json)).toList();
  return list;
}



Future<List<ReviewsModel>> getReviews(http.Client client, String username, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'user': username,
    'start': start
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/trade-review/index'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  return compute(parseReviews, response.body);
}
List<ReviewsModel> parseReviews(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  List<ReviewsModel> list =
  parsed.map<ReviewsModel>((json) => new ReviewsModel.fromJson(json)).toList();
  return list;
}


Future<List<TransactionsModel>> getTransactions(http.Client client, String currency) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'currency': currency,
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/transactions'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  if(currency=="ALL" && response.statusCode == 200) prefs.setString("cache_transactions", response.body);
  return compute(parseTransactions, response.body);
}
Future<List<TransactionsModel>> getTransaction(http.Client client, String reference) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'reference': reference
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/view-transaction'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  return compute(parseTransactions, response.body);
}
Future<List<TransactionsModel>> getTransactionsCached() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cache = prefs.getString("cache_transactions");
  return compute(parseTransactions, cache);
}
// A function that will convert a response body into a List
List<TransactionsModel> parseTransactions(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  List<TransactionsModel> list =
  parsed.map<TransactionsModel>((json) => new TransactionsModel.fromJson(json)).toList();
  return list;
}


Future<List<NotificationsModel>> getNotifications(http.Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/notifications'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  return compute(parseNotifications, response.body);
}
// A function that will convert a response body into a List
List<NotificationsModel> parseNotifications(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  List<NotificationsModel> list =
  parsed.map<NotificationsModel>((json) => new NotificationsModel.fromJson(json)).toList();
  return list;
}


Future<List<CryptoModel>> getCryptos(http.Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/crypto_wallets'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  if(response.statusCode == 200 && response.body.length>50) prefs.setString("cache_cryptos", response.body);
  return compute(parseCryptos, response.body);
}
Future<List<CryptoModel>> getCryptosCached() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cache = prefs.getString("cache_cryptos");
  return compute(parseCryptos, cache);
}
// A function that will convert a response body into a List
List<CryptoModel> parseCryptos(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  List<CryptoModel> list =
  parsed.map<CryptoModel>((json) => new CryptoModel.fromJson(json)).toList();
  return list;
}


Future<List<ConversationsModel>> getConversations(http.Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/conversations'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  if(response.statusCode == 200) prefs.setString("cache_conversations", response.body);
  return compute(parseConversations, response.body);
}

Future<List<ConversationsModel>> getUserConversations(http.Client client, String to, String from, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  var username = prefs.getString("username");
  Map data = {
    'email': email,
    'to': to,
    'from': from,
    'start': start
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/user_conversations'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  if(start=="0"){
    if(response.statusCode == 200) prefs.setString(username!.toLowerCase()==to.toLowerCase()?"cache_$from":"cache_$to", response.body);
  }
  return compute(parseConversations, response.body);
}
Future<List<ConversationsModel>> getUserConversationsCached(String to, String from) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var username = prefs.getString("username");
  var cache = prefs.getString(username!.toLowerCase()==to.toLowerCase()?"cache_$from":"cache_$to");
  return compute(parseConversations, cache);
}
Future<List<ConversationsModel>> getConversationsCached() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cache = prefs.getString("cache_conversations");
  return compute(parseConversations, cache);
}
List<ConversationsModel> parseConversations(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  List<ConversationsModel> list =
  parsed.map<ConversationsModel>((json) => new ConversationsModel.fromJson(json)).toList();
  return list;
}


Future<List<MarketsModel>> getMarkets(http.Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/markets'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );

  if(response.statusCode == 200 && response.body.length>50) prefs.setString("markets", response.body);
  return compute(parseMarkets, response.body);
}

Future<List<MarketsModel>> getMarketsCached() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cache = prefs.getString("markets");
  return compute(parseMarkets, cache);
}
List<MarketsModel> parseMarkets(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  List<MarketsModel> list =
  parsed.map<MarketsModel>((json) => new MarketsModel.fromJson(json)).toList();
  return list;
}



Future<List<UserModel>> getReferrals(http.Client client, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'start': start
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/referrals'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  if(start=="0"){
    if(response.statusCode == 200) prefs.setString("cache_referrals", response.body);
  }
  return compute(parseReferrals, response.body);
}
Future<List<UserModel>> getReferralsCached() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cache = prefs.getString("cache_referrals");
  return compute(parseReferrals, cache);
}
List<UserModel> parseReferrals(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  List<UserModel> list =
  parsed.map<UserModel>((json) => new UserModel.fromJson(json)).toList();
  return list;
}

Future<List<AirdropsModel>> getAirdrops(http.Client client, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'start': start
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/airdrops'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  if(start=="0"){
    if(response.statusCode == 200) prefs.setString("cache_airdrops", response.body);
  }
  return compute(parseAirdrops, response.body);
}
Future<List<AirdropsModel>> getAirdropsCached() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cache = prefs.getString("cache_airdrops");
  return compute(parseAirdrops, cache);
}
List<AirdropsModel> parseAirdrops(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  List<AirdropsModel> list =
  parsed.map<AirdropsModel>((json) => new AirdropsModel.fromJson(json)).toList();
  return list;
}

Future<List<TradingModel>> getTradingById(http.Client client, String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'id': id,
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/trade/detail'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  return compute(parseTradings, response.body);
}

Future<List<TradingModel>> getTradings(http.Client client, String start, String type) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'start': start,
    'type': type
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/trade/index'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  if(start=="0"){
    if(response.statusCode == 200) prefs.setString("cache_tradings_$type", response.body);
  }
  return compute(parseTradings, response.body);
}

Future<List<TradingModel>> getTradingsCached(String type) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cache = prefs.getString("cache_tradings_$type");
  return compute(parseTradings, cache);
}
List<TradingModel> parseTradings(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  List<TradingModel> list =
  parsed.map<TradingModel>((json) => new TradingModel.fromJson(json)).toList();
  return list;
}


Future<List<P2PModel>> getP2P(http.Client client, String start, String currency_id, String amount, String bank_id, String type, String sort) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'currency_id': currency_id,
    'amount': amount,
    'sort': sort,
    'type': type,
    'fiat_gateway_id': bank_id,
    'start': start
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/p2p-trade'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  if(start=="0"){
    if(response.statusCode == 200) prefs.setString("cache_p2p_$type"+"_$currency_id", response.body);
  }
  return compute(parseP2P, response.body);
}

Future<List<P2PModel>> getP2PUser(http.Client client, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'start': start
  };

  var body = json.encode(data);
  final response = await client.post(Uri.parse(Strings.url+'/p2p-user'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  if(start=="0"){
    if(response.statusCode == 200) prefs.setString("cache_p2p_3_user", response.body);
  }
  return compute(parseP2P, response.body);
}

Future<List<P2PModel>> getP2PCached(String currency_id, String type) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cache = prefs.getString("cache_p2p_$type"+"_$currency_id");
  return compute(parseP2P, cache);
}



List<P2PModel> parseP2P(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  List<P2PModel> list =
  parsed.map<P2PModel>((json) => new P2PModel.fromJson(json)).toList();
  return list;
}

