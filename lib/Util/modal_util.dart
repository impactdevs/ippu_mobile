import 'package:flutter/material.dart';
import 'package:ippu/main.dart';

class ModalUtil {
  //show an alert dialog
static void showAlertDialog(fileName, progress){
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Downloading $fileName'),
        content: Text('Downloading $fileName $progress%'),
      );
    },
  );
}
}