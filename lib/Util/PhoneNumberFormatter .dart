import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    final formattedValue = _formatPhoneNumber(text);
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }

  String _formatPhoneNumber(String text) {
    if (text.length > 13) {
      text = text.substring(0, 13);
    }

    if (text.length <= 4) {
      return text;
    } else if (text.length <= 7) {
      return '${text.substring(0, 4)} ${text.substring(4)}';
    } else if (text.length <= 10) {
      return '${text.substring(0, 4)} ${text.substring(4, 7)} ${text.substring(7)}';
    } else {
      return '${text.substring(0, 4)} ${text.substring(4, 7)} ${text.substring(7, 10)} ${text.substring(10)}';
    }
  }
}
