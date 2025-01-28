import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'rest/auth_rest.dart';

class AuthController {
  static String ACCESS_TOKEN = "access_token";

  Future<Map<String, dynamic>> saveFcmToken(int userId) async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    String fcmToken = await checkForFcmToken();
    Map<String, String> details = {
      "fcm_device_token": fcmToken,
      "user_id": "$userId"
    };
    try {
      final response = await client.saveFcmToken(body: details);

      if (response.containsKey('message')) {
        return response;
      } else {
        return {
          "error": "Failed to save fcm token",
          "status": "error",
        };
      }
    } catch (e) {
      return {
        "error": "Failed to save fcm token",
        "status": "error",
      };
    }
  }

  Future<String> checkForFcmToken() async {
    //get fcm token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //check if token is available and if not create one
    String? fcmToken = prefs.getString('fcm_token') ?? "";
    if (fcmToken == "") {
      //create token
      fcmToken = await FirebaseMessaging.instance.getToken();
      //save token
      prefs.setString('fcm_token', fcmToken!);
    }

    return fcmToken;
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    log("email: $email, password: $password");
    final dio = Dio();
    final client = AuthRestClient(dio);
    try {
      Map<String, String> user = {"email": email, "password": password};
      final response = await client.signIn(body: user);
      if (response.containsKey('authorization') &&
          response['authorization'].containsKey('token')) {
        final accessToken = response['authorization']['token'];
        // Save the access token for later use
        await saveAccessToken(accessToken);

        //save fcm token
        await saveFcmToken(response['user']['id']);
        return response;
      } else {
        return {
          "error": "Invalid credentials",
          "status": "error",
        };
      } // Handle the case when the access token is not present in the response
    } catch (e) {
      return {
        "error": "Invalid credentials",
        "status": "error",
      };
    }
  }

  saveAccessToken(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(ACCESS_TOKEN, accessToken);
  }

  getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(ACCESS_TOKEN)) {
      return "";
    }
    return prefs.getString(ACCESS_TOKEN);
  }

  Future<Map<String, dynamic>> signUp(Map<String, dynamic> user) async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Accept'] = "application/json";
    dio.options.validateStatus = (status) => status! < 500;
    dio.options.followRedirects = false;
    try {
      final response = await client.signUp(body: user);
      if (response.containsKey('user')) {
        return {
          "message": response['message'],
          "status": "success",
        };
      } else {
        return {
          "error": response['message'],
          "status": "error",
        };
      }
    } catch (e) {
      return {
        "error": "Invalid credentials",
        "status": "error",
      };
    }
  }

  Future<Map<String, dynamic>> checkPhoneNumber(String phoneNumber) async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Accept'] = "application/json";
    dio.options.validateStatus = (status) => status! < 500;
    dio.options.followRedirects = false;
    Map<String, String> details = {"phone_number": phoneNumber};

    try {
      final response = await client.checkPhoneNumber(body: details);

      if (response.containsKey('status')) {
        return {'status': 'success', 'message': "phone number registered"};
      } else {
        return {'status': 'error', 'message': "phone number not registered"};
      }
    } catch (e) {
      // Exception handling
      return {
        "error": "An error occurred",
        "status": "error",
      };
    }
  }

  Future<Map<String, dynamic>> phoneLogin(String phoneNumber) async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Accept'] = "application/json";
    dio.options.validateStatus = (status) => status! < 500;
    dio.options.followRedirects = false;
    Map<String, String> details = {"phone_number": phoneNumber};
    try {
      final response = await client.phoneLogin(body: details);
      //check for status key
      if (response.containsKey('authorization') &&
          response['authorization'].containsKey('token')) {
        final accessToken = response['authorization']['token'];
        // Save the access token for later use
        await saveAccessToken(accessToken);

        //save fcm token
        await saveFcmToken(response['user']['id']);
        return {'status': 'success', 'message': "phone number registered"};
      } else {
        return {
          "error": "Invalid credentials",
          "status": "error",
        };
      } // Handle the case when the access token is not present in the response
    } catch (e) {
      return {
        "error": "Phone number not found",
        "status": "error",
      };
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    dio.options.headers['Accept'] = "application/json";
    dio.options.headers['Content-Type'] = "application/json";
    dio.options.validateStatus = (status) => status! < 500;
    try {
      final response = await client.getProfile();
      if (response.containsKey('data') && response.containsKey('message')) {
        return response;
      } else {
        return {
          "error": "Unauthorized",
          "status": "error",
        };
      }
    } catch (e) {
      return {
        "error": "Failed to get profile",
        "status": "error",
      };
    }
  }

  Future<Map<String, dynamic>> getEducationBackground(
      String userId, String points, String field) async {
    final dio = Dio();
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    final client = AuthRestClient(dio);
    Map<String, String> details = {
      "user_id": userId,
      "points": points,
      "field": field
    };
    try {
      final response = await client.getEducationBackground(body: details);
      return response;
    } catch (e) {
      return {
        "error": "Failed to get education background",
        "status": "error",
      };
    }
  }

  Future<List<dynamic>> getCpds(int userId) async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    //'X-Requested-With': 'XMLHttpRequest'
    dio.options.headers['X-Requested-With'] = "XMLHttpRequest";
    //print what is being sent
    // dio.interceptors.add(LogInterceptor(responseBody: true));

    try {
      final response = await client.getCpds(user_id: userId);
      return response['data'];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getPublicCpds() async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    //'X-Requested-With': 'XMLHttpRequest'
    dio.options.headers['X-Requested-With'] = "XMLHttpRequest";
    //print what is being sent
    // dio.interceptors.add(LogInterceptor(responseBody: true));

    try {
      final response = await client.getPublicCpds();
      return response['data'];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getAllCommunications(int userId) async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    dio.options.headers['X-Requested-With'] = "XMLHttpRequest";

    try {
      final response = await client.getAllCommunications(user_id: userId);
      return response['data'].values.toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getPublicCommunications() async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    dio.options.headers['X-Requested-With'] = "XMLHttpRequest";

    try {
      final response = await client.getPublicCommunications();
      return response['data'].values.toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getEducationDetails() async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    //'X-Requested-With': 'XMLHttpRequest'
    dio.options.headers['X-Requested-With'] = "XMLHttpRequest";
    //print what is being sent
    // dio.interceptors.add(LogInterceptor(responseBody: true));

    try {
      final response = await client.getEducationDetails();
      return response['data'];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getEvents(int userId) async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    print("Bearer ${await getAccessToken()}");
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    dio.options.headers['X-Requested-With'] = ['XMLHttpRequest'];
    try {
      final response = await client.getEvents(user_id: userId);
      return response['data'];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getPublicEvents() async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    print("Bearer ${await getAccessToken()}");
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    dio.options.headers['X-Requested-With'] = ['XMLHttpRequest'];
    try {
      final response = await client.getPublicEvents();
      return response['data'];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getUpcomingCpds() async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    print("Bearer ${await getAccessToken()}");
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    dio.options.headers['X-Requested-With'] = ['XMLHttpRequest'];
    try {
      final response = await client.getUpcomingCpds();
      return response['data'];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getUpcomingEvents() async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    print("Bearer ${await getAccessToken()}");
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    dio.options.headers['X-Requested-With'] = ['XMLHttpRequest'];
    try {
      final response = await client.getUpcomingEvents();
      return response['data'];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> signOut() async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    dio.options.headers['Accept'] = "application/json";
    try {
      final response = await client.signOut();
      //check if response contains message
      if (response.containsKey('message')) {
        return response;
      } else {
        return {
          "error": "Failed to sign out",
          "status": "error",
        };
      }
    } catch (e) {
      return {
        "error": "Failed to sign out",
        "status": "error",
      };
    }
  }

  Future<Map<String, dynamic>> store(File? attach, int userId) async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    dio.options.headers['Accept'] = "application/json";

    try {
      final response = await client.store(userId, attach!);
      //check if response contains message
      if (response.containsKey('message')) {
        return {
          "message": "Profile picture uploaded successfully",
          "profile_photo_path": response['profile_photo_path'],
        };
      } else {
        return {
          "error": "Failed to upload profile picture",
          "status": "error",
        };
      }
    } catch (e) {
      return {
        "error": "Failed to upload profile picture",
        "status": "error",
      };
    }
  }

  //subscribe
  Future<Map<String, dynamic>> subscribe() async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    try {
      final response = await client.subscribe();
      //check if response contains message
      if (response.containsKey('message')) {
        return response;
      } else {
        return {
          "error": "Failed to subscribe",
          "status": "error",
        };
      }
    } catch (e) {
      return {
        "error": "Failed to subscribe",
        "status": "error",
      };
    }
  }

  Future<Map<String, dynamic>> downloadEventCertificate(int event) async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    dio.options.headers['Accept'] = "application/json";
    try {
      final response = await client.downloadEventCertificate(event: event);
      //check if response contains message
      if (response.containsKey('message')) {
        return {
          "certificate": response['data']['certificate'],
          "status": "success",
        };
      } else {
        return {
          "error": "Failed to download certificate",
          "status": "error",
        };
      }
    } catch (e) {
      return {
        "error": "Failed to download certificate",
        "status": "error",
      };
    }
  }

  Future<Map<String, dynamic>> downloadCpdCertificate(int cpd) async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    dio.options.headers['Accept'] = "application/json";
    try {
      final response = await client.downloadCpdCertificate(cpd: cpd);
      //check if response contains message
      if (response.containsKey('message')) {
        return {
          "certificate": response['data']['certificate'],
          "status": "success",
        };
      } else {
        return {
          "error": "Failed to download certificate",
          "status": "error",
        };
      }
    } catch (e) {
      return {
        "error": "Failed to download certificate",
        "status": "error",
      };
    }
  }

  Future<Map<String, dynamic>> downloadMembershipCertificate() async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    dio.options.headers['Accept'] = "application/json";
    try {
      final response = await client.downloadMembershipCertificate();
      //check if response contains message
      if (response.containsKey('message')) {
        return {
          "certificate": response['data']['certificate'],
          "status": "success",
        };
      } else {
        return {
          "error": "Failed to download certificate",
          "status": "error",
        };
      }
    } catch (e) {
      return {
        "error": "Failed to download certificate",
        "status": "error",
      };
    }
  }

  //get my cpds
  Future<List<dynamic>> getMyCpds() async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    dio.options.headers['Accept'] = "application/json";
    try {
      final response = await client.getMyCpds();
      return response['data'];
    } catch (e) {
      return [];
    }
  }

  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final logIn = await AuthenticateWithGoogleToken(googleAuth!.accessToken);
      if (logIn) {
        return true;
      } else {
        return false;
      }
    } on Exception catch (e) {
      // log('Failed to login with Google: $e');
      // TODO
      return false;
    }
  }

  Future<bool> authenticateWithAppleEmail(
      Map<String, String> credentials) async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    //accept application/json
    dio.options.headers['Accept'] = "application/json";

    try {
      final response =
          await client.authenticateWithAppleEmail(body: credentials);
      if (response.containsKey('authorization') &&
          response['authorization'].containsKey('token')) {
        final accessToken = response['authorization']['token'];
        // Save the access token for later use
        await saveAccessToken(accessToken);

        //save fcm token
        await saveFcmToken(response['user']['id']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // log('Failed to login with Apple: $e');
      return false;
    }
  }

  Future<bool> AuthenticateWithGoogleToken(String? token) async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    //accept application/json
    dio.options.headers['Accept'] = "application/json";
    Map<String, String> details = {"token": token!};
    try {
      final response = await client.AuthenticateWithGoogleToken(body: details);
      if (response.containsKey('authorization') &&
          response['authorization'].containsKey('token')) {
        final accessToken = response['authorization']['token'];
        // Save the access token for later use
        await saveAccessToken(accessToken);

        //save fcm token
        await saveFcmToken(response['user']['id']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  //payments history
  Future<dynamic> getPaymentsHistory() async {
    final dio = Dio();
    final client = AuthRestClient(dio);
    dio.options.headers['Authorization'] = "Bearer ${await getAccessToken()}";
    dio.options.headers['Accept'] = "application/json";
    try {
      final response = await client.getPaymentsHistory();

      //check if response contains message
      if (response.containsKey('data')) {
        return response['data'];
      } else {
        return [];
      }
    } catch (e) {
      log("Error: $e");
      return [];
    }
  }
}
