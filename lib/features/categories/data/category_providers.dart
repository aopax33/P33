import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/data/auth_providers.dart';
import '../data/category_repository.dart';
import '../domain/category_model.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(firebase: ref.watch(firebaseServiceProvider));
});

final approvedCategoriesProvider =
    StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(categoryRepositoryProvider).approvedCategoriesStream();
});

// ── Suggest category notifier ──────────────────────────────────────────────

class SuggestCategoryState {
  final bool isLoading;
  final String? error;
  final bool success;

  const SuggestCategoryState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });
}

class SuggestCategoryNotifier
    extends StateNotifier<SuggestCategoryState> {
  final CategoryRepository _repo;
  final String _userId;

  SuggestCategoryNotifier(this._repo, this._userId)
      : super(const SuggestCategoryState());

  Future<void> suggest({required String name, required String icon}) async {
    if (_userId.isEmpty) {
      state = const SuggestCategoryState(
          error: 'You must be signed in to suggest a category.');
      return;
    }
    state = const SuggestCategoryState(isLoading: true);
    try {
      await _repo.suggestCategory(
          name: name, icon: icon, suggestedBy: _userId);
      state = const SuggestCategoryState(success: true);
    } catch (e) {
      state = SuggestCategoryState(error: e.toString());
    }
  }

  void reset() => state = const SuggestCategoryState();
}

final suggestCategoryNotifierProvider = StateNotifierProvider.autoDispose<
    SuggestCategoryNotifier, SuggestCategoryState>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return SuggestCategoryNotifier(
      ref.watch(categoryRepositoryProvider), user?.uid ?? '');
});
