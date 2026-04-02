import '../../../services/firebase_service.dart';
import '../../products/domain/product_model.dart';
import '../../auth/domain/user_model.dart';

class ProfileRepository {
  final FirebaseService _firebase;

  ProfileRepository({required FirebaseService firebase})
      : _firebase = firebase;

  Stream<UserModel?> userStream(String uid) {
    return _firebase.usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = Map<String, dynamic>.from(doc.data() as Map);
      data['id'] = doc.id;
      return UserModel.fromJson(data);
    });
  }

  Stream<List<ProductModel>> submittedProductsStream(String userId) {
    return _firebase.productsRef
        .where('submittedBy', isEqualTo: userId)
        .where('isVisible', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = Map<String, dynamic>.from(doc.data() as Map);
              data['id'] = doc.id;
              return ProductModel.fromJson(data);
            }).toList());
  }

  Future<List<ProductModel>> fetchProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += 10) {
      chunks.add(ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10));
    }
    final List<ProductModel> results = [];
    for (final chunk in chunks) {
      final snap = await _firebase.productsRef
          .where('__name__', whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        data['id'] = doc.id;
        results.add(ProductModel.fromJson(data));
      }
    }
    return results;
  }
}
