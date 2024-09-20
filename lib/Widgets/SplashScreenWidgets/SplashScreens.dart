import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:ippu/Screens/public_dashboard.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      title: "Discover about IPPU",
      description:
          "Bringing together Public & Private Sector Procurement & Supply Chain Professionals in Uganda.",
      image: "assets/image4.png",
    ),
    const OnboardingPage(
      title: "Events & CPD Trainings",
      description:
          "Get access to all Events & CPD Trainings in the procurement and supply chain professional community.",
      image: "assets/image6.png",
    ),
    const OnboardingPage(
      title: "Effective Communication",
      description:
          "Get timely updates and do not miss out on any important communications.",
      image: "assets/image3.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _pages[index];
            },
          ),
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const PublicDashboardScreen();
                }));
              },
              child: const Text("Skip"),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text("Back"),
                  )
                else
                  const SizedBox(width: 80),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const PublicDashboardScreen();
                      }));
                    }
                  },
                  child: Text(
                      _currentPage < _pages.length - 1 ? "Next" : "Finish"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: size.height * 0.28),
        SizedBox(height: size.height * 0.04),
        Text(title,
            style: GoogleFonts.lato(
                fontSize: size.height * 0.025, fontWeight: FontWeight.bold)),
        SizedBox(height: size.height * 0.02),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontSize: size.height * 0.018),
          ),
        ),
      ],
    );
  }
}
