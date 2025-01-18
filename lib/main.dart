import 'package:feedback/feedback.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:newsdroid/adapter/favorite_adapter.dart';
import 'package:newsdroid/auth/auth.dart';
import 'package:newsdroid/screens/login/login.dart';
import 'package:newsdroid/updater/updater.dart';
import 'package:newsdroid/widgets/bottom_navigation.dart';
import 'package:newsdroid/widgets/permissions/permissions.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:newsdroid/theme/theme.dart';
import 'package:newsdroid/models/favorite_model.dart';
import 'firebase_options.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
  Hive.registerAdapter(
    FavoritePostAdapter(),
  );
  await Hive.openBox('favorite_posts');

  // Data da publicacao formatada
  await initializeDateFormatting();

  // OneSignal
  OneSignal.initialize("93a92029-c592-4c02-b492-d32d3cf6225e");

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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FavoritePostsModel>(
          create: (_) => FavoritePostsModel(),
        ),
        ChangeNotifierProvider<ThemeModel>(
          create: (_) => ThemeModel(),
        ),
      ],
      child: Consumer<ThemeModel>(
        builder: (_, themeModel, __) {
          return MaterialApp(
              theme: themeModel.lightTheme,
              darkTheme: themeModel.darkTheme,
              themeMode: _getThemeMode(themeModel.themeMode),
              debugShowCheckedModeBanner: false,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: _buildHome(authService),
              routes: {
                '/login': (context) => LoginScreen(authService: authService),
              });
        },
      ),
    );
  }

  Widget _buildHome(AuthService authService) {
    return FutureBuilder<User?>(
      future: authService.currentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Updater.checkUpdateApp(context);
          if (snapshot.hasData) {
            return const BottomNavigationContainer();
          } else {
            return LoginScreen(authService: authService);
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }
      },
    );
  }
}
