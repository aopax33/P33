import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import '../../products/domain/product_model.dart';

class DashboardRepository {
  final FirebaseService _firebase;

  DashboardRepository({required FirebaseService firebase})
      : _firebase = firebase;

  /// Returns the top-rated product (by avgRating, min 1 rating) per category.
  Stream<Map<String, ProductModel>> topProductsPerCategoryStream() {
    return _firebase.productsRef
        .where('isVisible', isEqualTo: true)
        .where('totalRatings', isGreaterThan: 0)
        .orderBy('totalRatings', descending: true)
        .orderBy('avgRating', descending: true)
        .limit(200)
        .snapshots()
        .map((snap) {
      final Map<String, ProductModel> result = {};
      for (final doc in snap.docs) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        data['id'] = doc.id;
        final product = ProductModel.fromJson(data);
        if (!result.containsKey(product.categoryId)) {
          result[product.categoryId] = product;
        }
      }
      return result;
    });
  }

  /// Stats for a quick overview.
  Future<Map<String, int>> fetchStats() async {
    final products =
        await _firebase.productsRef.where('isVisible', isEqualTo: true).get();
    final ratings = await _firebase.ratingsRef.get();
    final users = await _firebase.usersRef.get();
    return {
      'products': products.size,
      'ratings': ratings.size,
      'users': users.size,
    };
  }
}
