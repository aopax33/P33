import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/firebase_service.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final AuthService _authService;
  final FirebaseService _firebaseService;

  AuthRepository({
    required AuthService authService,
    required FirebaseService firebaseService,
  })  : _authService = authService,
        _firebaseService = firebaseService;

  // ── Auth state ─────────────────────────────────────────────────────────────

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  User? get currentUser => _authService.currentUser;

  // ── Sign In ────────────────────────────────────────────────────────────────

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmail(
        email: email, password: password);
    return _getOrCreateUserDoc(credential.user!);
  }

  Future<UserModel> signInWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    return _getOrCreateUserDoc(credential.user!);
  }

  Future<UserModel> signInWithApple() async {
    final credential = await _authService.signInWithApple();
    return _getOrCreateUserDoc(credential.user!);
  }

  // ── Register ───────────────────────────────────────────────────────────────

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _authService.signUp(
        email: email, password: password, displayName: displayName);
    return _getOrCreateUserDoc(credential.user!);
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────

  Future<void> signOut() => _authService.signOut();

  // ── User document ──────────────────────────────────────────────────────────

  Future<UserModel?> fetchUserModel(String uid) async {
    final data = await _firebaseService.getDoc(
        _firebaseService.usersRef, uid);
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  Stream<UserModel?> userModelStream(String uid) {
    return _firebaseService
        .docStream(_firebaseService.usersRef, uid)
        .map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return UserModel.fromJson(data);
    });
  }

  Future<void> updateUserModel(UserModel user) async {
    await _firebaseService.setDoc(
        _firebaseService.usersRef, user.id, user.toJson(), merge: true);
  }

  Future<void> updateAvatar(String uid, String avatarUrl) async {
    await _firebaseService.updateDoc(
        _firebaseService.usersRef, uid, {'avatarUrl': avatarUrl});
    await _authService.updatePhotoURL(avatarUrl);
  }

  // ── Like / dislike ─────────────────────────────────────────────────────────

  Future<void> likeProduct(String uid, String productId) async {
    await _firebaseService.usersRef.doc(uid).update({
      'likedProducts': FieldValue.arrayUnion([productId]),
      'dislikedProducts': FieldValue.arrayRemove([productId]),
    });
  }

  Future<void> dislikeProduct(String uid, String productId) async {
    await _firebaseService.usersRef.doc(uid).update({
      'dislikedProducts': FieldValue.arrayUnion([productId]),
      'likedProducts': FieldValue.arrayRemove([productId]),
    });
  }

  Future<void> removeLikeDislike(String uid, String productId) async {
    await _firebaseService.usersRef.doc(uid).update({
      'likedProducts': FieldValue.arrayRemove([productId]),
      'dislikedProducts': FieldValue.arrayRemove([productId]),
    });
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<UserModel> _getOrCreateUserDoc(User firebaseUser) async {
    final existing = await fetchUserModel(firebaseUser.uid);
    if (existing != null) return existing;

    final newUser = UserModel(
      id: firebaseUser.uid,
      displayName: firebaseUser.displayName ?? 'User',
      email: firebaseUser.email ?? '',
      avatarUrl: firebaseUser.photoURL,
      authProvider: _authService.currentAuthProvider,
      likedProducts: const [],
      dislikedProducts: const [],
      createdAt: DateTime.now(),
      isActive: true,
    );

    await _firebaseService.setDoc(
        _firebaseService.usersRef, newUser.id, newUser.toJson());
    return newUser;
  }
}
