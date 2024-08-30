import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import '../../Util/app_endpoints.dart';

part 'auth_rest.g.dart';

@RestApi(baseUrl: AppEndpoints.baseUrl)
abstract class AuthRestClient {
  factory AuthRestClient(Dio dio, {String baseUrl}) = _AuthRestClient;

  @POST(AppEndpoints.fcmToken)
  Future<dynamic> saveFcmToken({@Body() required Map<String, String> body});

  @POST(AppEndpoints.loginEndPoint)
  Future<dynamic> signIn({@Body() required Map<String, String> body});

  @POST(AppEndpoints.regiserEndPoint)
  Future<dynamic> signUp({@Body() required Map<String, dynamic> body});

  @POST(AppEndpoints.checkPhoneNumberEndPoint)
  Future<dynamic> checkPhoneNumber({@Body() required Map<String, String> body});

  @POST(AppEndpoints.phoneLoginEndPoint)
  Future<dynamic> phoneLogin({@Body() required Map<String, String> body});

  @POST(AppEndpoints.googleLoginEndPoint)
  Future<dynamic> AuthenticateWithGoogleToken(
      {@Body() required Map<String, String> body});

  @POST(AppEndpoints.appleLoginEndPoint)
  Future<dynamic> authenticateWithAppleEmail(
      {@Body() required Map<String, String> body});

  @POST(AppEndpoints.logoutEndPoint)
  Future<dynamic> signOut();

  @GET(AppEndpoints.userProfile)
  Future<dynamic> getProfile();

  @POST(AppEndpoints.uploadProfilePicture)
  @FormUrlEncoded()
  Future<dynamic> store(@Path('user') int userId,
      @Part(name: 'profile_photo_path') File profilePhotoPath);

  @GET(AppEndpoints.accountTypesEndPoint)
  Future<dynamic> getAccountTypes();

  @POST(AppEndpoints.educationBackgroundEndPoint)
  Future<dynamic> getEducationBackground(
      {@Body() required Map<String, String> body});

  @GET(AppEndpoints.educationBackgroundEndPoint)
  Future<dynamic> getEducationDetails();

  //get all communications with user_id as a parameter
  @GET(AppEndpoints.communicationsEndPoint)
  Future<dynamic> getAllCommunications({@Path() required int user_id});

  @GET(AppEndpoints.cpdsEndPoint)
  Future<dynamic> getCpds({@Path() required int user_id});

  //attended cpds
  @GET(AppEndpoints.myCpdsEndPoint)
  Future<dynamic> getMyCpds();

  @GET(AppEndpoints.eventsEndPoint)
  Future<dynamic> getEvents({@Path() required int user_id});

  @GET(AppEndpoints.downloadEventCertificate)
  Future<dynamic> downloadEventCertificate({@Path() required int event});

  @GET(AppEndpoints.downloadCpdCertificate)
  Future<dynamic> downloadCpdCertificate({@Path() required int cpd});

  @GET(AppEndpoints.downloadMembershipCertificate)
  Future<dynamic> downloadMembershipCertificate();

  @GET(AppEndpoints.upcomingCpdsEndPoint)
  Future<dynamic> getUpcomingCpds();

  @GET(AppEndpoints.upcomingEventsEndPoint)
  Future<dynamic> getUpcomingEvents();

  @POST(AppEndpoints.subscribe)
  Future<dynamic> subscribe();

  @GET(AppEndpoints.paymentsHistory)
  Future<dynamic> getPaymentsHistory();
}
