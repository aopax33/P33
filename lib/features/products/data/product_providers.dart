import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/data/auth_providers.dart';
import '../../../services/storage_service.dart';
import '../data/product_repository.dart';
import '../domain/product_model.dart';

// ── Repository provider ────────────────────────────────────────────────────

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(
    firebaseService: ref.watch(firebaseServiceProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

// ── Filter state ───────────────────────────────────────────────────────────

class ProductFilter {
  final String? categoryId;
  final String? store;
  final String? company;
  final String searchQuery;
  final String sortBy;
  final bool descending;

  const ProductFilter({
    this.categoryId,
    this.store,
    this.company,
    this.searchQuery = '',
    this.sortBy = 'avgRating',
    this.descending = true,
  });

  ProductFilter copyWith({
    String? categoryId,
    String? store,
    String? company,
    String? searchQuery,
    String? sortBy,
    bool? descending,
    bool clearCategory = false,
    bool clearStore = false,
    bool clearCompany = false,
  }) {
    return ProductFilter(
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      store: clearStore ? null : (store ?? this.store),
      company: clearCompany ? null : (company ?? this.company),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      descending: descending ?? this.descending,
    );
  }
}

final productFilterProvider =
    StateProvider<ProductFilter>((ref) => const ProductFilter());

// ── Products stream ────────────────────────────────────────────────────────

final productsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  final filter = ref.watch(productFilterProvider);
  final repo = ref.watch(productRepositoryProvider);

  return repo.productsStream(
    categoryId: filter.categoryId,
    store: filter.store,
    company: filter.company,
    searchQuery: filter.searchQuery,
    sortBy: filter.sortBy,
    descending: filter.descending,
  );
});

// ── Single product stream ──────────────────────────────────────────────────

final productStreamProvider =
    StreamProvider.family<ProductModel?, String>((ref, productId) {
  return ref.watch(productRepositoryProvider).productStream(productId);
});

// ── Distinct stores/companies ──────────────────────────────────────────────

final distinctStoresProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(productRepositoryProvider).fetchDistinctStores();
});

final distinctCompaniesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(productRepositoryProvider).fetchDistinctCompanies();
});

// ── Add product notifier ───────────────────────────────────────────────────

class AddProductState {
  final bool isLoading;
  final String? error;
  final String? successId;

  const AddProductState({
    this.isLoading = false,
    this.error,
    this.successId,
  });
}

class AddProductNotifier extends StateNotifier<AddProductState> {
  final ProductRepository _repo;
  final String _userId;

  AddProductNotifier(this._repo, this._userId)
      : super(const AddProductState());

  Future<void> addProduct({
    required String name,
    required String company,
    required String store,
    required String categoryId,
    File? photoFile,
  }) async {
    state = const AddProductState(isLoading: true);
    try {
      final id = await _repo.addProduct(
        name: name,
        company: company,
        store: store,
        categoryId: categoryId,
        submittedBy: _userId,
        photoFile: photoFile,
      );
      state = AddProductState(successId: id);
    } catch (e) {
      state = AddProductState(error: e.toString());
    }
  }

  void reset() => state = const AddProductState();
}

final addProductNotifierProvider =
    StateNotifierProvider.autoDispose<AddProductNotifier, AddProductState>(
        (ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  final userId = user?.uid ?? '';
  return AddProductNotifier(ref.watch(productRepositoryProvider), userId);
});
