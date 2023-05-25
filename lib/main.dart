import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'telas/web/webview.dart';
import 'tema/propriedade_tema.dart';

//Android < 7.1.1 Corrige o erro de Certificado de Internet
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

main() async {
  runApp(const MyApp());

  HttpOverrides.global = MyHttpOverrides();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  OneSignal.shared.setAppId("d02a874a-6b10-43ac-a65b-747ceca1e323");
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    print("Accepted permission: $accepted");
  });

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: AppTheme().darkTheme,
      theme: AppTheme().lightTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      title: "News-Droid",
      home: const Scaffold(
        body: SafeArea(
          child: WebScreen(),
        ),
      ),
    );
  }
}
