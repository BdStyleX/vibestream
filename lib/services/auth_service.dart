import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get changes => _auth.authStateChanges();
  User? get user => _auth.currentUser;

  Future<void> signIn(String email, String pass) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: pass);

  Future<void> signUp(String name, String email, String pass) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: pass);
    await cred.user!.updateDisplayName(name.trim());
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resetPassword(String email) => _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();

  /// In-app account deletion (required by Google Play for apps with accounts).
  /// Re-authenticates first, then removes the user's posts, profile and login.
  Future<void> deleteAccount(String password) async {
    final u = _auth.currentUser!;
    await u.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: u.email!, password: password));
    final posts = await _db.collection('posts').where('uid', isEqualTo: u.uid).get();
    for (final d in posts.docs) {
      await d.reference.delete();
    }
    await _db.collection('users').doc(u.uid).delete();
    await u.delete();
  }

  static String friendly(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'That email address looks wrong.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email or password is incorrect.';
        case 'email-already-in-use':
          return 'An account with this email already exists.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'network-request-failed':
          return 'No internet connection.';
        case 'too-many-requests':
          return 'Too many attempts. Try again later.';
      }
      return e.message ?? 'Something went wrong.';
    }
    return 'Something went wrong.';
  }
}
