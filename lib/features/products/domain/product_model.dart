import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/firestore_utils.dart';

class ProductModel {
  final String id;
  final String name;
  final String company;
  final String store;
  final String categoryId;
  final String? photoUrl;
  final double avgRating;
  final int totalRatings;
  final int totalLikes;
  final int totalDislikes;
  final String submittedBy;
  final DateTime createdAt;
  final bool isVisible;

  const ProductModel({
    required this.id,
    required this.name,
    required this.company,
    required this.store,
    required this.categoryId,
    this.photoUrl,
    this.avgRating = 0.0,
    this.totalRatings = 0,
    this.totalLikes = 0,
    this.totalDislikes = 0,
    required this.submittedBy,
    required this.createdAt,
    this.isVisible = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: FirestoreUtils.getString(json, 'id'),
      name: FirestoreUtils.getString(json, 'name'),
      company: FirestoreUtils.getString(json, 'company'),
      store: FirestoreUtils.getString(json, 'store'),
      categoryId: FirestoreUtils.getString(json, 'categoryId'),
      photoUrl: json['photoUrl'] as String?,
      avgRating: FirestoreUtils.getDouble(json, 'avgRating'),
      totalRatings: FirestoreUtils.getInt(json, 'totalRatings'),
      totalLikes: FirestoreUtils.getInt(json, 'totalLikes'),
      totalDislikes: FirestoreUtils.getInt(json, 'totalDislikes'),
      submittedBy: FirestoreUtils.getString(json, 'submittedBy'),
      createdAt: FirestoreUtils.toDateTime(json['createdAt']) ?? DateTime.now(),
      isVisible: FirestoreUtils.getBool(json, 'isVisible', defaultValue: true),
    );
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return ProductModel.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'store': store,
      'categoryId': categoryId,
      'photoUrl': photoUrl,
      'avgRating': avgRating,
      'totalRatings': totalRatings,
      'totalLikes': totalLikes,
      'totalDislikes': totalDislikes,
      'submittedBy': submittedBy,
      'createdAt': FirestoreUtils.fromDateTime(createdAt),
      'isVisible': isVisible,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? company,
    String? store,
    String? categoryId,
    String? photoUrl,
    double? avgRating,
    int? totalRatings,
    int? totalLikes,
    int? totalDislikes,
    String? submittedBy,
    DateTime? createdAt,
    bool? isVisible,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      store: store ?? this.store,
      categoryId: categoryId ?? this.categoryId,
      photoUrl: photoUrl ?? this.photoUrl,
      avgRating: avgRating ?? this.avgRating,
      totalRatings: totalRatings ?? this.totalRatings,
      totalLikes: totalLikes ?? this.totalLikes,
      totalDislikes: totalDislikes ?? this.totalDislikes,
      submittedBy: submittedBy ?? this.submittedBy,
      createdAt: createdAt ?? this.createdAt,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ProductModel(id: $id, name: $name, store: $store, avgRating: $avgRating)';
}
