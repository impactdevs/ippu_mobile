import 'package:flutter/material.dart';
import 'package:ippu/Util/color_font_pallete.dart';
import 'package:pinput/pinput.dart';

class PinInput extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onPinComplete; // Callback method
  const PinInput({super.key, required this.controller, this.onPinComplete});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: MediaQuery.of(context).size.width * 0.14,
      height: MediaQuery.of(context).size.width * 0.14,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 214, 208, 208),
        border: Border.all(color: inputColor),
        borderRadius: BorderRadius.circular(50),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border:
          Border.all(color: const Color.fromARGB(255, 28, 126, 224), width: 3),
      borderRadius: BorderRadius.circular(50),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromARGB(255, 206, 208, 209),
      ),
    );

    return Pinput(
      length: 6,
      androidSmsAutofillMethod: AndroidSmsAutofillMethod.none,
      listenForMultipleSmsOnAndroid: true,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      controller: controller,
      submittedPinTheme: submittedPinTheme,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      validator: (value) {
        if (value != null && value.length == 6 && onPinComplete != null) {
          onPinComplete!(value);
        }
        return null;
      },
    );
  }
}
