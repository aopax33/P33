import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/firestore_utils.dart';

class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final String authProvider;
  final List<String> likedProducts;
  final List<String> dislikedProducts;
  final DateTime createdAt;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    required this.authProvider,
    this.likedProducts = const [],
    this.dislikedProducts = const [],
    required this.createdAt,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: FirestoreUtils.getString(json, 'id'),
      displayName: FirestoreUtils.getString(json, 'displayName'),
      email: FirestoreUtils.getString(json, 'email'),
      avatarUrl: json['avatarUrl'] as String?,
      authProvider: FirestoreUtils.getString(json, 'authProvider', defaultValue: 'email'),
      likedProducts: FirestoreUtils.getStringList(json, 'likedProducts'),
      dislikedProducts: FirestoreUtils.getStringList(json, 'dislikedProducts'),
      createdAt: FirestoreUtils.toDateTime(json['createdAt']) ?? DateTime.now(),
      isActive: FirestoreUtils.getBool(json, 'isActive', defaultValue: true),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return UserModel.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
      'authProvider': authProvider,
      'likedProducts': likedProducts,
      'dislikedProducts': dislikedProducts,
      'createdAt': FirestoreUtils.fromDateTime(createdAt),
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? displayName,
    String? email,
    String? avatarUrl,
    String? authProvider,
    List<String>? likedProducts,
    List<String>? dislikedProducts,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authProvider: authProvider ?? this.authProvider,
      likedProducts: likedProducts ?? this.likedProducts,
      dislikedProducts: dislikedProducts ?? this.dislikedProducts,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UserModel(id: $id, displayName: $displayName, email: $email)';
}
