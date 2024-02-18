import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:newsdroid/adapter/favorito_adapter.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:newsdroid/tema/tema.dart';
import 'package:newsdroid/widgets/bottom_navigation.dart';
import 'package:newsdroid/models/favorito_model.dart';
import 'firebase_options.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(BetterFeedback(
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
  ));

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Favoritos
  await Hive.initFlutter();
  Hive.registerAdapter(FavoritePostAdapter());
  await Hive.openBox('favorite_posts');

  // Data da publicacao formatada
  await initializeDateFormatting();

  // Firebase
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

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FavoritePostsModel>(
            create: (_) => FavoritePostsModel()),
        ChangeNotifierProvider<ThemeModel>(create: (_) => ThemeModel()),
      ],
      child: Consumer<ThemeModel>(
        builder: (_, theme, __) {
          return DynamicColorBuilder(
              builder: (lightColorScheme, darkColorScheme) {
            if (!theme.isDynamicColorsEnabled) {
              lightColorScheme = null;
              darkColorScheme = null;
            }

            return MaterialApp(
              theme: ThemeData(
                brightness: Brightness.light,
                colorScheme: lightColorScheme?.copyWith(
                  primary: theme.isDarkMode ? Colors.black : Colors.white,
                ),
                useMaterial3: true,
                textTheme: Typography().black.apply(fontFamily: 'OpenSans'),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                colorScheme: darkColorScheme?.copyWith(
                  primary: theme.isDarkMode ? Colors.white : Colors.black,
                ),
                useMaterial3: true,
                textTheme: Typography().white.apply(fontFamily: 'OpenSans'),
              ),
              themeMode: theme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              debugShowCheckedModeBanner: false,
              home: const BottomNavigationContainer(),
            );
          });
        },
      ),
    );
  }
}
