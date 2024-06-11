import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/blogger',
    ],
  );

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount == null) {
        return null;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        if (kDebugMode) {
          print('Usuário autenticado com sucesso: ${user.displayName}');
        }
      } else {
        if (kDebugMode) {
          print('Falha na autenticação: Usuário nulo');
        }
      }

      return user;
    } catch (error) {
      if (kDebugMode) {
        print('Erro na autenticação: $error');
      }
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<User?> currentUser() async {
    return _auth.currentUser;
  }

  Future<GoogleSignInAccount?> get googleSignInAccount async {
    return _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
  }

  Future<String?> get accessToken async {
    final googleAccount = await googleSignInAccount;
    if (googleAccount != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;
      return googleAuth.accessToken;
    }
    return null;
  }
}
