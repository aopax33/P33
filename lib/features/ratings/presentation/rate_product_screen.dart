import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../features/auth/data/auth_providers.dart';
import '../../../features/products/data/product_providers.dart';
import '../data/rating_providers.dart';
import '../data/rating_repository.dart';

class RateProductScreen extends ConsumerStatefulWidget {
  final String productId;
  const RateProductScreen({super.key, required this.productId});

  @override
  ConsumerState<RateProductScreen> createState() => _RateProductScreenState();
}

class _RateProductScreenState extends ConsumerState<RateProductScreen> {
  double _score = 3;
  bool? _liked;
  File? _photoFile;
  bool _submitting = false;
  bool _prefilled = false;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _photoFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to rate products.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(ratingRepositoryProvider).submitRating(
            userId: user.uid,
            productId: widget.productId,
            score: _score.round(),
            liked: _liked,
            photoFile: _photoFile,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rating submitted!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productStreamProvider(widget.productId));
    final existingRating = ref.watch(userProductRatingProvider(widget.productId));

    // Pre-fill state from existing rating once
    existingRating.whenData((r) {
      if (r != null && !_prefilled) {
        _prefilled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {
            _score = r.score.toDouble();
            _liked = r.liked;
          });
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(productAsync.valueOrNull?.name ?? 'Rate Product'),
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${product.company} · ${product.store}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Star rating ──────────────────────────────────────────
                Text(
                  'Your Rating',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Center(
                  child: RatingBar.builder(
                    initialRating: _score,
                    minRating: 1,
                    maxRating: 5,
                    allowHalfRating: false,
                    itemSize: 48,
                    itemBuilder: (context, _) =>
                        const Icon(Icons.star, color: AppTheme.starColor),
                    onRatingUpdate: (val) => setState(() => _score = val),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _scoreLabel(_score.round()),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Like / Dislike ───────────────────────────────────────
                Text(
                  'Like or Dislike?',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Optional — independent from your star rating',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LikeChip(
                      label: '👍 Like',
                      selected: _liked == true,
                      onTap: () => setState(
                          () => _liked = _liked == true ? null : true),
                    ),
                    const SizedBox(width: 16),
                    _LikeChip(
                      label: '👎 Dislike',
                      selected: _liked == false,
                      color: Colors.red.shade400,
                      onTap: () => setState(
                          () => _liked = _liked == false ? null : false),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Photo upload ─────────────────────────────────────────
                Text(
                  'Add a Photo (Optional)',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _submitting ? null : _pickPhoto,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _photoFile != null
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
                        width: _photoFile != null ? 2 : 1,
                      ),
                    ),
                    child: _photoFile != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.file(
                                  _photoFile!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _photoFile = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  size: 40,
                                  color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to add a photo from your gallery',
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 40),

                // ── Submit ───────────────────────────────────────────────
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          existingRating.valueOrNull != null
                              ? 'Update Rating'
                              : 'Submit Rating',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
                if (existingRating.valueOrNull != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () async {
                            setState(() => _submitting = true);
                            try {
                              await ref
                                  .read(ratingRepositoryProvider)
                                  .deleteRating(existingRating.value!.id);
                              if (mounted) context.pop();
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())));
                                setState(() => _submitting = false);
                              }
                            }
                          },
                    child: const Text(
                      'Remove My Rating',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _scoreLabel(int score) {
    switch (score) {
      case 1:
        return 'Terrible';
      case 2:
        return 'Bad';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }
}

class _LikeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _LikeChip({
    required this.label,
    required this.selected,
    this.color = AppTheme.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          border: Border.all(
              color: selected ? color : Colors.grey.shade400),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade700,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
