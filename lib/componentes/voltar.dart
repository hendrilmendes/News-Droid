import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackPressed {
  DateTime _backPressedTime = DateTime.now();

  Future<bool> exit(BuildContext context) async {
    Duration difference = DateTime.now().difference(_backPressedTime);
    _backPressedTime = DateTime.now();
    if (difference >= const Duration(seconds: 2)) {
      SnackBar snack = const SnackBar(
        content: Text("Volte novamente para fechar"),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snack);
      return false; // disable back press
    } else {
      return Platform.isIOS
          ? await const MethodChannel("android_app_retain")
              .invokeMethod("sendToBackground")
          : SystemChannels.platform
              .invokeMethod('SystemNavigator.pop'); //  exit the app
    }
  }
}
