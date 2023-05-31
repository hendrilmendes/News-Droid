import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
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

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());

  HttpOverrides.global = MyHttpOverrides();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  OneSignal.shared.setAppId("93a92029-c592-4c02-b492-d32d3cf6225e");
  OneSignal.shared.promptUserForPushNotificationPermission();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  FirebasePerformance performance = FirebasePerformance.instance;
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
