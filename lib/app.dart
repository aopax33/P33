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

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppConstants.routeSplash,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isSplash = state.matchedLocation == AppConstants.routeSplash;
      final isOnboarding = state.matchedLocation == AppConstants.routeOnboarding;
      final isAuth = state.matchedLocation == AppConstants.routeLogin ||
          state.matchedLocation == AppConstants.routeRegister;

      // Let splash always render first
      if (isSplash || isOnboarding) return null;

      // If loading auth state, stay
      if (authState.isLoading) return null;

      // If not logged in and not on auth screen, redirect to login
      if (!isLoggedIn && !isAuth) return AppConstants.routeLogin;

      // If logged in and on auth screen, redirect to dashboard
      if (isLoggedIn && isAuth) return AppConstants.routeDashboard;

      return null;
    },
    routes: [
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
      GoRoute(
        path: AppConstants.routeDashboard,
        name: AppConstants.dashboardRoute,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppConstants.routeProducts,
        name: AppConstants.productsRoute,
        builder: (context, state) => const ProductListScreen(),
        routes: [
          GoRoute(
            path: ':productId',
            name: AppConstants.productDetailRoute,
            builder: (context, state) {
              final productId = state.pathParameters['productId']!;
              return ProductDetailScreen(productId: productId);
            },
            routes: [
              GoRoute(
                path: 'rate',
                name: AppConstants.rateProductRoute,
                builder: (context, state) {
                  final productId = state.pathParameters['productId']!;
                  return RateProductScreen(productId: productId);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppConstants.routeAddProduct,
        name: AppConstants.addProductRoute,
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: AppConstants.routeProfile,
        name: AppConstants.profileRoute,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppConstants.routeSuggestCategory,
        name: AppConstants.suggestCategoryRoute,
        builder: (context, state) => const SuggestCategoryScreen(),
      ),
    ],
  );
});

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
