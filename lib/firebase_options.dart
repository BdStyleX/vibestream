// Fill these from Firebase Console > Project settings > Your apps > Web app (</>) > SDK setup and configuration.
// (Or run `flutterfire configure`, which overwrites this file.)
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'PASTE_apiKey',
    appId: 'PASTE_appId',
    messagingSenderId: 'PASTE_messagingSenderId',
    projectId: 'PASTE_projectId',
    authDomain: 'PASTE_authDomain',
    storageBucket: 'PASTE_storageBucket',
  );
}
