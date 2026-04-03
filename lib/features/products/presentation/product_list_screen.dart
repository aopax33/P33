import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/product_card.dart';
import '../../categories/data/category_providers.dart';
import '../data/product_providers.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(productFilterProvider);
    final productsAsync = ref.watch(productsStreamProvider);
    final categoriesAsync = ref.watch(approvedCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, filter),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppConstants.routeAddProduct),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products, brands...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(productFilterProvider.notifier).state =
                              filter.copyWith(searchQuery: '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) {
                ref.read(productFilterProvider.notifier).state =
                    filter.copyWith(searchQuery: v);
              },
            ),
          ),

          // Category chips
          categoriesAsync.when(
            data: (cats) => SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                children: [
                  _CategoryChip(
                    label: 'All',
                    isSelected: filter.categoryId == null,
                    onTap: () => ref
                        .read(productFilterProvider.notifier)
                        .state = filter.copyWith(clearCategory: true),
                  ),
                  ...cats.map((c) => _CategoryChip(
                        label: '${c.icon} ${c.name}',
                        isSelected: filter.categoryId == c.id,
                        onTap: () => ref
                            .read(productFilterProvider.notifier)
                            .state = filter.copyWith(categoryId: c.id),
                      )),
                ],
              ),
            ),
            loading: () => const SizedBox(height: 52),
            error: (_, __) => const SizedBox(height: 52),
          ),

          // Sort bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  productsAsync.when(
                    data: (p) => '${p.length} products',
                    loading: () => '',
                    error: (_, __) => '',
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.textSecondary),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: filter.sortBy,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                        value: 'avgRating', child: Text('Highest Rated')),
                    DropdownMenuItem(
                        value: 'totalRatings', child: Text('Most Rated')),
                    DropdownMenuItem(
                        value: 'createdAt', child: Text('Newest')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(productFilterProvider.notifier).state =
                          filter.copyWith(sortBy: v);
                    }
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Product list
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return EmptyStateWidget(
                    title: 'No products found',
                    subtitle: filter.searchQuery.isNotEmpty
                        ? 'Try a different search term'
                        : 'Be the first to add a product!',
                    icon: Icons.shopping_basket_outlined,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final category = AppConstants.predefinedCategories
                        .where((c) => c['id'] == product.categoryId)
                        .firstOrNull;
                    return ProductCard(
                      product: product,
                      categoryIcon: category?['icon'],
                      categoryName: category?['name'],
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(message: 'Loading products...'),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () =>
                    ref.invalidate(productsStreamProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, ProductFilter filter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _FilterSheet(currentFilter: filter),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip(
      {required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  final ProductFilter currentFilter;
  const _FilterSheet({required this.currentFilter});

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late String? _selectedStore;
  late String? _selectedCompany;

  @override
  void initState() {
    super.initState();
    _selectedStore = widget.currentFilter.store;
    _selectedCompany = widget.currentFilter.company;
  }

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(distinctStoresProvider);
    final companiesAsync = ref.watch(distinctCompaniesProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Filter Products',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ref.read(productFilterProvider.notifier).state =
                      const ProductFilter();
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          storesAsync.when(
            data: (stores) => DropdownButtonFormField<String?>(
              value: _selectedStore,
              decoration: const InputDecoration(
                  labelText: 'Store', prefixIcon: Icon(Icons.store_outlined)),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Stores')),
                ...stores.map((s) =>
                    DropdownMenuItem(value: s, child: Text(s))),
              ],
              onChanged: (v) => setState(() => _selectedStore = v),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 12),
          companiesAsync.when(
            data: (companies) => DropdownButtonFormField<String?>(
              value: _selectedCompany,
              decoration: const InputDecoration(
                  labelText: 'Brand',
                  prefixIcon: Icon(Icons.business_outlined)),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('All Brands')),
                ...companies.map((c) =>
                    DropdownMenuItem(value: c, child: Text(c))),
              ],
              onChanged: (v) => setState(() => _selectedCompany = v),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final current = ref.read(productFilterProvider);
              ref.read(productFilterProvider.notifier).state = current.copyWith(
                store: _selectedStore,
                company: _selectedCompany,
                clearStore: _selectedStore == null,
                clearCompany: _selectedCompany == null,
              );
              Navigator.pop(context);
            },
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}
