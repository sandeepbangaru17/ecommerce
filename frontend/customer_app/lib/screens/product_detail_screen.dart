import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../theme/customer_app_theme.dart';
import '../utils/formatters.dart';
import '../utils/product_visuals.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ApiClient apiClient;
  final Product product;
  final List<Product> allProducts;
  final Map<String, int>? cart;
  final VoidCallback? onCartChanged;

  const ProductDetailScreen({
    super.key,
    required this.apiClient,
    required this.product,
    this.allProducts = const [],
    this.cart,
    this.onCartChanged,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Map<String, int> _localCart;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _localCart = widget.cart ?? {};
    _quantity = _localCart[widget.product.id] ?? 1;
  }

  void _addToCart() async {
    if (widget.cart != null) {
      final current = widget.cart![widget.product.id] ?? 0;
      widget.cart![widget.product.id] = current + _quantity;
      widget.onCartChanged?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_quantity}x ${widget.product.name} added to cart'),
          backgroundColor: CustomerAppTheme.primaryGreen,
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () => _goToCart(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_quantity}x ${widget.product.name} added to cart'),
          backgroundColor: CustomerAppTheme.primaryGreen,
        ),
      );
    }
  }

  Future<void> _goToCart() async {
    if (!widget.apiClient.isAuthenticated) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            apiClient: widget.apiClient,
            returnToPrevious: true,
          ),
        ),
      );
      if (loggedIn != true) return;
    }

    if (!mounted) return;
    // Use allProducts so all cart items can be displayed correctly
    final products = widget.allProducts.isNotEmpty
        ? widget.allProducts
        : [widget.product];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CartScreen(
          apiClient: widget.apiClient,
          products: products,
          cart: _localCart,
          onOrderPlaced: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget _buildPriceDisplay(double price, {double fontSize = 32}) {
    return Text(
      '₹${price.toStringAsFixed(0)}',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: CustomerAppTheme.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final inStock = product.stock > 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 768;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isWide ? 'Product Details' : product.name,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: CustomerAppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: CustomerAppTheme.pageBg,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildImagePanel(product),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 2,
                        child: _buildInfoPanel(product, inStock),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagePanel(product),
                      const SizedBox(height: 24),
                      _buildInfoPanel(product, inStock),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePanel(Product product) {
    final imageUrl = (product.imageUrl != null && product.imageUrl!.isNotEmpty)
        ? product.imageUrl!
        : ProductVisuals.fallbackImageUrl(product);

    return Container(
      decoration: BoxDecoration(
        color: CustomerAppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                color: CustomerAppTheme.addCartBg,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: CustomerAppTheme.primaryGreen,
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              color: CustomerAppTheme.addCartBg,
              child: Center(
                child: Icon(
                  Icons.eco_rounded,
                  color: CustomerAppTheme.primaryGreen.withValues(alpha: 0.35),
                  size: 80,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPanel(Product product, bool inStock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: CustomerAppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            product.category ?? 'Grocery',
            style: const TextStyle(
              color: CustomerAppTheme.primaryGreen,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: CustomerAppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: CustomerAppTheme.accentLime,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: CustomerAppTheme.primaryGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "4.5",
                    style: TextStyle(
                      color: CustomerAppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "(15 reviews)",
              style: TextStyle(
                color: CustomerAppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: inStock
                    ? CustomerAppTheme.success.withValues(alpha: 0.1)
                    : CustomerAppTheme.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                inStock ? "In Stock" : "Out of Stock",
                style: TextStyle(
                  color: inStock
                      ? CustomerAppTheme.success
                      : CustomerAppTheme.danger,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPriceDisplay(product.price),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 16),
        Text(
          "Description",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CustomerAppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.description ??
              'Fresh product delivered to your door. We ensure quality and freshness in every order.',
          style: TextStyle(
            color: CustomerAppTheme.textSecondary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CustomerAppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withValues(alpha: 0.06),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow(
                  Icons.local_shipping_outlined, "Free delivery above ₹499"),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.access_time, "Express delivery in 10 mins"),
              const SizedBox(height: 12),
              _buildInfoRow(
                  Icons.payments_outlined, "Cash on delivery available"),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.verified_outlined, "Quality guaranteed"),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (inStock) ...[
          const Text(
            "Quantity",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CustomerAppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: CustomerAppTheme.addCartBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CustomerAppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.remove,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CustomerAppTheme.primaryGreen,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_quantity < product.stock) setState(() => _quantity++);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CustomerAppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: inStock ? _addToCart : null,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text(
                    "Add to Cart (₹${(product.price * _quantity).toStringAsFixed(0)})"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomerAppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: inStock ? _goToCart : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomerAppTheme.accentLime,
                  foregroundColor: CustomerAppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Buy Now",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CustomerAppTheme.addCartBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: CustomerAppTheme.primaryGreen, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: CustomerAppTheme.textPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
