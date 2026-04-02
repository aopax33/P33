import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/data/auth_providers.dart';
import '../data/category_providers.dart';

const _emojiOptions = [
  '🥛', '🍞', '🥦', '🥩', '🧊', '🍿', '🥤', '🥣', '🥫', '🧂',
  '🍝', '🍫', '☕', '🍷', '💊', '🍼', '🧴', '🧹', '🐾', '🌿',
  '🌍', '📦', '🍎', '🧀', '🥚', '🥕', '🫙', '🧆', '🥜', '🍯',
];

class SuggestCategoryScreen extends ConsumerStatefulWidget {
  const SuggestCategoryScreen({super.key});

  @override
  ConsumerState<SuggestCategoryScreen> createState() =>
      _SuggestCategoryScreenState();
}

class _SuggestCategoryScreenState
    extends ConsumerState<SuggestCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _selectedEmoji = '📦';

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(suggestCategoryNotifierProvider.notifier).suggest(
          name: _nameCtrl.text.trim(),
          icon: _selectedEmoji,
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final state = ref.watch(suggestCategoryNotifierProvider);

    if (auth == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Suggest Category')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sign in to suggest categories'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.success) {
      return Scaffold(
        appBar: AppBar(title: const Text('Suggest Category')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text('Suggestion Submitted!',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text(
                'Your suggestion is pending admin review.\nWe\'ll add it if approved!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(suggestCategoryNotifierProvider.notifier).reset();
                  context.pop();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Suggest a Category')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Missing a category? Suggest one!',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Admin will review and approve your suggestion.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g. Gluten-Free Foods',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter a name';
                  if (v.trim().length < 3) return 'Name too short';
                  if (v.trim().length > 40) return 'Name too long';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text('Choose an Icon',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              // Selected
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(_selectedEmoji,
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Text(
                      'Selected icon',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Emoji grid
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _emojiOptions
                    .map(
                      (e) => GestureDetector(
                        onTap: () =>
                            setState(() => _selectedEmoji = e),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _selectedEmoji == e
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.15)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedEmoji == e
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(e,
                                style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 32),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(state.error!,
                      style: const TextStyle(color: Colors.red)),
                ),
              ElevatedButton(
                onPressed: state.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit Suggestion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
