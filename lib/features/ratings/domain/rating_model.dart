import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/firestore_utils.dart';

class RatingModel {
  final String id;
  final String userId;
  final String productId;
  final int score; // 1-5
  final bool? liked;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RatingModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.score,
    this.liked,
    this.photoUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: FirestoreUtils.getString(json, 'id'),
      userId: FirestoreUtils.getString(json, 'userId'),
      productId: FirestoreUtils.getString(json, 'productId'),
      score: FirestoreUtils.getInt(json, 'score', defaultValue: 3),
      liked: json['liked'] as bool?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: FirestoreUtils.toDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: FirestoreUtils.toDateTime(json['updatedAt']),
    );
  }

  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return RatingModel.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'score': score,
      'liked': liked,
      'photoUrl': photoUrl,
      'createdAt': FirestoreUtils.fromDateTime(createdAt),
      'updatedAt': FirestoreUtils.fromDateTime(updatedAt),
    };
  }

  RatingModel copyWith({
    String? id,
    String? userId,
    String? productId,
    int? score,
    bool? liked,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RatingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      score: score ?? this.score,
      liked: liked ?? this.liked,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RatingModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'RatingModel(id: $id, productId: $productId, score: $score)';
}
