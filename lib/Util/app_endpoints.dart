class AppEndpoints {
  static const String baseUrl = 'https://ippu.org/api';

  static const String loginEndPoint = "/login";
  static const String regiserEndPoint = "/register";
  //check for the entered phone number
  static const String checkPhoneNumberEndPoint = "/check-phone-number";
  //phone number login
  static const String phoneLoginEndPoint = "/phone-number-login";
  //sign in with google
  static const String googleLoginEndPoint = "/login-by-google";
  //sign in with apple
  static const String appleLoginEndPoint = "/login-by-apple";
  static const String logoutEndPoint = "/logout";

  static const String cpdsEndPoint = "/cpds/{user_id}";
  static const String eventsEndPoint = "/events/{user_id}";
  static const String educationBackgroundEndPoint = "/education-background";
  static const String upcomingCpdsEndPoint = "/upcoming-cpds";
  static const String upcomingEventsEndPoint = "/upcoming-events";
  static const String myEventsEndPoint ="/attended-events/";
  static const String accountTypesEndPoint = "/account-types";
  static const String communicationsEndPoint = "/communications/{user_id}}";
  static const String fcmToken ="/fcm-device-token";
  static const String uploadProfilePicture ="/update-profile-photo";
  static const String userProfile = "/profile";

  static const String myCpdsEndPoint ="/attended-cpds/";

  static const String downloadEventCertificate = "/events/certificate/{event}";
  static const String downloadCpdCertificate = "/cpds/certificate/{cpd}";

  static const String downloadMembershipCertificate = "/membership-certificate";

  static const String paymentsHistory = "/payments-history";

  static const String subscribe = "/subscribe";
}