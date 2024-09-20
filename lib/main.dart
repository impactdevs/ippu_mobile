import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Providers/ProfilePicProvider.dart';
import 'package:ippu/Providers/SubscriptionStatus.dart';
import 'package:ippu/Providers/auth.dart';
import 'package:ippu/Providers/network.dart';
import 'package:ippu/Screens/DefaultScreen.dart';
import 'package:ippu/Screens/EducationBackgroundScreen.dart';
import 'package:ippu/Screens/EventsScreen.dart';
import 'package:ippu/Screens/WorkExperience.dart';
import 'package:ippu/Widgets/AuthenticationWidgets/LoginScreen.dart';
import 'package:ippu/Widgets/SplashScreenWidgets/SplashScreens.dart';
import 'package:ippu/firebase_options.dart';
import 'package:ippu/models/UserProvider.dart';
import 'package:ippu/services/FirebaseApi.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isFirstLaunch = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setValue().then((isFirstLaunch) {
      setState(() {
        this.isFirstLaunch = isFirstLaunch;
        isLoading =
            false; // Set loading to false once the operation is complete
      });
    });
  }

  Future<bool> setValue() async {
    final prefs = await SharedPreferences.getInstance();
    int launchCount = prefs.getInt('counter') ?? 0;
    prefs.setInt('counter', launchCount + 1);
    if (launchCount == 0) {
      await FirebaseApi().initNotifications();

      await askForNotificationPermission();
      // If it's the first launch, return true.
      return true;
    } else {
      // If it's not the first launch, return false.
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider(create: (context) => ProfilePicProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(
            create: (context) => SubscriptionStatusProvider()),
        ChangeNotifierProvider(create: (context) => CheckNetworkConnectivity()),
      ],
      child: OverlaySupport(
        child: GetMaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'IPPU Membership APP',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: GoogleFonts.latoTextTheme(
              Theme.of(context).textTheme,
            ).copyWith(
              bodyLarge: const TextStyle(
                color: Colors.blue, // Set your desired text color here
              ),
              bodyMedium: const TextStyle(
                color: Colors.blue, // Set your desired text color here
              ),
              bodySmall: const TextStyle(
                color: Colors.blue, // Set your desired text color here
              ),
              displayLarge: const TextStyle(
                color: Colors.blue, // Set your desired text color here
              ),
              displayMedium: const TextStyle(
                color: Colors.blue, // Set your desired text color here
              ),
            ),
          ),
          home: isLoading
              ? const Scaffold(
                  backgroundColor:
                      Colors.white, // Set the background color to white
                  body: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue, // Set the color of the spinner
                      ),
                    ),
                  ),
                )
              : isFirstLaunch
                  ? const OnboardingScreens()
                  : Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        auth.isLoggedIn();
                        return auth.isAuthenticated
                            ? const DefaultScreen()
                            : const LoginScreen();
                      },
                    ),
          routes: {
            '/myevents': (context) => const EventsScreen(),
            '/educationbackground': (context) =>
                const EducationBackgroundScreen(),
            '/workexperience': (context) => const WorkExperience(),
            '/homescreen': (context) => const DefaultScreen(),
          },
        ),
      ),
    );
  }

  Future<bool> askForNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      //show an alert dialog with "you will receive notifications when new events are added"
      AlertDialog(
        title: const Text("Notification Permission Granted"),
        content: const Text(
            "You will receive notifications when new events are added"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          )
        ],
      );

      return true;
    } else {
      //show an alert dialog with "you will not receive notifications when new events are added"
      AlertDialog(
        title: const Text("Notification Permission Denied"),
        content: const Text(
            "You will not receive notifications when new events are added"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          )
        ],
      );

      return false;
    }
  }
}
