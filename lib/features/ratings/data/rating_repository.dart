import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import '../../../services/storage_service.dart';
import '../domain/rating_model.dart';

class RatingRepository {
  final FirebaseService _firebase;
  final StorageService _storage;

  RatingRepository({
    required FirebaseService firebase,
    required StorageService storage,
  })  : _firebase = firebase,
        _storage = storage;

  Stream<List<RatingModel>> ratingsForProduct(String productId) {
    return _firebase.ratingsRef
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = Map<String, dynamic>.from(doc.data() as Map);
              data['id'] = doc.id;
              return RatingModel.fromJson(data);
            }).toList());
  }

  Stream<RatingModel?> userRatingForProduct(
      String userId, String productId) {
    return _firebase.ratingsRef
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      final data = Map<String, dynamic>.from(doc.data() as Map);
      data['id'] = doc.id;
      return RatingModel.fromJson(data);
    });
  }

  Future<void> submitRating({
    required String userId,
    required String productId,
    required int score,
    bool? liked,
    File? photoFile,
  }) async {
    // Check for existing rating
    final existing = await _firebase.ratingsRef
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();

    String? photoUrl;
    String docId;

    if (existing.docs.isNotEmpty) {
      docId = existing.docs.first.id;
    } else {
      docId = _firebase.ratingsRef.doc().id;
    }

    if (photoFile != null) {
      photoUrl = await _storage.uploadRatingPhoto(
          ratingId: docId, file: photoFile);
    }

    if (existing.docs.isNotEmpty) {
      // Update
      final updates = <String, dynamic>{
        'score': score,
        'liked': liked,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      await _firebase.ratingsRef.doc(docId).update(updates);
    } else {
      // Create
      final rating = RatingModel(
        id: docId,
        userId: userId,
        productId: productId,
        score: score,
        liked: liked,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
      );
      await _firebase.ratingsRef.doc(docId).set(rating.toJson());
    }
  }

  Future<void> deleteRating(String ratingId) async {
    await _firebase.ratingsRef.doc(ratingId).delete();
  }
}
