import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/firestore_utils.dart';
import '../../../core/constants/app_constants.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final bool isPredefined;
  final String status; // approved / pending / rejected
  final String? suggestedBy;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.isPredefined = false,
    this.status = AppConstants.categoryStatusApproved,
    this.suggestedBy,
    required this.createdAt,
  });

  bool get isApproved => status == AppConstants.categoryStatusApproved;
  bool get isPending => status == AppConstants.categoryStatusPending;
  bool get isRejected => status == AppConstants.categoryStatusRejected;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: FirestoreUtils.getString(json, 'id'),
      name: FirestoreUtils.getString(json, 'name'),
      icon: FirestoreUtils.getString(json, 'icon', defaultValue: '📦'),
      isPredefined: FirestoreUtils.getBool(json, 'isPredefined'),
      status: FirestoreUtils.getString(json, 'status',
          defaultValue: AppConstants.categoryStatusApproved),
      suggestedBy: json['suggestedBy'] as String?,
      createdAt: FirestoreUtils.toDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return CategoryModel.fromJson(data);
  }

  /// Build CategoryModel instances from the predefined list in AppConstants.
  static List<CategoryModel> get predefined {
    return AppConstants.predefinedCategories.map((cat) {
      return CategoryModel(
        id: cat['id']!,
        name: cat['name']!,
        icon: cat['icon']!,
        isPredefined: true,
        status: AppConstants.categoryStatusApproved,
        createdAt: DateTime(2024, 1, 1),
      );
    }).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'isPredefined': isPredefined,
      'status': status,
      'suggestedBy': suggestedBy,
      'createdAt': FirestoreUtils.fromDateTime(createdAt),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    bool? isPredefined,
    String? status,
    String? suggestedBy,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isPredefined: isPredefined ?? this.isPredefined,
      status: status ?? this.status,
      suggestedBy: suggestedBy ?? this.suggestedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CategoryModel(id: $id, name: $name, status: $status)';
}
