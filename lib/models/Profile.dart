class Profile {

  String name;
  final String? gender;
  late final String? dob;
  final String? membership_number;
  final String? address;
  final String? phone_no;
  final String? alt_phone_no;
  final String? nok_name;
  final String? nok_email;
  final String? nok_phone_no;

 
  Profile({
    required this.name,
    this.gender,
    this.dob,
    this.membership_number,
    this.address,
    this.phone_no,
    this.alt_phone_no,
    this.nok_name,
    this.nok_email,
    this.nok_phone_no,
  });
}
