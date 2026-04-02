import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/data/auth_providers.dart';
import '../data/dashboard_repository.dart';
import '../../products/domain/product_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(firebase: ref.watch(firebaseServiceProvider));
});

final topProductsPerCategoryProvider =
    StreamProvider<Map<String, ProductModel>>((ref) {
  return ref.watch(dashboardRepositoryProvider).topProductsPerCategoryStream();
});

final dashboardStatsProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.watch(dashboardRepositoryProvider).fetchStats();
});
