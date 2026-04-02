class AppConstants {
  AppConstants._();

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ratingsCollection = 'ratings';
  static const String categoriesCollection = 'categories';

  // Storage paths
  static const String productPhotosPath = 'product_photos';
  static const String ratingPhotosPath = 'rating_photos';
  static const String avatarsPath = 'avatars';

  // Pagination
  static const int pageSize = 20;

  // Rating
  static const int minRating = 1;
  static const int maxRating = 5;

  // Route names
  static const String routeSplash = '/splash';
  static const String routeOnboarding = '/onboarding';
  static const String routeDashboard = '/dashboard';
  static const String routeProducts = '/products';
  static const String routeProductDetail = '/products/:productId';
  static const String routeRateProduct = '/products/:productId/rate';
  static const String routeAddProduct = '/add-product';
  static const String routeProfile = '/profile';
  static const String routeSuggestCategory = '/suggest-category';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';

  // Named route keys (used with GoRouter)
  static const String splashRoute = 'splash';
  static const String onboardingRoute = 'onboarding';
  static const String dashboardRoute = 'dashboard';
  static const String productsRoute = 'products';
  static const String productDetailRoute = 'product-detail';
  static const String rateProductRoute = 'rate-product';
  static const String addProductRoute = 'add-product';
  static const String profileRoute = 'profile';
  static const String suggestCategoryRoute = 'suggest-category';
  static const String loginRoute = 'login';
  static const String registerRoute = 'register';

  // Predefined categories
  static const List<Map<String, String>> predefinedCategories = [
    {'id': 'dairy', 'name': 'Dairy & Eggs', 'icon': '🥛'},
    {'id': 'bakery', 'name': 'Bakery & Bread', 'icon': '🍞'},
    {'id': 'produce', 'name': 'Fruits & Vegetables', 'icon': '🥦'},
    {'id': 'meat', 'name': 'Meat & Seafood', 'icon': '🥩'},
    {'id': 'frozen', 'name': 'Frozen Foods', 'icon': '🧊'},
    {'id': 'snacks', 'name': 'Snacks & Chips', 'icon': '🍿'},
    {'id': 'beverages', 'name': 'Beverages', 'icon': '🥤'},
    {'id': 'cereal', 'name': 'Cereal & Breakfast', 'icon': '🥣'},
    {'id': 'canned', 'name': 'Canned & Jarred Goods', 'icon': '🥫'},
    {'id': 'condiments', 'name': 'Condiments & Sauces', 'icon': '🧴'},
    {'id': 'pasta', 'name': 'Pasta, Rice & Grains', 'icon': '🍝'},
    {'id': 'baking', 'name': 'Baking & Spices', 'icon': '🧂'},
    {'id': 'deli', 'name': 'Deli & Prepared Foods', 'icon': '🥗'},
    {'id': 'health', 'name': 'Health & Vitamins', 'icon': '💊'},
    {'id': 'baby', 'name': 'Baby & Toddler', 'icon': '🍼'},
    {'id': 'personal', 'name': 'Personal Care', 'icon': '🧴'},
    {'id': 'household', 'name': 'Household & Cleaning', 'icon': '🧹'},
    {'id': 'pet', 'name': 'Pet Food & Supplies', 'icon': '🐾'},
    {'id': 'international', 'name': 'International Foods', 'icon': '🌍'},
    {'id': 'organic', 'name': 'Organic & Natural', 'icon': '🌿'},
    {'id': 'chocolate', 'name': 'Chocolate & Candy', 'icon': '🍫'},
    {'id': 'coffee', 'name': 'Coffee & Tea', 'icon': '☕'},
    {'id': 'wine', 'name': 'Wine & Beer', 'icon': '🍷'},
    {'id': 'other', 'name': 'Other', 'icon': '📦'},
  ];

  // Auth providers
  static const String authProviderEmail = 'email';
  static const String authProviderGoogle = 'google';
  static const String authProviderApple = 'apple';

  // Category statuses
  static const String categoryStatusApproved = 'approved';
  static const String categoryStatusPending = 'pending';
  static const String categoryStatusRejected = 'rejected';
}
