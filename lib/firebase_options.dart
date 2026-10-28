// Web Firebase config (public by design; security comes from Firestore/Storage rules).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'AIzaSyCbE0xtTYnQJOCp6RqBMDtdOVjYmRtRxNY',
    appId: '1:208763405491:web:075cc3d5b7a6980c88dcc6',
    messagingSenderId: '208763405491',
    projectId: 'vibestream-97da9',
    authDomain: 'vibestream-97da9.firebaseapp.com',
    storageBucket: 'vibestream-97da9.firebasestorage.app',
  );
}
