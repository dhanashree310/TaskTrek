import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In with Calendar scope
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar',
    ],
  );

  User? get currentUser => _auth.currentUser;

  // -------------------------------------------------------------
  // EMAIL REGISTER
  // -------------------------------------------------------------
  Future<User?> register(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim().toLowerCase(), // normalize email
          password: password.trim());
      return cred.user;
    } catch (e) {
      print("Register Error: $e");
      return null;
    }
  }

  // -------------------------------------------------------------
  // EMAIL LOGIN
  // -------------------------------------------------------------
  Future<User?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim().toLowerCase(), // normalize email
          password: password.trim());
      return cred.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // -------------------------------------------------------------
  // GOOGLE LOGIN
  // -------------------------------------------------------------
  Future<User?> googleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      return userCred.user;
    } catch (e) {
      print("Google Sign In Error: $e");
      return null;
    }
  }

  // -------------------------------------------------------------
  // GUEST LOGIN (Firebase Anonymous)
  // -------------------------------------------------------------
  Future<User?> guestLogin() async {
    try {
      final cred = await _auth.signInAnonymously();
      return cred.user;
    } catch (e) {
      print("Guest Login Error: $e");
      return null;
    }
  }

  // -------------------------------------------------------------
  // GOOGLE CALENDAR ACCESS TOKEN
  // -------------------------------------------------------------
  Future<String?> getAccessToken() async {
    final googleUser = _googleSignIn.currentUser;
    if (googleUser == null) return null;

    final auth = await googleUser.authentication;
    return auth.accessToken;
  }

  // -------------------------------------------------------------
  // LOGOUT
  // -------------------------------------------------------------
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
