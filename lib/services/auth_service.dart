import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _initialized = false;

  static User? get currentUser => _auth.currentUser;

  static bool get isSignedIn => _auth.currentUser != null;

  // Initialize Google Sign In (required for version 7.x+)
  static Future<void> initialize() async {
    if (!_initialized) {
      await _googleSignIn.initialize();
      _initialized = true;
    }
  }

  // Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Ensure Google Sign In is initialized
      await initialize();

      // Trigger the authentication flow (authenticate() replaces signIn() in v7.x)
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Obtain the auth details from the request
      // In version 7.x, authentication is still a Future and contains accessToken and idToken
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return null;
    }
  }

  // Sign in with Apple (iOS only)
  static Future<UserCredential?> signInWithApple() async {
    try {
      if (!Platform.isIOS) {
        throw UnsupportedError('Apple Sign In is only available on iOS');
      }

      // Request credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      debugPrint('Error signing in with Apple: $e');
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Get user display name
  static String? get displayName => _auth.currentUser?.displayName;

  // Get user email
  static String? get email => _auth.currentUser?.email;

  // Get user photo URL
  static String? get photoUrl => _auth.currentUser?.photoURL;

  // Get user ID
  static String? get userId => _auth.currentUser?.uid;
}
