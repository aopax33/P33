import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/data/auth_providers.dart';
import '../../../features/products/data/product_providers.dart';
import '../data/rating_repository.dart';
import '../domain/rating_model.dart';

final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  return RatingRepository(
    firebase: ref.watch(firebaseServiceProvider),
    storage: ref.watch(storageServiceProvider),
  );
});

final productRatingsProvider =
    StreamProvider.family<List<RatingModel>, String>((ref, productId) {
  return ref.watch(ratingRepositoryProvider).ratingsForProduct(productId);
});

final userProductRatingProvider =
    StreamProvider.family<RatingModel?, String>((ref, productId) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(null);
  return ref
      .watch(ratingRepositoryProvider)
      .userRatingForProduct(user.uid, productId);
});

// ── Submit rating notifier ─────────────────────────────────────────────────

class SubmitRatingState {
  final bool isLoading;
  final String? error;
  final bool success;

  const SubmitRatingState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });
}

class SubmitRatingNotifier
    extends StateNotifier<SubmitRatingState> {
  final RatingRepository _repo;
  final String _userId;

  SubmitRatingNotifier(this._repo, this._userId)
      : super(const SubmitRatingState());

  Future<void> submit({
    required String productId,
    required int score,
    bool? liked,
    String? localPhotoPath,
  }) async {
    state = const SubmitRatingState(isLoading: true);
    try {
      await _repo.submitRating(
        userId: _userId,
        productId: productId,
        score: score,
        liked: liked,
      );
      state = const SubmitRatingState(success: true);
    } catch (e) {
      state = SubmitRatingState(error: e.toString());
    }
  }

  void reset() => state = const SubmitRatingState();
}

final submitRatingNotifierProvider =
    StateNotifierProvider.autoDispose<SubmitRatingNotifier, SubmitRatingState>(
        (ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return SubmitRatingNotifier(
      ref.watch(ratingRepositoryProvider), user?.uid ?? '');
});
