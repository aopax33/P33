import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/data/auth_providers.dart';
import '../data/profile_repository.dart';
import '../../products/domain/product_model.dart';
import '../../auth/domain/user_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(firebase: ref.watch(firebaseServiceProvider));
});

final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).userStream(user.uid);
});

final submittedProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref
      .watch(profileRepositoryProvider)
      .submittedProductsStream(user.uid);
});

final likedProductsProvider =
    FutureProvider<List<ProductModel>>((ref) async {
  final userAsync = ref.watch(currentUserProfileProvider);
  final user = userAsync.valueOrNull;
  if (user == null || user.likedProducts.isEmpty) return [];
  return ref
      .watch(profileRepositoryProvider)
      .fetchProductsByIds(user.likedProducts);
});

final dislikedProductsProvider =
    FutureProvider<List<ProductModel>>((ref) async {
  final userAsync = ref.watch(currentUserProfileProvider);
  final user = userAsync.valueOrNull;
  if (user == null || user.dislikedProducts.isEmpty) return [];
  return ref
      .watch(profileRepositoryProvider)
      .fetchProductsByIds(user.dislikedProducts);
});
