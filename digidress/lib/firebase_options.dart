// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCeS4U-59yjLlxsre0EpdrLtVTxqa4w_qY',
    appId: '1:916879133384:web:2190d505463998e92eb3fd',
    messagingSenderId: '916879133384',
    projectId: 'digidress-sdp-firebase-55245',
    authDomain: 'digidress-sdp-firebase-55245.firebaseapp.com',
    storageBucket: 'digidress-sdp-firebase-55245.appspot.com',
    measurementId: 'G-R2HWVF0LMZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBorA8cYjlr45nYP3LVHlwfHJ4JTsxizIY',
    appId: '1:916879133384:android:aec996fea85fb45d2eb3fd',
    messagingSenderId: '916879133384',
    projectId: 'digidress-sdp-firebase-55245',
    storageBucket: 'digidress-sdp-firebase-55245.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBgSg1qDeu8axIWdkXzXdLsDrwhIQodT6M',
    appId: '1:916879133384:ios:bcb55e240d3344612eb3fd',
    messagingSenderId: '916879133384',
    projectId: 'digidress-sdp-firebase-55245',
    storageBucket: 'digidress-sdp-firebase-55245.appspot.com',
    iosBundleId: 'com.example.digidress',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBgSg1qDeu8axIWdkXzXdLsDrwhIQodT6M',
    appId: '1:916879133384:ios:bcb55e240d3344612eb3fd',
    messagingSenderId: '916879133384',
    projectId: 'digidress-sdp-firebase-55245',
    storageBucket: 'digidress-sdp-firebase-55245.appspot.com',
    iosBundleId: 'com.example.digidress',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCeS4U-59yjLlxsre0EpdrLtVTxqa4w_qY',
    appId: '1:916879133384:web:6db579a0e6d524fe2eb3fd',
    messagingSenderId: '916879133384',
    projectId: 'digidress-sdp-firebase-55245',
    authDomain: 'digidress-sdp-firebase-55245.firebaseapp.com',
    storageBucket: 'digidress-sdp-firebase-55245.appspot.com',
    measurementId: 'G-THCC1K96VX',
  );
}
