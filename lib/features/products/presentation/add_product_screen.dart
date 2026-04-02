import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../categories/data/category_providers.dart';
import '../data/product_providers.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _storeController = TextEditingController();
  String? _selectedCategoryId;
  File? _photoFile;

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _storeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _photoFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    await ref.read(addProductNotifierProvider.notifier).addProduct(
          name: _nameController.text,
          company: _companyController.text,
          store: _storeController.text,
          categoryId: _selectedCategoryId!,
          photoFile: _photoFile,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addProductNotifierProvider);
    final categoriesAsync = ref.watch(approvedCategoriesProvider);

    // Handle success
    ref.listen(addProductNotifierProvider, (prev, next) {
      if (next.successId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        context.go('/products/${next.successId}');
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: LoadingOverlay(
        isLoading: state.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.textHint),
                    ),
                    child: _photoFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_photoFile!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  size: 48, color: AppTheme.textHint),
                              const SizedBox(height: 8),
                              Text('Tap to add a photo',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary)),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter the product name';
                    }
                    if (v.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _companyController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Brand / Company *',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter the brand name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _storeController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Store / Supermarket *',
                    prefixIcon: Icon(Icons.store_outlined),
                    hintText: 'e.g. Walmart, Whole Foods, Costco',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter the store name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Category dropdown
                categoriesAsync.when(
                  data: (categories) => DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text('${c.icon} ${c.name}'),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCategoryId = v),
                    validator: (v) =>
                        v == null ? 'Please select a category' : null,
                  ),
                  loading: () =>
                      const LinearProgressIndicator(),
                  error: (_, __) =>
                      const Text('Could not load categories'),
                ),

                const SizedBox(height: 12),

                // Suggest category link
                TextButton.icon(
                  onPressed: () => context.push(
                      AppConstants.routeSuggestCategory),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Don't see your category? Suggest one"),
                ),

                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: state.isLoading ? null : _submit,
                  icon: const Icon(Icons.check),
                  label: const Text('Submit Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
