import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:newsdroid/adapter/favorite_adapter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:newsdroid/theme/theme.dart';
import 'package:newsdroid/widgets/bottom_navigation.dart';
import 'package:newsdroid/models/favorite_model.dart';
import 'firebase_options.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
  OneSignal.Notifications.requestPermission(true);

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
            theme: ThemeModel.lightTheme(context: context),
            darkTheme: ThemeModel.darkTheme(context: context),
            themeMode: _getThemeMode(themeModel.themeMode),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const BottomNavigationContainer(),
          );
        },
      ),
    );
  }
}
