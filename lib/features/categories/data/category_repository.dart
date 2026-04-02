import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/firebase_service.dart';
import '../domain/category_model.dart';

class CategoryRepository {
  final FirebaseService _firebase;

  CategoryRepository({required FirebaseService firebase})
      : _firebase = firebase;

  Stream<List<CategoryModel>> approvedCategoriesStream() {
    return _firebase.categoriesRef
        .where('status', isEqualTo: AppConstants.categoryStatusApproved)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = Map<String, dynamic>.from(doc.data() as Map);
              data['id'] = doc.id;
              return CategoryModel.fromJson(data);
            }).toList());
  }

  Future<CategoryModel?> fetchCategory(String categoryId) async {
    final doc = await _firebase.categoriesRef.doc(categoryId).get();
    if (!doc.exists) return null;
    final data = Map<String, dynamic>.from(doc.data() as Map);
    data['id'] = doc.id;
    return CategoryModel.fromJson(data);
  }

  Future<void> seedPredefinedCategories() async {
    final batch = _firebase.firestore.batch();
    for (final cat in CategoryModel.predefined) {
      final ref = _firebase.categoriesRef.doc(cat.id);
      final doc = await ref.get();
      if (!doc.exists) {
        batch.set(ref, cat.toJson());
      }
    }
    await batch.commit();
  }

  Future<void> suggestCategory({
    required String name,
    required String icon,
    required String suggestedBy,
  }) async {
    final ref = _firebase.categoriesRef.doc();
    final cat = CategoryModel(
      id: ref.id,
      name: name.trim(),
      icon: icon,
      isPredefined: false,
      status: AppConstants.categoryStatusPending,
      suggestedBy: suggestedBy,
      createdAt: DateTime.now(),
    );
    await ref.set(cat.toJson());
  }
}
