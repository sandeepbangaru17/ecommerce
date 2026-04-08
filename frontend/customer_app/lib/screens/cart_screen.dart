import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../theme/customer_app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/add_to_cart_button.dart';

class CartScreen extends StatefulWidget {
  final ApiClient apiClient;
  final List<Product> products;
  final Map<String, int>? cart;
  final VoidCallback? onOrderPlaced;

  const CartScreen({
    super.key,
    required this.apiClient,
    required this.products,
    this.cart,
    this.onOrderPlaced,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  late Map<String, int> _localCart;

  @override
  void initState() {
    super.initState();
    _localCart = widget.cart ?? {};
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<MapEntry<Product, int>> get _cartItems {
    return _localCart.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
          final product = widget.products.firstWhere(
            (item) => item.id == entry.key,
            orElse: () => Product(
              id: entry.key,
              name: 'Unknown product',
              price: 0,
              stock: 0,
              isActive: false,
              createdAt: DateTime.now(),
            ),
          );
          return MapEntry(product, entry.value);
        })
        .where((entry) => entry.key.isActive)
        .toList();
  }

  double get _total => _cartItems.fold(
        0,
        (sum, entry) => sum + (entry.key.price * entry.value),
      );

  void _changeQuantity(Product product, int delta) {
    final next = (_localCart[product.id] ?? 0) + delta;
    setState(() {
      if (next <= 0) {
        _localCart.remove(product.id);
      } else {
        _localCart[product.id] = next;
      }
    });
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cartItems.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final items = _cartItems
          .map((entry) => {
                'product_id': entry.key.id,
                'quantity': entry.value,
                'unit_price': entry.key.price,
              })
          .toList();

      await widget.apiClient.post(
        '/orders',
        body: {
          'shipping_address': _addressController.text.trim(),
          'contact_phone': _phoneController.text.trim(),
          'notes': _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          'items': items,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully'),
          backgroundColor: CustomerAppTheme.primaryGreen,
        ),
      );
      _localCart.clear();
      widget.onOrderPlaced?.call();
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bucket'),
        backgroundColor: CustomerAppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: CustomerAppTheme.pageBg,
        child: _cartItems.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: CustomerAppTheme.accentLime,
            ),
            const SizedBox(height: 16),
            const Text(
              "Your bucket is empty",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CustomerAppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Add some fresh groceries!",
              style: TextStyle(
                fontSize: 14,
                color: CustomerAppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomerAppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Shop Now"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildCartItemsList(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildCheckoutCard(),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildCartItemsList(),
                    const SizedBox(height: 16),
                    _buildCheckoutCard(),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildCartItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Items",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CustomerAppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._cartItems.map(
          (entry) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CustomerAppTheme.cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  color: Color(0x0F000000),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: entry.key.imageUrl != null &&
                          entry.key.imageUrl!.isNotEmpty
                      ? Image.network(
                          entry.key.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildItemPlaceholder(),
                        )
                      : _buildItemPlaceholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CustomerAppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.key.category ?? 'Fresh',
                        style: const TextStyle(
                          fontSize: 12,
                          color: CustomerAppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatInr(entry.key.price),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CustomerAppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: _buildQuantityControls(entry.key, entry.value),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: CustomerAppTheme.addCartBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image,
        color: CustomerAppTheme.textSecondary,
      ),
    );
  }

  Widget _buildQuantityControls(Product product, int quantity) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: CustomerAppTheme.addCartBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => _changeQuantity(product, -1),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: CustomerAppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.remove,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: CustomerAppTheme.primaryGreen,
            ),
          ),
          GestureDetector(
            onTap: quantity >= product.stock
                ? null
                : () => _changeQuantity(product, 1),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: CustomerAppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomerAppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x0F000000),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(
                    color: CustomerAppTheme.textSecondary,
                  ),
                ),
                Text(
                  formatInr(_total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delivery',
                  style: TextStyle(
                    color: CustomerAppTheme.textSecondary,
                  ),
                ),
                Text(
                  _total >= 499 ? 'Free' : '₹49',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _total >= 499 ? CustomerAppTheme.primaryGreen : null,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CustomerAppTheme.textPrimary,
                  ),
                ),
                Text(
                  formatInr(_total + (_total >= 499 ? 0 : 49)),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CustomerAppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CustomerAppTheme.addCartBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    color: CustomerAppTheme.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Cash on Delivery",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CustomerAppTheme.primaryGreen,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.check_circle,
                    color: CustomerAppTheme.primaryGreen,
                    size: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Delivery Address",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: CustomerAppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              minLines: 2,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter your full address",
                filled: true,
                fillColor: CustomerAppTheme.pageBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Address is required'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Phone number",
                filled: true,
                fillColor: CustomerAppTheme.pageBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Phone is required'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Order notes (optional)",
                filled: true,
                fillColor: CustomerAppTheme.pageBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomerAppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Place Order →",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
