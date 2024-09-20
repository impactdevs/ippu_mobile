class UserData {
  final int id;
  String name;
  final String email;
  final String? token;
  final String? gender;
  late final String? dob;
  String? membership_number;
  final String? address;
  final String? phone_no;
  final String? points;
  final String? alt_phone_no;
  final String? nok_name;
  final String? nok_address;
  final String? nok_phone_no;
  final String? subscription_status;
  String profile_pic;
  final int? account_type_id;
  final String? membership_amount;
  final String membership_expiry_date;
  UserData({
    required this.id,
    this.points,
    required this.name,
    required this.email,
    this.token,
    this.gender,
    this.dob,
    this.subscription_status,
    this.membership_number,
    this.address,
    this.phone_no,
    this.alt_phone_no,
    this.nok_name,
    this.nok_address,
    this.nok_phone_no,
    required this.profile_pic,
    this.account_type_id,
    this.membership_amount,
    required this.membership_expiry_date,
  });

  bool checkifAnyIsNull() {
    return [gender, dob, address, phone_no].contains('null');
  }
}
