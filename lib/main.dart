import 'package:feedback/feedback.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:newsdroid/adapter/favorite_adapter.dart';
import 'package:newsdroid/auth/auth.dart';
import 'package:newsdroid/l10n/app_localizations.dart';
import 'package:newsdroid/screens/login/login.dart';
import 'package:newsdroid/updater/updater.dart';
import 'package:newsdroid/widgets/bottom_navigation.dart';
import 'package:newsdroid/widgets/permissions/permissions.dart';
import 'package:provider/provider.dart';
import 'package:newsdroid/theme/theme.dart';
import 'package:newsdroid/models/favorite_model.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Shorebird
  await ShorebirdUpdater().checkForUpdate();

  // AdMob
  await MobileAds.instance.initialize();

  runApp(
    BetterFeedback(
      theme: FeedbackThemeData.light(),
      darkTheme: FeedbackThemeData.dark(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalFeedbackLocalizationsDelegate(),
      ],
      localeOverride: const Locale('pt'),
      child: const MyApp(),
    ),
  );

  // Favoritos
  await Hive.initFlutter();
  Hive.registerAdapter(FavoritePostAdapter());
  await Hive.openBox('favorite_posts');

  // Data da publicacao formatada
  await initializeDateFormatting();

  // Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (kDebugMode) {
    print("Permissão concedida ao usuário: ${settings.authorizationStatus}");
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      print("Recebi uma mensagem enquanto estava em primeiro plano!");
    }
    if (kDebugMode) {
      print("Dados da mensagem: ${message.data}");
    }

    if (message.notification != null) {
      if (kDebugMode) {
        print("A mensagem continha uma notificação: ${message.notification}");
      }
    }
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Lidando com uma mensagem em segundo plano: ${message.messageId}");
  }

  //Permissoes
  await requestPermissions();

  // Firebase
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
}

ThemeMode _getThemeMode(ThemeModeType mode) {
  switch (mode) {
    case ThemeModeType.light:
      return ThemeMode.light;
    case ThemeModeType.dark:
      return ThemeMode.dark;
    case ThemeModeType.system:
      return ThemeMode.system;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();
  bool _updateChecked = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FavoritePostsModel>(
          create: (_) => FavoritePostsModel(),
        ),
        ChangeNotifierProvider<ThemeModel>(create: (_) => ThemeModel()),
      ],
      child: Consumer<ThemeModel>(
        builder: (_, themeModel, _) {
          return MaterialApp(
            theme: themeModel.lightTheme,
            darkTheme: themeModel.darkTheme,
            themeMode: _getThemeMode(themeModel.themeMode),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: _buildHome(context),
            routes: {
              '/login': (context) => LoginScreen(authService: authService),
            },
          );
        },
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    return FutureBuilder<User?>(
      future: authService.currentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (!_updateChecked) {
            _updateChecked = true;
            Updater.checkUpdateApp(context);
          }

          if (snapshot.hasData) {
            return const BottomNavigationContainer();
          } else {
            return LoginScreen(authService: authService);
          }
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
      },
    );
  }
}
