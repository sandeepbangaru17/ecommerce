import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../theme/customer_app_theme.dart';
import '../utils/formatters.dart';
import '../utils/product_visuals.dart';
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
  bool _isLoading = true;
  String? _error;
  final Map<String, int> _cart = {};
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await widget.apiClient.get('/products');
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

  void _addToCart(Product product) {
    setState(() {
      _cart[product.id] = (_cart[product.id] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart')),
    );
  }

  int get _cartCount => _cart.values.fold(0, (left, right) => left + right);

  int get _activeProductCount => _products.where((item) => item.isActive).length;

  int get _categoryCount =>
      _products.map((item) => item.category).whereType<String>().toSet().length;

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
          (product.category ?? '').toLowerCase() == _selectedCategory.toLowerCase();
      final query = _searchQuery.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          (product.description ?? '').toLowerCase().contains(query) ||
          (product.category ?? '').toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 24,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aurum Collective',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 2),
            Text(
              'Luxury storefront',
              style: TextStyle(fontSize: 13, color: CustomerAppTheme.muted),
            ),
          ],
        ),
        actions: [
          _TopIconButton(
            icon: Icons.receipt_long_outlined,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrdersScreen(apiClient: widget.apiClient),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _CartAction(
              count: _cartCount,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CartScreen(
                      apiClient: widget.apiClient,
                      products: _products,
                      cart: _cart,
                    ),
                  ),
                );
                setState(() {});
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _TopIconButton(
              icon: Icons.logout_rounded,
              onTap: () {
                widget.apiClient.setToken(null);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(apiClient: widget.apiClient),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF7ED),
              Color(0xFFF7F1E8),
              Color(0xFFF1E7D8),
            ],
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: CustomerAppTheme.muted,
              ),
              const SizedBox(height: 16),
              Text('Unable to load the collection', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _loadProducts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1280
            ? 4
            : width >= 960
                ? 3
                : width >= 700
                    ? 2
                    : 1;
        final spacing = width >= 960 ? 24.0 : 16.0;
        final cardAspectRatio = columns == 1 ? 0.94 : 0.78;
        final visibleProducts = _visibleProducts;

        return RefreshIndicator(
          onRefresh: _loadProducts,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(spacing, 12, spacing, spacing),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _HeroPanel(
                        totalItems: _activeProductCount,
                        cartCount: _cartCount,
                        categoryCount: _categoryCount,
                      ),
                      const SizedBox(height: 18),
                      _DiscoveryBar(
                        categories: _categories,
                        selectedCategory: _selectedCategory,
                        resultCount: visibleProducts.length,
                        onSearchChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                        onCategorySelected: (value) {
                          setState(() => _selectedCategory = value);
                        },
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Featured Collection',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Handpicked catalog, real product art, and sharper discovery for daily shopping.',
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(spacing, 0, spacing, 32),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = visibleProducts[index];
                      return _ProductCard(
                        product: product,
                        onAdd: product.stock > 0 ? () => _addToCart(product) : null,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
                                apiClient: widget.apiClient,
                                product: product,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: visibleProducts.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: cardAspectRatio,
                  ),
                ),
              ),
              if (visibleProducts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: CustomerAppTheme.muted,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No products match your selection',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try a broader search term or switch to another category.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final int totalItems;
  final int cartCount;
  final int categoryCount;

  const _HeroPanel({
    required this.totalItems,
    required this.cartCount,
    required this.categoryCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomerAppTheme.primary,
            Color(0xFF1B5139),
            Color(0xFF2A6F50),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: CustomerAppTheme.primary.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURATED FOR INDIA',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'A premium storefront built for polished browsing across desktop and mobile.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  height: 1.12,
                ),
          ),
          const SizedBox(height: 14),
          const Text(
            'From discovery to checkout, every screen now leans into warmer tones, softer surfaces, and a stronger retail hierarchy.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _MetricChip(label: 'Active products', value: '$totalItems'),
              _MetricChip(label: 'Categories', value: '$categoryCount'),
              _MetricChip(label: 'Cart items', value: '$cartCount'),
            ],
          ),
          const SizedBox(height: 18),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroPill(label: 'Free delivery above Rs. 4,999'),
              _HeroPill(label: '7-day assisted returns'),
              _HeroPill(label: 'Cash on delivery available'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;

  const _HeroPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DiscoveryBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final int resultCount;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;

  const _DiscoveryBar({
    required this.categories,
    required this.selectedCategory,
    required this.resultCount,
    required this.onSearchChanged,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 820;
                final search = TextField(
                  onChanged: onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Search for headphones, sneakers, shirts...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                );
                final result = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: CustomerAppTheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    '$resultCount results',
                    style: const TextStyle(
                      color: CustomerAppTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );

                return stacked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          search,
                          const SizedBox(height: 12),
                          result,
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: search),
                          const SizedBox(width: 14),
                          result,
                        ],
                      );
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories
                  .map(
                    (category) => ChoiceChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (_) => onCategorySelected(category),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onAdd;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final inStock = product.stock > 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF1DEC1),
                        Color(0xFFEAD0A4),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -18,
                        top: -18,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: ProductArtwork(
                            product: product,
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        top: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.48),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            product.stock > 10 ? 'Popular pick' : 'Limited stock',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  if (product.category != null)
                    Chip(
                      label: Text(product.category!),
                      visualDensity: VisualDensity.compact,
                    ),
                  Chip(
                    backgroundColor: (inStock
                            ? CustomerAppTheme.success
                            : CustomerAppTheme.danger)
                        .withValues(alpha: 0.12),
                    label: Text(inStock ? 'Ready to ship' : 'Out of stock'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                product.description ?? 'A premium catalog item tailored for modern lifestyles.',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ProductVisuals.highlights(product)
                    .take(2)
                    .map(
                      (item) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: CustomerAppTheme.text,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const Spacer(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatInr(product.price),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: CustomerAppTheme.primary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text('Stock ${product.stock}'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: onAdd,
                    child: Text(inStock ? 'Add' : 'View'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.white.withValues(alpha: 0.9),
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: CustomerAppTheme.primary),
        ),
      ),
    );
  }
}

class _CartAction extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _CartAction({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _TopIconButton(icon: Icons.shopping_bag_outlined, onTap: onTap),
        if (count > 0)
          Positioned(
            right: 2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: CustomerAppTheme.secondary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
