import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class _OnboardingPage {
  final String emoji;
  final String title;
  final String description;
  final Color color;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}

const _pages = [
  _OnboardingPage(
    emoji: '🛒',
    title: 'Discover Great Products',
    description:
        'Browse thousands of supermarket products rated by real shoppers just like you.',
    color: AppTheme.primaryColor,
  ),
  _OnboardingPage(
    emoji: '⭐',
    title: 'Rate & Review',
    description:
        'Share your opinion. Rate products 1–5 stars, like or dislike, and add photos.',
    color: Color(0xFF1565C0),
  ),
  _OnboardingPage(
    emoji: '🏆',
    title: 'Find the Best',
    description:
        'See the top-rated products in every category on our live public dashboard.',
    color: Color(0xFF6A1B9A),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppConstants.routeLogin);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (context, index) =>
                _PageContent(page: _pages[index]),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomNav(
              currentPage: _currentPage,
              totalPages: _pages.length,
              onNext: _next,
              onSkip: () => context.go(AppConstants.routeLogin),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            page.color,
            page.color.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(page.emoji, style: const TextStyle(fontSize: 100)),
              const SizedBox(height: 40),
              Text(
                page.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                page.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 17,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _BottomNav({
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == totalPages - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == currentPage ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == currentPage
                      ? AppTheme.primaryColor
                      : AppTheme.starEmptyColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onNext,
            child: Text(isLast ? 'Get Started' : 'Next'),
          ),
          if (!isLast)
            TextButton(
              onPressed: onSkip,
              child: const Text('Skip'),
            ),
        ],
      ),
    );
  }
}
