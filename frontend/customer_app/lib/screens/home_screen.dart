import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../theme/customer_app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/navbar.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final ApiClient apiClient;

  const HomeScreen({super.key, required this.apiClient});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;
  final Map<String, int> _cart = {};
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadOrders();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await widget.apiClient.get('/products?is_active=true');
      final products = (response as List<dynamic>)
          .map((entry) => Product.fromJson(entry as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOrders() async {
    if (!widget.apiClient.isAuthenticated) return;

    try {
      final response = await widget.apiClient.get('/orders');
      final orders = (response as List<dynamic>)
          .map((entry) => Order.fromJson(entry as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _orders = orders;
      });
    } catch (_) {}
  }

  Future<bool> _promptLoginIfNeeded() async {
    if (widget.apiClient.isAuthenticated) {
      return true;
    }

    final loggedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          apiClient: widget.apiClient,
          returnToPrevious: true,
        ),
      ),
    );

    if (!mounted) return false;

    if (loggedIn == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in successfully')),
      );
      return true;
    }

    return widget.apiClient.isAuthenticated;
  }

  Future<void> _openOrders() async {
    final canContinue = await _promptLoginIfNeeded();
    if (!mounted || !canContinue) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrdersScreen(apiClient: widget.apiClient),
      ),
    );

    // Refresh orders when returning to home screen
    if (mounted) _loadOrders();
  }

  Future<void> _openCart() async {
    final canContinue = await _promptLoginIfNeeded();
    if (!mounted || !canContinue) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CartScreen(
          apiClient: widget.apiClient,
          products: _products,
          cart: _cart,
          onOrderPlaced: () {
            _loadOrders();
          },
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleAccountAction() async {
    if (widget.apiClient.isAuthenticated) {
      // Called from popup menu "Sign Out" option
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      widget.apiClient.setToken(null);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out successfully')),
      );
      setState(() {});
      return;
    }

    await _promptLoginIfNeeded();
    if (mounted) {
      setState(() {});
    }
  }

  int get _cartCount => _cart.values.fold(0, (left, right) => left + right);

  int get _activeProductCount =>
      _products.where((item) => item.isActive).length;

  List<String> get _categories => [
        'All',
        ..._products
            .map((item) => item.category?.trim())
            .whereType<String>()
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList()
          ..sort(),
      ];

  List<Product> get _visibleProducts {
    return _products.where((product) {
      final matchesCategory = _selectedCategory == 'All' ||
          (product.category ?? '').toLowerCase() ==
              _selectedCategory.toLowerCase();
      return matchesCategory;
    }).toList();
  }

  final Map<String, String> _categoryEmojis = {
    'Fruits': '🍎',
    'Vegetables': '🥬',
    'Dairy': '🥛',
    'Bakery': '🍞',
    'Beverages': '🥤',
    'Snacks': '🍪',
    'Meat': '🥩',
    'Fish': '🐟',
    'Grocery': '🛒',
  };

  String _getCategoryEmoji(String? category) {
    if (category == null) return '🛒';
    return _categoryEmojis[category] ?? '🛒';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        cartItemCount: _cartCount,
        onCartTap: _openCart,
        onOrdersTap: _openOrders,
        onUserTap: _handleAccountAction,
        isLoggedIn: widget.apiClient.isAuthenticated,
      ),
      body: Container(
        color: CustomerAppTheme.pageBg,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: CustomerAppTheme.primaryGreen,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: CustomerAppTheme.textSecondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 36,
                  color: CustomerAppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Unable to load products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CustomerAppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: CustomerAppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomerAppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: CustomerAppTheme.primaryGreen,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1100
              ? 4
              : width >= 700
                  ? 3
                  : 2;
          final spacing = 12.0;
          final visibleProducts = _visibleProducts;

          return ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              const SizedBox(height: 12),
              _buildHeroBanner(),
              const SizedBox(height: 16),
              _buildCategoriesRow(),
              const SizedBox(height: 16),
              _buildYouMightNeedSection(columns, spacing),
              const SizedBox(height: 16),
              _buildWeeklyBestSellingSection(columns, spacing),
              if (widget.apiClient.isAuthenticated) ...[
                const SizedBox(height: 16),
                _buildMyOrdersSection(),
              ],
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroBanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return Container(
          height: isWide ? 160 : 140,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CustomerAppTheme.primaryGreen,
                CustomerAppTheme.primaryGreen.withValues(alpha: 0.85),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: CustomerAppTheme.primaryGreen.withValues(alpha: 0.25),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: isWide ? 3 : 2,
                child: Padding(
                  padding: EdgeInsets.all(isWide ? 20 : 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: CustomerAppTheme.accentLime,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Fresh & Fast",
                          style: TextStyle(
                            color: CustomerAppTheme.primaryGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Farm Fresh",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWide ? 22 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Groceries",
                        style: TextStyle(
                          color: CustomerAppTheme.accentLime,
                          fontSize: isWide ? 22 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Up to 30% off on vegetables",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isWide ? 12 : 10,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _selectedCategory = 'All');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: CustomerAppTheme.primaryGreen,
                          padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 20 : 14, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Shop now",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isWide ? 13 : 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isWide)
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Icon(
                      Icons.shopping_bag_rounded,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesRow() {
    final categories = _categories;

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == categories.length) {
            return Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: CustomerAppTheme.accentLime,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_forward,
                    color: CustomerAppTheme.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "See all",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: CustomerAppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            );
          }

          final category = categories[index];
          final isAll = category == 'All';

          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: CustomerAppTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                setState(() => _selectedCategory = category);
              },
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isAll ? '🛒' : _getCategoryEmoji(category),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: CustomerAppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isAll ? 'All' : 'Fresh',
                    style: TextStyle(
                      fontSize: 9,
                      color: CustomerAppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildYouMightNeedSection(int columns, double spacing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "You might need",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CustomerAppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: CustomerAppTheme.primaryGreen,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "See more",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _products.take(5).length,
              itemBuilder: (context, index) {
                final product = _products[index];
                final screenWidth = MediaQuery.of(context).size.width;
                // Each card is ~42% of screen width so 2.4 cards visible
                final cardWidth = (screenWidth - 32) / 2.4;
                return SizedBox(
                  width: cardWidth,
                  child: Padding(
                    padding: EdgeInsets.only(right: spacing),
                    child: ProductCard(
                      product: product,
                      cart: _cart,
                      onTap: () => _navigateToProductDetail(product),
                      onCartChanged: () => setState(() {}),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBestSellingSection(int columns, double spacing) {
    final categories = _categories;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Weekly Best Selling",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CustomerAppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: CustomerAppTheme.primaryGreen,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "See more",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                    },
                    backgroundColor: CustomerAppTheme.cardBg,
                    selectedColor: CustomerAppTheme.filterActiveBg,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : CustomerAppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? CustomerAppTheme.filterActiveBg
                          : CustomerAppTheme.textSecondary
                              .withValues(alpha: 0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: 0.62,
            ),
            itemCount: _visibleProducts.length,
            itemBuilder: (context, index) {
              final product = _visibleProducts[index];
              return ProductCard(
                product: product,
                cart: _cart,
                onTap: () => _navigateToProductDetail(product),
                onCartChanged: () => setState(() {}),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA726);
      case 'confirmed':
      case 'shipped':
      case 'delivered':
        return CustomerAppTheme.primaryGreen;
      case 'cancelled':
        return CustomerAppTheme.danger;
      default:
        return CustomerAppTheme.textSecondary;
    }
  }

  String _getDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Widget _buildMyOrdersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My Orders",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CustomerAppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: _openOrders,
                style: TextButton.styleFrom(
                  foregroundColor: CustomerAppTheme.primaryGreen,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "View all",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 112,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _orders.length > 5 ? 5 : _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Container(
                  width: 168,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CustomerAppTheme.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 6,
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#${order.id.substring(0, 6)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: CustomerAppTheme.textSecondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getDisplayStatus(order.status),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(order.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${order.itemCount} items',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: CustomerAppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        formatInr(order.totalAmount),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: CustomerAppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppDownloadBanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return Container(
          height: isWide ? 140 : 160,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6B1B5E), Color(0xFF8E24AA)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: const Color(0xFF6B1B5E).withValues(alpha: 0.3),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: isWide ? 3 : 2,
                child: Padding(
                  padding: EdgeInsets.all(isWide ? 20 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Get All Your",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: isWide ? 18 : 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Essentials Delivered!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWide ? 20 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StoreButton("Play Store", Icons.android),
                          const SizedBox(width: 8),
                          _StoreButton("App Store", Icons.apple),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isWide)
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Icon(
                      Icons.delivery_dining,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          apiClient: widget.apiClient,
          product: product,
          allProducts: _products,
          cart: _cart,
          onCartChanged: () => setState(() {}),
        ),
      ),
    );
  }
}

class _StoreButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StoreButton(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
