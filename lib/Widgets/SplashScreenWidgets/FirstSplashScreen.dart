import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:ippu/Util/TextWords.dart';

import 'package:ippu/Widgets/AuthenticationWidgets/LoginScreen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'SecondSplashScreen.dart';

class FirstSplashScreen extends StatefulWidget {
  const FirstSplashScreen({super.key});

  @override
  State<FirstSplashScreen> createState() => _FirstSplashScreenState();
}

class _FirstSplashScreenState extends State<FirstSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    timeDilation = 2.0; // Slowing down the animation for demonstration purposes

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.015,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(''),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const LoginScreen();
                    }));
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: size.width * 0.05),
                    child: Text(
                      "skip",
                      style: GoogleFonts.lato(
                          fontSize: size.height * 0.025,
                          color: const Color.fromARGB(255, 42, 129, 201),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: size.height * 0.088,
            ),
            SizedBox(
              height: size.height * 0.35,
              width: double.maxFinite,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + 0.1 * _animation.value,
                    child: child,
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/image4.png"),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.048,
            ),
            Text(
              "Discover about IPPU",
              style: GoogleFonts.lato(
                  letterSpacing: 1,
                  fontSize: size.width * 0.082,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 42, 129, 201)),
            ),
            SizedBox(
              height: size.height * 0.015,
            ),
            Padding(
              padding: EdgeInsets.only(
                  right: size.width * 0.05, left: size.width * 0.06),
              child: Text(
                discoverAboutIPPU,
                style: GoogleFonts.lato(fontSize: size.height * 0.016),
              ),
            ),
            SizedBox(
              height: size.height * 0.055,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: size.width * 0.084),
                      height: size.height * 0.052,
                      width: size.width * 0.062,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 42, 129, 201)
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: size.width * 0.04),
                      height: size.height * 0.052,
                      width: size.width * 0.062,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: size.width * 0.04),
                      height: size.height * 0.052,
                      width: size.width * 0.062,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const SecondSplashScreen();
                    }));
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: size.width * 0.04),
                    height: size.height * 0.08,
                    width: size.width * 0.16,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 42, 129, 201),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: size.height * 0.04,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
