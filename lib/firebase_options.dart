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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    storageBucket: 'news-droid-app-1670874618271.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyACvJFaikcjYaXMTzDR2YQSbCbQUxgF9aE',
    appId: '1:728569554138:ios:d85197e9f123a9928471e3',
    messagingSenderId: '728569554138',
    projectId: 'news-droid-app-1670874618271',
    storageBucket: 'news-droid-app-1670874618271.firebasestorage.app',
    androidClientId:
        '728569554138-7ruh4kc52r9j0phuv657qa64ogk0q09k.apps.googleusercontent.com',
    iosClientId:
        '728569554138-e4onusju0gnidnf1dgs1e4b0kstjc18q.apps.googleusercontent.com',
    iosBundleId:
        'com.github.hendrilmendes.news.OneSignalNotificationServiceExtension',
  );
}
