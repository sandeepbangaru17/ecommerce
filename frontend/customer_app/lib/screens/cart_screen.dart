import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../theme/customer_app_theme.dart';
import '../utils/formatters.dart';
import '../utils/product_visuals.dart';

class CartScreen extends StatefulWidget {
  final ApiClient apiClient;
  final List<Product> products;
  final Map<String, int> cart;

  const CartScreen({
    super.key,
    required this.apiClient,
    required this.products,
    required this.cart,
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

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<MapEntry<Product, int>> get _cartItems {
    return widget.cart.entries
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
    final next = (widget.cart[product.id] ?? 0) + delta;
    setState(() {
      if (next <= 0) {
        widget.cart.remove(product.id);
      } else {
        widget.cart[product.id] = next;
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
        const SnackBar(content: Text('Order placed successfully')),
      );
      widget.cart.clear();
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
    const emptyState = Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 54, color: CustomerAppTheme.muted),
            SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: CustomerAppTheme.text,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add a few pieces from the collection to begin checkout.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: _cartItems.isEmpty
          ? emptyState
          : DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFAF3),
                    CustomerAppTheme.canvas,
                  ],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 980;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 11, child: _buildCartPanel()),
                                  const SizedBox(width: 24),
                                  Expanded(flex: 9, child: _buildCheckoutPanel()),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildCartPanel(),
                                  const SizedBox(height: 20),
                                  _buildCheckoutPanel(),
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCartPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your selection',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: CustomerAppTheme.text,
              ),
            ),
            const SizedBox(height: 8),
            const Text('A concise summary before your cash-on-delivery checkout.'),
            const SizedBox(height: 18),
            ..._cartItems.map(
              (entry) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: CustomerAppTheme.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: CustomerAppTheme.secondary.withValues(alpha: 0.14),
                      ),
                      child: ProductArtwork(
                        product: entry.key,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key.name,
                            style: const TextStyle(
                              color: CustomerAppTheme.text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('${formatInr(entry.key.price)} x ${entry.value}'),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () => _changeQuantity(entry.key, -1),
                                icon: const Icon(Icons.remove_rounded),
                              ),
                              Text(
                                '${entry.value}',
                                style: const TextStyle(
                                  color: CustomerAppTheme.text,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: entry.value >= entry.key.stock
                                    ? null
                                    : () => _changeQuantity(entry.key, 1),
                                icon: const Icon(Icons.add_rounded),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatInr(entry.key.price * entry.value),
                          style: const TextStyle(
                            color: CustomerAppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery details',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: CustomerAppTheme.text,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: CustomerAppTheme.primary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Grand total',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Text(
                    formatInr(_total),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Shipping address',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Address is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Contact number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Phone is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes for delivery',
                prefixIcon: Icon(Icons.edit_note_outlined),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _placeOrder,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : const Text('Place order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
