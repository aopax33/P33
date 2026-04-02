import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../../../services/firebase_service.dart';
import '../../../services/storage_service.dart';
import '../domain/product_model.dart';

class ProductRepository {
  final FirebaseService _firebaseService;
  final StorageService _storageService;

  ProductRepository({
    required FirebaseService firebaseService,
    required StorageService storageService,
  })  : _firebaseService = firebaseService,
        _storageService = storageService;

  // ── Streams ────────────────────────────────────────────────────────────────

  Stream<List<ProductModel>> productsStream({
    String? categoryId,
    String? store,
    String? company,
    String? searchQuery,
    String sortBy = 'avgRating',
    bool descending = true,
    int limit = AppConstants.pageSize,
  }) {
    Query query = _firebaseService.productsRef
        .where('isVisible', isEqualTo: true);

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    if (store != null && store.isNotEmpty) {
      query = query.where('store', isEqualTo: store);
    }
    if (company != null && company.isNotEmpty) {
      query = query.where('company', isEqualTo: company);
    }

    query = query.orderBy(sortBy, descending: descending).limit(limit);

    return query.snapshots().map((snapshot) {
      final products = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return ProductModel.fromJson(data);
          })
          .where((p) {
            if (searchQuery == null || searchQuery.isEmpty) return true;
            final q = searchQuery.toLowerCase();
            return p.name.toLowerCase().contains(q) ||
                p.company.toLowerCase().contains(q) ||
                p.store.toLowerCase().contains(q);
          })
          .toList();
      return products;
    });
  }

  Stream<ProductModel?> productStream(String productId) {
    return _firebaseService.productsRef.doc(productId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return ProductModel.fromJson(data);
    });
  }

  Stream<List<ProductModel>> topRatedPerCategory(
      String categoryId, int limit) {
    return _firebaseService.productsRef
        .where('isVisible', isEqualTo: true)
        .where('categoryId', isEqualTo: categoryId)
        .where('totalRatings', isGreaterThan: 0)
        .orderBy('totalRatings', descending: true)
        .orderBy('avgRating', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return ProductModel.fromJson(data);
            }).toList());
  }

  Stream<List<ProductModel>> productsByIds(List<String> ids) {
    if (ids.isEmpty) return Stream.value([]);
    // Firestore whereIn supports max 30 items
    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += 30) {
      chunks.add(ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30));
    }
    // For simplicity, return only first chunk (expand for production use)
    return _firebaseService.productsRef
        .where(FieldPath.documentId, whereIn: chunks.first)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return ProductModel.fromJson(data);
            }).toList());
  }

  // ── CRUD ───────────────────────────────────────────────────────────────────

  Future<ProductModel> fetchProduct(String productId) async {
    final data = await _firebaseService.getDoc(
        _firebaseService.productsRef, productId);
    if (data == null) throw Exception('Product not found');
    return ProductModel.fromJson(data);
  }

  Future<String> addProduct({
    required String name,
    required String company,
    required String store,
    required String categoryId,
    required String submittedBy,
    File? photoFile,
  }) async {
    final ref = _firebaseService.productsRef.doc();
    final productId = ref.id;

    String? photoUrl;
    if (photoFile != null) {
      photoUrl = await _storageService.uploadProductPhoto(
          file: photoFile, productId: productId);
    }

    final product = ProductModel(
      id: productId,
      name: name.trim(),
      company: company.trim(),
      store: store.trim(),
      categoryId: categoryId,
      photoUrl: photoUrl,
      submittedBy: submittedBy,
      createdAt: DateTime.now(),
    );

    await ref.set(product.toJson());
    return productId;
  }

  Future<void> updateProductVisibility(
      String productId, bool isVisible) async {
    await _firebaseService.updateDoc(
        _firebaseService.productsRef, productId, {'isVisible': isVisible});
  }

  Future<void> updateProductPhoto(
      String productId, String photoUrl) async {
    await _firebaseService.updateDoc(
        _firebaseService.productsRef, productId, {'photoUrl': photoUrl});
  }

  // ── Distinct value helpers ─────────────────────────────────────────────────

  Future<List<String>> fetchDistinctStores() async {
    final snapshot = await _firebaseService.productsRef
        .where('isVisible', isEqualTo: true)
        .get();
    final stores = snapshot.docs
        .map((d) => (d.data() as Map<String, dynamic>)['store'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    stores.sort();
    return stores;
  }

  Future<List<String>> fetchDistinctCompanies() async {
    final snapshot = await _firebaseService.productsRef
        .where('isVisible', isEqualTo: true)
        .get();
    final companies = snapshot.docs
        .map((d) =>
            (d.data() as Map<String, dynamic>)['company'] as String? ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    companies.sort();
    return companies;
  }
}
