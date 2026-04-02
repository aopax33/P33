import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream of Firebase auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in Firebase user, or null.
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Register with email and password, then update display name.
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(displayName.trim());
    return credential;
  }

  /// Sign in with Google.
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign_in_cancelled',
        message: 'Google sign-in was cancelled by the user.',
      );
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  /// Sign in with Apple (iOS only).
  Future<UserCredential> signInWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw UnsupportedError('Apple Sign-In is only supported on iOS/macOS.');
    }

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(oauthCredential);

    // Apple only provides name on first sign-in
    if (appleCredential.givenName != null) {
      final fullName =
          '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
              .trim();
      await userCredential.user?.updateDisplayName(fullName);
    }

    return userCredential;
  }

  /// Send a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Sign out from Firebase and Google.
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Update the display name for the current user.
  Future<void> updateDisplayName(String displayName) async {
    await _auth.currentUser?.updateDisplayName(displayName.trim());
  }

  /// Update the photo URL for the current user.
  Future<void> updatePhotoURL(String photoURL) async {
    await _auth.currentUser?.updatePhotoURL(photoURL);
  }

  /// Determine the auth provider used by the current user.
  String get currentAuthProvider {
    final providerData = _auth.currentUser?.providerData;
    if (providerData == null || providerData.isEmpty) return 'email';
    final providerId = providerData.first.providerId;
    if (providerId.contains('google')) return 'google';
    if (providerId.contains('apple')) return 'apple';
    return 'email';
  }
}
