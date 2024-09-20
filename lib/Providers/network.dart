import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

class CheckNetworkConnectivity extends ChangeNotifier {
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void setConnectionStatus(bool status) {
    _isConnected = status;
    notifyListeners();
  }

  Future<void> checkNetworkStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setConnectionStatus(false);
    } else {
      setConnectionStatus(true);
    }
  }
}
