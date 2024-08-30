import 'package:flutter/material.dart';

class SecondSetOfRows extends StatefulWidget {
  const SecondSetOfRows({super.key});

  @override
  State<SecondSetOfRows> createState() => _SecondSetOfRowsState();
}

class _SecondSetOfRowsState extends State<SecondSetOfRows> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: size.height * 0.009,
          ),
          height: size.height * 0.39,
          width: size.width * 0.90,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                offset: const Offset(0.8, 1.0),
                blurRadius: 4.0,
                spreadRadius: 0.2,
              ),
            ],
          ),
          child: const Text(""),
        )
      ],
    );
  }
}
