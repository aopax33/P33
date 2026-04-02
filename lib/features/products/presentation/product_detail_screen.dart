import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../auth/data/auth_providers.dart';
import '../../ratings/data/rating_providers.dart';
import '../data/product_providers.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productStreamProvider(productId));
    final userAsync = ref.watch(currentUserModelProvider);
    final ratingsAsync = ref.watch(productRatingsProvider(productId));

    return productAsync.when(
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const AppErrorWidget(message: 'Product not found'),
          );
        }

        final user = userAsync.valueOrNull;
        final isLiked = user?.likedProducts.contains(productId) ?? false;
        final isDisliked = user?.dislikedProducts.contains(productId) ?? false;

        final category = AppConstants.predefinedCategories
            .where((c) => c['id'] == product.categoryId)
            .firstOrNull;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App bar with hero image
              SliverAppBar(
                expandedHeight: product.photoUrl != null ? 280 : 160,
                pinned: true,
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    product.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: product.photoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: product.photoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                              color: AppTheme.primaryDark),
                          errorWidget: (_, __, ___) =>
                              Container(color: AppTheme.primaryDark),
                        )
                      : Container(
                          color: AppTheme.primaryDark,
                          child: const Icon(Icons.shopping_basket_outlined,
                              size: 80, color: Colors.white54),
                        ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating summary
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.avgRating.toStringAsFixed(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                  ),
                                  RatingStars(
                                      rating: product.avgRating, size: 20),
                                  Text(
                                    '${product.totalRatings} ratings',
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  children: [
                                    _RatingBar(
                                        label: '5',
                                        count: ratingsAsync.valueOrNull
                                                ?.where((r) => r.score == 5)
                                                .length ??
                                            0,
                                        total: product.totalRatings),
                                    _RatingBar(
                                        label: '4',
                                        count: ratingsAsync.valueOrNull
                                                ?.where((r) => r.score == 4)
                                                .length ??
                                            0,
                                        total: product.totalRatings),
                                    _RatingBar(
                                        label: '3',
                                        count: ratingsAsync.valueOrNull
                                                ?.where((r) => r.score == 3)
                                                .length ??
                                            0,
                                        total: product.totalRatings),
                                    _RatingBar(
                                        label: '2',
                                        count: ratingsAsync.valueOrNull
                                                ?.where((r) => r.score == 2)
                                                .length ??
                                            0,
                                        total: product.totalRatings),
                                    _RatingBar(
                                        label: '1',
                                        count: ratingsAsync.valueOrNull
                                                ?.where((r) => r.score == 1)
                                                .length ??
                                            0,
                                        total: product.totalRatings),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Like / Dislike / Rate buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  context.push('/products/$productId/rate'),
                              icon: const Icon(Icons.star_outline),
                              label: const Text('Rate Product'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _LikeButton(
                            isLiked: isLiked,
                            count: product.totalLikes,
                            onTap: () {
                              if (user == null) return;
                              if (isLiked) {
                                ref
                                    .read(authRepositoryProvider)
                                    .removeLikeDislike(user.id, productId);
                              } else {
                                ref
                                    .read(authRepositoryProvider)
                                    .likeProduct(user.id, productId);
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          _DislikeButton(
                            isDisliked: isDisliked,
                            count: product.totalDislikes,
                            onTap: () {
                              if (user == null) return;
                              if (isDisliked) {
                                ref
                                    .read(authRepositoryProvider)
                                    .removeLikeDislike(user.id, productId);
                              } else {
                                ref
                                    .read(authRepositoryProvider)
                                    .dislikeProduct(user.id, productId);
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Product info
                      Text('Product Information',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _InfoRow(
                          label: 'Brand', value: product.company,
                          icon: Icons.business_outlined),
                      _InfoRow(
                          label: 'Store', value: product.store,
                          icon: Icons.store_outlined),
                      if (category != null)
                        _InfoRow(
                            label: 'Category',
                            value: '${category['icon']} ${category['name']}',
                            icon: Icons.category_outlined),

                      const SizedBox(height: 24),

                      // Reviews section
                      Text('Reviews',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      ratingsAsync.when(
                        data: (ratings) {
                          if (ratings.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('No reviews yet. Be the first!',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary)),
                            );
                          }
                          return Column(
                            children: ratings
                                .take(5)
                                .map((r) => _ReviewTile(rating: r))
                                .toList(),
                          );
                        },
                        loading: () =>
                            const LoadingWidget(message: 'Loading reviews...'),
                        error: (e, _) =>
                            AppErrorWidget(message: e.toString()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const LoadingWidget(message: 'Loading product...'),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(message: e.toString()),
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;

  const _RatingBar(
      {required this.label, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(width: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor: AppTheme.starEmptyColor,
                valueColor:
                    const AlwaysStoppedAnimation(AppTheme.starColor),
              ),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 24,
            child: Text(count.toString(),
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(color: AppTheme.textSecondary)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  final bool isLiked;
  final int count;
  final VoidCallback onTap;

  const _LikeButton(
      {required this.isLiked,
      required this.count,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
              color: isLiked ? Colors.green : AppTheme.textHint),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                size: 18,
                color: isLiked ? Colors.green : AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text('$count'),
          ],
        ),
      ),
    );
  }
}

class _DislikeButton extends StatelessWidget {
  final bool isDisliked;
  final int count;
  final VoidCallback onTap;

  const _DislikeButton(
      {required this.isDisliked,
      required this.count,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
              color: isDisliked ? Colors.red : AppTheme.textHint),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
                isDisliked
                    ? Icons.thumb_down
                    : Icons.thumb_down_outlined,
                size: 18,
                color:
                    isDisliked ? Colors.red : AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text('$count'),
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final dynamic rating;

  const _ReviewTile({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RatingStars(rating: rating.score.toDouble(), size: 16),
                const Spacer(),
                if (rating.liked != null)
                  Icon(
                    rating.liked! ? Icons.thumb_up : Icons.thumb_down,
                    size: 16,
                    color: rating.liked!
                        ? Colors.green
                        : Colors.red,
                  ),
              ],
            ),
            if (rating.photoUrl != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: rating.photoUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
