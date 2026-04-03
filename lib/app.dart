import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/data/auth_providers.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/onboarding_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/products/presentation/product_list_screen.dart';
import 'features/products/presentation/product_detail_screen.dart';
import 'features/products/presentation/add_product_screen.dart';
import 'features/ratings/presentation/rate_product_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/categories/presentation/suggest_category_screen.dart';

// ── Navigator keys ──────────────────────────────────────────────────────────

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ── Router ───────────────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppConstants.routeSplash,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final loc = state.matchedLocation;

      final isPublic = loc == AppConstants.routeSplash ||
          loc == AppConstants.routeOnboarding ||
          loc == AppConstants.routeLogin ||
          loc == AppConstants.routeRegister;

      if (isPublic) return null;
      if (authState.isLoading) return null;

      // Guests may browse dashboard and products (read-only)
      final isGuestAllowed = loc == AppConstants.routeDashboard ||
          loc.startsWith(AppConstants.routeProducts);

      if (!isLoggedIn && !isGuestAllowed) return AppConstants.routeLogin;
      if (isLoggedIn &&
          (loc == AppConstants.routeLogin ||
              loc == AppConstants.routeRegister)) {
        return AppConstants.routeDashboard;
      }
      return null;
    },
    routes: [
      // ── Standalone screens (no bottom nav) ──────────────────────────────
      GoRoute(
        path: AppConstants.routeSplash,
        name: AppConstants.splashRoute,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.routeOnboarding,
        name: AppConstants.onboardingRoute,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        name: AppConstants.loginRoute,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeRegister,
        name: AppConstants.registerRoute,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Main shell with bottom nav ───────────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) =>
            MainShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: AppConstants.routeDashboard,
            name: AppConstants.dashboardRoute,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppConstants.routeProducts,
            name: AppConstants.productsRoute,
            builder: (context, state) => const ProductListScreen(),
          ),
          GoRoute(
            path: AppConstants.routeProfile,
            name: AppConstants.profileRoute,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Full-screen routes (push over shell) ────────────────────────────
      GoRoute(
        path: '/products/:productId',
        name: AppConstants.productDetailRoute,
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/products/:productId/rate',
        name: AppConstants.rateProductRoute,
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return RateProductScreen(productId: productId);
        },
      ),
      GoRoute(
        path: AppConstants.routeAddProduct,
        name: AppConstants.addProductRoute,
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: AppConstants.routeSuggestCategory,
        name: AppConstants.suggestCategoryRoute,
        builder: (context, state) => const SuggestCategoryScreen(),
      ),
    ],
  );
});

// ── Main shell widget ─────────────────────────────────────────────────────────

class MainShell extends StatelessWidget {
  final String location;
  final Widget child;

  const MainShell({super.key, required this.location, required this.child});

  int _selectedIndex(String loc) {
    if (loc.startsWith(AppConstants.routeProducts)) return 1;
    if (loc.startsWith(AppConstants.routeProfile)) return 2;
    return 0; // dashboard
  }

  @override
  Widget build(BuildContext context) {
    final idx = _selectedIndex(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go(AppConstants.routeDashboard);
              break;
            case 1:
              context.go(AppConstants.routeProducts);
              break;
            case 2:
              context.go(AppConstants.routeProfile);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Top Rated',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Browse',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ── App ───────────────────────────────────────────────────────────────────────

class ShelfRateApp extends ConsumerWidget {
  const ShelfRateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ShelfRate',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
