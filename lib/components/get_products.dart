import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/banks_model.dart';
import '../models/bills_model.dart';

class Products {
  static List<Bills> betting = <Bills>[];
  static List<Bills> electricity = <Bills>[];
  static List<Bills> banks = <Bills>[];
  static List<BanksModel> bank_accounts = <BanksModel>[];
  static List<Bills> beneficiaries = <Bills>[];
  static List<Bills> crypto_currencies = <Bills>[];
  static List<Bills> data = <Bills>[];
  static List<Bills> cable = <Bills>[];
  static List<Bills> vtu = <Bills>[];

  getProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //get products
    List<Bills> betting2 = [];
    List<Bills> electricity2 = [];
    List<Bills> banks2 = [];
    List<BanksModel> bank_accounts2 = [];
    List<Bills> beneficiaries2 = [];
    List<Bills> data2 = [];
    List<Bills> vtu2 = [];
    List<Bills> cable2 = [];
    List<Bills> crypto_currencies2 = [];


    try{
    //get crypto currencies
    var currencies = json.decode(prefs.getString("crypto_currencies")!) as List<dynamic>;
    for (var planl in currencies) {
      crypto_currencies2.add(Bills(amount: planl["image"], name: planl["name"], plan: "${planl["id"]}", size: planl["symbol"]));
    }
    }catch(e){}

    try{
    //get banks list
    var bank = json.decode(prefs.getString("banks")!) as List<dynamic>;
    for(var planl in bank) {
        banks2.add(Bills(amount: "empty", name: planl["name"], plan: planl["code"], size: "empty",),);
    }
    }catch(e){}

    try{
    //get beneficiaries
    var elect = json.decode(prefs.getString("beneficiaries")!) as List<dynamic>;
    for(var planl in elect) {
          beneficiaries2.add(Bills(amount: planl["account_name"], name: planl["bank_name"], plan: "${planl["bank_code"]}", size: "${planl["account_number"]}"),);
    }
    }catch(e){}

    try{
      //get betting list
      var list = json.decode(prefs.getString("betting")!) as List<dynamic>;
      for(var planl in list) {
        betting2.add(Bills(amount: "${planl["value"]}", name: planl["product"], plan: "${planl["product_id"]}", size: planl["product"],));
      }
    }catch(e){}

    try{
      //get electricity list
      var list = json.decode(prefs.getString("electricity")!) as List<dynamic>;
      for(var planl in list) {
        electricity2.add(Bills(amount: "${planl["value"]}", name: planl["product"], plan: "${planl["product_id"]}", size: planl["product"],));
      }
    }catch(e){}

    try{
      //get cable list
      var list = json.decode(prefs.getString("cable")!) as List<dynamic>;
      for(var planl in list) {
        cable2.add(Bills(amount: "${planl["value"]}", name: planl["product"], plan: "${planl["product_id"]}", size: "${planl["product_category_id"]}",));
      }
    }catch(e){}

    try{
      //get data list
      var list = json.decode(prefs.getString("data")!) as List<dynamic>;
      for(var planl in list) {
        data2.add(Bills(amount: "${planl["value"]}", name: planl["product"], plan: "${planl["product_id"]}", size: "${planl["product_category_id"]}",));
      }
    }catch(e){}

    try{
      //get vtu list
      var list = json.decode(prefs.getString("vtu")!) as List<dynamic>;
      for(var planl in list) {
        vtu2.add(Bills(amount: "${planl["value"]}", name: planl["product"], plan: "${planl["product_id"]}", size: "${planl["comm"]}",));
      }
    }catch(e){}


    try{
      final parsed = json.decode(prefs.getString("bank_accounts")!).cast<Map<String, dynamic>>();
      bank_accounts2 = parsed.map<BanksModel>((json) => new BanksModel.fromJson(json)).toList();
    }catch(e){}


    betting = betting2;
    electricity = electricity2;
    banks = banks2;
    bank_accounts = bank_accounts2;
    beneficiaries = beneficiaries2;
    cable = cable2;
    data = data2;
    vtu = vtu2;
    crypto_currencies = crypto_currencies2;
  }





  List<Bills> getProduct(var type){
    switch (type){
      case "betting": return betting;
      case "electricity": return electricity;
      case "beneficiaries": return beneficiaries;
      case "banks": return banks;
      case "data": return data;
      case "cable": return cable;
      case "vtu": return vtu;
      default: return banks;
    }
  }

  List<Bills> getCurrencies(){
    return crypto_currencies;
  }

  List<BanksModel> getBankAccounts(){
    return bank_accounts;
  }




}