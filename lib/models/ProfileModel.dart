class ProfileModel {
  int? id;
  String? name;
  String? email;
  String? membershipNumber;
  String? address;
  String? gender;
  String? dob;
  String? phoneNo;
  String? altPhoneNo;
  int? accountTypeId;
  String? userType;
  String? status;
  String? comment;
  int? subscribed;
  String? points;
  int? activeStatus;
  String? avatar;
  int? darkMode;
  String? nokName;
  String? nokAddress;
  String? nokPhoneNo;
  String? subscriptionStatus;
  LatestMembership? latestMembership;

  ProfileModel({
    this.id,
    this.name,
    this.email,
    this.membershipNumber,
    this.address,
    this.gender,
    this.dob,
    this.phoneNo,
    this.altPhoneNo,
    this.accountTypeId,
    this.userType,
    this.status,
    this.comment,
    this.subscribed,
    this.points,
    this.activeStatus,
    this.avatar,
    this.darkMode,
    this.nokName,
    this.nokAddress,
    this.nokPhoneNo,
    this.subscriptionStatus,
    this.latestMembership,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['data']['id'],
      name: json['data']['name'],
      email: json['data']['email'],
      membershipNumber: json['data']['membership_number'],
      address: json['data']['address'],
      gender: json['data']['gender'],
      dob: json['data']['dob'],
      phoneNo: json['data']['phone_no'],
      altPhoneNo: json['data']['alt_phone_no'],
 
      accountTypeId: json['data']['account_type_id'],
      userType: json['data']['user_type'],
      status: json['data']['status'],
      comment: json['data']['comment'],
      subscribed: json['data']['subscribed'],
       points: json['data']['points'],
 
      activeStatus: json['data']['active_status'],
      avatar: json['data']['avatar'],
      darkMode: json['data']['dark_mode'],
       nokName: json['data']['nok_name'],
      nokAddress: json['data']['nok_address'],
      nokPhoneNo: json['data']['nok_phone_no'],
      subscriptionStatus: json['data']['subscription_status'],
      latestMembership: LatestMembership.fromJson(json['data']['latest_membership']),
    );
  }
}

class LatestMembership {
  int? id;
  int? userId;
  String? expiryDate;
  String? processedDate;
  String? processedBy;
  String? comment;
  String? paymentAmount;
  String? status;
  String? createdAt;
  String? updatedAt;

  LatestMembership({
        this.id,
        this.userId,
        this.expiryDate,
        this.processedDate,
        this.processedBy,
        this.comment,
        this.paymentAmount,
        this.status,
        this.createdAt,
        this.updatedAt,
  });

  factory LatestMembership.fromJson(Map<String, dynamic> json) {
    return LatestMembership(
      id: json['id'],
      userId: json['user_id'],
      expiryDate: json['expiry_date'],
      processedDate: json['processed_date'],
      processedBy: json['processed_by'],
      comment: json['comment'],
      paymentAmount: json['payment_amount'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
