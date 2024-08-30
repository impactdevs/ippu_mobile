import 'package:flutter/material.dart';

class IppuTermsOfUse extends StatefulWidget {
  const IppuTermsOfUse({super.key});

  @override
  State<IppuTermsOfUse> createState() => _IppuTermsOfUseState();
}

class _IppuTermsOfUseState extends State<IppuTermsOfUse> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IPPU Terms of use",),
        backgroundColor:const Color.fromARGB(255, 42, 129, 201),
        elevation: 0,
      ),
    );
  }
}