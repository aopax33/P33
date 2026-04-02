import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/product_card.dart';
import '../../../features/auth/data/auth_providers.dart';
import '../../../features/products/domain/product_model.dart';
import '../data/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProfileProvider);
    final auth = ref.watch(authStateProvider).valueOrNull;

    if (auth == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sign in to view your profile'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppConstants.routeLogin),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) context.go(AppConstants.routeLogin);
              },
              tooltip: 'Sign Out',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Liked'),
              Tab(text: 'Disliked'),
              Tab(text: 'Submitted'),
            ],
          ),
        ),
        body: Column(
          children: [
            // User info header
            user.when(
              loading: () => const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) => const SizedBox.shrink(),
              data: (u) => u == null
                  ? const SizedBox.shrink()
                  : _ProfileHeader(
                      displayName: u.displayName,
                      email: u.email,
                      avatarUrl: u.avatarUrl,
                    ),
            ),
            // Tabs
            Expanded(
              child: TabBarView(
                children: [
                  _LikedTab(),
                  _DislikedTab(),
                  _SubmittedTab(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go(AppConstants.routeAddProduct),
          icon: const Icon(Icons.add),
          label: const Text('Add Product'),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? avatarUrl;

  const _ProfileHeader({
    required this.displayName,
    required this.email,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
            backgroundImage: avatarUrl != null
                ? CachedNetworkImageProvider(avatarUrl!)
                : null,
            child: avatarUrl == null
                ? Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 24,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(email,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LikedTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liked = ref.watch(likedProductsProvider);
    return liked.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (products) => _ProductGrid(
        products: products,
        emptyMessage: 'No liked products yet.\nTap 👍 on any product!',
      ),
    );
  }
}

class _DislikedTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disliked = ref.watch(dislikedProductsProvider);
    return disliked.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (products) => _ProductGrid(
        products: products,
        emptyMessage: 'No disliked products.',
      ),
    );
  }
}

class _SubmittedTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitted = ref.watch(submittedProductsProvider);
    return submitted.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (products) => _ProductGrid(
        products: products,
        emptyMessage:
            'You haven\'t submitted any products yet.\nTap + to add one!',
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  final String emptyMessage;

  const _ProductGrid(
      {required this.products, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(emptyMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey.shade500)),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) => ProductCard(product: products[i]),
    );
  }
}
