// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDh2lGCHDaSEConjHkRp7Ny6fZq3L7g65E',
    appId: '1:728569554138:android:44d66ca44bb6bf948471e3',
    messagingSenderId: '728569554138',
    projectId: 'news-droid-app-1670874618271',
    storageBucket: 'news-droid-app-1670874618271.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyACvJFaikcjYaXMTzDR2YQSbCbQUxgF9aE',
    appId: '1:728569554138:ios:145e8d595761f37f8471e3',
    messagingSenderId: '728569554138',
    projectId: 'news-droid-app-1670874618271',
    storageBucket: 'news-droid-app-1670874618271.appspot.com',
    iosBundleId: 'com.github.hendrilmendes.news',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyACvJFaikcjYaXMTzDR2YQSbCbQUxgF9aE',
    appId: '1:728569554138:ios:32bf23abe659fa7e8471e3',
    messagingSenderId: '728569554138',
    projectId: 'news-droid-app-1670874618271',
    storageBucket: 'news-droid-app-1670874618271.appspot.com',
    iosBundleId: 'com.github.hendrilmendes.newsdroid.RunnerTests',
  );
}
