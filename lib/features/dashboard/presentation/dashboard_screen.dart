import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../features/auth/data/auth_providers.dart';
import '../../../features/categories/data/category_providers.dart';
import '../../../features/categories/domain/category_model.dart';
import '../../../features/products/domain/product_model.dart';
import '../data/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topProducts = ref.watch(topProductsPerCategoryProvider);
    final categories = ref.watch(approvedCategoriesProvider);
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.valueOrNull != null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.local_grocery_store, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text('ShelfRate'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go(AppConstants.routeProducts),
            tooltip: 'Browse Products',
          ),
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.go(AppConstants.routeProfile),
              tooltip: 'My Profile',
            )
          else
            TextButton(
              onPressed: () => context.go(AppConstants.routeLogin),
              child: const Text('Sign In'),
            ),
        ],
      ),
      floatingActionButton: isLoggedIn
          ? FloatingActionButton.extended(
              onPressed: () => context.go(AppConstants.routeAddProduct),
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(topProductsPerCategoryProvider),
        child: topProducts.when(
          loading: () => const LoadingWidget(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (productMap) {
            if (productMap.isEmpty) {
              return const _EmptyDashboard();
            }
            return categories.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (cats) =>
                  _DashboardContent(productMap: productMap, categories: cats),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('No products yet',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Be the first to add and rate a product!',
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final Map<String, ProductModel> productMap;
  final List<CategoryModel> categories;

  const _DashboardContent(
      {required this.productMap, required this.categories});

  @override
  Widget build(BuildContext context) {
    // Sort categories: show only those that have a top product
    final activeCats = categories
        .where((c) => productMap.containsKey(c.id))
        .toList();
    // Append predefined categories not in approved list but in productMap
    final allCategoryIds = categories.map((c) => c.id).toSet();
    final extraIds =
        productMap.keys.where((id) => !allCategoryIds.contains(id));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🏆 Top Rated Products',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Best product in each category',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              if (i < activeCats.length) {
                final cat = activeCats[i];
                final product = productMap[cat.id]!;
                return _CategoryTopCard(
                    category: cat, product: product);
              }
              final extraId = extraIds.elementAt(i - activeCats.length);
              final product = productMap[extraId]!;
              final cat = CategoryModel(
                id: extraId,
                name: AppConstants.predefinedCategories
                    .firstWhere((c) => c['id'] == extraId,
                        orElse: () => {'name': extraId, 'icon': '📦'})['name']!,
                icon: AppConstants.predefinedCategories
                    .firstWhere((c) => c['id'] == extraId,
                        orElse: () => {'name': extraId, 'icon': '📦'})['icon']!,
                createdAt: DateTime.now(),
              );
              return _CategoryTopCard(category: cat, product: product);
            },
            childCount: activeCats.length + extraIds.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _CategoryTopCard extends StatelessWidget {
  final CategoryModel category;
  final ProductModel product;

  const _CategoryTopCard(
      {required this.category, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/products/${product.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(category.icon,
                      style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.company} · ${product.store}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingStars(
                            rating: product.avgRating, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${product.avgRating.toStringAsFixed(1)} (${product.totalRatings})',
                          style:
                              Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Photo
              if (product.photoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: product.photoUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey.shade200,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
