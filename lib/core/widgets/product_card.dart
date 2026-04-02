import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import '../../features/products/domain/product_model.dart';
import 'rating_stars.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final String? categoryName;
  final String? categoryIcon;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.categoryName,
    this.categoryIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ??
            () => context.push(
                  '/products/${product.id}',
                ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.photoUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 80,
                          height: 80,
                          color: AppTheme.backgroundColor,
                          child: const Icon(Icons.image_outlined,
                              color: AppTheme.textHint),
                        ),
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 12),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.company,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.store_outlined,
                            size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          product.store,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        RatingStars(
                          rating: product.avgRating,
                          size: 16,
                          showLabel: true,
                          totalRatings: product.totalRatings,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Category badge
              if (categoryIcon != null) ...[
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(categoryIcon!,
                        style: const TextStyle(fontSize: 24)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.shopping_basket_outlined,
          color: AppTheme.textHint, size: 32),
    );
  }
}

class ProductCardCompact extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ProductCardCompact({
    super.key,
    required this.product,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap ??
          () => context.push('/products/${product.id}'),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: product.photoUrl != null
            ? CachedNetworkImage(
                imageUrl: product.photoUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _smallPlaceholder(),
              )
            : _smallPlaceholder(),
      ),
      title: Text(product.name,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Row(
        children: [
          RatingStars(rating: product.avgRating, size: 14, showLabel: true),
          const SizedBox(width: 8),
          Text(product.store,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
      trailing: trailing,
    );
  }

  Widget _smallPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      color: AppTheme.backgroundColor,
      child: const Icon(Icons.shopping_basket_outlined,
          color: AppTheme.textHint, size: 24),
    );
  }
}
