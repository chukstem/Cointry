
class BanksModel {
  String reference_number;
  String name;
  String iban;
  String swift;
  String fsc;
  String address;
  String account_holder_name;
  String account_holder_address;
  String note;
  String country;
  BanksModel({required this.reference_number, required this.name, required this.iban, required this.swift, required this.fsc, required this.address, required this.account_holder_name, required this.account_holder_address, required this.note, required this.country});

  factory BanksModel.fromJson(Map<String, dynamic> json) {
    return BanksModel(
      reference_number: json['reference_number'] as String,
      name: json['name'] as String,
      iban: json['iban'] as String,
      swift: json['swift'] as String,
      fsc: json['ifsc'] as String,
      address: json['address'] as String,
      account_holder_name: json['account_holder_name'] as String,
      account_holder_address: json['account_holder_address'] as String,
      note: json['note'] as String,
      country: json['country'] as String,
    );
  }
}